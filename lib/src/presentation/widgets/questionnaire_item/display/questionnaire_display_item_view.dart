import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/21/24.
class QuestionnaireDisplayItemView extends QuestionnaireItemView {
  QuestionnaireDisplayItemView({
    super.key,
    required super.item,
    super.enableWhenController,
  }) : super(controller: DummyController());

  @override
  State createState() => QuestionnaireDisplayItemViewState();
}

class QuestionnaireDisplayItemViewState
    extends QuestionnaireItemViewState<QuestionnaireDisplayItemView> {
  @override
  bool get handleControllerErrorManually => false;
  @override
  Widget? buildTitleView(
    BuildContext context, {
    bool? forGroup,
    bool? noPadding,
    TextStyle? style,
  }) => null;
  @override
  Widget buildBody(BuildContext context) =>
      super.buildTitleView(
        context,
        noPadding: true,
        style: theme.textTheme.titleMedium,
      ) ??
      SizedBox();
}
