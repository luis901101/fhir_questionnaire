import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_questionnaire/src/logic/utils/fhir_extensions_utils.dart';
import 'package:flutter/material.dart';

extension CodeableConceptUtils on CodeableConcept {
  String? title(final BuildContext context) {
    final locale = QuestionnaireLocalization.of(context).localization.locale;

    final textLocalized =
        textElement?.extension_?.translationForLocale(locale) ?? text;

    return textLocalized ?? coding?.firstOrNull?.title(context);
  }
}

extension CodingUtils on Coding {
  String?  title(final BuildContext context) {
    final locale = QuestionnaireLocalization.of(context).localization.locale;
    final displayLocalized =
        displayElement?.extension_?.translationForLocale(locale) ?? display;

    return displayLocalized ?? code?.value ?? system?.value?.toString();
  }
}

extension FhirDateUtils on FhirDate {
  DateTime get asDateTime => DateTime(year, month, day);
}

extension FhirTimeUtils on FhirTime {
  DateTime get asDateTime =>
      DateTime.now().copyWith(hour: hour, minute: minute);
}

extension FhirDateTimeUtils on FhirDateTime {
  DateTime get asDateTime =>
      DateTime(year, month, day, hour, minute, second, millisecond);
}

extension QuestionnaireItemUtils on QuestionnaireItem {
  String? title(final BuildContext context) {
    final locale = QuestionnaireLocalization.of(context).localization.locale;

    final textLocalized =
        textElement?.extension_?.translationForLocale(locale) ?? text;
    return textLocalized ?? code?.firstOrNull?.title(context);
  }
}

extension QuestionnaireUtils on Questionnaire {
  FhirCanonical get asFhirCanonical =>
      FhirCanonical('${R4ResourceType.Questionnaire.name}/$fhirId');
}

extension QuestionnaireAnswerOptionUtils on QuestionnaireAnswerOption {
  String? valueStringLocalized(final BuildContext context) {
    final locale = QuestionnaireLocalization.of(context).localization.locale;
    return valueStringElement?.extension_?.translationForLocale(locale) ??
        valueString;
  }
}
