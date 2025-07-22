import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_r4/fhir_r4.dart';

extension CodeableConceptUtils on CodeableConcept {
  String? get title => text?.valueString ?? coding?.firstOrNull?.title;
}

extension CodingUtils on Coding {
  String? get title =>
      display?.valueString ??
      code?.valueString ??
      system?.valueString?.toString();
}

extension FhirTimeUtils on FhirTime {
  DateTime get asDateTime =>
      DateTime.now().copyWith(hour: hour, minute: minute);
}

extension QuestionnaireItemUtils on QuestionnaireItem {
  String? get title => text?.valueString ?? code?.firstOrNull?.title;
}

extension QuestionnaireUtils on Questionnaire {
  FhirCanonical get asFhirCanonical =>
      FhirCanonical('${R4ResourceType.Questionnaire.name}/$id');
}

extension QuestionnaireAnswerOptiontils on QuestionnaireAnswerOption {
  String? get title =>
      extension_?.localize() ??
      valueCoding?.extension_?.localize() ??
      valueCoding?.title ??
      valueString?.valueString ??
      valueInteger?.toString();
}
