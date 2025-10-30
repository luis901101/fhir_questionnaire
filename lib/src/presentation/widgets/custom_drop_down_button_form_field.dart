import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomDropDownButtonFormField<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>>? items;
  final DropdownButtonBuilder? selectedItemBuilder;
  final CustomValueController<T>? controller;
  final T? value;
  final Widget? hint;
  final Widget? disabledHint;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onTap;
  final int? elevation;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double? iconSize;
  final bool? isDense;
  final bool? isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool? autofocus;
  final Color? dropdownColor;
  final InputDecoration? decoration;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final bool disabled;
  final bool showClearButtonOnValueChanged;
  final VoidCallback? onRetry;
  final VoidCallback? onAdd;

  const CustomDropDownButtonFormField({
    super.key,
    this.items,
    this.selectedItemBuilder,
    this.controller,
    this.value,
    this.hint,
    this.disabledHint,
    this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = true,
    this.isExpanded = true,
    this.itemHeight,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.decoration,
    this.onSaved,
    this.validator,
    this.disabled = false,
    this.showClearButtonOnValueChanged = false,
    this.onRetry,
    this.onAdd,
  });

  @override
  State createState() => _CustomDropDownButtonFormFieldState<T>();

  static Widget buildDropDown<T>({
    bool isLoading = false,
    required List<T> values,
    List<String> valuesNames = const [],
    CustomValueController<T>? controller,
    FocusNode? focusNode,
    InputDecoration? inputDecoration,
    ValueChanged<T?>? onChanged,
    String Function(T value)? nameResolver,
    bool disabled = false,
    bool? isDense,
    bool showClearButtonOnValueChanged = false,
    Widget Function(T item, int pos)? itemBuilder,
    VoidCallback? onRetry,
    VoidCallback? onAdd,
  }) {
    controller ??= CustomValueController<T>();
    final itemsController = CustomValueController<List<DropdownMenuItem<T>>>();
    List<DropdownMenuItem<T>> dropDownItems = [];
    T? currentValue = controller.value;
    if (!isLoading && values.isNotEmpty) controller.value = null;
    for (int i = 0; i < values.length; ++i) {
      T value = values[i];
      String valueName = i < valuesNames.length
          ? valuesNames[i]
          : (nameResolver?.call(value) ?? value?.toString())!;
      if (currentValue == value) controller.value = value;
      dropDownItems.add(
        DropdownMenuItem<T>(
          value: value,
          child: itemBuilder?.call(value, i) ?? Text(valueName),
        ),
      );
    }
    itemsController.value = dropDownItems;
    return IgnorePointer(
      ignoring: isLoading || disabled,
      child: CustomDropDownButtonFormField<T>(
        //          key: GlobalKey(),
        controller: controller,
        items: dropDownItems,
        onChanged: onChanged,
        focusNode: focusNode,
        decoration: (inputDecoration ?? const InputDecoration()).copyWith(
          errorText: controller.error,
        ),
        disabled: disabled,
        isDense: isDense,
        showClearButtonOnValueChanged: showClearButtonOnValueChanged,
        onRetry: onRetry,
        onAdd: onAdd,
      ),
    );
  }
}

class _CustomDropDownButtonFormFieldState<T>
    extends State<CustomDropDownButtonFormField<T>> {
  T? value;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(controllerListener);
  }

  void controllerListener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    value = widget.value ?? widget.controller?.value;
    if (widget.disabled) {
      widget.focusNode?.unfocus();
    }
    return DropdownButtonFormField<T?>(
      items: widget.items,
      selectedItemBuilder: widget.selectedItemBuilder,
      initialValue: /*widget.disabled ? null :*/ value,
      hint: widget.hint,
      disabledHint: widget.disabledHint,
      onChanged: /*widget.disabled ? null :*/ onChanged,
      onTap: widget.disabled
          ? null
          : (widget.onTap ?? () => widget.focusNode?.requestFocus()),
      elevation: widget.elevation ?? 8,
      style: widget.style,
      icon:
          widget.icon ??
          (showSuffixButtons
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showAddButton) addButton,
                    if (showRetryButton) retryButton,
                    if (showClearButton) clearButton,
                  ],
                )
              : null),
      iconDisabledColor: widget.iconDisabledColor,
      iconEnabledColor: widget.disabled
          ? (widget.iconDisabledColor ?? Theme.of(context).disabledColor)
          : widget.iconEnabledColor,
      iconSize: widget.iconSize ?? 4,
      isDense: widget.isDense ?? true,
      isExpanded: widget.isExpanded ?? true,
      itemHeight: widget.itemHeight,
      focusColor: widget.focusColor,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus ?? false,
      dropdownColor: widget.dropdownColor,
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        suffix: showSuffixButtons ? null : const SizedBox(width: 10),
        errorText: widget.controller?.error,
        contentPadding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
      ),
      onSaved: widget.onSaved,
      validator: widget.validator,
    );
  }

  Widget get addButton => IconButton(
    icon: const Icon(Icons.add),
    padding: EdgeInsets.zero,
    color: Theme.of(context).colorScheme.primary,
    onPressed: widget.onAdd,
  );

  Widget get retryButton => IconButton(
    icon: const Icon(Icons.refresh),
    padding: EdgeInsets.zero,
    color: Theme.of(context).colorScheme.primary,
    onPressed: widget.onRetry,
  );

  Widget get clearButton => IconButton(
    icon: const Icon(Icons.clear),
    padding: EdgeInsets.zero,
    onPressed: () {
      onChanged(null);
    },
  );

  bool get showSuffixButtons =>
      showAddButton || showRetryButton || showClearButton;

  bool get showAddButton =>
      widget.onAdd != null && widget.controller?.error == null;

  bool get showRetryButton =>
      widget.onRetry != null && widget.controller?.error != null;

  bool get showClearButton =>
      widget.showClearButtonOnValueChanged && value != null;

  void onChanged(T? value) {
    bool clearButtonCurrentlyVisible = showClearButton;
    this.value = value;
    if (widget.onChanged != null) {
      widget.onChanged!.call(value);
    } else {
      widget.controller?.value = value;
    }
    if (widget.showClearButtonOnValueChanged) {
      if (value == null && clearButtonCurrentlyVisible) {
        setState(() {});
      } else if (value != null && !clearButtonCurrentlyVisible) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    try {
      widget.controller?.removeListener(controllerListener);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
