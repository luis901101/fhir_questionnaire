import 'dart:convert';
import 'dart:typed_data';

import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand_signature/signature.dart';

const _signatureQuestionnaireJson = '''
{
  "resourceType": "Questionnaire",
  "id": "example-signature",
  "status": "draft",
  "extension": [
    {
      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-signatureRequired",
      "valueCodeableConcept": {
        "coding": [
          {
            "system": "urn:iso-astm:E1762-95:2013",
            "code": "1.2.840.10065.1.12.1.1",
            "display": "Author's Signature"
          }
        ]
      }
    }
  ],
  "item": [
    { "linkId": "intro", "type": "display", "text": "Intro" },
    {
      "linkId": "consent-group",
      "type": "group",
      "text": "Consent",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-signatureRequired",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "urn:iso-astm:E1762-95:2013",
                "code": "1.2.840.10065.1.12.1.7",
                "display": "Consent Signature"
              }
            ]
          }
        }
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fakePng = Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, 1, 2, 3, 4, // PNG magic + a few bytes
  ]);

  group('signature detection extensions', () {
    final questionnaire = Questionnaire.fromJsonString(
      _signatureQuestionnaireJson,
    );

    test('root level signature is detected with its coding', () {
      expect(questionnaire.hasSignature, isTrue);
      expect(
        questionnaire.signatureTypeCoding?.first.code?.value,
        '1.2.840.10065.1.12.1.1',
      );
    });

    test('item (group) level signature is detected with its own coding', () {
      final group = questionnaire.item!.firstWhere(
        (e) => e.linkId == 'consent-group',
      );
      expect(group.hasSignature, isTrue);
      expect(
        group.signatureTypeCoding?.first.code?.value,
        '1.2.840.10065.1.12.1.7',
      );
    });

    test('non-signature item is not detected', () {
      final intro = questionnaire.item!.firstWhere((e) => e.linkId == 'intro');
      expect(intro.hasSignature, isFalse);
      expect(intro.signatureTypeCoding, isNull);
    });
  });

  group('buildSignatureExtension', () {
    final controller = QuestionnaireController();

    test('emits questionnaireresponse-signature with PNG data + given type', () {
      final coding = [
        Coding(
          system: FhirUri('urn:iso-astm:E1762-95:2013'),
          code: FhirCode('1.2.840.10065.1.12.1.7'),
          display: 'Consent Signature',
        ),
      ];
      final ext = controller.buildSignatureExtension(fakePng, type: coding);

      expect(
        ext.url?.value?.toString(),
        'http://hl7.org/fhir/StructureDefinition/questionnaireresponse-signature',
      );
      final signature = ext.valueSignature!;
      expect(signature.type.first.code?.value, '1.2.840.10065.1.12.1.7');
      expect(signature.sigFormat?.value, 'image/png');
      expect(signature.data?.value, base64.encode(fakePng));
    });

    test('falls back to a default coding when none provided', () {
      final ext = controller.buildSignatureExtension(fakePng);
      expect(ext.valueSignature!.type, isNotEmpty);
    });
  });

  group('item level response generation', () {
    test('signature bytes are embedded on the matching response item extension '
        'with the item coding', () {
      final questionnaire = Questionnaire.fromJsonString(
        _signatureQuestionnaireJson,
      );
      final controller = QuestionnaireController();
      final bundles = controller.buildQuestionnaireItems(questionnaire);

      // The group with a signature marker gets a SignatureController as its
      // bundle controller. Simulate a drawn signature.
      final signatureBundles = _flatten(
        bundles,
      ).where((b) => b.controller is SignatureController).toList();
      expect(signatureBundles, hasLength(1));
      for (final bundle in signatureBundles) {
        (bundle.controller as SignatureController).value = fakePng;
      }

      final response = controller.generateResponse(
        questionnaire: questionnaire,
        itemBundles: bundles,
      );

      final groupResponse = response.item!.firstWhere(
        (e) => e.linkId == 'consent-group',
      );
      final sigExt = groupResponse.extension_!.firstWhere(
        (e) =>
            e.url?.value?.toString() ==
            'http://hl7.org/fhir/StructureDefinition/questionnaireresponse-signature',
      );
      expect(
        sigExt.valueSignature?.type.first.code?.value,
        '1.2.840.10065.1.12.1.7',
      );
      expect(sigExt.valueSignature?.sigFormat?.value, 'image/png');
      expect(sigExt.valueSignature?.data?.value, base64.encode(fakePng));
      // The group still renders/serializes its children.
      expect(groupResponse.item, isNotNull);
    });
  });

  group('widget smoke test', () {
    testWidgets('signature field shows a tappable preview that opens a pad', (
      tester,
    ) async {
      // Use a realistic portrait phone surface (the signature dialog sizes its
      // pad from the viewport's shortest side).
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final questionnaire = Questionnaire.fromJsonString(
        _signatureQuestionnaireJson,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: QuestionnaireView(
            questionnaire: questionnaire,
            onSubmit: (_) {},
          ),
        ),
      );
      // Bounded pumps (avoid pumpAndSettle — several 300ms animations).
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // The form shows the signature preview placeholder, not a live pad.
      expect(find.byType(HandSignature), findsNothing);
      expect(find.text('Tap to sign'), findsAtLeastNWidgets(1));

      // Tapping the preview opens the drawing dialog with a pad + Done button.
      await tester.tap(find.text('Tap to sign').first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(HandSignature), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
