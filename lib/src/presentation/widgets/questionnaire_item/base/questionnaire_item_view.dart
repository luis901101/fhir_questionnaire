import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:fhir_questionnaire/src/presentation/utils/validation_utils.dart';
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
  String? lastControllerError;
  FieldController get controller => widget.controller;
  QuestionnaireItem get item => widget.item;

  bool get isRequired => item.required_?.value ?? false;
  bool get isReadOnly => item.readOnly?.value ?? false;
  int? get maxLength => item.maxLength?.value;
  @override
  bool get wantKeepAlive => false;

  bool get handleControllerErrorManually => true;

  void onControllerErrorChanged() {
    if (lastControllerError != controller.error) {
      lastControllerError = controller.error;
      setState(() {});
    } else if (lastControllerError.isNotEmpty && controller.isNotEmpty) {
      controller.clearError();
    }
  }

  @override
  void initState() {
    super.initState();
    if (handleControllerErrorManually) {
      controller.addListener(onControllerErrorChanged);
    }
    controller.validations.addAll([
      if (isRequired) ValidationUtils.requiredFieldValidation,
    ]);
  }

  @override
  void dispose() {
    controller.removeListener(onControllerErrorChanged);
    super.dispose();
  }
}
