import 'dart:ui';

import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_base_localization.dart';
import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_en_localization.dart';
import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_es_localization.dart';

class QuestionnaireLocalization {
  QuestionnaireLocalization._();
  static final instance = QuestionnaireLocalization._();

  final Locale _defaultLocale = Locale('en', '');
  Locale? _locale;
  Locale get locale => _locale ?? _defaultLocale;
  QuestionnaireBaseLocalization get localization =>
      _localizationsMap[locale.toLanguageTag()] ??
      _localizationsMap[locale.languageCode] ??
      _defaultLocalization;

  QuestionnaireBaseLocalization _defaultLocalization =
      QuestionnaireEnLocalization();

  final Map<String, QuestionnaireBaseLocalization> _localizationsMap = {
    'en': QuestionnaireEnLocalization(),
    'es': QuestionnaireEsLocalization(),
  };

  void load({
    QuestionnaireBaseLocalization? defaultLocalization,
    List<QuestionnaireBaseLocalization>? localizations,
    Locale? locale,
  }) {
    _locale = locale;
    if (defaultLocalization != null) {
      _defaultLocalization = defaultLocalization;
    }
    if (localizations != null) {
      for (final localization in localizations) {
        _localizationsMap[localization.locale.toLanguageTag()] = localization;
        _localizationsMap[localization.locale.languageCode] = localization;
      }
    }
  }
}
