import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_base_localization.dart';

/// English localizations
class QuestionnaireEnLocalization extends QuestionnaireBaseLocalization {
  QuestionnaireEnLocalization() : super('en');

  @override
  String get btnSubmit => 'Submit';
  @override
  String get exceptionNoEmptyField => 'This field is required.';
  @override
  String get exceptionValueMustBeAPositiveIntegerNumber =>
      'Value must be a positive integer number.';
  @override
  String get exceptionValueMustBeAPositiveNumber =>
      'Value must be a positive number.';
  @override
  String exceptionValueOutOfRange(dynamic minValue, dynamic maxValue) =>
      'The value must be in a range of $minValue to $maxValue.';
  @override
  String exceptionTextLength(dynamic minLength, dynamic maxLength) =>
      'Text must be at least $minLength characters and $maxLength at most.';
  @override
  String exceptionTextMaxLength(dynamic maxLength) =>
      'Text must be $maxLength characters at most.';
}
