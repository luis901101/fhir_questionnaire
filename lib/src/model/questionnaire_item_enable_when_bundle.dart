import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire/src/logic/enumerator/questionnaire_enable_when_operator.dart';
import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';

class QuestionnaireItemEnableWhenBundle {
  late final QuestionnaireEnableWhenOperator operator;
  final FieldController controller;
  final QuestionnaireEnableWhen expectedAnswer;
  QuestionnaireItemEnableWhenBundle({
    required this.controller,
    required this.expectedAnswer,
  }) {
    operator = QuestionnaireEnableWhenOperator.valueOf(
            expectedAnswer.operator_.valueString) ??
        QuestionnaireEnableWhenOperator.exists;
  }
}
