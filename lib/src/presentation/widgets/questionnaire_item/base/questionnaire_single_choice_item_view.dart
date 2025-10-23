import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/9/24.
abstract class QuestionnaireSingleChoiceItemView
    extends QuestionnaireChoiceItemView {
  QuestionnaireSingleChoiceItemView({
    super.key,
    CustomValueController<QuestionnaireAnswerOption>? controller,
    required super.item,
    super.isOpen = false,
    super.enableWhenController,
  }) : super(
            controller: controller ??
                CustomValueController<QuestionnaireAnswerOption>(
                  focusNode: FocusNode(),
                ));
}

abstract class QuestionnaireSingleChoiceItemViewState<
        SF extends QuestionnaireSingleChoiceItemView>
    extends QuestionnaireChoiceItemViewState<SF> {
  @override
  CustomValueController<QuestionnaireAnswerOption> get controller =>
      super.controller as CustomValueController<QuestionnaireAnswerOption>;

  @override
  void initState() {
    super.initState();
    if (controller.value == null) {
      QuestionnaireAnswerOption? initial;
      for (final value in item.initial ?? <QuestionnaireInitial>[]) {
        if (value.valueCoding != null) {
          initial = QuestionnaireAnswerOption(
            valueCoding: value.valueCoding!,
          );
          break;
        } else if (value.valueString != null) {
          initial = QuestionnaireAnswerOption(
            valueString: value.valueString,
          );
          break;
        }
      }

      if (initial != null) {
        controller.value = initial;
      }
    }
  }

  String? get selectedValueCode => selectedValue?.valueCoding?.code?.value;
  QuestionnaireAnswerOption? get selectedValue => controller.value;
  set selectedValue(QuestionnaireAnswerOption? value) =>
      controller.value = value;
  void onSelectedValueChanged(QuestionnaireAnswerOption? value) {
    setState(() {
      controller.clearError();
      selectedValue = value;
    });
  }

  @override
  QuestionnaireAnswerOption onOpenAnswerAdded(String value,
      {bool? hideKeyboard}) {
    final answer = super.onOpenAnswerAdded(value, hideKeyboard: hideKeyboard);
    selectedValue = answer;
    return answer;
  }
}
