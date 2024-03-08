import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_base_localization.dart';
import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_en_localization.dart';
import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_es_localization.dart';

class QuestionnaireLocalization {
  static final instance = QuestionnaireLocalization();
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
    String? locale,
  }) {
    if (defaultLocalization != null) {
      _defaultLocalization = defaultLocalization;
    }
    if (localizations != null) {
      for (final localization in localizations) {
        _localizationsMap[localization.locale] = localization;
      }
    }
    if (locale != null) {
      localization = _localizationsMap[locale] ?? _defaultLocalization;
    }
  }
}
