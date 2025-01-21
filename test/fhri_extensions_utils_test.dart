import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/logic/utils/fhir_extensions_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Should extract translation value from translation extension for the title field',
    () {
      const jsonString = r'''
{
  "resourceType": "Questionnaire",
  "title": "Health questionnaire",
  "_title": {
    "extension": [
      {
        "url": "http://hl7.org/fhir/StructureDefinition/translation",
        "extension": [
          {
            "url": "lang",
            "valueCode": "de"
          },
          {
            "url": "content",
            "valueString": "Gesundheitsfragebogen"
          }
        ]
      }
    ]
  },
  "item": []
}
''';

      final questionnaire = Questionnaire.fromJsonString(jsonString);
      expect(
        questionnaire.titleElement?.extension_?.translationForLocale('de'),
        'Gesundheitsfragebogen',
      );
    },
  );
}
