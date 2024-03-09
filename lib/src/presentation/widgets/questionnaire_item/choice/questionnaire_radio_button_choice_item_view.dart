import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/logic/utils/coding_utils.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_choice_item_view.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/9/24.
class QuestionnaireRadioButtonChoiceItemView
    extends QuestionnaireChoiceItemView {
  QuestionnaireRadioButtonChoiceItemView(
      {super.key, super.controller, required super.item});

  @override
  State createState() => QuestionnaireRadioButtonChoiceItemViewState();
}

class QuestionnaireRadioButtonChoiceItemViewState
    extends QuestionnaireChoiceItemViewState<
        QuestionnaireRadioButtonChoiceItemView> {
  @override
  Widget choiceView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values
          .map((entry) => RadioListTile<QuestionnaireAnswerOption>(
                title: Text('${entry.valueCoding?.title}'),
                value: entry,
                groupValue: selectedValue,
                onChanged: onSelectedValueChanged,
              ))
          .toList(),
    );
  }
}
