import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

class ValidationUtils {
  static EnhancedEmptyValidationController get requiredFieldValidation =>
      EnhancedEmptyValidationController(
        message: QuestionnaireLocalization
            .instance
            .localization
            .exceptionNoEmptyField,
      );

  static ValidationController get positiveIntegerNumberValidation =>
      PositiveIntegerValidationController(
        message: QuestionnaireLocalization
            .instance
            .localization
            .exceptionValueMustBeAPositiveIntegerNumber,
      );

  static ValidationController positiveNumberValidation({
    String? message,
    bool required = false,
  }) => ValidationController(
    message:
        message ??
        QuestionnaireLocalization
            .instance
            .localization
            .exceptionValueMustBeAPositiveNumber,
    isValid: ({controller}) {
      String? textValue = controller?.rawValue?.toString();
      if (!required && textValue.isEmpty) return true;
      num? value = NumUtils.tryParse(textValue!);
      return (value ?? -1) >= 0;
    },
  );

  static ValidationController rangeValidationController({
    required dynamic minValue,
    required dynamic maxValue,
  }) => RangeValidationController(
    message: QuestionnaireLocalization.instance.localization
        .exceptionValueOutOfRange(
          minValue is DateTime ? minValue.formattedDate() : minValue,
          maxValue is DateTime ? maxValue.formattedDate() : maxValue,
        ),
    minValue: minValue,
    maxValue: maxValue,
  );

  static ValidationController minRangeValidationController(dynamic minValue) =>
      MinRangeValidationController(
        message: QuestionnaireLocalization.instance.localization
            .exceptionValueMinRange(minValue),
        minValue: minValue,
      );

  static ValidationController maxRangeValidationController(dynamic maxValue) =>
      MaxRangeValidationController(
        message: QuestionnaireLocalization.instance.localization
            .exceptionValueMaxRange(maxValue),
        maxValue: maxValue,
      );

  static List<ValidationController>
  get requiredPositiveIntegerNumberValidations => [
    requiredFieldValidation,
    positiveIntegerNumberValidation,
  ];

  static List<ValidationController> get requiredPositiveNumberValidations => [
    requiredFieldValidation,
    positiveNumberValidation(),
  ];

  static ValidationController lengthValidation({
    int minLength = 0,
    int? maxLength,
    String? message,
    bool required = false,
    bool considerExtendedCharacters = true,
  }) => ValidationController(
    message:
        message ??
        QuestionnaireLocalization.instance.localization.exceptionTextLength(
          minLength,
          maxLength ?? (minLength * 2),
        ),
    isValid: ({controller}) {
      String textValue = controller?.rawValue?.toString().trim() ?? '';
      int length = considerExtendedCharacters
          ? textValue.characters.length
          : textValue.length;
      if (!required && length == 0) return true;
      return length >= minLength && (maxLength == null || length <= maxLength);
    },
  );

  static ValidationController minLengthValidation({
    required int minLength,
    String? message,
    bool required = false,
    bool considerExtendedCharacters = true,
  }) => ValidationController(
    message:
        message ??
        QuestionnaireLocalization.instance.localization.exceptionTextMinLength(
          minLength,
        ),
    isValid: ({controller}) {
      String textValue = controller?.rawValue?.toString().trim() ?? '';
      int length = considerExtendedCharacters
          ? textValue.characters.length
          : textValue.length;
      if (!required && length == 0) return true;
      return length >= minLength;
    },
  );

  static ValidationController maxLengthValidation({
    required int maxLength,
    String? message,
    bool required = false,
    bool considerExtendedCharacters = true,
  }) => ValidationController(
    message:
        message ??
        QuestionnaireLocalization.instance.localization.exceptionTextMaxLength(
          maxLength,
        ),
    isValid: ({controller}) {
      String textValue = controller?.rawValue?.toString().trim() ?? '';
      int length = considerExtendedCharacters
          ? textValue.characters.length
          : textValue.length;
      if (!required && length == 0) return true;
      return length <= maxLength;
    },
  );

  static ValidationController urlValidation({
    String? message,
    bool required = false,
  }) => UrlValidationController(
    message:
        message ??
        QuestionnaireLocalization.instance.localization.exceptionInvalidUrl,
    required: required,
  );
}

class EnhancedEmptyValidationController extends ValidationController {
  EnhancedEmptyValidationController({String? message})
    : super(
        message:
            message ??
            QuestionnaireLocalization
                .instance
                .localization
                .exceptionNoEmptyField,
        isValid: ({controller}) {
          final rawValue = controller?.rawValue;
          if (rawValue is List<QuestionnaireAnswerOption>) {
            return rawValue.isNotEmpty;
          } else {
            return TextUtils.isNotEmpty(rawValue?.toString().trim());
          }
        },
      );
}
