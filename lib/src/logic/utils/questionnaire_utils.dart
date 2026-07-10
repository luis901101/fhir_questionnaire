import 'package:collection/collection.dart';
import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';

extension CodeableConceptUtils on CodeableConcept {
  String? get title => text ?? coding?.firstOrNull?.title;
}

extension FhirExtensionSignatureUtils on FhirExtension {
  /// Whether this is the `questionnaire-signatureRequired` marker extension.
  bool get isSignatureRequired =>
      url?.value?.toString() == FhirConstants.signatureRequiredExtensionUrl;
}

extension CodingUtils on Coding {
  String? get title => display ?? code?.value ?? system?.value?.toString();
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
  String? get title =>
      extension_?.localize() ?? text ?? code?.firstOrNull?.title;

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
      FhirCanonical('${R4ResourceType.Questionnaire.name}/$fhirId');

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
      valueString ??
      valueInteger?.toString();
}
