abstract class QuestionnaireBaseLocalization {
  final String locale;

  QuestionnaireBaseLocalization(this.locale);

  String get btnSubmit;
  String get btnUpload;
  String get btnChange;
  String get btnRemove;
  String get textOtherOption;
  String get textDate;
  String get textTime;
  String get exceptionNoEmptyField;
  String get exceptionValueMustBeAPositiveIntegerNumber;
  String get exceptionValueMustBeAPositiveNumber;
  String get exceptionInvalidUrl;
  String exceptionValueOutOfRange(dynamic minValue, dynamic maxValue);
  String exceptionTextLength(dynamic minLength, dynamic maxLength);
  String exceptionTextMaxLength(dynamic maxLength);
}
