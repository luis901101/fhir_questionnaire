import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_text_field_item_view.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/5/24.
class QuestionnaireStringItemView extends QuestionnaireTextFieldItemView {
  QuestionnaireStringItemView(
      {super.key, super.controller, required super.item});

  @override
  State createState() => QuestionnaireStringItemViewState();
}

class QuestionnaireStringItemViewState
    extends QuestionnaireTextFieldItemViewState<QuestionnaireStringItemView> {}
