import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_questionnaire/src/logic/enumerator/questionnaire_enable_when%20_operator.dart';
import 'package:fhir_questionnaire/src/logic/enumerator/questionnaire_enable_when_behavior.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/model/questionnaire_item_enable_when_bundle.dart';
import 'package:flutter/cupertino.dart';

class QuestionnaireItemEnableWhenController {
  late final List<QuestionnaireItemEnableWhenBundle> _enableWhenBundleList;
  late final QuestionnaireEnableWhenBehavior _behavior;
  ValueChanged<bool>? _onEnabledChanged;

  QuestionnaireItemEnableWhenController({
    required List<QuestionnaireItemEnableWhenBundle>? enableWhenBundleList,
    required FhirCode? behavior,
  })  : _enableWhenBundleList = enableWhenBundleList ?? [],
        _behavior = QuestionnaireEnableWhenBehavior.valueOf(behavior?.value) ??
            QuestionnaireEnableWhenBehavior.defaultValue;

  bool init({required ValueChanged<bool> onEnabledChangedListener}) {
    _onEnabledChanged = onEnabledChangedListener;
    _addListeners();
    return _checkIfEnabled();
  }

  void dispose() {
    _onEnabledChanged = null;
    _removeListeners();
  }

  void _onControllerChange() {
    _checkIfEnabled();
  }

  bool _checkIfEnabled() {
    bool enabled = _behavior.init();
    for (final enableWhenBundle in _enableWhenBundleList) {
      final controller = enableWhenBundle.controller;
      dynamic expectedValue = enableWhenBundle.expectedAnswer.answerString ??
          enableWhenBundle.expectedAnswer.answerInteger?.value ??
          enableWhenBundle.expectedAnswer.answerDecimal?.value ??
          enableWhenBundle.expectedAnswer.answerBoolean?.value ??
          enableWhenBundle.expectedAnswer.answerQuantity?.value?.value ??
          enableWhenBundle.expectedAnswer.answerTime?.asDateTime ??
          enableWhenBundle.expectedAnswer.answerDate?.asDateTime ??
          enableWhenBundle.expectedAnswer.answerDateTime?.asDateTime ??
          enableWhenBundle.expectedAnswer.answerCoding?.code?.value;
      dynamic controllerValue;
      if (controller.rawValue is QuestionnaireAnswerOption) {
        final answerOption = controller.rawValue as QuestionnaireAnswerOption;
        controllerValue = answerOption.valueString ??
            answerOption.valueInteger?.value ??
            answerOption.valueTime?.asDateTime ??
            answerOption.valueDate?.asDateTime ??
            answerOption.valueCoding?.code?.value;
      } else {
        // Any other possible controller value can be treated as dynamic
        controllerValue = controller.rawValue;
      }

      num? controllerValueAsNum =
          NumUtils.tryParse(controllerValue?.toString());
      num? expectedValueAsNum = NumUtils.tryParse(expectedValue?.toString());

      if (controllerValue == null && expectedValue == null) {
        continue;
      }

      switch (enableWhenBundle.operator) {
        case QuestionnaireEnableWhenOperator.exists:
          final bool existAnswer =
              enableWhenBundle.expectedAnswer.answerBoolean?.value ?? false;
          enabled = _behavior.check(
              enabled,
              (TextUtils.isNotEmpty(controller.rawValue?.toString()) &&
                      existAnswer) ||
                  (TextUtils.isEmpty(controller.rawValue?.toString()) &&
                      !existAnswer));
          break;
        case QuestionnaireEnableWhenOperator.equals:
          enabled = _behavior.check(enabled,
              controllerValue?.toString() == expectedValue?.toString());
          break;
        case QuestionnaireEnableWhenOperator.notEquals:
          enabled = _behavior.check(enabled,
              controllerValue?.toString() != expectedValue?.toString());
          break;
        case QuestionnaireEnableWhenOperator.greaterThan:
          enabled = _behavior.check(
              enabled,
              controllerValueAsNum != null &&
                  expectedValueAsNum != null &&
                  controllerValueAsNum > expectedValueAsNum);
          break;
        case QuestionnaireEnableWhenOperator.lessThan:
          enabled = _behavior.check(
              enabled,
              controllerValueAsNum != null &&
                  expectedValueAsNum != null &&
                  controllerValueAsNum < expectedValueAsNum);
          break;
        case QuestionnaireEnableWhenOperator.greaterOrEquals:
          enabled = _behavior.check(
              enabled,
              controllerValueAsNum != null &&
                  expectedValueAsNum != null &&
                  controllerValueAsNum >= expectedValueAsNum);
          break;
        case QuestionnaireEnableWhenOperator.lessOrEquals:
          enabled = _behavior.check(
              enabled,
              controllerValueAsNum != null &&
                  expectedValueAsNum != null &&
                  controllerValueAsNum <= expectedValueAsNum);
          break;
      }
      if (enabled && _behavior.isAny) {
        break;
      }
    }
    _onEnabledChanged?.call(enabled);
    return enabled;
  }

  void _addListeners() {
    for (final enableWhenBundle in _enableWhenBundleList) {
      enableWhenBundle.controller.addListener(_onControllerChange);
    }
  }

  void _removeListeners() {
    for (final enableWhenBundle in _enableWhenBundleList) {
      enableWhenBundle.controller.removeListener(_onControllerChange);
    }
  }
}
