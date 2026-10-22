import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:material_ui/material_ui.dart';

/// Created by luis901101 on 3/9/24.
abstract class QuestionnaireChoiceItemView extends QuestionnaireItemView {
  final bool isOpen;
  QuestionnaireChoiceItemView({
    super.key,
    CustomValueController? controller,
    required super.item,
    super.enableWhenController,
    super.children,
    this.isOpen = false,
  }) : super(
         controller:
             controller ??
             QuestionnaireChoiceController(
               focusNode: FocusNode(),
               options: [...?item.answerOption],
             ),
       );

  /// The options the item offers: the ones its [QuestionnaireChoiceController]
  /// holds, or the item's `answerOption`s for any other controller.
  List<QuestionnaireAnswerOption> get choiceOptions {
    final controller = this.controller;
    return controller is QuestionnaireChoiceController
        ? controller.options
        : (item.answerOption ?? []);
  }
}

abstract class QuestionnaireChoiceItemViewState<
  SF extends QuestionnaireChoiceItemView
>
    extends QuestionnaireItemViewState<SF> {
  @override
  CustomValueController get controller =>
      super.controller as CustomValueController;

  List<QuestionnaireAnswerOption>? _localValues;

  /// The options shown. With a [QuestionnaireChoiceController] they are the
  /// controller's own list, so options added here or from code are shared.
  List<QuestionnaireAnswerOption> get values {
    final controller = this.controller;
    return controller is QuestionnaireChoiceController
        ? controller.options
        : (_localValues ??= [...?item.answerOption]);
  }

  @override
  bool get wantKeepAlive => isOpen;

  bool get isOpen => widget.isOpen;
  String valueNameResolver(QuestionnaireAnswerOption value) =>
      value.title ?? '';

  QuestionnaireAnswerOption onOpenAnswerAdded(
    String value, {
    bool? hideKeyboard,
  }) {
    hideKeyboard ??= true;
    final controller = this.controller;
    QuestionnaireAnswerOption newAnwser;
    if (controller is QuestionnaireChoiceController) {
      newAnwser = controller.optionForText(value);
    } else {
      final existingAnswer = values
          .where((answer) => answer.valueString == value)
          .firstOrNull;
      if (existingAnswer == null) {
        newAnwser = QuestionnaireAnswerOption(valueString: value);
        values.add(newAnwser);
      } else {
        newAnwser = existingAnswer;
      }
    }

    if (hideKeyboard) {
      InputMethodUtils.hideInputMethod(force: true);
    }
    controller.clearError();
    return newAnwser;
  }

  Widget choiceView(BuildContext context);

  @override
  Widget? buildErrorManuallyView(BuildContext context) => null;

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        choiceView(context),
        ?super.buildErrorManuallyView(context),
        if (isOpen) ...[
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              QuestionnaireLocalization.instance.localization.textOtherOption,
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
        ],
      ],
    );
  }
}
