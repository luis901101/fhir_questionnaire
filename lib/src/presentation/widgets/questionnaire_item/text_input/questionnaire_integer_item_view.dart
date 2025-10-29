import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_text_field_item_view.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/5/24.
class QuestionnaireIntegerItemView extends QuestionnaireTextFieldItemView {
  QuestionnaireIntegerItemView(
      {super.key,
      super.controller,
      required super.item,
      super.enableWhenController});

  @override
  State createState() => QuestionnaireIntegerItemViewState();
}

class QuestionnaireIntegerItemViewState
    extends QuestionnaireTextFieldItemViewState<QuestionnaireIntegerItemView> {
  @override

  @override
  TextInputType? get keyboardType =>
      const TextInputType.numberWithOptions(signed: false, decimal: false);
  @override
  TextCapitalization? get textCapitalization => TextCapitalization.none;
}
