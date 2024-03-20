import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_text_field_item_view.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/5/20.
class QuestionnaireUrlItemView extends QuestionnaireTextFieldItemView {
  QuestionnaireUrlItemView({
    super.key,
    super.controller,
    required super.item,
    super.enableWhenController,
  });

  @override
  State createState() => QuestionnaireUrlItemViewState();
}

class QuestionnaireUrlItemViewState
    extends QuestionnaireTextFieldItemViewState<QuestionnaireUrlItemView> {
  @override
  void initState() {
    super.initState();
    controller.validations.add(ValidationUtils.urlValidation());
  }

  @override
  TextInputType? get keyboardType => TextInputType.url;
  @override
  TextCapitalization? get textCapitalization => TextCapitalization.none;
  @override
  int? get maxLines => 1;
}
