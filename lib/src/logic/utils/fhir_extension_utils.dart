import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:intl/intl.dart';

extension FhirExtensionUtils on Iterable<FhirExtension> {
  String? localize([final String? locale]) {
    final translation = firstWhereOrNull(
      (ext) =>
          ext.url ==
              FhirUri('http://hl7.org/fhir/StructureDefinition/translation') &&
          ext.extension_?.firstWhereOrNull((e) =>
                  e.url == FhirUri('lang') &&
                  e.valueCode?.value == (locale ?? Intl.defaultLocale)) !=
              null,
    )?.extension_?.firstWhereOrNull((e) => e.url == FhirUri('content'));

    return translation?.valueString ?? translation?.valueMarkdown?.toString();
  }
}
