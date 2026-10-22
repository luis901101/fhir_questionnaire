import 'package:collection/collection.dart';
import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:material_ui/material_ui.dart';

/// Created by luis901101 on 3/9/24.
abstract class QuestionnaireSingleChoiceItemView
    extends QuestionnaireChoiceItemView {
  QuestionnaireSingleChoiceItemView({
    super.key,
    CustomValueController<QuestionnaireAnswerOption>? controller,
    required super.item,
    super.isOpen = false,
    super.enableWhenController,
    super.children,
  }) : super(
         controller:
             controller ??
             QuestionnaireChoiceController<QuestionnaireAnswerOption>(
               focusNode: FocusNode(),
               options: [...?item.answerOption],
             ),
       );

  @override
  void applyInitialValue() {
    final controller =
        this.controller as CustomValueController<QuestionnaireAnswerOption>;
    if (controller.value != null) return;
    final values = choiceOptions;
    QuestionnaireAnswerOption? initial;
    for (final value in item.initial ?? <QuestionnaireInitial>[]) {
      if (value.valueCoding != null) {
        final valueCode = value.valueCoding?.code?.value;
        initial =
            values.firstWhereOrNull(
              (e) => e.valueCoding?.code?.value == valueCode,
            ) ??
            QuestionnaireAnswerOption(valueCoding: value.valueCoding!);
        break;
      } else if (value.valueString != null) {
        initial =
            values.firstWhereOrNull(
              (e) => e.valueString == value.valueString,
            ) ??
            QuestionnaireAnswerOption(valueString: value.valueString);
        break;
      }
    }

    if (initial != null) {
      controller.value = initial;
    }
  }
}

abstract class QuestionnaireSingleChoiceItemViewState<
  SF extends QuestionnaireSingleChoiceItemView
>
    extends QuestionnaireChoiceItemViewState<SF> {
  @override
  CustomValueController<QuestionnaireAnswerOption> get controller =>
      super.controller as CustomValueController<QuestionnaireAnswerOption>;

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
  QuestionnaireAnswerOption onOpenAnswerAdded(
    String value, {
    bool? hideKeyboard,
  }) {
    final answer = super.onOpenAnswerAdded(value, hideKeyboard: hideKeyboard);
    selectedValue = answer;
    return answer;
  }
}
