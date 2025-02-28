import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/9/24.
abstract class QuestionnaireChoiceItemView extends QuestionnaireItemView {
  final bool isOpen;
  QuestionnaireChoiceItemView({
    super.key,
    CustomValueController? controller,
    required super.item,
    super.enableWhenController,
    this.isOpen = false,
  }) : super(
            controller: controller ??
                CustomValueController(
                  focusNode: FocusNode(),
                ));
}

abstract class QuestionnaireChoiceItemViewState<
        SF extends QuestionnaireChoiceItemView>
    extends QuestionnaireItemViewState<SF> {
  @override
  CustomValueController get controller =>
      super.controller as CustomValueController;
  final List<QuestionnaireAnswerOption> values = [];
  @override
  void initState() {
    super.initState();
    values.addAll(item.answerOption ?? []);
  }

  @override
  bool get wantKeepAlive => isOpen;

  bool get isOpen => widget.isOpen;
  String valueNameResolver(QuestionnaireAnswerOption value) =>
      value.valueCoding?.title(context) ??
      value.valueStringLocalized(context) ??
      value.valueInteger?.toString() ??
      '';

  QuestionnaireAnswerOption onOpenAnswerAdded(String value,
      {bool? hideKeyboard}) {
    hideKeyboard ??= true;
    final answer = QuestionnaireAnswerOption(valueString: value);
    values.add(answer);
    if (hideKeyboard) {
      InputMethodUtils.hideInputMethod(force: true);
    }
    controller.clearError();
    return answer;
  }

  Widget choiceView(BuildContext context);

  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.title(context).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 4.0,
            ),
            child: Text(
              item.title(context)!,
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
        if (isOpen) ...[
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 4.0,
            ),
            child: Text(
              QuestionnaireLocalization
                  .of(context).localization.textOtherOption,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          CustomTextField(
            focusNode: controller.focusNode,
            enabled: !isReadOnly,
            maxLength: maxLength,
            customButtonIcon: Icons.add,
            customButtonColor: theme.colorScheme.primary,
            customButtonAction: (controller) {
              if (controller.isNotEmpty) {
                onOpenAnswerAdded(controller.text);
                controller.clear();
                setState(() {});
              }
            },
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
          ),
        ]
      ],
    );
  }
}
