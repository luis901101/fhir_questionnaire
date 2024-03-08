import 'package:flutter/material.dart';
import 'package:fhir_questionnaire/src/item/base/questionnaire_text_field_item_view.dart';

/// Created by luis901101 on 3/5/24.
class QuestionnaireTextItemView extends QuestionnaireTextFieldItemView {
  QuestionnaireTextItemView({super.key, super.controller, required super.item});

  @override
  State createState() => QuestionnaireTextItemViewState();
}

class QuestionnaireTextItemViewState
    extends QuestionnaireTextFieldItemViewState<QuestionnaireTextItemView> {
  @override
  TextInputType? get keyboardType => TextInputType.multiline;
  @override
  TextCapitalization? get textCapitalization => TextCapitalization.sentences;
  @override
  int? get maxLines => 5;
}
