import 'package:flutter/material.dart';
import 'package:fhir_questionnaire/src/item/base/questionnaire_text_field_item_view.dart';

/// Created by luis901101 on 3/5/24.
class QuestionnaireStringItemView extends QuestionnaireTextFieldItemView {
  QuestionnaireStringItemView(
      {super.key, super.controller, required super.item});

  @override
  State createState() => QuestionnaireStringItemViewState();
}

class QuestionnaireStringItemViewState
    extends QuestionnaireTextFieldItemViewState<QuestionnaireStringItemView> {}
