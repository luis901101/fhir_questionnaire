import 'package:collection/collection.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/20/24.
class QuestionnaireBooleanItemView extends QuestionnaireItemView {
  QuestionnaireBooleanItemView({
    super.key,
    CustomValueController<bool>? controller,
    required super.item,
    super.enableWhenController,
  }) : super(
            controller: controller ??
                CustomValueController<bool>(
                  focusNode: FocusNode(),
                ));

  @override
  State createState() => QuestionnaireBooleanItemViewState();
}

class QuestionnaireBooleanItemViewState
    extends QuestionnaireItemViewState<QuestionnaireBooleanItemView> {
  @override
  CustomValueController<bool> get controller =>
      super.controller as CustomValueController<bool>;
  bool get value => controller.value ??= false;
  set value(bool value) => controller.value = value;

  @override
  void initState() {
    super.initState();
    if (controller.value == null) {
      final initial = item.initial
              ?.firstWhereOrNull((item) => item.valueBoolean != null)
              ?.valueBoolean
              ?.value ??
          false;

      value = initial;
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged:
          isReadOnly ? null : (value) => setState(() => this.value = value),
      title: item.title.isEmpty ? null : Text(item.title!),
      contentPadding: const EdgeInsets.only(left: 8),
    );
  }
}
