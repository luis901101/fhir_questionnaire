abstract class QuestionnaireBaseLocalization {
  final String locale;

  QuestionnaireBaseLocalization(this.locale);

  String get btnSubmit;
  String get textOtherOption;
  String get exceptionNoEmptyField;
  String get exceptionValueMustBeAPositiveIntegerNumber;
  String get exceptionValueMustBeAPositiveNumber;
  String exceptionValueOutOfRange(dynamic minValue, dynamic maxValue);
  String exceptionTextLength(dynamic minLength, dynamic maxLength);
  String exceptionTextMaxLength(dynamic maxLength);
}
