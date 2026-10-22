import 'package:collection/collection.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:material_ui/material_ui.dart';

/// Created by luis901101 on 3/5/24.
abstract class QuestionnaireTextFieldItemView extends QuestionnaireItemView {
  QuestionnaireTextFieldItemView({
    super.key,
    CustomTextEditingController? controller,
    required super.item,
    super.enableWhenController,
    super.children,
  }) : super(
         controller:
             controller ?? CustomTextEditingController(focusNode: FocusNode()),
       );

  @override
  void applyInitialValue() {
    final controller = this.controller as CustomTextEditingController;
    if (controller.text.isNotEmpty) return;
    final initial = item.initial?.firstWhereOrNull(
      (item) =>
          item.valueString.isNotEmpty ||
          TextUtils.isNotEmpty(item.valueUri?.value?.toString()) ||
          item.valueInteger?.value != null ||
          item.valueDecimal?.value != null,
    );
    final String? initialValue =
        (initial?.valueString ??
                initial?.valueUri?.value?.toString() ??
                initial?.valueInteger?.value ??
                initial?.valueDecimal?.value)
            ?.toString();

    if (initialValue.isNotEmpty) {
      controller.text = initialValue!;
    }
  }
}

abstract class QuestionnaireTextFieldItemViewState<
  SF extends QuestionnaireTextFieldItemView
>
    extends QuestionnaireItemViewState<SF> {
  @override
  CustomTextEditingController get controller =>
      super.controller as CustomTextEditingController;

  TextInputType? get keyboardType => TextInputType.text;
  TextInputAction? get textInputAction => TextInputAction.next;
  TextCapitalization? get textCapitalization => TextCapitalization.sentences;
  int? get maxLines => null;

  @override
  bool get handleControllerErrorManually => false;

  @override
  Widget? buildHintTextView(BuildContext context) => null;
  @override
  Widget? buildHelperTextView(BuildContext context) => null;

  @override
  Widget buildBody(BuildContext context) {
    return CustomTextField(
      controller: controller,
      focusNode: controller.focusNode,
      enabled: !isReadOnly,
      maxLength: maxLength,
      maxLines: maxLines,
      textInputAction: (maxLines != null && maxLines! > 1)
          ? null
          : textInputAction,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hintText,
        helperText: helperTextAsButton ? null : helperText,
        helperMaxLines: 10,
      ),
    );
  }
}
