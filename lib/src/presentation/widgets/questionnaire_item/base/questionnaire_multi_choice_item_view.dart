import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/logic/utils/coding_utils.dart';
import 'package:fhir_questionnaire/src/logic/utils/questionnaire_item_utils.dart';
import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_item_view.dart';
import 'package:fhir_questionnaire/src/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

/// Created by luis901101 on 3/9/24.
abstract class QuestionnaireMultiChoiceItemView extends QuestionnaireItemView {
  QuestionnaireMultiChoiceItemView(
      {super.key,
      CustomValueController<List<QuestionnaireAnswerOption>>? controller,
      required super.item})
      : super(
            controller: controller ??
                CustomValueController<List<QuestionnaireAnswerOption>>(
                  focusNode: FocusNode(),
                ));
}

abstract class QuestionnaireMultiChoiceItemViewState<
        SF extends QuestionnaireMultiChoiceItemView>
    extends QuestionnaireItemViewState<SF> {
  @override
  CustomValueController<List<QuestionnaireAnswerOption>> get controller =>
      super.controller
          as CustomValueController<List<QuestionnaireAnswerOption>>;
  String? lastControllerError;
  @override
  void initState() {
    super.initState();
    if (handleControllerErrorManually) {
      controller.addListener(onControllerErrorChanged);
    }
    final initial =
        item.initial?.firstWhereOrNull((item) => item.valueCoding != null);

    if (initial?.valueCoding != null) {
      selectedValues.add(QuestionnaireAnswerOption(
        valueCoding: initial?.valueCoding!,
      ));
    }
    controller.validations.addAll([
      if (isRequired) ValidationUtils.requiredFieldValidation,
    ]);
  }

  bool get handleControllerErrorManually => true;
  String valueNameResolver(QuestionnaireAnswerOption value) =>
      value.valueCoding?.title ?? '';
  List<QuestionnaireAnswerOption> get values => item.answerOption ?? [];
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

  void onControllerErrorChanged() {
    if (lastControllerError != controller.error) {
      lastControllerError = controller.error;
      setState(() {});
    } else if (lastControllerError.isNotEmpty && controller.isNotEmpty) {
      controller.clearError();
    }
  }

  Widget choiceView(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 4.0,
            ),
            child: Text(
              item.title!,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        choiceView(context),
        if (handleControllerErrorManually && controller.hasError)
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 4.0,
            ),
            child: Text(
              '${controller.error}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    controller.removeListener(onControllerErrorChanged);
    super.dispose();
  }
}
