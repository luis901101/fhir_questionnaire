import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/logic/utils/coding_utils.dart';
import 'package:fhir_questionnaire/src/logic/utils/questionnaire_item_utils.dart';
import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_item_view.dart';
import 'package:fhir_questionnaire/src/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

/// Created by luis901101 on 3/9/24.
abstract class QuestionnaireSingleChoiceItemView extends QuestionnaireItemView {
  QuestionnaireSingleChoiceItemView(
      {super.key,
      CustomValueController<QuestionnaireAnswerOption>? controller,
      required super.item})
      : super(
            controller: controller ??
                CustomValueController<QuestionnaireAnswerOption>(
                  focusNode: FocusNode(),
                ));
}

abstract class QuestionnaireSingleChoiceItemViewState<
        SF extends QuestionnaireSingleChoiceItemView>
    extends QuestionnaireItemViewState<SF> {
  @override
  CustomValueController<QuestionnaireAnswerOption> get controller =>
      super.controller as CustomValueController<QuestionnaireAnswerOption>;
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
      controller.value = QuestionnaireAnswerOption(
        valueCoding: initial?.valueCoding!,
      );
    }
    controller.validations.addAll([
      if (isRequired) ValidationUtils.requiredFieldValidation,
    ]);
  }

  bool get handleControllerErrorManually => true;
  String valueNameResolver(QuestionnaireAnswerOption value) =>
      value.valueCoding?.title ?? '';
  List<QuestionnaireAnswerOption> get values => item.answerOption ?? [];
  String? get selectedValueCode => selectedValue?.valueCoding?.code?.value;
  QuestionnaireAnswerOption? get selectedValue => controller.value;
  set selectedValue(QuestionnaireAnswerOption? value) =>
      controller.value = value;
  void onSelectedValueChanged(QuestionnaireAnswerOption? value) {
    setState(() {
      selectedValue = value;
    });
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
