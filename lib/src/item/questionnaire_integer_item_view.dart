import 'package:flutter/material.dart';
import 'package:fhir_questionnaire/src/item/base/questionnaire_text_field_item_view.dart';
import 'package:fhir_questionnaire/src/utils/validation_utils.dart';

/// Created by luis901101 on 3/5/24.
class QuestionnaireIntegerItemView extends QuestionnaireTextFieldItemView {
  QuestionnaireIntegerItemView(
      {super.key, super.controller, required super.item});

  @override
  State createState() => QuestionnaireIntegerItemViewState();
}

class QuestionnaireIntegerItemViewState
    extends QuestionnaireTextFieldItemViewState<QuestionnaireIntegerItemView> {
  @override
  void initState() {
    super.initState();
    controller.validations.addAll(
        [ValidationUtils.positiveNumberValidation(required: isRequired)]);
  }

  @override
  TextInputType? get keyboardType =>
      const TextInputType.numberWithOptions(signed: false, decimal: false);
  @override
  TextCapitalization? get textCapitalization => TextCapitalization.none;
}
