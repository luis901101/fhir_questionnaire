import 'dart:typed_data';

import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extensions that describe the form and must never show up in the response.
const _hidden =
    '{ "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-hidden", "valueBoolean": true }';
const _entryFormat =
    '{ "url": "http://hl7.org/fhir/StructureDefinition/entryFormat", "valueString": "e.g. Jane" }';
const _minLength =
    '{ "url": "http://hl7.org/fhir/StructureDefinition/minLength", "valueInteger": 2 }';
const _itemControl =
    '{ "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl", '
    '"valueCodeableConcept": { "coding": [ { "system": "http://hl7.org/fhir/questionnaire-item-control", "code": "page" } ] } }';

/// A questionnaire carrying authoring extensions at every level and not a
/// single expression, so nothing ever enters the calculation loop.
const _noExpressionsQuestionnaireJson =
    '''
{
  "resourceType": "Questionnaire",
  "status": "active",
  "extension": [
    {
      "url": "http://hl7.org/fhir/StructureDefinition/variable",
      "valueExpression": {
        "language": "text/fhirpath",
        "name": "itemCount",
        "expression": "%resource.repeat(item).count()"
      }
    }
  ],
  "item": [
    {
      "linkId": "group-1",
      "type": "group",
      "text": "A group",
      "extension": [ $_itemControl ],
      "item": [
        { "linkId": "answered", "type": "string", "text": "Answered", "extension": [ $_entryFormat, $_minLength ] },
        { "linkId": "unanswered", "type": "string", "text": "Unanswered", "extension": [ $_hidden ] }
      ]
    },
    { "linkId": "flag", "type": "boolean", "text": "A flag", "extension": [ $_hidden ] }
  ]
}
''';

/// A calculated item followed by siblings carrying authoring extensions, which
/// the resolution loop used to leave behind once it had resolved the first
/// expression it found.
const _calculatedThenSiblingsQuestionnaireJson =
    '''
{
  "resourceType": "Questionnaire",
  "status": "active",
  "item": [
    { "linkId": "source", "type": "boolean", "text": "Source" },
    {
      "linkId": "calculated",
      "type": "boolean",
      "readOnly": true,
      "extension": [
        {
          "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression",
          "valueExpression": {
            "language": "text/fhirpath",
            "expression": "iif(%resource.repeat(item).where(linkId='source').answer.value = true, true, false)"
          }
        },
        $_hidden
      ]
    },
    { "linkId": "after-a", "type": "string", "text": "After A", "extension": [ $_entryFormat ] },
    { "linkId": "after-b", "type": "string", "text": "After B", "extension": [ $_minLength ] },
    {
      "linkId": "after-c",
      "type": "group",
      "text": "After C",
      "extension": [ $_itemControl ],
      "item": [
        { "linkId": "after-c-1", "type": "string", "text": "After C1", "extension": [ $_hidden ] }
      ]
    }
  ]
}
''';

/// An expression that cannot be evaluated, so the item stays unresolved.
const _brokenExpressionQuestionnaireJson =
    '''
{
  "resourceType": "Questionnaire",
  "status": "active",
  "item": [
    {
      "linkId": "broken",
      "type": "boolean",
      "readOnly": true,
      "extension": [
        {
          "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression",
          "valueExpression": {
            "language": "text/fhirpath",
            "expression": "this is not ( valid fhirpath"
          }
        },
        $_hidden
      ]
    }
  ]
}
''';

/// A signature group that also carries authoring extensions, to make sure the
/// stripping keeps the extension the response owns.
const _noisySignatureQuestionnaireJson =
    '''
{
  "resourceType": "Questionnaire",
  "status": "active",
  "item": [
    {
      "linkId": "consent-group",
      "type": "group",
      "text": "Consent",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-signatureRequired",
          "valueCodeableConcept": {
            "coding": [
              { "system": "urn:iso-astm:E1762-95:2013", "code": "1.2.840.10065.1.12.1.7", "display": "Consent Signature" }
            ]
          }
        },
        $_itemControl,
        $_entryFormat
      ],
      "item": [
        { "linkId": "consent-agree", "type": "boolean", "text": "Agree" }
      ]
    }
  ]
}
''';

List<QuestionnaireItemBundle> _flatten(
  List<QuestionnaireItemBundle> bundles,
) => [
  for (final bundle in bundles) ...[bundle, ..._flatten(bundle.children ?? [])],
];

/// Every response item of [items], sub items included.
List<QuestionnaireResponseItem> _flattenResponse(
  List<QuestionnaireResponseItem>? items,
) => [
  for (final item in items ?? const <QuestionnaireResponseItem>[]) ...[
    item,
    ..._flattenResponse(item.item),
  ],
];

QuestionnaireItemBundle _bundleOf(
  List<QuestionnaireItemBundle> bundles,
  String linkId,
) => _flatten(bundles).firstWhere((bundle) => bundle.item.linkId == linkId);

QuestionnaireResponseItem _responseItemOf(
  QuestionnaireResponse response,
  String linkId,
) =>
    _flattenResponse(response.item).firstWhere((item) => item.linkId == linkId);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('questionnaire extensions do not reach the response', () {
    test('when the questionnaire declares no expression at all', () {
      final questionnaire = Questionnaire.fromJsonString(
        _noExpressionsQuestionnaireJson,
      );
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);

      // One answered item and one boolean, leaving `unanswered` empty so the
      // items without an answer are covered too.
      (_bundleOf(bundles, 'answered').controller as CustomTextEditingController)
              .text =
          'Jane';
      (_bundleOf(bundles, 'flag').controller as CustomValueController<bool>)
              .value =
          true;

      final response = controller.generateResponse(
        questionnaire: questionnaire,
        itemBundles: bundles,
      );

      // The root only ever carries what the response itself owns.
      expect(response.extension_, isNull);

      final items = _flattenResponse(response.item);
      expect(
        items.map((item) => item.linkId),
        containsAll(<String>['group-1', 'answered', 'unanswered', 'flag']),
      );
      for (final item in items) {
        expect(item.extension_, isNull, reason: 'item ${item.linkId}');
      }
    });

    test('on the siblings that follow a calculated item', () {
      final questionnaire = Questionnaire.fromJsonString(
        _calculatedThenSiblingsQuestionnaireJson,
      );
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);

      (_bundleOf(bundles, 'source').controller as CustomValueController<bool>)
              .value =
          true;
      (_bundleOf(bundles, 'calculated').controller
                  as CustomValueController<bool>)
              .value =
          false;

      final response = controller.generateResponse(
        questionnaire: questionnaire,
        itemBundles: bundles,
      );

      // The expression still runs, it just leaves nothing behind.
      expect(
        _responseItemOf(
          response,
          'calculated',
        ).answer!.first.valueBoolean?.value,
        isTrue,
      );
      for (final item in _flattenResponse(response.item)) {
        expect(item.extension_, isNull, reason: 'item ${item.linkId}');
      }
    });

    test('when an expression cannot be evaluated', () {
      final questionnaire = Questionnaire.fromJsonString(
        _brokenExpressionQuestionnaireJson,
      );
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);

      (_bundleOf(bundles, 'broken').controller as CustomValueController<bool>)
              .value =
          false;

      final response = controller.generateResponse(
        questionnaire: questionnaire,
        itemBundles: bundles,
      );
      final broken = _responseItemOf(response, 'broken');

      // The unresolved expression is dropped along with everything else, and
      // the item keeps whatever the item view produced.
      expect(broken.extension_, isNull);
      expect(broken.answer!.first.valueBoolean?.value, isFalse);
    });

    test('leaving a signature item with only its signature extension', () {
      final questionnaire = Questionnaire.fromJsonString(
        _noisySignatureQuestionnaireJson,
      );
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);

      (_bundleOf(bundles, 'consent-group').controller as SignatureController)
          .value = Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
      ]);

      final response = controller.generateResponse(
        questionnaire: questionnaire,
        itemBundles: bundles,
      );
      final groupResponse = _responseItemOf(response, 'consent-group');

      expect(groupResponse.extension_, hasLength(1));
      expect(
        groupResponse.extension_!.single.url?.value?.toString(),
        FhirConstants.responseSignatureExtensionUrl,
      );
    });
  });
}
