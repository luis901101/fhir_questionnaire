import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/custom_drop_down_button_form_field.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_single_choice_item_view.dart';
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
      nameResolver: valueNameResolver,
    );
  }
}
