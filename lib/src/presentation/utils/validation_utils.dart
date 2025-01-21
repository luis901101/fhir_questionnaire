import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_localization.dart';
import 'package:flutter/material.dart';
import 'package:fhir_questionnaire/src/logic/utils/num_utils.dart';
import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:flutter/widgets.dart';

class ValidationUtils {
  static ValidationController requiredFieldValidation() =>
      EnhancedEmptyValidationController();

  static ValidationController positiveIntegerNumberValidation(
          BuildContext context) =>
      PositiveIntegerValidationController(
          message: QuestionnaireLocalization.of(context)
              .localization
              .exceptionValueMustBeAPositiveIntegerNumber);

  static ValidationController positiveNumberValidation({
    required BuildContext context,
    String? message,
    bool required = false,
  }) =>
      ValidationController(
          message: message ??
              QuestionnaireLocalization.of(context)
                  .localization
                  .exceptionValueMustBeAPositiveNumber,
          isValid: ({controller}) {
            String? textValue = controller?.rawValue?.toString();
            if (!required && textValue.isEmpty) return true;
            num? value = NumUtils.tryParse(textValue!);
            return (value ?? -1) >= 0;
          });

  static ValidationController integerRangeValidationController({
    required BuildContext context,
    required int minValue,
    required int maxValue,
  }) =>
      IntegerRangeValidationController(
        message: QuestionnaireLocalization.of(context)
            .localization
            .exceptionValueOutOfRange(minValue, maxValue),
        minValue: minValue,
        maxValue: maxValue,
      );

  static List<ValidationController> requiredPositiveIntegerNumberValidations(
          BuildContext context) =>
      [
        requiredFieldValidation(),
        positiveIntegerNumberValidation(context),
      ];

  static List<ValidationController> requiredPositiveNumberValidations(
          BuildContext context) =>
      [
        requiredFieldValidation(),
        positiveNumberValidation(context: context),
      ];

  static ValidationController lengthValidation({
    required BuildContext context,
    int minLength = 0,
    int? maxLength,
    String? message,
    bool required = false,
    bool considerExtendedCharacters = true,
  }) =>
      ValidationController(
          message: message ??
              QuestionnaireLocalization.of(context)
                  .localization
                  .exceptionTextLength(minLength, maxLength ?? (minLength * 2)),
          isValid: ({controller}) {
            String textValue = controller?.rawValue?.toString().trim() ?? '';
            int length = considerExtendedCharacters
                ? textValue.characters.length
                : textValue.length;
            if (!required && length == 0) return true;
            return length >= minLength &&
                (maxLength == null || length <= maxLength);
          });

  static ValidationController maxLengthValidation({
    required int maxLength,
    required BuildContext context,
    String? message,
    bool required = false,
    bool considerExtendedCharacters = true,
  }) =>
      ValidationController(
          message: message ??
              QuestionnaireLocalization.of(context)
                  .localization
                  .exceptionTextMaxLength(maxLength),
          isValid: ({controller}) {
            String textValue = controller?.rawValue?.toString().trim() ?? '';
            int length = considerExtendedCharacters
                ? textValue.characters.length
                : textValue.length;
            if (!required && length == 0) return true;
            return length <= maxLength;
          });

  static ValidationController urlValidation({
    String? message,
    bool required = false,
    required BuildContext context,
  }) =>
      UrlValidationController(
        message: message ??
            QuestionnaireLocalization.of(context)
                .localization
                .exceptionInvalidUrl,
        required: required,
      );
}

class EnhancedEmptyValidationController extends ValidationController {
  final String? customMessage;

  EnhancedEmptyValidationController({
    this.customMessage,
  }) : super(
          isValid: ({controller}) {
            final rawValue = controller?.rawValue;
            if (rawValue is List<QuestionnaireAnswerOption>) {
              return rawValue.isNotEmpty;
            } else {
              return TextUtils.isNotEmpty(rawValue?.toString().trim());
            }
          },
        );

  @override
  String? get message => customMessage ??
      QuestionnaireLocalization.current.localization.exceptionNoEmptyField;
}
