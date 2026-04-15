import 'package:collection/collection.dart';
import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/9/24.
abstract class QuestionnaireMultiChoiceItemView
    extends QuestionnaireChoiceItemView {
  QuestionnaireMultiChoiceItemView({
    super.key,
    CustomValueController<List<QuestionnaireAnswerOption>>? controller,
    required super.item,
    super.isOpen = false,
    super.enableWhenController,
  }) : super(
         controller:
             controller ??
             CustomValueController<List<QuestionnaireAnswerOption>>(
               focusNode: FocusNode(),
             ),
       );
}

abstract class QuestionnaireMultiChoiceItemViewState<
  SF extends QuestionnaireMultiChoiceItemView
>
    extends QuestionnaireChoiceItemViewState<SF> {
  @override
  CustomValueController<List<QuestionnaireAnswerOption>> get controller =>
      super.controller
          as CustomValueController<List<QuestionnaireAnswerOption>>;
  @override
  void initState() {
    super.initState();
    if (controller.value.isEmpty) {
      List<QuestionnaireAnswerOption> initial = [];
      for (final value in item.initial ?? <QuestionnaireInitial>[]) {
        if (value.valueCoding != null) {
          final valueCode = value.valueCoding?.code?.value;
          initial.add(
            values.firstWhereOrNull(
                  (e) => e.valueCoding?.code?.value == valueCode,
                ) ??
                QuestionnaireAnswerOption(valueCoding: value.valueCoding!),
          );
        } else if (value.valueString != null) {
          initial.add(
            values.firstWhereOrNull(
                  (e) => e.valueString == value.valueString,
                ) ??
                QuestionnaireAnswerOption(valueString: value.valueString),
          );
        }
      }

      if (initial.isNotEmpty) {
        selectedValues.addAll(initial);
      }
    }
  }

  List<QuestionnaireAnswerOption> get selectedValues => controller.value ??= [];
  bool isSelected(QuestionnaireAnswerOption? value) =>
      selectedValues.contains(value);
  void onSelectedValuesChanged(
    bool? selected,
    QuestionnaireAnswerOption value,
  ) {
    if (selected == true) {
      selectedValues.add(value);
    } else {
      selectedValues.remove(value);
    }

    setState(() {
      controller.clearError(notify: true);
    });
  }

  @override
  QuestionnaireAnswerOption onOpenAnswerAdded(
    String value, {
    bool? hideKeyboard,
  }) {
    final answer = super.onOpenAnswerAdded(
      value,
      hideKeyboard: hideKeyboard ?? false,
    );
    onSelectedValuesChanged(true, answer);
    return answer;
  }
}
