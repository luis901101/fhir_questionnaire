import 'package:fhir_questionnaire/src/localization/questionnaire_base_localization.dart';

/// Spanish localizations
class QuestionnaireEsLocalization extends QuestionnaireBaseLocalization {
  QuestionnaireEsLocalization() : super('es');

  @override
  String get btnSubmit => 'Enviar';
  @override
  String get exceptionNoEmptyField => 'Este campo es requerido.';
  @override
  String get exceptionValueMustBeAPositiveIntegerNumber => 'El valor debe ser un número entero positivo.';
  @override
  String get exceptionValueMustBeAPositiveNumber => 'El valor debe ser un número positivo.';
  @override
  String exceptionValueOutOfRange(dynamic minValue, dynamic maxValue) => 'El valor debe estar en un rango de $minValue a $maxValue.';
  @override
  String exceptionTextLength(dynamic minLength, dynamic maxLength) => 'El texto debe tener al menos $minLength caracteres y $maxLength como máximo.';
  @override
  String exceptionTextMaxLength(dynamic maxLength) => 'El texto debe tener $maxLength caracteres como máximo.';
}
