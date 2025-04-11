import 'package:collection/collection.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/cupertino.dart';

class QuestionnaireItemEnableWhenController {
  late final List<QuestionnaireItemEnableWhenBundle> _enableWhenBundleList;
  late final QuestionnaireEnableWhenBehavior _behavior;
  ValueChanged<bool>? _onEnabledChanged;

  QuestionnaireItemEnableWhenController({
    required List<QuestionnaireItemEnableWhenBundle>? enableWhenBundleList,
    required FhirCode? behavior,
  })  : _enableWhenBundleList = enableWhenBundleList ?? [],
        _behavior =
            QuestionnaireEnableWhenBehavior.valueOf(behavior?.valueString) ??
                QuestionnaireEnableWhenBehavior.defaultValue;

  bool init({required ValueChanged<bool> onEnabledChangedListener}) {
    _onEnabledChanged = onEnabledChangedListener;
    _addListeners();
    return checkIfEnabled();
  }

  void dispose() {
    _onEnabledChanged = null;
    _removeListeners();
  }

  void _onControllerChange() {
    checkIfEnabled();
  }

  bool checkIfEnabled({bool notify = true}) {
    bool enabled = _behavior.init();
    for (final enableWhenBundle in _enableWhenBundleList) {
      final controller = enableWhenBundle.controller;
      dynamic expectedValue = enableWhenBundle.expectedAnswer.answerString ??
          enableWhenBundle.expectedAnswer.answerInteger?.valueInt ??
          enableWhenBundle.expectedAnswer.answerDecimal?.valueDouble ??
          enableWhenBundle.expectedAnswer.answerBoolean?.valueBoolean ??
          enableWhenBundle.expectedAnswer.answerQuantity?.value?.valueDouble ??
          enableWhenBundle.expectedAnswer.answerTime?.asDateTime ??
          enableWhenBundle.expectedAnswer.answerDate?.valueDateTime ??
          enableWhenBundle.expectedAnswer.answerDateTime?.valueDateTime ??
          enableWhenBundle.expectedAnswer.answerCoding?.code?.valueString;
      List<dynamic> controllerValues = [];
      if (controller.rawValue is QuestionnaireAnswerOption) {
        final answerOption = controller.rawValue as QuestionnaireAnswerOption;
        final controllerValueOption = answerOption.valueString ??
            answerOption.valueInteger?.valueInt ??
            answerOption.valueTime?.asDateTime ??
            answerOption.valueDate?.valueDateTime ??
            answerOption.valueCoding?.code?.valueString;
        if (controllerValueOption != null) {
          controllerValues = [controllerValueOption];
        }
      } else if (controller.rawValue is List<QuestionnaireAnswerOption>) {
        final answerOptions =
            controller.rawValue as List<QuestionnaireAnswerOption>;

        final values = answerOptions
            .map((answerOption) =>
                answerOption.valueString ??
                answerOption.valueInteger?.valueInt ??
                answerOption.valueTime?.asDateTime ??
                answerOption.valueDate?.valueDateTime ??
                answerOption.valueCoding?.code?.valueString)
            .nonNulls;

        controllerValues = values.toList() as List<dynamic>;
      } else {
        // Any other possible controller value can be treated as dynamic
        controllerValues = [controller.rawValue];
      }

      List<num>? controllerValuesAsNum = controllerValues
          .map((e) => NumUtils.tryParse(e?.toString()))
          .nonNulls
          .toList();
      num? expectedValueAsNum = NumUtils.tryParse(expectedValue?.toString());

      if (controllerValues.isEmpty && expectedValue == null) {
        continue;
      }

      switch (enableWhenBundle.operator) {
        case QuestionnaireEnableWhenOperator.exists:
          final bool existAnswer =
              enableWhenBundle.expectedAnswer.answerBoolean?.valueBoolean ??
                  false;
          enabled = _behavior.check(
              enabled,
              (TextUtils.isNotEmpty(controller.rawValue?.toString()) &&
                      existAnswer) ||
                  (TextUtils.isEmpty(controller.rawValue?.toString()) &&
                      !existAnswer));
          break;
        case QuestionnaireEnableWhenOperator.equals:
          enabled = _behavior.check(
            enabled,
            controllerValues.firstWhereOrNull((controllerValue) =>
                    controllerValue?.toString() == expectedValue?.toString()) !=
                null,
          );
          break;
        case QuestionnaireEnableWhenOperator.notEquals:
          enabled = _behavior.check(
            enabled,
            controllerValues.firstWhereOrNull((controllerValue) =>
                    controllerValue?.toString() != expectedValue?.toString()) !=
                null,
          );
          break;
        case QuestionnaireEnableWhenOperator.greaterThan:
          enabled = _behavior.check(
            enabled,
            expectedValueAsNum != null &&
                controllerValuesAsNum.firstWhereOrNull(
                        (value) => value > expectedValueAsNum) !=
                    null,
          );
          break;
        case QuestionnaireEnableWhenOperator.lessThan:
          enabled = _behavior.check(
            enabled,
            expectedValueAsNum != null &&
                controllerValuesAsNum.firstWhereOrNull(
                        (value) => value < expectedValueAsNum) !=
                    null,
          );
          break;
        case QuestionnaireEnableWhenOperator.greaterOrEquals:
          enabled = _behavior.check(
            enabled,
            expectedValueAsNum != null &&
                controllerValuesAsNum.firstWhereOrNull(
                        (value) => value >= expectedValueAsNum) !=
                    null,
          );
          break;
        case QuestionnaireEnableWhenOperator.lessOrEquals:
          enabled = _behavior.check(
            enabled,
            expectedValueAsNum != null &&
                controllerValuesAsNum.firstWhereOrNull(
                        (value) => value <= expectedValueAsNum) !=
                    null,
          );
          break;
      }
      if (enabled && _behavior.isAny) {
        break;
      }
    }
    if (notify) {
      _onEnabledChanged?.call(enabled);
    }
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
