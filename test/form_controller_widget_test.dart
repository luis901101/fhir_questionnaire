import 'dart:convert';
import 'dart:io';

import 'package:fhir_r4/fhir_r4.dart' hide QuestionnaireItemType;
import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _signatureRequiredUrl =
    'http://hl7.org/fhir/StructureDefinition/questionnaire-signatureRequired';

/// A valid 1x1 PNG: the signature preview decodes the signature as an image.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);
const _displayCategoryUrl =
    'http://hl7.org/fhir/StructureDefinition/questionnaire-displayCategory';

/// Pumps [questionnaire] in a [QuestionnaireView] on a phone-sized surface.
Future<void> _pumpForm(
  WidgetTester tester,
  Questionnaire questionnaire, {
  ValueChanged<QuestionnaireResponse>? onSubmit,
  QuestionnaireFormController? formController,
  Key? key,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: QuestionnaireView(
        key: key,
        questionnaire: questionnaire,
        onSubmit: onSubmit ?? (_) {},
        formController: formController,
      ),
    ),
  );
  // Bounded pumps (avoid pumpAndSettle — several 300ms animations).
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Pumps frames until [future] completes, and returns its value.
Future<T> _complete<T>(WidgetTester tester, Future<T> future) async {
  bool done = false;
  late T result;
  future.then((value) {
    result = value;
    done = true;
  });
  for (int i = 0; i < 200 && !done; ++i) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(done, isTrue, reason: 'the future never completed');
  return result;
}

/// Pumps frames for a second, so every running animation ends.
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 20; ++i) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Questionnaire _fixture(String name) => Questionnaire.fromJsonString(
  File('test/fixtures/$name').readAsStringSync(),
);

Map<String, dynamic> _string(String linkId, String text, {bool? required}) => {
  'linkId': linkId,
  'type': 'string',
  'text': text,
  'required': ?required,
};

/// A form far longer than the screen: 30 text questions around a required one,
/// a section with nested questions, and a question shown only when [toggle]
/// is on, all far down.
Questionnaire _longForm() => Questionnaire.fromJson({
  'resourceType': 'Questionnaire',
  'status': 'active',
  'item': [
    {'linkId': 'toggle', 'type': 'boolean', 'text': 'Show the follow-up?'},
    for (int i = 1; i <= 25; ++i)
      _string('q${i.toString().padLeft(2, '0')}', 'Question $i'),
    _string('late', 'A required question far down', required: true),
    {
      'linkId': 'section',
      'type': 'group',
      'text': 'A section far down',
      'item': [
        _string('nested-a', 'Nested question A'),
        _string('nested-b', 'Nested question B'),
      ],
    },
    {
      ..._string('revealed', 'The follow-up question', required: true),
      'enableWhen': [
        {'question': 'toggle', 'operator': '=', 'answerBoolean': true},
      ],
    },
    for (int i = 26; i <= 30; ++i) _string('q$i', 'Question $i'),
  ],
});

/// A short question followed by one far taller than the screen.
Questionnaire _tallForm() => Questionnaire.fromJson({
  'resourceType': 'Questionnaire',
  'status': 'active',
  'item': [
    _string('q01', 'Question 1'),
    _string('tall', 'A long consent text. ' * 220),
    for (int i = 2; i <= 10; ++i)
      _string('q${i.toString().padLeft(2, '0')}', 'Question $i'),
  ],
});

/// Whether the item [uid] is built now.
bool _isBuilt(QuestionnaireFormController form, String uid) =>
    form.itemOf(uid)!.view.controller.key.currentContext != null;

/// Asserts the whole item [uid] is on screen, clear of the Submit button band.
void _expectEntirelyVisible(
  WidgetTester tester,
  QuestionnaireFormController form,
  String uid,
) {
  expect(_isBuilt(form, uid), isTrue, reason: '$uid is not built');
  final item = tester.getRect(
    find.byKey(form.itemOf(uid)!.view.controller.key),
  );
  final viewport = tester.getRect(find.byType(ListView));
  expect(item.top, greaterThanOrEqualTo(viewport.top), reason: '$uid top');
  expect(
    item.bottom,
    lessThanOrEqualTo(
      viewport.bottom - QuestionnaireFormController.revealBottomMargin,
    ),
    reason: '$uid bottom',
  );
}

/// Whether the item [uid] is entirely on screen.
bool _isEntirelyVisible(
  WidgetTester tester,
  QuestionnaireFormController form,
  String uid,
) {
  if (!_isBuilt(form, uid)) return false;
  final item = tester.getRect(
    find.byKey(form.itemOf(uid)!.view.controller.key),
  );
  final viewport = tester.getRect(find.byType(ListView));
  return item.top >= viewport.top &&
      item.bottom <=
          viewport.bottom - QuestionnaireFormController.revealBottomMargin;
}

Finder _inItem(QuestionnaireFormController form, String uid, Finder finder) =>
    find.descendant(
      of: find.byKey(form.itemOf(uid)!.view.controller.key),
      matching: finder,
    );

void main() {
  group('QuestionnaireFormController', () {
    testWidgets('lists the items in display order with their metadata', (
      tester,
    ) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(
        tester,
        Questionnaire.fromJson({
          'resourceType': 'Questionnaire',
          'status': 'active',
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
          'item': [
            {'linkId': 'intro', 'type': 'display', 'text': 'Welcome'},
            {
              'linkId': 'section',
              'type': 'group',
              'text': 'Section',
              'item': [
                {
                  'linkId': 'mood',
                  'type': 'choice',
                  'text': 'How are you?',
                  'required': true,
                  'answerOption': [
                    {
                      'valueCoding': {'code': 'good', 'display': 'Good'},
                    },
                    {
                      'valueCoding': {'code': 'bad', 'display': 'Bad'},
                    },
                  ],
                  'item': [
                    {
                      'linkId': 'mood-help',
                      'type': 'display',
                      'text': 'Pick the closest one.',
                      'extension': [
                        {
                          'url': _displayCategoryUrl,
                          'valueCodeableConcept': {
                            'coding': [
                              {
                                'system': 'http://hl7.org/fhir/questionnaire-display-category',
                                'code': 'help',
                              },
                            ],
                          },
                        },
                      ],
                    },
                  ],
                },
              ],
            },
            {
              'linkId': 'meds',
              'type': 'open-choice',
              'text': 'Medications',
              'repeats': true,
              'answerOption': [
                {'valueString': 'Aspirin'},
              ],
            },
          ],
        }),
        formController: form,
      );

      expect(form.isAttached, isTrue);
      expect(form.items.map((item) => item.uid), [
        'intro',
        'section',
        'section/mood',
        'section/mood/mood-help',
        'meds',
        QuestionnaireFormController.rootSignatureUid,
      ]);
      final mood = form.itemOf('section/mood')!;
      expect(mood.depth, 1);
      expect(mood.parentUid, 'section');
      expect(mood.type, QuestionnaireItemType.choice);
      expect(mood.text, 'How are you?');
      expect(mood.required, isTrue);
      expect(mood.options.map((option) => option.title), ['Good', 'Bad']);
      expect(mood.allowsFreeText, isFalse);
      expect(mood.helperText, 'Pick the closest one.');
      expect(form.itemOf('section/mood/mood-help')!.hidden, isTrue);
      final meds = form.itemOf('meds')!;
      expect(meds.repeats, isTrue);
      expect(meds.allowsFreeText, isTrue);
      expect(meds.required, isFalse);
      final signature = form.items.last;
      expect(signature.isSignature, isTrue);
      expect(signature.requiresSignature, isTrue);
      expect(signature.required, isTrue);
      expect(signature.signed, isFalse);
      expect(form.itemOf('intro')!.type, QuestionnaireItemType.display);
    });

    testWidgets('evaluates enableWhen for items not built yet', (tester) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(tester, _longForm(), formController: form);

      expect(_isBuilt(form, 'revealed'), isFalse);
      expect(form.isEnabled('revealed'), isFalse);
      form.setAnswer('toggle', true);
      expect(form.isEnabled('revealed'), isTrue);
      expect(_isBuilt(form, 'revealed'), isFalse);
    });

    testWidgets('sets and reads an answer of every answerable type', (
      tester,
    ) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(
        tester,
        _fixture('sample_generic.json'),
        formController: form,
      );
      List<QuestionnaireResponseAnswer> answer(String uid, Object value) {
        form.setAnswer(uid, value);
        return form.answerOf(uid);
      }

      expect(
        answer('1', 'Jane Roe').single.valueString?.valueString,
        'Jane Roe',
      );
      expect(
        answer('8', 'Headache').single.valueString?.valueString,
        'Headache',
      );
      expect(answer('6', 7).single.valueInteger?.valueInt, 7);
      expect(() => form.setAnswer('6', 7.5), throwsArgumentError);
      expect(
        answer('401', 'https://example.org').single.valueUri?.valueString,
        'https://example.org',
      );
      expect(answer('501', true).single.valueBoolean?.valueBoolean, isTrue);

      final yes = form.itemOf('104')!.options.first;
      expect(answer('104', yes).single.valueCoding?.code?.valueString, 'yes');
      // An equal option built elsewhere is replaced by the item's own.
      final female = QuestionnaireAnswerOption(
        valueX: Coding(code: FhirCode('female'), display: FhirString('Female')),
      );
      expect(
        answer('4', female).single.valueCoding?.code?.valueString,
        'female',
      );
      final age = form.itemOf('102')!.options[1];
      expect(answer('102', age).single.valueCoding?.code?.valueString, '26-35');
      final diets = form.itemOf('100')!.options;
      expect(
        answer('100', [
          diets[1],
          diets[2],
        ]).map((a) => a.valueCoding?.code?.valueString),
        ['vegan', 'glutenFree'],
      );
      expect(
        answer('5', 'Medication C').single.valueString?.valueString,
        'Medication C',
      );
      expect(
        form.itemOf('5')!.options.map((option) => option.title),
        contains('Medication C'),
      );
      expect(
        answer('101', [form.itemOf('101')!.options.first, 'Swimming']).map(
          (a) => a.valueCoding?.code?.valueString ?? a.valueString?.valueString,
        ),
        ['yoga', 'Swimming'],
      );

      expect(
        answer('2', DateTime(2020, 5, 17)).single.valueDate?.valueString,
        '2020-05-17',
      );
      expect(
        answer('2.2', DateTime(2024, 1, 2, 9, 30)).single.valueDateTime,
        isNotNull,
      );
      expect(
        answer('2.1', DateTime(2024, 1, 2, 8, 15)).single.valueTime,
        isNotNull,
      );
      final weight = answer('300/302', 72.5).single.valueQuantity;
      expect(weight?.value?.valueDouble, 72.5);
      expect(weight?.unit?.valueString, 'kg');

      // Values outside the options and items that cannot be answered.
      expect(() => form.setAnswer('104', 'Maybe'), throwsArgumentError);
      expect(
        () => form.setAnswer(
          '104',
          QuestionnaireAnswerOption(valueX: FhirString('Maybe')),
        ),
        throwsArgumentError,
      );
      expect(() => form.setAnswer('1', 42), throwsArgumentError);
      expect(() => form.setAnswer('502', 'file'), throwsArgumentError);
      expect(() => form.setAnswer('intro', 'x'), throwsArgumentError);
      expect(() => form.setAnswer('300', 'x'), throwsArgumentError);
      expect(() => form.setAnswer('7', 180), throwsArgumentError);
      expect(form.itemOf('7')!.readOnly, isTrue);

      form.clearAnswer('1');
      expect(form.answerOf('1'), isEmpty);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('rejects setting the root signature', (tester) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(
        tester,
        Questionnaire.fromJson({
          'resourceType': 'Questionnaire',
          'status': 'active',
          'extension': [
            {
              'url': _signatureRequiredUrl,
              'valueCodeableConcept': {
                'coding': [
                  {'code': '1.2.840.10065.1.12.1.1'},
                ],
              },
            },
          ],
          'item': [_string('name', 'Name')],
        }),
        formController: form,
      );
      expect(
        () =>
            form.setAnswer(QuestionnaireFormController.rootSignatureUid, _png),
        throwsArgumentError,
      );
    });

    testWidgets('shows on screen every value set from code', (tester) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(
        tester,
        _fixture('sample_generic.json'),
        formController: form,
      );
      Future<void> set(String uid, Object value) async {
        await _complete(tester, form.scrollTo(uid));
        form.setAnswer(uid, value);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      }

      await set('501', true);
      expect(
        tester.widget<Switch>(_inItem(form, '501', find.byType(Switch))).value,
        isTrue,
      );

      final yes = form.itemOf('104')!.options.first;
      await set('104', yes);
      expect(
        tester
            .widget<RadioGroup<QuestionnaireAnswerOption>>(
              _inItem(
                form,
                '104',
                find.byType(RadioGroup<QuestionnaireAnswerOption>),
              ),
            )
            .groupValue,
        same(yes),
      );

      await set('100', [form.itemOf('100')!.options[1]]);
      expect(
        tester
            .widget<CheckboxListTile>(
              _inItem(
                form,
                '100',
                find.widgetWithText(CheckboxListTile, 'Vegan'),
              ),
            )
            .value,
        isTrue,
      );

      await set('102', form.itemOf('102')!.options[1]);
      expect(_inItem(form, '102', find.text('26-35')), findsOneWidget);

      await set('2', DateTime(2020, 5, 17));
      expect(
        _inItem(form, '2', find.text(DateTime(2020, 5, 17).formattedDate())),
        findsOneWidget,
      );

      await set('2.1', DateTime(2024, 1, 2, 8, 15));
      expect(
        _inItem(
          form,
          '2.1',
          find.text(DateTime(2024, 1, 2, 8, 15).formattedTime()),
        ),
        findsOneWidget,
      );

      await set('300/301', 172);
      expect(_inItem(form, '300/301', find.text('172.0')), findsOneWidget);

      await set('1', 'Jane Roe');
      expect(_inItem(form, '1', find.text('Jane Roe')), findsOneWidget);

      await set('5', 'Medication C');
      expect(_inItem(form, '5', find.text('Medication C')), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('highlights one item at a time', (tester) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(tester, _longForm(), formController: form);
      AnimatedContainer highlightOf(String uid) => tester.widget(
        _inItem(form, uid, find.byType(AnimatedContainer)).first,
      );

      expect(highlightOf('q01').foregroundDecoration, isNull);
      form.highlight('q01');
      await tester.pump();
      expect(form.highlightedUid, 'q01');
      expect(highlightOf('q01').foregroundDecoration, isNotNull);
      expect(highlightOf('q02').foregroundDecoration, isNull);

      form.highlight('q02');
      await tester.pump();
      expect(highlightOf('q01').foregroundDecoration, isNull);
      expect(highlightOf('q02').foregroundDecoration, isNotNull);

      form.clearHighlight();
      await tester.pump();
      expect(highlightOf('q02').foregroundDecoration, isNull);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('highlights list tile items without hiding their ink', (
      tester,
    ) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(
        tester,
        _fixture('sample_generic.json'),
        formController: form,
      );
      // Radio, check box and switch items are list tiles. The highlight moves
      // on while the last one is still fading out, so items rebuild with a
      // tint between their list tiles and the form's Material.
      await _complete(tester, form.scrollTo('4'));
      for (final uid in ['104', '4', '5', '4', '104']) {
        form.highlight(uid);
        await tester.pump(const Duration(milliseconds: 40));
        await tester.pump(const Duration(milliseconds: 40));
        expect(tester.takeException(), isNull, reason: uid);
      }
      await _complete(tester, form.scrollTo('501'));
      for (final uid in ['501', '502', '501']) {
        form.highlight(uid);
        await tester.pump(const Duration(milliseconds: 40));
        expect(tester.takeException(), isNull, reason: uid);
      }
      await tester.pump(const Duration(seconds: 1));
    });

    group('scrollTo leaves the whole item on screen', () {
      testWidgets('a top level item far down that was never built', (
        tester,
      ) async {
        final form = QuestionnaireFormController();
        addTearDown(form.dispose);
        await _pumpForm(tester, _longForm(), formController: form);

        expect(_isBuilt(form, 'late'), isFalse);
        await _complete(tester, form.scrollTo('late'));
        _expectEntirelyVisible(tester, form, 'late');
      });

      testWidgets('a nested item in a section far down', (tester) async {
        final form = QuestionnaireFormController();
        addTearDown(form.dispose);
        await _pumpForm(tester, _longForm(), formController: form);

        expect(_isBuilt(form, 'section/nested-b'), isFalse);
        await _complete(tester, form.scrollTo('section/nested-b'));
        _expectEntirelyVisible(tester, form, 'section/nested-b');
      });

      testWidgets('an item just enabled by an answer', (tester) async {
        final form = QuestionnaireFormController();
        addTearDown(form.dispose);
        await _pumpForm(tester, _longForm(), formController: form);

        expect(_isBuilt(form, 'revealed'), isFalse);
        form.setAnswer('toggle', true);
        await _complete(tester, form.scrollTo('revealed'));
        _expectEntirelyVisible(tester, form, 'revealed');
        // Still entirely visible once the expansion has settled.
        await tester.pump(const Duration(seconds: 1));
        _expectEntirelyVisible(tester, form, 'revealed');
      });

      testWidgets('an item above the current position', (tester) async {
        final form = QuestionnaireFormController();
        addTearDown(form.dispose);
        await _pumpForm(tester, _longForm(), formController: form);

        await _complete(tester, form.scrollTo('q30'));
        _expectEntirelyVisible(tester, form, 'q30');
        expect(_isEntirelyVisible(tester, form, 'q02'), isFalse);
        await _complete(tester, form.scrollTo('q02'));
        _expectEntirelyVisible(tester, form, 'q02');
      });

      testWidgets('an item on screen that grows once highlighted', (
        tester,
      ) async {
        final form = QuestionnaireFormController();
        addTearDown(form.dispose);
        await _pumpForm(tester, _longForm(), formController: form);

        // Its bottom lands right at the limit.
        await _complete(tester, form.scrollTo('q20'));
        _expectEntirelyVisible(tester, form, 'q20');
        form.highlight('q20');
        await _complete(tester, form.scrollTo('q20'));
        await _settle(tester);
        _expectEntirelyVisible(tester, form, 'q20');
      });

      testWidgets('an item taller than the screen, once the item above it is '
          'no longer highlighted', (tester) async {
        final form = QuestionnaireFormController();
        addTearDown(form.dispose);
        await _pumpForm(tester, _tallForm(), formController: form);

        form.highlight('q01');
        await _complete(tester, form.scrollTo('q01'));
        form.highlight('tall');
        await _complete(tester, form.scrollTo('tall'));
        await _settle(tester);
        final item = tester.getRect(
          find.byKey(form.itemOf('tall')!.view.controller.key),
        );
        final viewport = tester.getRect(find.byType(ListView));
        expect(item.top, greaterThanOrEqualTo(viewport.top));
      });

      testWidgets('an invalid item highlighted right after validate', (
        tester,
      ) async {
        final form = QuestionnaireFormController();
        addTearDown(form.dispose);
        await _pumpForm(tester, _longForm(), formController: form);

        // Its bottom lands right at the limit, so validating does not scroll.
        await _complete(tester, form.scrollTo('late'));
        final invalid = form.validate();
        expect(invalid.first, 'late');
        form.highlight(invalid.first);
        await _settle(tester);
        _expectEntirelyVisible(tester, form, 'late');
      });
    });

    testWidgets('validate flags a required item never built and skips a '
        'disabled one', (tester) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(tester, _longForm(), formController: form);

      expect(_isBuilt(form, 'late'), isFalse);
      // 'revealed' is required too, but disabled while the toggle is off.
      final invalid = form.validate();
      expect(invalid, ['late']);
      await tester.pump(const Duration(seconds: 2));

      form.setAnswer('late', 'Done');
      form.setAnswer('toggle', true);
      expect(form.validate(), ['revealed']);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('buildResponse is what the Submit button submits', (
      tester,
    ) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      QuestionnaireResponse? submitted;
      await _pumpForm(
        tester,
        _fixture('sample_generic.json'),
        formController: form,
        onSubmit: (response) => submitted = response,
      );
      form.setAnswer('1', 'Jane Roe');
      form.setAnswer('4', form.itemOf('4')!.options.first);
      form.setAnswer('102', form.itemOf('102')!.options.first);
      form.setAnswer('103', '7 hours');
      form.setAnswer('8', 'Headache');
      form.setAnswer('300/302', 72.5);
      // The form asks for a root level signature, which only the user adds.
      form
              .itemOf(QuestionnaireFormController.rootSignatureUid)!
              .signatureController!
              .value =
          _png;

      await tester.drag(find.byType(ListView), const Offset(0, -20000));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Submit'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(submitted, isNotNull);
      // The signature carries the time it was built; the rest must match.
      Map<String, dynamic> withoutSignatureTime(QuestionnaireResponse r) {
        final json = r.toJson();
        for (final ext in (json['extension'] as List? ?? [])) {
          (ext['valueSignature'] as Map?)?.remove('when');
        }
        return json;
      }

      expect(
        withoutSignatureTime(submitted!),
        withoutSignatureTime(await form.buildResponse()),
      );
      expect(submitted!.extension_, hasLength(1));
    });

    testWidgets('initial values count before their items are built', (
      tester,
    ) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(
        tester,
        Questionnaire.fromJson({
          'resourceType': 'Questionnaire',
          'status': 'active',
          'item': [
            for (int i = 1; i <= 20; ++i) _string('q$i', 'Question $i'),
            {
              ..._string('seeded-text', 'Seeded text', required: true),
              'initial': [
                {'valueString': 'seed'},
              ],
            },
            {
              'linkId': 'seeded-bool',
              'type': 'boolean',
              'text': 'Seeded switch',
              'initial': [
                {'valueBoolean': true},
              ],
            },
            {
              'linkId': 'seeded-choice',
              'type': 'choice',
              'text': 'Seeded choice',
              'required': true,
              'answerOption': [
                {
                  'valueCoding': {'code': 'a', 'display': 'A'},
                },
                {
                  'valueCoding': {'code': 'b', 'display': 'B'},
                },
              ],
              'initial': [
                {
                  'valueCoding': {'code': 'b'},
                },
              ],
            },
            {
              'linkId': 'seeded-date',
              'type': 'date',
              'text': 'Seeded date',
              'initial': [
                {'valueDate': '2021-03-04'},
              ],
            },
            {'linkId': 'plain-bool', 'type': 'boolean', 'text': 'Plain switch'},
          ],
        }),
        formController: form,
      );

      expect(_isBuilt(form, 'seeded-text'), isFalse);
      expect(form.validate(), isEmpty);
      final before = (await form.buildResponse()).toJson();
      expect(
        form.answerOf('seeded-text').single.valueString?.valueString,
        'seed',
      );
      expect(
        form.answerOf('seeded-bool').single.valueBoolean?.valueBoolean,
        isTrue,
      );
      expect(
        form.answerOf('seeded-choice').single.valueCoding?.code?.valueString,
        'b',
      );
      expect(
        form.answerOf('plain-bool').single.valueBoolean?.valueBoolean,
        isFalse,
      );

      for (final item in form.items) {
        await _complete(tester, form.scrollTo(item.uid));
      }
      expect((await form.buildResponse()).toJson(), before);
    });

    testWidgets('notifies each answer change, telling user edits from code', (
      tester,
    ) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      await _pumpForm(tester, _longForm(), formController: form);
      final changes = <(String?, bool)>[];
      form.addListener(
        () => changes.add((form.lastChangedUid, form.lastChangeByCode)),
      );

      await tester.enterText(_inItem(form, 'q01', find.byType(TextField)), 'x');
      await tester.pump();
      form.setAnswer('q02', 'y');
      await tester.pump();
      await tester.tap(_inItem(form, 'toggle', find.byType(Switch)));
      await tester.pump();
      // Focus and highlight changes are not answer changes.
      form.highlight('q03');
      await tester.pump();

      expect(changes, [('q01', false), ('q02', true), ('toggle', false)]);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('stays attached to the state that replaced the first one', (
      tester,
    ) async {
      final form = QuestionnaireFormController();
      addTearDown(form.dispose);
      final questionnaire = _longForm();
      await _pumpForm(
        tester,
        questionnaire,
        formController: form,
        key: const ValueKey(1),
      );
      final first = form.items.first.bundle;
      await _pumpForm(
        tester,
        questionnaire,
        formController: form,
        key: const ValueKey(2),
      );

      expect(form.isAttached, isTrue);
      final state = tester.state<QuestionnaireViewState>(
        find.byType(QuestionnaireView),
      );
      expect(form.items.first.bundle, same(state.itemBundles.first));
      expect(form.items.first.bundle, isNot(same(first)));
    });
  });

  group('defect regressions', () {
    testWidgets('a question that requires a signature still validates its '
        'own answer', (tester) async {
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
      await _pumpForm(tester, questionnaire);
      final state = tester.state<QuestionnaireViewState>(
        find.byType(QuestionnaireView),
      );
      final bundle = state.itemBundles.single;
      final signatureView = bundle.view as QuestionnaireSignatureView;
      (signatureView.controller as SignatureController).value = _png;
      await tester.pump();

      // Signed, but the required answer is empty: the form is not valid.
      expect(state.validate(), isFalse);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('a sub-question nested under a question is shown, and a help '
        'child stays helper text', (tester) async {
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
                'linkId': 'pain-help',
                'type': 'display',
                'text': 'Any pain in the last week counts.',
                'extension': [
                  {
                    'url': _displayCategoryUrl,
                    'valueCodeableConcept': {
                      'coding': [
                        {
                          'system': 'http://hl7.org/fhir/questionnaire-display-category',
                          'code': 'help',
                        },
                      ],
                    },
                  },
                ],
              },
              {
                'linkId': 'pain-where',
                'type': 'string',
                'text': 'Where does it hurt?',
              },
            ],
          },
        ],
      });
      await _pumpForm(tester, questionnaire);

      expect(find.text('Where does it hurt?'), findsOneWidget);
      expect(find.text('Any pain in the last week counts.'), findsOneWidget);
    });
  });
}
