import 'package:collection/collection.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart';

extension CodeableConceptUtils on CodeableConcept {
  String? get title => text?.valueString ?? coding?.firstOrNull?.title;
}

extension FhirExtensionSignatureUtils on FhirExtension {
  /// Whether this is the `questionnaire-signatureRequired` marker extension.
  bool get isSignatureRequired =>
      url.valueString == FhirConstants.signatureRequiredExtensionUrl;
}

extension CodingUtils on Coding {
  String? get title =>
      display?.valueString ?? code?.valueString ?? system?.valueString;
}

extension FhirDateUtils on FhirDate {
  DateTime get asDateTime => DateTime.now().copyWith(
    isUtc: isUtc,
    year: year ?? 1,
    month: month ?? 1,
    day: day ?? 1,
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );
}

extension FhirTimeUtils on FhirTime {
  DateTime get asDateTime => DateTime.now().copyWith(
    year: 1,
    month: 1,
    day: 1,
    hour: hour ?? 0,
    minute: minute ?? 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );
}

extension FhirDateTimeUtils on FhirDateTime {
  DateTime get asDateTime => DateTime.now().copyWith(
    isUtc: isUtc,
    year: year ?? 1,
    month: month ?? 1,
    day: day ?? 1,
    hour: hour ?? 0,
    minute: minute ?? 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );
}

extension QuestionnaireItemUtils on QuestionnaireItem {
  String? get title =>
      extension_?.localize() ?? text?.valueString ?? code?.firstOrNull?.title;

  /// Whether this item requires a hand written signature.
  bool get hasSignature =>
      extension_?.any((e) => e.isSignatureRequired) ?? false;

  /// The signature type coding declared by the `questionnaire-signatureRequired`
  /// extension of this item, used as [Signature.type] in the response.
  List<Coding>? get signatureTypeCoding => extension_
      ?.firstWhereOrNull((e) => e.isSignatureRequired)
      ?.valueCodeableConcept
      ?.coding;
}

extension QuestionnaireUtils on Questionnaire {
  FhirCanonical get asFhirCanonical =>
      FhirCanonical('${R4ResourceType.Questionnaire.name}/${id?.valueString}');

  /// Whether this Questionnaire requires a hand written signature at root level.
  bool get hasSignature =>
      extension_?.any((e) => e.isSignatureRequired) ?? false;

  /// The signature type coding declared by the root level
  /// `questionnaire-signatureRequired` extension, used as [Signature.type] in
  /// the response.
  List<Coding>? get signatureTypeCoding => extension_
      ?.firstWhereOrNull((e) => e.isSignatureRequired)
      ?.valueCodeableConcept
      ?.coding;
}

extension QuestionnaireAnswerOptiontils on QuestionnaireAnswerOption {
  String? get title =>
      extension_?.localize() ??
      valueCoding?.extension_?.localize() ??
      valueCoding?.title ??
      valueString?.valueString ??
      valueInteger?.valueString;
}
