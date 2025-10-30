import 'package:collection/collection.dart';

/// Docs: https://hl7.org/fhir/R4/valueset-questionnaire-enable-operator.html
enum QuestionnaireEnableWhenOperator {
  /// True if whether an answer exists is equal to the enableWhen answer (which must be a boolean).
  exists('exists'),

  /// True if whether at least one answer has a value that is equal to the enableWhen answer.
  equals('='),

  /// True if whether at least no answer has a value that is equal to the enableWhen answer.
  notEquals('!='),

  /// True if whether at least no answer has a value that is greater than the enableWhen answer.
  greaterThan('>'),

  /// True if whether at least no answer has a value that is less than the enableWhen answer.
  lessThan('<'),

  /// True if whether at least no answer has a value that is greater or equal to the enableWhen answer.
  greaterOrEquals('>='),

  /// True if whether at least no answer has a value that is less or equal to the enableWhen answer.
  lessOrEquals('<=');

  final String operator;
  const QuestionnaireEnableWhenOperator(this.operator);

  static QuestionnaireEnableWhenOperator? valueOf(String? operator) =>
      QuestionnaireEnableWhenOperator.values.firstWhereOrNull(
        (value) => value.operator == operator,
      );
}
