import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/9/24.
class QuestionnaireCheckBoxChoiceItemView
    extends QuestionnaireMultiChoiceItemView {
  QuestionnaireCheckBoxChoiceItemView(
      {super.key,
      super.controller,
      required super.item,
      super.isOpen,
      super.enableWhenController});

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
                contentPadding: EdgeInsets.zero,
                title: Text(valueNameResolver(entry)),
                value: isSelected(entry),
                onChanged: (selected) =>
                    onSelectedValuesChanged(selected, entry),
              ))
          .toList(),
    );
  }
}
