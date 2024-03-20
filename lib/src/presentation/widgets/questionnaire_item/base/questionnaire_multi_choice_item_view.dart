import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_questionnaire/src/logic/utils/iterable_utils.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_choice_item_view.dart';
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
            controller: controller ??
                CustomValueController<List<QuestionnaireAnswerOption>>(
                  focusNode: FocusNode(),
                ));
}

abstract class QuestionnaireMultiChoiceItemViewState<
        SF extends QuestionnaireMultiChoiceItemView>
    extends QuestionnaireChoiceItemViewState<SF> {
  @override
  CustomValueController<List<QuestionnaireAnswerOption>> get controller =>
      super.controller
          as CustomValueController<List<QuestionnaireAnswerOption>>;
  @override
  void initState() {
    super.initState();
    if (controller.value.isEmpty) {
      final initial =
          item.initial?.firstWhereOrNull((item) => item.valueCoding != null);

      if (initial?.valueCoding != null) {
        selectedValues.add(QuestionnaireAnswerOption(
          valueCoding: initial?.valueCoding!,
        ));
      }
    }
  }

  List<QuestionnaireAnswerOption> get selectedValues => controller.value ??= [];
  bool isSelected(QuestionnaireAnswerOption? value) =>
      selectedValues.contains(value);
  void onSelectedValuesChanged(
      bool? selected, QuestionnaireAnswerOption value) {
    if (selected == true) {
      selectedValues.add(value);
    } else {
      selectedValues.remove(value);
    }
    setState(() {});
  }

  @override
  QuestionnaireAnswerOption onOpenAnswerAdded(String value,
      {bool? hideKeyboard}) {
    final answer =
        super.onOpenAnswerAdded(value, hideKeyboard: hideKeyboard ?? false);
    onSelectedValuesChanged(true, answer);
    return answer;
  }
}
