import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_item_view.dart';
import 'package:flutter/material.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/custom_text_field.dart';
import 'package:fhir_questionnaire/src/logic/utils/questionnaire_item_utils.dart';
import 'package:fhir_questionnaire/src/utils/validation_utils.dart';
import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:collection/collection.dart';

/// Created by luis901101 on 3/5/24.
abstract class QuestionnaireTextFieldItemView extends QuestionnaireItemView {
  QuestionnaireTextFieldItemView(
      {super.key, CustomTextEditingController? controller, required super.item})
      : super(
            controller: controller ??
                CustomTextEditingController(
                  focusNode: FocusNode(),
                ));
}

abstract class QuestionnaireTextFieldItemViewState<
        SF extends QuestionnaireTextFieldItemView>
    extends QuestionnaireItemViewState<SF> {
  @override
  void initState() {
    super.initState();
    final initial = item.initial?.firstWhereOrNull((item) =>
        item.valueString.isNotEmpty ||
        item.valueInteger?.value != null ||
        item.valueDecimal?.value != null);
    final String? initialValue = (initial?.valueString ??
            initial?.valueInteger?.value ??
            initial?.valueDecimal?.value)
        ?.toString();

    if (initialValue.isNotEmpty) {
      (controller as CustomTextEditingController).text = initialValue!;
    }
    controller.validations.addAll([
      if (isRequired) ValidationUtils.requiredFieldValidation,
      if ((maxLength ?? 0) > 0)
        ValidationUtils.maxLengthValidation(maxLength: maxLength!),
    ]);
  }

  TextInputType? get keyboardType => TextInputType.text;
  TextInputAction? get textInputAction => TextInputAction.next;
  TextCapitalization? get textCapitalization => TextCapitalization.sentences;
  int? get maxLines => null;

  @override
  Widget build(BuildContext context) {
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
        CustomTextField(
          controller: controller as CustomTextEditingController,
          focusNode: controller.focusNode,
          enabled: !isReadOnly,
          maxLength: maxLength,
          maxLines: maxLines,
          textInputAction:
              (maxLines != null && maxLines! > 1) ? null : textInputAction,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
        ),
      ],
    );
  }
}
