import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

class CustomTextField extends StatefulWidget {
  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  final CustomTextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final int maxLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String>? onChanged;
  final bool listenOnControllerChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final GestureTapCallback? onTap;
  final StrutStyle? strutStyle;
  final TextAlignVertical? textAlignVertical;
  final bool readOnly;
  final bool? showCursor;
  final String obscuringCharacter;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final int? minLines;
  final bool expands;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final double? cursorHeight;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final DragStartBehavior dragStartBehavior;
  final MouseCursor? mouseCursor;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final String? restorationId;
  final TapRegionCallback? onTapOutside;
  final Clip clipBehavior;
  final bool scribbleEnabled;
  final bool enableIMEPersonalizedLearning;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;

  final Color? customButtonColor;
  final Widget? customButtonView;
  final IconData? customButtonIcon;
  final double customButtonIconSize;
  final double customButtonIconPadding;
  final ValueChanged<CustomTextEditingController>? customButtonAction;
  final bool useCustomButton;
  final bool autoValidate;
  final String? Function(String)? onValidate;

  CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    InputDecoration? decoration,
    TextInputType? keyboardType,
    this.textInputAction,
    TextCapitalization? textCapitalization,
    this.style,
    TextAlign? textAlign,
    this.textDirection,
    bool? autofocus,
    bool? obscureText,
    bool? autocorrect,
    int? maxLines,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    bool? listenOnControllerChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    double? cursorWidth,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    EdgeInsets? scrollPadding,
    bool? enableInteractiveSelection,
    this.selectionControls,
    this.onTap,
    this.onTapOutside,
    this.strutStyle,
    this.textAlignVertical,
    bool? readOnly,
    this.showCursor,
    String? obscuringCharacter,
    this.smartDashesType,
    this.smartQuotesType,
    bool? enableSuggestions,
    this.minLines,
    bool? expands,
    this.onAppPrivateCommand,
    this.cursorHeight,
    ui.BoxHeightStyle? selectionHeightStyle,
    ui.BoxWidthStyle? selectionWidthStyle,
    DragStartBehavior? dragStartBehavior,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scribbleEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    SpellCheckConfiguration? spellCheckConfiguration,
    this.magnifierConfiguration,
    this.customButtonColor,
    this.customButtonView,
    this.customButtonIcon,
    double? customButtonIconSize,
    double? customButtonIconPadding,
    this.customButtonAction,
    this.useCustomButton = true,
    this.autoValidate = true,
    this.onValidate,
    bool autoMultiline = false,
  })  : decoration = (decoration ??= const InputDecoration()).copyWith(
//      enabledBorder: OutlineInputBorder(
//        borderRadius: BorderRadius.circular(R.dimens.radiusMedium),
//        borderSide: BorderSide(color: Colors.transparent)
//      ),
//      focusedBorder: OutlineInputBorder(
//        borderRadius: BorderRadius.circular(R.dimens.radiusMedium),
//        borderSide: BorderSide(color: R.colors.colorPrimary)
//      ),
//      filled: true,
          errorMaxLines: decoration.errorMaxLines ?? 4,
        ),
        keyboardType = autoMultiline ? TextInputType.multiline : keyboardType,
        textCapitalization = textCapitalization ?? TextCapitalization.none,
        textAlign = textAlign ?? TextAlign.start,
        autofocus = autofocus ?? false,
        obscureText = obscureText ?? false,
        autocorrect = autocorrect ?? true,
        maxLines = autoMultiline ? 1 : (maxLines ?? 1),
        listenOnControllerChanged = listenOnControllerChanged ?? true,
        cursorWidth = cursorWidth ?? 2.0,
        scrollPadding = scrollPadding ?? const EdgeInsets.all(20.0),
        enableInteractiveSelection = enableInteractiveSelection ?? true,
        readOnly = readOnly ?? false,
        obscuringCharacter = obscuringCharacter ?? '•',
        enableSuggestions = enableSuggestions ?? true,
        expands = expands ?? false,
        selectionHeightStyle = selectionHeightStyle ?? ui.BoxHeightStyle.tight,
        selectionWidthStyle = selectionWidthStyle ?? ui.BoxWidthStyle.tight,
        dragStartBehavior = dragStartBehavior ?? DragStartBehavior.start,
        spellCheckConfiguration = spellCheckConfiguration ??
            (kIsWeb
                ? null
                : SpellCheckConfiguration(
                    spellCheckService: DefaultSpellCheckService(),
                  )),
        customButtonIconSize = customButtonIconSize ?? 24,
        customButtonIconPadding = customButtonIconPadding ?? 8;

  @override
  State createState() => CustomTextFieldState();
}

class CustomTextFieldState<S extends CustomTextField> extends State<S> {
  late final CustomTextEditingController controller;
  String lastText = '';
  bool startedTyping = false;

  CustomTextFieldState();

  bool get hasText => controller.isNotEmpty;
  bool get hadText => lastText.isNotEmpty;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? CustomTextEditingController();
    lastText = controller.text;
    if (widget.listenOnControllerChanged) {
      controller.addListener(onControllerTextChanged);
    }
  }

  InputDecoration get decoration {
    return widget.decoration.copyWith(
      errorText: controller.error,
      suffixIcon: widget.decoration.suffixIcon != null || !showCustomButton
          ? widget.decoration.suffixIcon
          : widget.customButtonView ??
              IconButton(
                icon: customButtonIcon,
                iconSize: widget.customButtonIconSize,
                padding: EdgeInsets.all(widget.customButtonIconPadding),
                onPressed:
                    (widget.enabled ?? true) ? onCustomButtonPressed : null,
              ),
      suffixText: null,
    );
  }

  void onCustomButtonPressed() {
    if (widget.customButtonAction != null) {
      widget.customButtonAction?.call(controller);
    } else {
      controller.text = '';
    }
  }

  Widget get customButtonIcon {
    if (widget.customButtonIcon != null) {
      return Icon(
        widget.customButtonIcon,
        color: widget.customButtonColor,
      );
    }
    return Icon(
      Icons.clear,
      color: widget.customButtonColor,
    );
  }

  bool get showCustomButton => widget.useCustomButton && hasText;

  void onControllerTextChanged() {
    if (controller.text.isNotEmpty) {
      startedTyping = true;
    }
    if (startedTyping) {
      onChanged(controller.text);
    }
  }

  void onChanged(String value) {
    bool refreshState = autoValidate && onValidate(value);
    if (hadText != value.isNotEmpty) {
      refreshState |= true;
    }
    lastText = value;
    widget.onChanged?.call(value);
    if (refreshState) {
      setState(() {});
    }
  }

  bool get autoValidate => widget.autoValidate;

  bool onValidate(String value) {
    if (widget.onValidate != null) {
      String currentErrorMessage = controller.error ?? '';
      String newErrorMessage = widget.onValidate?.call(value) ?? '';
      if (currentErrorMessage != newErrorMessage) {
        controller
            .setError(newErrorMessage.isNotEmpty ? newErrorMessage : null);
        return true;
      }
    } else {
      final wasValid = !controller.hasError;
      final lastError = controller.error;
      final isValid = controller.validate(notify: false);
      final currentError = controller.error;
      if (isValid) {
        controller.clearError();
      }
      if (wasValid != isValid || lastError != currentError) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.key,
      controller: controller,
      focusNode: widget.focusNode,
      decoration: decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onChanged: widget.listenOnControllerChanged
          ? null
          : onChanged, //onChanged function is managed above in the onTextChanged function
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      scribbleEnabled: widget.scribbleEnabled,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      contextMenuBuilder: widget.contextMenuBuilder,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      magnifierConfiguration: widget.magnifierConfiguration,
    );
  }

  @override
  void dispose() {
    controller.removeListener(onControllerTextChanged);
    super.dispose();
  }
}
