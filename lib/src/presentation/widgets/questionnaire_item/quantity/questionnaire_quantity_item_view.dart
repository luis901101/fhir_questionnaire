import 'package:collection/collection.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/19/24.
class QuestionnaireQuantityItemView extends QuestionnaireItemView {
  QuestionnaireQuantityItemView({
    super.key,
    CustomValueController<Quantity>? controller,
    required super.item,
    super.enableWhenController,
  }) : super(
         controller:
             controller ??
             CustomValueController<Quantity>(focusNode: FocusNode()),
       );

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
    fixedUnit = item
        .extension_
        ?.firstOrNull
        ?.valueCodeableConcept
        ?.coding
        ?.firstOrNull
        ?.code
        ?.valueString;
    if (controller.value == null) {
      final initial = item.initial
          ?.firstWhereOrNull((item) => item.valueQuantity != null)
          ?.valueQuantity;

      if (initial != null) {
        value = initial.copyWith();
      } else if (fixedUnit != null) {
        value = value.copyWith(unit: FhirString(fixedUnit!));
      }
    }
    valueEditingController.text = value.value?.valueString ?? '';
    unitEditingController.text =
        value.unit?.valueString ?? value.code?.valueString ?? '';
    comparatorController.value =
        QuestionnaireCustomQuantityComparator.valueOf(
          asQuantityComparator: value.comparator,
        ) ??
        QuestionnaireCustomQuantityComparator.defaultValue;
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
