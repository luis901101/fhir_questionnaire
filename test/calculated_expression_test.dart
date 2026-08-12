import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart';
import 'package:fhir_r4/fhir_r4.dart' hide QuestionnaireItemType;
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
    .firstWhere((item) => item.linkId.valueString == linkId);

/// Generates a response for [_consentQuestionnaireJson] with the consent choice
/// answered with the option identified by [answerCode].
Future<QuestionnaireResponse> _responseForConsent(String answerCode) async {
  final questionnaire = Questionnaire.fromJsonString(_consentQuestionnaireJson);
  final controller = QuestionnaireController();
  final bundles = controller.buildQuestionnaireItems(questionnaire);
  final flatBundles = _flatten(bundles);

  final consentBundle = flatBundles.firstWhere(
    (bundle) => bundle.item.linkId.valueString == 'consent-acceptance-id',
  );
  (consentBundle.controller as CustomValueController<QuestionnaireAnswerOption>)
      .value = consentBundle.item.answerOption!.firstWhere(
    (option) => option.valueCoding?.code?.valueString == answerCode,
  );

  // The bundles are built here without ever being rendered, so seed the value
  // QuestionnaireBooleanItemViewState.initState would have set. Without it the
  // calculated item reaches generateResponse with no answer at all and the test
  // would not cover the case this guards against: an answer already being there.
  final calculatedBundle = flatBundles.firstWhere(
    (bundle) => bundle.item.linkId.valueString == 'consent-response',
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
    test(
      'resolves to true, replacing the boolean view default of false',
      () async {
        final response = await _responseForConsent('agree');
        final consentResponse = _findItem(response.item!, 'consent-response');

        expect(consentResponse.answer, hasLength(1));
        expect(
          consentResponse.answer!.first.valueBoolean?.valueBoolean,
          isTrue,
        );
        // The extensions copied over from the questionnaire item are not kept.
        expect(consentResponse.extension_, isNull);
      },
    );

    test('resolves to false when the consent is not accepted', () async {
      final response = await _responseForConsent('disagree');
      final consentResponse = _findItem(response.item!, 'consent-response');

      expect(consentResponse.answer!.first.valueBoolean?.valueBoolean, isFalse);
    });
  });

  group('buildAnswerFromCalculatedValue', () {
    final controller = FhirPathController();

    test('maps a FhirBoolean to valueBoolean', () {
      expect(
        controller
            .buildAnswerFromCalculatedValue(FhirBoolean(true))
            ?.valueBoolean
            ?.valueBoolean,
        isTrue,
      );
    });

    test('maps a FhirInteger to valueInteger and a FhirDecimal to '
        'valueDecimal', () {
      expect(
        controller
            .buildAnswerFromCalculatedValue(FhirInteger(7))
            ?.valueInteger
            ?.valueInt,
        7,
      );
      expect(
        controller
            .buildAnswerFromCalculatedValue(FhirDecimal(7.5))
            ?.valueDecimal
            ?.valueNum,
        7.5,
      );
    });

    test('maps a FhirString to valueString', () {
      expect(
        controller
            .buildAnswerFromCalculatedValue(FhirString('hello'))
            ?.valueString
            ?.valueString,
        'hello',
      );
    });

    test('narrows a FhirCode down to a valueString', () {
      final answer = controller.buildAnswerFromCalculatedValue(
        FhirCode('agree'),
      );

      expect(answer?.valueString?.valueString, 'agree');
      // A `FhirCode` value would be serialized as an invalid `valueCode`.
      expect(answer?.toJson().keys, contains('valueString'));
    });

    test('maps a Coding to valueCoding', () {
      final answer = controller.buildAnswerFromCalculatedValue(
        Coding(
          system: FhirUri('http://example.org'),
          code: FhirCode('agree'),
          display: FhirString('I agree'),
        ),
      );

      expect(answer?.valueCoding?.code?.valueString, 'agree');
    });

    test('maps a Quantity to valueQuantity', () {
      final answer = controller.buildAnswerFromCalculatedValue(
        Quantity(value: FhirDecimal(170), unit: FhirString('cm')),
      );

      expect(answer?.valueQuantity?.value?.valueNum, 170);
      expect(answer?.valueQuantity?.unit?.valueString, 'cm');
    });

    test('returns null for a value with no answer counterpart', () {
      expect(
        controller.buildAnswerFromCalculatedValue(
          CodeableConcept(text: FhirString('nope')),
        ),
        isNull,
      );
    });
  });
}
