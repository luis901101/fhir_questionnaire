import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_text_field_item_view.dart';
import 'package:fhir_questionnaire/src/utils/validation_utils.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/5/24.
class QuestionnaireDecimalItemView extends QuestionnaireTextFieldItemView {
  QuestionnaireDecimalItemView(
      {super.key, super.controller, required super.item});

  @override
  State createState() => QuestionnaireDecimalItemViewState();
}

class QuestionnaireDecimalItemViewState
    extends QuestionnaireTextFieldItemViewState<QuestionnaireDecimalItemView> {
  @override
  void initState() {
    super.initState();
    controller.validations.addAll(
        [ValidationUtils.positiveNumberValidation(required: isRequired)]);
  }

  @override
  TextInputType? get keyboardType =>
      const TextInputType.numberWithOptions(signed: false, decimal: true);
  @override
  TextCapitalization? get textCapitalization => TextCapitalization.none;
}
