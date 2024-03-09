import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_text_field_item_view.dart';
import 'package:flutter/material.dart';

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
