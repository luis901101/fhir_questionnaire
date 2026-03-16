import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';

extension CodeableConceptUtils on CodeableConcept {
  String? get title => text?.valueString ?? coding?.firstOrNull?.title;
}

extension CodingUtils on Coding {
  String? get title =>
      display?.valueString ?? code?.valueString ?? system?.valueString;
}

extension FhirDateUtils on FhirDate {
  DateTime get asDateTime => DateTime(year ?? 0, month ?? 1, day ?? 1);
}

extension FhirTimeUtils on FhirTime {
  DateTime get asDateTime =>
      DateTime.now().copyWith(hour: hour ?? 0, minute: minute ?? 0);
}

extension FhirDateTimeUtils on FhirDateTime {
  DateTime get asDateTime => DateTime(
    year ?? 0,
    month ?? 1,
    day ?? 1,
    hour ?? 0,
    minute ?? 0,
    second ?? 0,
    millisecond ?? 0,
  );
}

extension QuestionnaireItemUtils on QuestionnaireItem {
  String? get title =>
      extension_?.localize() ??
      text?.valueString ??
      code?.firstOrNull?.title;
}

extension QuestionnaireUtils on Questionnaire {
  FhirCanonical get asFhirCanonical =>
      FhirCanonical('${R4ResourceType.Questionnaire.name}/${id?.valueString ?? ''}');
}

extension QuestionnaireAnswerOptiontils on QuestionnaireAnswerOption {
  String? get title =>
      extension_?.localize() ??
      valueCoding?.extension_?.localize() ??
      valueCoding?.title ??
      valueString?.valueString ??
      valueInteger?.valueNum?.toString();
}
