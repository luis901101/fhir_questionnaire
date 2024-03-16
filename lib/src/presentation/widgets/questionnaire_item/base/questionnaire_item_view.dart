import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:fhir_questionnaire/src/model/questionnaire_item_enable_when_controller.dart';
import 'package:fhir_questionnaire/src/presentation/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:fhir/r4.dart';

/// Created by luis901101 on 3/5/24.
abstract class QuestionnaireItemView extends StatefulWidget {
  final FieldController controller;
  final QuestionnaireItem item;
  final QuestionnaireItemEnableWhenController? enableWhenController;
  const QuestionnaireItemView(
      {super.key,
      required this.controller,
      required this.item,
      this.enableWhenController});
}

abstract class QuestionnaireItemViewState<SF extends QuestionnaireItemView>
    extends State<SF> with AutomaticKeepAliveClientMixin {
  bool isEnabled = true;
  String? lastControllerError;
  FieldController get controller => widget.controller;
  QuestionnaireItemEnableWhenController? get enableWhenController =>
      widget.enableWhenController;
  QuestionnaireItem get item => widget.item;

  bool get isRequired => item.required_?.value ?? false;
  bool get isReadOnly => item.readOnly?.value ?? false;
  int? get maxLength => item.maxLength?.value;
  @override
  bool get wantKeepAlive => false;

  bool get handleControllerErrorManually => true;

  @override
  void initState() {
    super.initState();
    if (handleControllerErrorManually) {
      controller.addListener(onControllerErrorChanged);
    }
    controller.validations.addAll([
      if (isRequired) ValidationUtils.requiredFieldValidation,
    ]);
    isEnabled =
        enableWhenController?.init(onEnabledChangedListener: onEnabled) ?? true;
  }

  void onControllerErrorChanged() {
    if (lastControllerError != controller.error) {
      lastControllerError = controller.error;
      setState(() {});
    } else if (lastControllerError.isNotEmpty && controller.isNotEmpty) {
      controller.clearError();
    }
  }

  void onEnabled(bool enabled) {
    if (isEnabled != enabled) {
      setState(() => isEnabled = enabled);
    }
  }

  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        height: isEnabled ? null : 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: buildBody(context),
        ),
      ),
    );
    // return Visibility(
    //     visible: isEnabled,
    //     child: Padding(
    //       padding: const EdgeInsets.only(bottom: 24.0),
    //       child: buildBody(context),
    //     ),
    // );
  }

  @override
  void dispose() {
    controller.removeListener(onControllerErrorChanged);
    enableWhenController?.dispose();
    super.dispose();
  }
}
