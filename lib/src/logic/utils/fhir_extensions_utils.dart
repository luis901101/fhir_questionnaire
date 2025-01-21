import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';

const _fhirTranslationExtension =
    'http://hl7.org/fhir/StructureDefinition/translation';

extension FhirExtensionUtils on Iterable<FhirExtension> {
  String? translationForLocale(String locale) {
    final allTranslations =
        where((ext) => ext.url?.toString() == _fhirTranslationExtension);

    if (allTranslations.isEmpty) {
      return null;
    } else {
      final match = allTranslations.firstWhereOrNull((translation) {
        return translation.extension_?.firstWhereOrNull((ext) =>
                ext.url?.toString() == 'lang' &&
                ext.valueCode?.toString() == locale) !=
            null;
      });

      if (match != null) {
        final content = match.extension_
            ?.firstWhereOrNull((ext) => ext.url?.toString() == 'content');

        return content?.valueString ?? content?.valueMarkdown?.toString();
      }
    }
  }
}
