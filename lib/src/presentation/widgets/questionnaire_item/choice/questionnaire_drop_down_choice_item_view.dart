import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/custom_drop_down_button_form_field.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_choice_item_view.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/9/24.
class QuestionnaireDropDownChoiceItemView extends QuestionnaireChoiceItemView {
  QuestionnaireDropDownChoiceItemView(
      {super.key, super.controller, required super.item});

  @override
  State createState() => QuestionnaireDropDownChoiceItemViewState();
}

class QuestionnaireDropDownChoiceItemViewState
    extends QuestionnaireChoiceItemViewState<
        QuestionnaireDropDownChoiceItemView> {
  @override
  bool get handleControllerErrorManually => false;
  @override
  Widget choiceView(BuildContext context) {
    return CustomDropDownButtonFormField.buildDropDown<
        QuestionnaireAnswerOption>(
      controller: controller,
      values: values,
      nameResolver: valueNameResolver,
    );
  }
}
