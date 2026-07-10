/// Centralized static constants used across the package, mainly the FHIR
/// extension/coding URLs and URIs that were previously scattered as inline
/// string literals.
abstract class FhirConstants {
  // FHIR extension URLs (http://hl7.org/fhir/StructureDefinition/...)

  /// Extension declaring that a hand written signature is required on the
  /// Questionnaire (root or item). Its `valueCodeableConcept.coding` declares
  /// the kind of signature (used as [Signature.type] in the response).
  /// Docs: http://hl7.org/fhir/R4/extension-questionnaire-signaturerequired.html
  static const String signatureRequiredExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/questionnaire-signatureRequired';

  /// Extension emitted on the QuestionnaireResponse (root or item) holding the
  /// captured signature as a `valueSignature`.
  /// Docs: http://hl7.org/fhir/R4/extension-questionnaireresponse-signature.html
  static const String responseSignatureExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/questionnaireresponse-signature';

  /// Extension defining a root level FHIRPath variable.
  static const String variableExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/variable';

  /// SDC extension defining a calculated expression (FHIRPath).
  static const String calculatedExpressionExtensionUrl =
      'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression';

  /// Extension holding translations of an element's content.
  /// Docs: http://hl7.org/fhir/StructureDefinition/translation
  static const String translationExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/translation';

  /// Extension providing a minimum length validation.
  /// Docs: http://hl7.org/fhir/R4/extension-minlength.html
  static const String minLengthExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/minLength';

  /// Extension providing a minimum value validation.
  /// Docs: http://hl7.org/fhir/R4/extension-minvalue.html
  static const String minValueExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/minValue';

  /// Extension providing a maximum value validation.
  /// Docs: http://hl7.org/fhir/R4/extension-maxvalue.html
  static const String maxValueExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/maxValue';

  /// Extension hiding an item.
  /// Docs: http://hl7.org/fhir/R4/extension-questionnaire-hidden.html
  static const String hiddenExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/questionnaire-hidden';

  /// Extension categorizing how a display item is presented (e.g. help text).
  /// Docs: https://hl7.org/fhir/R4/extension-questionnaire-displaycategory.html
  static const String displayCategoryExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/questionnaire-displayCategory';

  /// Extension providing a hint / entry format for an input.
  /// Docs: http://hl7.org/fhir/R4/extension-entryformat.html
  static const String entryFormatExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/entryFormat';

  /// Extension controlling how an item is rendered (e.g. help, flyover).
  static const String itemControlExtensionUrl =
      'http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl';

  // Nested translation sub-extension keys used inside a `translation` extension.

  /// Sub-extension key holding the language code of a translation.
  static const String translationLangExtensionUrl = 'lang';

  /// Sub-extension key holding the translated content.
  static const String translationContentExtensionUrl = 'content';

  // Signature default coding, used only when a marker declares no coding.

  /// Coding system for the default signature type.
  static const String signatureCodingSystem = 'urn:iso-astm:E1762-95:2013';

  /// Code for the default signature type ("Author's Signature").
  static const String defaultSignatureCode = '1.2.840.10065.1.12.1.1';

  /// Display for the default signature type.
  static const String defaultSignatureDisplay = "Author's Signature";
}
