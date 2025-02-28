import 'package:collection/collection.dart';
import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_base_localization.dart';

class QuestionnaireLocalizationData {
  QuestionnaireLocalizationData({
    required this.locale,
    required this.fallbackLocalization,
    required List<QuestionnaireBaseLocalization> localizations,
  }) {
    for (final localization in localizations) {
      _localizationsMap[localization.locale] = localization;
    }
  }

  final String locale;
  final QuestionnaireBaseLocalization fallbackLocalization;
  final Map<String, QuestionnaireBaseLocalization> _localizationsMap = {};

  QuestionnaireBaseLocalization get localization =>
      _localizationsMap[locale] ?? fallbackLocalization;


}
