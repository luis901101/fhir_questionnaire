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

  /// The [QuestionnaireItemType] of this item, or null for an unknown type.
  QuestionnaireItemType? get itemType =>
      QuestionnaireItemType.valueOf(type.value);

  /// Whether this item must be answered.
  bool get isRequired => required_?.value ?? false;

  /// Whether this item's answer cannot be changed.
  bool get isReadOnly => readOnly?.value ?? false;

  /// Whether this item may hold more than one answer.
  bool get isRepeating => repeats?.value ?? false;

  /// Whether this is a `display` item categorized as help by the
  /// `questionnaire-displayCategory` extension. Such an item is rendered as the
  /// helper text of the item it is nested under, not as an item of its own.
  /// Docs: https://hl7.org/fhir/R4/extension-questionnaire-displaycategory.html
  bool get isHelpDisplay =>
      type.value == QuestionnaireItemType.display.code &&
      (extension_?.any(
            (ext) =>
                ext.url?.value?.toString() ==
                    FhirConstants.displayCategoryExtensionUrl &&
                ext.valueCodeableConcept?.coding?.firstOrNull?.code?.value ==
                    QuestionnaireItemExtensionCode.help.code,
          ) ??
          false);

  /// Whether this item is hidden: it declares the `questionnaire-hidden`
  /// extension, or it is a help display (see [isHelpDisplay]).
  /// Docs: http://hl7.org/fhir/R4/extension-questionnaire-hidden.html
  bool get isHidden =>
      (extension_ ?? []).any(
        (ext) =>
            ext.url?.value?.toString() == FhirConstants.hiddenExtensionUrl &&
            ext.valueBoolean?.value == true,
      ) ||
      isHelpDisplay;

  /// The minimum length declared by the `minLength` extension.
  /// Docs: http://hl7.org/fhir/R4/extension-minlength.html
  int? get minLength => (extension_ ?? [])
      .firstWhereOrNull(
        (ext) =>
            ext.url?.value?.toString() == FhirConstants.minLengthExtensionUrl,
      )
      ?.valueInteger
      ?.value;

  /// The minimum value declared by the `minValue` extension. Depending on the
  /// item type it is an `int`, a `double` or a `DateTime`.
  /// Docs: http://hl7.org/fhir/R4/extension-minvalue.html
  dynamic get minValue => _boundValue(FhirConstants.minValueExtensionUrl);

  /// The maximum value declared by the `maxValue` extension. Depending on the
  /// item type it is an `int`, a `double` or a `DateTime`.
  /// Docs: http://hl7.org/fhir/R4/extension-maxvalue.html
  dynamic get maxValue => _boundValue(FhirConstants.maxValueExtensionUrl);

  dynamic _boundValue(String url) {
    final ext = (extension_ ?? []).firstWhereOrNull(
      (ext) => ext.url?.value?.toString() == url,
    );
    return ext?.valueInteger?.value ??
        ext?.valueDecimal?.value ??
        ext?.valueInstant?.value ??
        ext?.valueDate?.value ??
        ext?.valueDateTime?.value ??
        ext?.valueTime?.value;
  }

  /// The hint text declared by the `entryFormat` extension.
  /// Docs: http://hl7.org/fhir/R4/extension-entryformat.html
  String? get hintText => (extension_ ?? [])
      .firstWhereOrNull(
        (ext) =>
            ext.url?.value?.toString() == FhirConstants.entryFormatExtensionUrl,
      )
      ?.valueString;

  /// The first help display nested under this item (see [isHelpDisplay]).
  QuestionnaireItem? get helperItem =>
      item?.firstWhereOrNull((subItem) => subItem.isHelpDisplay);

  /// The text of [helperItem].
  String? get helperText => helperItem?.title;

  /// Whether [helperText] is shown behind a help button rather than as text
  /// below the item, as asked by the help item's `questionnaire-itemControl`.
  bool get helperTextAsButton => (helperItem?.extension_ ?? []).any(
    (ext) =>
        ext.url?.value?.toString() == FhirConstants.itemControlExtensionUrl &&
        [
          QuestionnaireItemExtensionCode.help.code,
          QuestionnaireItemExtensionCode.flyover.code,
        ].contains(ext.valueCodeableConcept?.coding?.firstOrNull?.code?.value),
  );
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
