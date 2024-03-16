import 'package:collection/collection.dart';

/// Docs: https://hl7.org/fhir/R4/valueset-questionnaire-enable-behavior.html
enum QuestionnaireEnableWhenBehavior {
  /// Enable the question when all the enableWhen criteria are satisfied.
  all,

  /// Enable the question when any of the enableWhen criteria are satisfied.
  any,
  ;

  static const defaultValue = any;

  bool get isAny => this == any;

  bool init() => this == all;
  bool check(bool currentValue, bool newValue) =>
      isAny ? currentValue || newValue : currentValue && newValue;

  static QuestionnaireEnableWhenBehavior? valueOf(String? name) =>
      QuestionnaireEnableWhenBehavior.values
          .firstWhereOrNull((value) => value.name == name);
}
