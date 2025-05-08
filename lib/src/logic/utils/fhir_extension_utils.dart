import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';

extension FhirExtensionUtils on Iterable<FhirExtension> {
  /// Attempts to localize the content of FHIR extensions based on the provided locale.
  ///
  /// This method searches for a translation within the FHIR extensions where:
  /// - The extension's URL is `http://hl7.org/fhir/StructureDefinition/translation`.
  /// - It contains a nested extension with a URL of `lang` and a `valueCode` matching
  ///   the provided `locale` or the default locale (`Intl.defaultLocale`).
  ///
  /// If a matching translation is found, it returns the `valueString` or `valueMarkdown`
  /// of the nested extension with a URL of `content`.
  ///
  /// - [locale]: The locale to search for. Defaults to `QuestionnaireLocalization.instance.localization.locale` if not provided.
  ///
  /// Returns the localized content as a `String`, or `null` if no matching translation is found.
  ///
  /// Example:
  /// ```dart
  /// final extensions = <FhirExtension>[
  ///   FhirExtension(
  ///     url: FhirUri('http://hl7.org/fhir/StructureDefinition/translation'),
  ///     extension_: [
  ///       FhirExtension(
  ///         url: FhirUri('lang'),
  ///         valueCode: Code('en'),
  ///       ),
  ///       FhirExtension(
  ///         url: FhirUri('content'),
  ///         valueString: 'Hello, World!',
  ///       ),
  ///     ],
  ///   ),
  /// ];
  ///
  /// final localizedContent = extensions.localize('en');
  /// print(localizedContent); // Output: Hello, World!
  /// ```
  String? localize([Locale? locale]) {
    locale ??= QuestionnaireLocalization.instance.localization.locale;
    String langTag = locale.toLanguageTag();
    String langCode = locale.languageCode;
    final translation = firstWhereOrNull(
      (ext) =>
          ext.url ==
              FhirUri('http://hl7.org/fhir/StructureDefinition/translation') &&
          ext.extension_?.firstWhereOrNull((e) =>
                  e.url == FhirUri('lang') && e.valueCode?.value == langTag ||
                  e.valueCode?.value == langCode) !=
              null,
    )?.extension_?.firstWhereOrNull((e) => e.url == FhirUri('content'));

    return translation?.valueString ?? translation?.valueMarkdown?.toString();
  }
}
