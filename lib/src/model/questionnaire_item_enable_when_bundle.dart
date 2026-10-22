import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/src/logic/enumerator/questionnaire_enable_when_operator.dart';
import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:flutter/foundation.dart';

class QuestionnaireItemEnableWhenBundle {
  late final QuestionnaireEnableWhenOperator operator;
  final FieldController controller;
  final QuestionnaireEnableWhen expectedAnswer;

  /// Whether the item [controller] belongs to is itself enabled. A disabled
  /// item counts as not answered when this condition is evaluated, as the FHIR
  /// specification asks. Null means always enabled.
  final ValueGetter<bool>? isSourceEnabled;

  QuestionnaireItemEnableWhenBundle({
    required this.controller,
    required this.expectedAnswer,
    this.isSourceEnabled,
  }) {
    operator =
        QuestionnaireEnableWhenOperator.valueOf(
          expectedAnswer.operator_?.value,
        ) ??
        QuestionnaireEnableWhenOperator.exists;
  }
}
