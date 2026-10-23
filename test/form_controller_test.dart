import 'dart:typed_data';

import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart';
import 'package:flutter_test/flutter_test.dart';

const _signatureRequiredUrl =
    'http://hl7.org/fhir/StructureDefinition/questionnaire-signatureRequired';

List<QuestionnaireItemBundle> _flatten(
  List<QuestionnaireItemBundle> bundles,
) => [
  for (final bundle in bundles) ...[bundle, ..._flatten(bundle.children ?? [])],
];

QuestionnaireItemBundle _bundle(
  List<QuestionnaireItemBundle> bundles,
  String linkId,
) =>
    _flatten(bundles)
        .firstWhere((bundle) => bundle.item.linkId.valueString == linkId);

List<QuestionnaireResponseItem> _flattenResponse(
  List<QuestionnaireResponseItem>? items,
) => [
  for (final item in items ?? <QuestionnaireResponseItem>[]) ...[
    item,
    ..._flattenResponse(item.item),
  ],
];

QuestionnaireResponseItem? _responseItem(
  QuestionnaireResponse response,
  String linkId,
) =>
    _flattenResponse(response.item)
        .where((item) => item.linkId.valueString == linkId)
        .firstOrNull;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('enableWhen', () {
    Questionnaire chain() => Questionnaire.fromJson({
      'resourceType': 'Questionnaire',
      'status': 'active',
      'item': [
        {'linkId': 'a', 'type': 'boolean', 'text': 'A'},
        {
          'linkId': 'b',
          'type': 'string',
          'text': 'B',
          'required': true,
          'enableWhen': [
            {'question': 'a', 'operator': '=', 'answerBoolean': true},
          ],
        },
        {
          'linkId': 'c',
          'type': 'string',
          'text': 'C',
          'required': true,
          'enableWhen': [
            {'question': 'b', 'operator': 'exists', 'answerBoolean': true},
          ],
        },
      ],
    });

    test('a disabled source counts as unanswered, down the chain', () async {
      final questionnaire = chain();
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);
      final a = _bundle(bundles, 'a').controller as CustomValueController<bool>;
      final b = _bundle(bundles, 'b').controller as CustomTextEditingController;
      final c = _bundle(bundles, 'c');
      final notified = <bool>[];
      c.enableWhenController!.init(onEnabledChangedListener: notified.add);

      a.value = true;
      b.text = 'filled';
      expect(c.enableWhenController!.checkIfEnabled(notify: false), isTrue);

      // B keeps its text but is disabled now, so C's condition on it fails,
      // and C hears about it although only A changed.
      notified.clear();
      a.value = false;
      expect(c.enableWhenController!.checkIfEnabled(notify: false), isFalse);
      expect(notified, contains(false));

      final response = await controller.generateResponse(
        questionnaire: questionnaire,
        itemBundles: bundles,
      );
      expect(_responseItem(response, 'a'), isNotNull);
      expect(_responseItem(response, 'b'), isNull);
      expect(_responseItem(response, 'c'), isNull);
      c.enableWhenController!.dispose();
    });

    test('a disabled item is not validated', () {
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(chain());
      final a = _bundle(bundles, 'a').controller as CustomValueController<bool>;
      final b = _bundle(bundles, 'b').controller;

      a.value = false;
      expect(b.validate(notify: false), isTrue);
      a.value = true;
      expect(b.validate(notify: false), isFalse);
    });

    test('exists counts a multiple choice with nothing selected as '
        'unanswered', () {
      final questionnaire = Questionnaire.fromJson({
        'resourceType': 'Questionnaire',
        'status': 'active',
        'item': [
          {
            'linkId': 'diet',
            'type': 'choice',
            'text': 'Diet',
            'repeats': true,
            'answerOption': [
              {
                'valueCoding': {'code': 'vegan'},
              },
            ],
          },
          {
            'linkId': 'diet-details',
            'type': 'string',
            'text': 'Details',
            'enableWhen': [
              {'question': 'diet', 'operator': 'exists', 'answerBoolean': true},
            ],
          },
        ],
      });
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);
      final diet =
          _bundle(bundles, 'diet').controller
              as CustomValueController<List<QuestionnaireAnswerOption>>;
      final details = _bundle(bundles, 'diet-details').enableWhenController!;

      diet.value = [];
      expect(details.checkIfEnabled(notify: false), isFalse);
      diet.value = [questionnaire.item!.first.answerOption!.first];
      expect(details.checkIfEnabled(notify: false), isTrue);
    });
  });

  group('defect regressions', () {
    test('an item hidden by enableWhen leaves its answer out of the '
        'response', () async {
      final questionnaire = Questionnaire.fromJson({
        'resourceType': 'Questionnaire',
        'status': 'active',
        'item': [
          {'linkId': 'smoker', 'type': 'boolean', 'text': 'Do you smoke?'},
          {
            'linkId': 'packs',
            'type': 'string',
            'text': 'How many packs a day?',
            'enableWhen': [
              {'question': 'smoker', 'operator': '=', 'answerBoolean': true},
            ],
          },
        ],
      });
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);

      (_bundle(bundles, 'smoker').controller as CustomValueController<bool>)
              .value =
          false;
      (_bundle(bundles, 'packs').controller as CustomTextEditingController)
              .text =
          '2';

      final response = await controller.generateResponse(
        questionnaire: questionnaire,
        itemBundles: bundles,
      );
      expect(_responseItem(response, 'smoker'), isNotNull);
      expect(_responseItem(response, 'packs'), isNull);
    });

    test('an enableWhen naming a later item is honoured', () {
      final questionnaire = Questionnaire.fromJson({
        'resourceType': 'Questionnaire',
        'status': 'active',
        'item': [
          {
            'linkId': 'details',
            'type': 'string',
            'text': 'Details',
            'enableWhen': [
              {'question': 'answer', 'operator': '=', 'answerString': 'yes'},
            ],
          },
          {'linkId': 'answer', 'type': 'string', 'text': 'Answer'},
        ],
      });
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);

      (_bundle(bundles, 'answer').controller as CustomTextEditingController)
              .text =
          'no';
      final enableWhen = _bundle(bundles, 'details').view.enableWhenController;
      expect(enableWhen, isNotNull);
      expect(enableWhen!.checkIfEnabled(notify: false), isFalse);

      (_bundle(bundles, 'answer').controller as CustomTextEditingController)
              .text =
          'yes';
      expect(enableWhen.checkIfEnabled(notify: false), isTrue);
    });

    test('an enableWhen naming the question a child is nested under is '
        'honoured', () {
      final questionnaire = Questionnaire.fromJson({
        'resourceType': 'Questionnaire',
        'status': 'active',
        'item': [
          {
            'linkId': 'pain',
            'type': 'boolean',
            'text': 'Are you in pain?',
            'item': [
              {
                'linkId': 'pain-where',
                'type': 'string',
                'text': 'Where?',
                'enableWhen': [
                  {'question': 'pain', 'operator': '=', 'answerBoolean': true},
                ],
              },
            ],
          },
        ],
      });
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);

      final pain =
          _bundle(bundles, 'pain').controller as CustomValueController<bool>;
      final enableWhen = _bundle(
        bundles,
        'pain-where',
      ).view.enableWhenController;
      expect(enableWhen, isNotNull);
      pain.value = false;
      expect(enableWhen!.checkIfEnabled(notify: false), isFalse);
      pain.value = true;
      expect(enableWhen.checkIfEnabled(notify: false), isTrue);
    });

    test('a question that requires a signature keeps its answer in the '
        'response', () async {
      final questionnaire = Questionnaire.fromJson({
        'resourceType': 'Questionnaire',
        'status': 'active',
        'item': [
          {
            'linkId': 'name',
            'type': 'string',
            'text': 'Full name',
            'required': true,
            'extension': [
              {
                'url': _signatureRequiredUrl,
                'valueCodeableConcept': {
                  'coding': [
                    {
                      'system': 'urn:iso-astm:E1762-95:2013',
                      'code': '1.2.840.10065.1.12.1.1',
                    },
                  ],
                },
              },
            ],
          },
        ],
      });
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);
      final bundle = _bundle(bundles, 'name');
      final signatureView = bundle.view as QuestionnaireSignatureView;
      final answerController =
          (signatureView.child as QuestionnaireItemView).controller
              as CustomTextEditingController;

      answerController.text = 'Jane Roe';
      (signatureView.controller as SignatureController).value =
          Uint8List.fromList([137, 80, 78, 71]);

      final response = await controller.generateResponse(
        questionnaire: questionnaire,
        itemBundles: bundles,
      );
      final item = _responseItem(response, 'name');
      expect(item, isNotNull);
      expect(item!.answer?.single.valueString?.valueString, 'Jane Roe');
      expect(
        item.extension_?.where(
          (e) => e.url.valueString?.endsWith('-signature') ?? false,
        ),
        hasLength(1),
      );
    });
  });
}
