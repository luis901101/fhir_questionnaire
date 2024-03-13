import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:fhir/r4.dart';

/// Created by luis901101 on 3/5/24.
abstract class QuestionnaireItemView extends StatefulWidget {
  final FieldController controller;
  final QuestionnaireItem item;
  const QuestionnaireItemView(
      {super.key, required this.controller, required this.item});
}

abstract class QuestionnaireItemViewState<SF extends QuestionnaireItemView>
    extends State<SF> with AutomaticKeepAliveClientMixin {
  FieldController get controller => widget.controller;
  QuestionnaireItem get item => widget.item;

  bool get isRequired => item.required_?.value ?? false;
  bool get isReadOnly => item.readOnly?.value ?? false;
  int? get maxLength => item.maxLength?.value;

  @override
  bool get wantKeepAlive => false;
}
