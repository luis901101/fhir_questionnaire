import 'package:fhir_questionnaire/src/logic/utils/coding_utils.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_multi_choice_item_view.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/9/24.
class QuestionnaireCheckBoxChoiceItemView
    extends QuestionnaireMultiChoiceItemView {
  QuestionnaireCheckBoxChoiceItemView(
      {super.key, super.controller, required super.item});

  @override
  State createState() => QuestionnaireCheckBoxChoiceItemViewState();
}

class QuestionnaireCheckBoxChoiceItemViewState
    extends QuestionnaireMultiChoiceItemViewState<
        QuestionnaireCheckBoxChoiceItemView> {
  @override
  Widget choiceView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values
          .map((entry) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('${entry.valueCoding?.title}'),
                value: isSelected(entry),
                onChanged: (selected) =>
                    onSelectedValuesChanged(selected, entry),
              ))
          .toList(),
    );
  }
}
