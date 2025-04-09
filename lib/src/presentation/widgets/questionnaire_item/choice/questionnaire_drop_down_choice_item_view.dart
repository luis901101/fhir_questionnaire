import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/9/24.
class QuestionnaireDropDownChoiceItemView
    extends QuestionnaireSingleChoiceItemView {
  QuestionnaireDropDownChoiceItemView(
      {super.key,
      super.controller,
      required super.item,
      super.isOpen,
      super.enableWhenController});

  @override
  State createState() => QuestionnaireDropDownChoiceItemViewState();
}

class QuestionnaireDropDownChoiceItemViewState
    extends QuestionnaireSingleChoiceItemViewState<
        QuestionnaireDropDownChoiceItemView> {
  @override
  bool get handleControllerErrorManually => false;
  @override
  Widget choiceView(BuildContext context) {
    return CustomDropDownButtonFormField.buildDropDown<
        QuestionnaireAnswerOption>(
      controller: controller,
      values: values,
      onChanged: onSelectedValueChanged,
      nameResolver: (answer) => answer.title ?? '',
    );
  }
}
