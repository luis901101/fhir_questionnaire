import 'package:adeptviews/adeptviews.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends AdeptTextField {
  CustomTextField({
    super.key,
    super.controller,
    super.focusNode,
    InputDecoration? decoration,
    TextInputType? keyboardType,
    super.textInputAction,
    super.textCapitalization,
    super.style,
    super.textAlign,
    super.textDirection,
    super.autofocus,
    super.obscureText,
    super.autocorrect = true,
    int? maxLines,
    super.maxLength,
    super.maxLengthEnforcement,
    super.onChanged,
    super.listenOnControllerChanged,
    super.onEditingComplete,
    super.onSubmitted,
    super.inputFormatters,
    super.enabled,
    super.cursorWidth,
    super.cursorRadius,
    super.cursorColor,
    super.keyboardAppearance,
    super.scrollPadding,
    super.enableInteractiveSelection,
    super.selectionControls,
    super.onTap,
    super.onTapOutside,
    super.strutStyle,
    super.textAlignVertical,
    super.readOnly,
    super.showCursor,
    super.obscuringCharacter,
    super.smartDashesType,
    super.smartQuotesType,
    super.enableSuggestions,
    super.minLines,
    super.expands,
    super.onAppPrivateCommand,
    super.cursorHeight,
    super.selectionHeightStyle,
    super.selectionWidthStyle,
    super.dragStartBehavior,
    super.mouseCursor,
    super.buildCounter,
    super.scrollController,
    super.scrollPhysics,
    super.autofillHints,
    super.clipBehavior,
    super.restorationId,
    super.scribbleEnabled,
    super.enableIMEPersonalizedLearning,
    super.contextMenuBuilder,
    SpellCheckConfiguration? spellCheckConfiguration,
    super.magnifierConfiguration,
    CustomButton? customButton,
    CustomButtonDefaultAction? customButtonDefaultAction,
    super.customButtonAction,
    super.customButtonColor,
    super.customButtonView,
    super.customButtonIcon,
    super.customButtonIconSize,
    super.customButtonIconPadding,
    super.autoValidate = true,
    super.onValidate,
    bool autoMultiline = false,
  }) : super(
          decoration: (decoration ??= const InputDecoration()).copyWith(
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
          keyboardType: autoMultiline ? TextInputType.multiline : keyboardType,
          maxLines: autoMultiline ? 1 : (maxLines ?? 1),
          spellCheckConfiguration: spellCheckConfiguration ??
              (kIsWeb
                  ? null
                  : SpellCheckConfiguration(
                      spellCheckService: DefaultSpellCheckService(),
                    )),
          customButton: customButton ?? CustomButton.ON_TEXT,
          customButtonDefaultAction:
              customButtonDefaultAction ?? CustomButtonDefaultAction.CLEAR,
        );
}
