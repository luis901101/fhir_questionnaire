import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter_test/flutter_test.dart';

/// A trimmed down version of the consent questionnaire sample: a `choice` item
/// the user answers and a hidden read-only `boolean` item whose value is
/// derived from it through a calculatedExpression.
const _consentQuestionnaireJson = '''
{
  "resourceType": "Questionnaire",
  "status": "active",
  "item": [
    {
      "linkId": "3",
      "type": "group",
      "text": "My Consent",
      "item": [
        {
          "linkId": "consent-acceptance-id",
          "type": "choice",
          "answerOption": [
            { "valueCoding": { "code": "agree", "display": "I agree" } },
            { "valueCoding": { "code": "disagree", "display": "I do not agree" } }
          ]
        }
      ]
    },
    {
      "linkId": "consent-response",
      "text": "Consent response",
      "type": "boolean",
      "readOnly": true,
      "extension": [
        {
          "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression",
          "valueExpression": {
            "language": "text/fhirpath",
            "expression": "iif(%resource.repeat(item).where(linkId='consent-acceptance-id').answer.value.code = 'agree', true, false)",
            "description": "Consent calculation"
          }
        },
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-hidden",
          "valueBoolean": true
        }
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

QuestionnaireResponseItem _findItem(
  List<QuestionnaireResponseItem> items,
  String linkId,
) => items
    .expand((item) => [item, ...?item.item])
    .firstWhere((item) => item.linkId == linkId);

/// Generates a response for [_consentQuestionnaireJson] with the consent choice
/// answered with the option identified by [answerCode].
QuestionnaireResponse _responseForConsent(String answerCode) {
  final questionnaire = Questionnaire.fromJsonString(_consentQuestionnaireJson);
  final controller = QuestionnaireController();
  final bundles = controller.buildQuestionnaireItems(questionnaire);
  final flatBundles = _flatten(bundles);

  final consentBundle = flatBundles.firstWhere(
    (bundle) => bundle.item.linkId == 'consent-acceptance-id',
  );
  (consentBundle.controller as CustomValueController<QuestionnaireAnswerOption>)
      .value = consentBundle.item.answerOption!.firstWhere(
    (option) => option.valueCoding?.code?.value == answerCode,
  );

  // The bundles are built here without ever being rendered, so seed the value
  // QuestionnaireBooleanItemViewState.initState would have set. Without it the
  // calculated item reaches generateResponse with no answer at all and the test
  // would not cover the case this guards against: an answer already being there.
  final calculatedBundle = flatBundles.firstWhere(
    (bundle) => bundle.item.linkId == 'consent-response',
  );
  (calculatedBundle.controller as CustomValueController<bool>).value = false;

  return controller.generateResponse(
    questionnaire: questionnaire,
    itemBundles: bundles,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('calculatedExpression on a boolean item', () {
    test('resolves to true, replacing the boolean view default of false', () {
      final response = _responseForConsent('agree');
      final consentResponse = _findItem(response.item!, 'consent-response');

      expect(consentResponse.answer, hasLength(1));
      expect(consentResponse.answer!.first.valueBoolean?.value, isTrue);
      // No extension of the questionnaire is kept, on any item.
      expect(consentResponse.extension_, isNull);
      expect(
        _findItem(response.item!, 'consent-acceptance-id').extension_,
        isNull,
      );
      expect(_findItem(response.item!, '3').extension_, isNull);
    });

    test('resolves to false when the consent is not accepted', () {
      final response = _responseForConsent('disagree');
      final consentResponse = _findItem(response.item!, 'consent-response');

      expect(consentResponse.answer!.first.valueBoolean?.value, isFalse);
    });
  });

  group('buildAnswerFromCalculatedValue', () {
    final controller = FhirPathController();

    test('maps a bool to valueBoolean', () {
      expect(
        controller.buildAnswerFromCalculatedValue(true)?.valueBoolean?.value,
        isTrue,
      );
    });

    test('maps an int to valueInteger and a double to valueDecimal', () {
      expect(
        controller.buildAnswerFromCalculatedValue(7)?.valueInteger?.value,
        7,
      );
      expect(
        controller.buildAnswerFromCalculatedValue(7.5)?.valueDecimal?.value,
        7.5,
      );
    });

    test('maps a String to valueString', () {
      expect(
        controller.buildAnswerFromCalculatedValue('hello')?.valueString,
        'hello',
      );
    });

    test('maps a Coding json to valueCoding', () {
      final answer = controller.buildAnswerFromCalculatedValue({
        'system': 'http://example.org',
        'code': 'agree',
        'display': 'I agree',
      });
      expect(answer?.valueCoding?.code?.value, 'agree');
    });

    test('maps a Quantity json to valueQuantity', () {
      final answer = controller.buildAnswerFromCalculatedValue({
        'value': 170,
        'unit': 'cm',
        'system': 'http://unitsofmeasure.org',
        'code': 'cm',
      });
      expect(answer?.valueQuantity?.value?.value, 170);
      expect(answer?.valueQuantity?.unit, 'cm');
    });

    test('returns null for a value with no answer counterpart', () {
      expect(controller.buildAnswerFromCalculatedValue(<int>[1, 2]), isNull);
    });
  });
}
