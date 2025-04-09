import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      '${item.extension_?.translation(Intl.defaultLocale) ?? item.title}',
      style: theme.textTheme.titleMedium,
    );
  }
}
