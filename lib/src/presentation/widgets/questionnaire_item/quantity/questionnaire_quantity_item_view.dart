import 'package:collection/collection.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart';
import 'package:material_ui/material_ui.dart';

/// Created by luis901101 on 3/19/24.
class QuestionnaireQuantityItemView extends QuestionnaireItemView {
  QuestionnaireQuantityItemView({
    super.key,
    CustomValueController<Quantity>? controller,
    required super.item,
    super.enableWhenController,
    super.children,
  }) : super(
         controller:
             controller ??
             CustomValueController<Quantity>(focusNode: FocusNode()),
       );

  /// The unit the item fixes, if any: the code of its first extension's
  /// coding (the `questionnaire-unit` extension).
  String? get fixedUnit => item
      .extension_
      ?.firstOrNull
      ?.valueCodeableConcept
      ?.coding
      ?.firstOrNull
      ?.code
      ?.valueString;

  @override
  void applyInitialValue() {
    final controller = this.controller as CustomValueController<Quantity>;
    if (controller.value != null) return;
    final initial = item.initial
        ?.firstWhereOrNull((item) => item.valueQuantity != null)
        ?.valueQuantity;

    if (initial != null) {
      controller.value = initial.copyWith();
    } else if (fixedUnit != null) {
      controller.value = Quantity(unit: FhirString(fixedUnit));
    }
  }

  @override
  State createState() => QuestionnaireQuantityItemViewState();
}

class QuestionnaireQuantityItemViewState
    extends QuestionnaireItemViewState<QuestionnaireQuantityItemView> {
  @override
  CustomValueController<Quantity> get controller =>
      super.controller as CustomValueController<Quantity>;
  final valueEditingController = CustomTextEditingController();
  final unitEditingController = CustomTextEditingController();
  final comparatorController =
      CustomValueController<QuestionnaireCustomQuantityComparator>();
  String? fixedUnit;

  Quantity get value => controller.value ??= const Quantity();
  set value(Quantity value) => controller.value = value;

  @override
  void initState() {
    super.initState();
    fixedUnit = widget.fixedUnit;
    _syncInputs();
  }

  /// Copies [value] into the value, unit and comparator inputs, leaving alone
  /// any input that already shows it, so typing keeps its caret.
  void _syncInputs() {
    final number = value.value?.valueDouble;
    if (DoubleUtils.tryParse(valueEditingController.text) != number) {
      valueEditingController.text = value.value?.valueString ?? '';
    }
    final unit = value.unit?.valueString ?? value.code?.valueString ?? '';
    if (unitEditingController.text != unit) {
      unitEditingController.text = unit;
    }
    final comparator =
        QuestionnaireCustomQuantityComparator.valueOf(
          asQuantityComparator: value.comparator,
        ) ??
        QuestionnaireCustomQuantityComparator.defaultValue;
    if (comparatorController.value != comparator) {
      comparatorController.value = comparator;
    }
  }

  @override
  void onControllerValueChanged() => _syncInputs();

  @override
  void dispose() {
    valueEditingController.dispose();
    unitEditingController.dispose();
    comparatorController.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    final noInputBorder =
        theme.inputDecorationTheme.border is! OutlineInputBorder ||
        (theme.inputDecorationTheme.border?.borderSide.style ==
                BorderStyle.none &&
            theme.inputDecorationTheme.border?.borderSide.width == 0);
    return CustomTextField(
      controller: valueEditingController,
      focusNode: controller.focusNode,
      enabled: !isReadOnly,
      maxLength: maxLength,
      textInputAction: TextInputAction.next,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onSubmitted: (text) {
        valueEditingController.focusNode?.unfocus();
        unitEditingController.focusNode?.requestFocus();
      },
      onChanged: (text) {
        value = value.copyWith(
          value: DoubleUtils.tryParse(text)?.asFhirDecimal,
        );
      },
      decoration: InputDecoration(
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 70,
              child:
                  CustomDropDownButtonFormField.buildDropDown<
                    QuestionnaireCustomQuantityComparator
                  >(
                    context: context,
                    controller: comparatorController,
                    disabled: isReadOnly,
                    values: QuestionnaireCustomQuantityComparator.values,
                    itemBuilder: (item, pos) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          child: Text(item.symbol, textAlign: TextAlign.center),
                        ),
                      );
                    },
                    onChanged: (comparator) {
                      value = value.copyWith(
                        comparator: comparator?.asQuantityComparator,
                      );
                    },
                    inputDecoration: const InputDecoration(),
                  ),
            ),
            if (noInputBorder)
              const SizedBox(height: 20, child: VerticalDivider()),
            const SizedBox(width: 8.0),
          ],
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (noInputBorder)
              const SizedBox(height: 20, child: VerticalDivider()),
            const SizedBox(width: 8.0),
            SizedBox(
              width: 80,
              child: CustomTextField(
                controller: unitEditingController,
                focusNode: unitEditingController.focusNode,
                enabled: !isReadOnly && fixedUnit == null,
                maxLength: maxLength,
                useCustomButton: false,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
                onChanged: (text) {
                  value = value.copyWith(
                    unit: text.isEmpty ? null : FhirString(text),
                  );
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
