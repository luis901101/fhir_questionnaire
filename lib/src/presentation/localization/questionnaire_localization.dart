import 'dart:ui';

import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_base_localization.dart';
import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_en_localization.dart';
import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_es_localization.dart';
import 'package:intl/intl.dart';

class QuestionnaireLocalization {
  static final instance = QuestionnaireLocalization();

  /// If set to true, the localization will always use Intl.defaultLocale if it's set
  static bool useIntlDefaultLocale = false;

  /// This locale will be used by extensions localization method when no locale is provided
  static Locale get locale => useIntlDefaultLocale && Intl.defaultLocale != null
      ? Locale(Intl.defaultLocale!)
      : instance.localization.locale;

  QuestionnaireBaseLocalization localization = QuestionnaireEnLocalization();
  QuestionnaireBaseLocalization _defaultLocalization =
      QuestionnaireEnLocalization();
  final Map<String, QuestionnaireBaseLocalization> _localizationsMap = {
    'en': QuestionnaireEnLocalization(),
    'es': QuestionnaireEsLocalization(),
  };
  QuestionnaireLocalization();

  void init({
    QuestionnaireBaseLocalization? defaultLocalization,
    List<QuestionnaireBaseLocalization>? localizations,
    Locale? locale,
  }) {
    if (defaultLocalization != null) {
      _defaultLocalization = defaultLocalization;
    }
    if (localizations != null) {
      for (final localization in localizations) {
        _localizationsMap[localization.locale.toLanguageTag()] = localization;
        _localizationsMap[localization.locale.languageCode] = localization;
      }
    }
    if (locale != null) {
      localization =
          _localizationsMap[locale.toLanguageTag()] ??
          _localizationsMap[locale.languageCode] ??
          _defaultLocalization;
    }
  }
}
