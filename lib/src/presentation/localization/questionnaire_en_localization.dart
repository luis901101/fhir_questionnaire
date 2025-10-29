import 'dart:ui';

import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_base_localization.dart';

/// English localizations
class QuestionnaireEnLocalization extends QuestionnaireBaseLocalization {
  QuestionnaireEnLocalization() : super(const Locale('en', 'US'));

  @override
  String get btnSubmit => 'Submit';
  @override
  String get btnUpload => 'Upload';
  @override
  String get btnChange => 'Change';
  @override
  String get btnRemove => 'Remove';
  @override
  String get textOtherOption => 'Other option';
  @override
  String get textDate => 'Date';
  @override
  String get textTime => 'Time';
  @override
  String get exceptionNoEmptyField => 'This field is required.';
  @override
  String get exceptionValueMustBeAPositiveIntegerNumber =>
      'Value must be a positive integer number.';
  @override
  String get exceptionValueMustBeAPositiveNumber =>
      'Value must be a positive number.';
  @override
  String get exceptionInvalidUrl => 'Invalid url.';
  @override
  String exceptionValueOutOfRange(dynamic minValue, dynamic maxValue) =>
      'The value must be in a range of $minValue to $maxValue.';
  @override
  String exceptionValueMinRange(dynamic minValue) =>
      'The value must be at least $minValue.';
  @override
  String exceptionValueMaxRange(dynamic maxValue) =>
      'The value must be at most $maxValue.';
  @override
  String exceptionTextLength(dynamic minLength, dynamic maxLength) =>
      'Text must be at least $minLength characters and $maxLength at most.';
  @override
  String exceptionTextMinLength(dynamic minLength) =>
      'Text must be $minLength characters at least.';
  @override
  String exceptionTextMaxLength(dynamic maxLength) =>
      'Text must be $maxLength characters at most.';
}
