import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_single_choice_item_view.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/9/24.
class QuestionnaireRadioButtonChoiceItemView
    extends QuestionnaireSingleChoiceItemView {
  QuestionnaireRadioButtonChoiceItemView(
      {super.key,
      super.controller,
      required super.item,
      super.isOpen,
      super.enableWhenController});

  @override
  State createState() => QuestionnaireRadioButtonChoiceItemViewState();
}

class QuestionnaireRadioButtonChoiceItemViewState
    extends QuestionnaireSingleChoiceItemViewState<
        QuestionnaireRadioButtonChoiceItemView> {
  @override
  Widget choiceView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values
          .map((entry) => RadioListTile<QuestionnaireAnswerOption>(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(valueNameResolver(entry)),
                value: entry,
                groupValue: selectedValue,
                onChanged: onSelectedValueChanged,
              ))
          .toList(),
    );
  }
}
