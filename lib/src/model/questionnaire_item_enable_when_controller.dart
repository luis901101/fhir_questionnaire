import 'package:collection/collection.dart';
import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/foundation.dart';

class QuestionnaireItemEnableWhenController {
  /// The `enableWhen` conditions this controller evaluates, as declared by the
  /// item. Each one is resolved into a [QuestionnaireItemEnableWhenBundle] by
  /// [bind].
  final List<QuestionnaireEnableWhen> enableWhen;
  List<QuestionnaireItemEnableWhenBundle> _enableWhenBundleList;
  late final QuestionnaireEnableWhenBehavior _behavior;
  ValueChanged<bool>? _onEnabledChanged;

  /// Controllers whose changes can change the result of [checkIfEnabled]
  /// besides the ones in the bundles: the ones the enabled state of each
  /// condition's source item depends on.
  Set<FieldController> _dependencies = {};
  bool _listening = false;
  bool _evaluating = false;
  bool _bound;

  QuestionnaireItemEnableWhenController({
    required List<QuestionnaireItemEnableWhenBundle>? enableWhenBundleList,
    required FhirCode? behavior,
  }) : _enableWhenBundleList = enableWhenBundleList ?? [],
       enableWhen = [
         for (final bundle in enableWhenBundleList ?? []) bundle.expectedAnswer,
       ],
       _bound = true,
       _behavior =
           QuestionnaireEnableWhenBehavior.valueOf(behavior?.valueString) ??
           QuestionnaireEnableWhenBehavior.defaultValue;

  /// Creates a controller for [enableWhen] whose conditions are resolved later,
  /// by [bind], once every item of the questionnaire has been built. This lets
  /// a condition name an item that comes later in the questionnaire, or the
  /// item this one is nested under.
  ///
  /// Until it is bound the item counts as enabled.
  QuestionnaireItemEnableWhenController.unbound({
    required this.enableWhen,
    required FhirCode? behavior,
  }) : _enableWhenBundleList = [],
       _bound = false,
       _behavior =
           QuestionnaireEnableWhenBehavior.valueOf(behavior?.valueString) ??
           QuestionnaireEnableWhenBehavior.defaultValue;

  /// Whether the conditions have been resolved, by the constructor or by
  /// [bind].
  bool get isBound => _bound;

  /// Resolves the conditions into [enableWhenBundleList]. [dependencies] are
  /// further controllers whose changes must trigger a new evaluation, such as
  /// the ones that decide whether a condition's source item is enabled.
  ///
  /// When a condition could not be resolved it is left out; when none could,
  /// the item counts as enabled.
  void bind(
    List<QuestionnaireItemEnableWhenBundle> enableWhenBundleList, {
    Iterable<FieldController> dependencies = const [],
  }) {
    final wasListening = _listening;
    if (wasListening) _removeListeners();
    _enableWhenBundleList = enableWhenBundleList;
    _dependencies = {...dependencies};
    _bound = true;
    if (wasListening) _addListeners();
  }

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
    // An item whose conditions could not be resolved is always enabled. The
    // guard also breaks dependency cycles between items: a condition that is
    // being evaluated counts as satisfied.
    if (_enableWhenBundleList.isEmpty || _evaluating) {
      if (notify) _onEnabledChanged?.call(true);
      return true;
    }
    _evaluating = true;
    bool enabled = _behavior.init();
    try {
      enabled = _evaluate();
    } finally {
      _evaluating = false;
    }
    if (notify) {
      _onEnabledChanged?.call(enabled);
    }
    return enabled;
  }

  bool _evaluate() {
    bool enabled = _behavior.init();
    for (final enableWhenBundle in _enableWhenBundleList) {
      final controller = enableWhenBundle.controller;
      // A disabled source item counts as not answered.
      final rawValue = (enableWhenBundle.isSourceEnabled?.call() ?? true)
          ? controller.rawValue
          : null;
      dynamic expectedValue =
          enableWhenBundle.expectedAnswer.answerString ??
          enableWhenBundle.expectedAnswer.answerInteger?.valueString ??
          enableWhenBundle.expectedAnswer.answerDecimal?.valueString ??
          enableWhenBundle.expectedAnswer.answerBoolean?.valueString ??
          enableWhenBundle.expectedAnswer.answerQuantity?.value?.valueString ??
          enableWhenBundle.expectedAnswer.answerTime?.asDateTime ??
          enableWhenBundle.expectedAnswer.answerDate?.asDateTime ??
          enableWhenBundle.expectedAnswer.answerDateTime?.asDateTime ??
          enableWhenBundle.expectedAnswer.answerCoding?.code?.valueString;
      List<dynamic> controllerValues = [];
      if (rawValue is QuestionnaireAnswerOption) {
        final answerOption = rawValue;
        final controllerValueOption =
            answerOption.valueString ??
            answerOption.valueInteger?.valueString ??
            answerOption.valueTime?.asDateTime ??
            answerOption.valueDate?.asDateTime ??
            answerOption.valueCoding?.code?.valueString;
        if (controllerValueOption != null) {
          controllerValues = [controllerValueOption];
        }
      } else if (rawValue is List<QuestionnaireAnswerOption>) {
        final answerOptions = rawValue;

        final values = answerOptions
            .map(
              (answerOption) =>
                  answerOption.valueString ??
                  answerOption.valueInteger?.valueString ??
                  answerOption.valueTime?.asDateTime ??
                  answerOption.valueDate?.asDateTime ??
                  answerOption.valueCoding?.code?.valueString,
            )
            .nonNulls;

        controllerValues = values.toList() as List<dynamic>;
      } else {
        // Any other possible controller value can be treated as dynamic. A
        // disabled source reads as null here, exactly like an unanswered one.
        controllerValues = [rawValue];
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
          final bool hasAnswer = rawValue is List
              ? rawValue.isNotEmpty
              : TextUtils.isNotEmpty(rawValue?.toString());
          enabled = _behavior.check(enabled, hasAnswer == existAnswer);
          break;
        case QuestionnaireEnableWhenOperator.equals:
          enabled = _behavior.check(
            enabled,
            controllerValues.firstWhereOrNull(
                  (controllerValue) =>
                      controllerValue?.toString() == expectedValue?.toString(),
                ) !=
                null,
          );
          break;
        case QuestionnaireEnableWhenOperator.notEquals:
          enabled = _behavior.check(
            enabled,
            controllerValues.firstWhereOrNull(
                  (controllerValue) =>
                      controllerValue?.toString() != expectedValue?.toString(),
                ) !=
                null,
          );
          break;
        case QuestionnaireEnableWhenOperator.greaterThan:
          enabled = _behavior.check(
            enabled,
            expectedValueAsNum != null &&
                controllerValuesAsNum.firstWhereOrNull(
                      (value) => value > expectedValueAsNum,
                    ) !=
                    null,
          );
          break;
        case QuestionnaireEnableWhenOperator.lessThan:
          enabled = _behavior.check(
            enabled,
            expectedValueAsNum != null &&
                controllerValuesAsNum.firstWhereOrNull(
                      (value) => value < expectedValueAsNum,
                    ) !=
                    null,
          );
          break;
        case QuestionnaireEnableWhenOperator.greaterOrEquals:
          enabled = _behavior.check(
            enabled,
            expectedValueAsNum != null &&
                controllerValuesAsNum.firstWhereOrNull(
                      (value) => value >= expectedValueAsNum,
                    ) !=
                    null,
          );
          break;
        case QuestionnaireEnableWhenOperator.lessOrEquals:
          enabled = _behavior.check(
            enabled,
            expectedValueAsNum != null &&
                controllerValuesAsNum.firstWhereOrNull(
                      (value) => value <= expectedValueAsNum,
                    ) !=
                    null,
          );
          break;
      }
      if (enabled && _behavior.isAny) {
        break;
      }
    }
    return enabled;
  }

  Set<FieldController> get _listenedControllers => {
    for (final enableWhenBundle in _enableWhenBundleList)
      enableWhenBundle.controller,
    ..._dependencies,
  };

  void _addListeners() {
    if (_listening) return;
    _listening = true;
    for (final controller in _listenedControllers) {
      controller.addListener(_onControllerChange);
    }
  }

  void _removeListeners() {
    if (!_listening) return;
    _listening = false;
    for (final controller in _listenedControllers) {
      controller.removeListener(_onControllerChange);
    }
  }
}
