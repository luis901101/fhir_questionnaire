import 'dart:ui';

import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_base_localization.dart';

/// Spanish localizations
class QuestionnaireEsLocalization extends QuestionnaireBaseLocalization {
  QuestionnaireEsLocalization() : super(const Locale('es', 'ES'));

  @override
  String get btnSubmit => 'Enviar';
  @override
  String get btnUpload => 'Cargar';
  @override
  String get btnChange => 'Cambiar';
  @override
  String get btnRemove => 'Quitar';
  @override
  String get textOtherOption => 'Optra opción';
  @override
  String get textDate => 'Fecha';
  @override
  String get textTime => 'Hora';
  @override
  String get exceptionNoEmptyField => 'Este campo es requerido.';
  @override
  String get exceptionValueMustBeAPositiveIntegerNumber =>
      'El valor debe ser un número entero positivo.';
  @override
  String get exceptionValueMustBeAPositiveNumber =>
      'El valor debe ser un número positivo.';
  @override
  String get exceptionInvalidUrl => 'Url inválida.';
  @override
  String exceptionValueOutOfRange(dynamic minValue, dynamic maxValue) =>
      'El valor debe estar en un rango de $minValue a $maxValue.';
  @override
  String exceptionTextLength(dynamic minLength, dynamic maxLength) =>
      'El texto debe tener al menos $minLength caracteres y $maxLength como máximo.';
  @override
  String exceptionTextMaxLength(dynamic maxLength) =>
      'El texto debe tener $maxLength caracteres como máximo.';
}
