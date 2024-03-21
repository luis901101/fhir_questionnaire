import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_choice_item_view.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

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
      final initial =
          item.initial?.firstWhereOrNull((item) => item.valueCoding != null);

      if (initial?.valueCoding != null) {
        controller.value = QuestionnaireAnswerOption(
          valueCoding: initial?.valueCoding!,
        );
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
