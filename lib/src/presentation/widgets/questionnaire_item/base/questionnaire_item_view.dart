import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/5/24.
abstract class QuestionnaireItemView extends StatefulWidget {
  final FieldController controller;
  final QuestionnaireItem item;
  final List<QuestionnaireItemView>? children;
  final QuestionnaireItemEnableWhenController? enableWhenController;
  const QuestionnaireItemView({
    super.key,
    required this.controller,
    required this.item,
    this.children,
    this.enableWhenController,
  });
}

abstract class QuestionnaireItemViewState<SF extends QuestionnaireItemView>
    extends State<SF>
    with AutomaticKeepAliveClientMixin {
  ThemeData theme = ThemeData();
  int? _minLengthCache;
  bool? _isHiddenCache;
  String? _hintTextCache;
  QuestionnaireItem? _helperItemCache;
  String? _helperTextCache;
  bool? _helperTextAsButtonCache;
  dynamic
  _minValueCache; // Can be any of instant, date, dateTime, time, decimal, integer, depending on the item type
  dynamic
  _maxValueCache; // Can be any of instant, date, dateTime, time, decimal, integer, depending on the item type
  bool isEnabled = true;
  String? lastControllerError;
  FieldController get controller => widget.controller;
  QuestionnaireItemEnableWhenController? get enableWhenController =>
      widget.enableWhenController;
  QuestionnaireItem get item => widget.item;
  List<QuestionnaireItemView>? get children => widget.children;
  EnhancedEmptyValidationController? requiredValidation;

  @override
  bool get wantKeepAlive => false;

  bool get isRequired => item.required_?.value ?? false;
  bool get isReadOnly => item.readOnly?.value ?? false;
  int? get maxLength => item.maxLength?.value;

  /// Checks for minLength extension to provide minimum length validation
  /// Docs: http://hl7.org/fhir/R4/extension-minlength.html
  int? get minLength => _minLengthCache ??= (item.extension_ ?? [])
      .firstWhereOrNull(
        (ext) =>
            ext.url?.value?.toString() ==
            'http://hl7.org/fhir/StructureDefinition/minLength',
      )
      ?.valueInteger
      ?.value;

  /// Checks for minValue extension to provide minimum value validation
  /// Docs: http://hl7.org/fhir/R4/extension-minvalue.html
  dynamic get minValue {
    if (_minValueCache != null) return _minValueCache;
    final minValueItem = (item.extension_ ?? []).firstWhereOrNull(
      (ext) =>
          ext.url?.value?.toString() ==
          'http://hl7.org/fhir/StructureDefinition/minValue',
    );
    return _minValueCache =
        minValueItem?.valueInteger?.value ??
        minValueItem?.valueDecimal?.value ??
        minValueItem?.valueInstant?.value ??
        minValueItem?.valueDate?.value ??
        minValueItem?.valueDateTime?.value ??
        minValueItem?.valueTime?.value;
  }

  /// Checks for maxValue extension to provide maximum value validation
  /// Docs: http://hl7.org/fhir/R4/extension-maxvalue.html
  dynamic get maxValue {
    if (_maxValueCache != null) return _maxValueCache;
    final maxValueItem = (item.extension_ ?? []).firstWhereOrNull(
      (ext) =>
          ext.url?.value?.toString() ==
          'http://hl7.org/fhir/StructureDefinition/maxValue',
    );
    return _maxValueCache =
        maxValueItem?.valueInteger?.value ??
        maxValueItem?.valueDecimal?.value ??
        maxValueItem?.valueInstant?.value ??
        maxValueItem?.valueDate?.value ??
        maxValueItem?.valueDateTime?.value ??
        maxValueItem?.valueTime?.value;
  }

  /// Checks for questionnaire-hidden extension to hide the item
  /// Docs: http://hl7.org/fhir/R4/extension-questionnaire-hidden.html
  bool get isHidden => _isHiddenCache ??=
      (item.extension_ ?? []).any(
        (ext) =>
            ext.url?.value?.toString() ==
                'http://hl7.org/fhir/StructureDefinition/questionnaire-hidden' &&
            ext.valueBoolean?.value == true,
      ) ||
      (item.type.value == QuestionnaireItemType.display.code &&
          (item.extension_?.any(
                (subExt) =>
                    subExt.url?.value?.toString() ==
                        'http://hl7.org/fhir/StructureDefinition/questionnaire-displayCategory' &&
                    subExt
                            .valueCodeableConcept
                            ?.coding
                            ?.firstOrNull
                            ?.code
                            ?.value ==
                        QuestionnaireItemExtensionCode.help.code,
              ) ??
              false));

  /// Checks for entryFormat extension to provide hint text
  /// Docs: http://hl7.org/fhir/R4/extension-entryformat.html
  String? get hintText => _hintTextCache ??= (item.extension_ ?? [])
      .firstWhereOrNull(
        (ext) =>
            ext.url?.value?.toString() ==
            'http://hl7.org/fhir/StructureDefinition/entryFormat',
      )
      ?.valueString;

  /// Checks for questionnaire-displayCategory extension to provide helper text
  /// Docs: https://hl7.org/fhir/R4/extension-questionnaire-displaycategory.html
  QuestionnaireItem?
  get helperItem => _helperItemCache ??= item.item?.firstWhereOrNull(
    (subItem) =>
        subItem.type.value == QuestionnaireItemType.display.code &&
        (subItem.extension_?.any(
              (subExt) =>
                  subExt.url?.value?.toString() ==
                      'http://hl7.org/fhir/StructureDefinition/questionnaire-displayCategory' &&
                  subExt
                          .valueCodeableConcept
                          ?.coding
                          ?.firstOrNull
                          ?.code
                          ?.value ==
                      QuestionnaireItemExtensionCode.help.code,
            ) ??
            false),
  );

  String? get helperText => _helperTextCache ??= helperItem?.title;

  bool get helperTextAsButton =>
      _helperTextAsButtonCache ??= (helperItem?.extension_ ?? []).any(
        (ext) =>
            ext.url?.value?.toString() ==
                'http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl' &&
            [
              QuestionnaireItemExtensionCode.help.code,
              QuestionnaireItemExtensionCode.flyover.code,
            ].contains(
              ext.valueCodeableConcept?.coding?.firstOrNull?.code?.value,
            ),
      );

  bool get handleControllerErrorManually => true;

  Widget? get helperButton => !helperTextAsButton || helperText.isEmpty
      ? null
      : HelperButton(text: helperText ?? '');

  @override
  void initState() {
    super.initState();
    if (handleControllerErrorManually) {
      controller.addListener(onControllerErrorChanged);
    }
    ValidationController? rangeValidation;
    if (minValue != null && maxValue != null) {
      rangeValidation = ValidationUtils.rangeValidationController(
        minValue: minValue,
        maxValue: maxValue,
      );
    } else if (minValue != null) {
      rangeValidation = ValidationUtils.minRangeValidationController(minValue);
    } else if (maxValue != null) {
      rangeValidation = ValidationUtils.maxRangeValidationController(maxValue);
    }
    if (isRequired) {
      requiredValidation = ValidationUtils.requiredFieldValidation;
    }
    controller.validations.addAll([
      if (isRequired) ?requiredValidation,
      ?rangeValidation,
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
      setState(() {});
    }
  }

  void onEnabled(bool enabled) {
    if (isEnabled != enabled) {
      if (isRequired && requiredValidation != null) {
        if (enabled) {
          controller.validations.add(requiredValidation!);
        } else {
          controller.validations.remove(requiredValidation);
        }
      }
      setState(() => isEnabled = enabled);
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    theme = Theme.of(context);
    return isHidden
        ? const SizedBox.shrink()
        : AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: ClipRect(
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                height: isEnabled ? null : 0,
                child: SizeRenderer(
                  onSizeRendered: onSizeRendered,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ?buildTitleView(context),
                        buildBody(context),
                        ?buildHintTextView(context),
                        ?buildHelperTextView(context),
                        ?buildErrorManuallyView(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget? buildTitleView(
    BuildContext context, {
    bool? forGroup,
    bool? noPadding,
    TextStyle? style,
  }) {
    forGroup ??= false;
    noPadding ??= false;
    if (item.title.isEmpty && !isRequired) return null;
    final fieldRadius =
        (theme.inputDecorationTheme.border is OutlineInputBorder)
        ? (theme.inputDecorationTheme.border as OutlineInputBorder).borderRadius
        : BorderRadius.zero;
    return Padding(
      padding: forGroup || noPadding
          ? EdgeInsets.zero
          : EdgeInsets.only(
              left: fieldRadius.topLeft.x / 2,
              right: fieldRadius.topRight.x / 2,
              bottom: 4.0,
            ),
      child: Row(
        children: [
          if (item.title.isNotEmpty || isRequired)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  color: forGroup ? theme.colorScheme.surface : null,
                  padding: forGroup || noPadding
                      ? const EdgeInsets.symmetric(horizontal: 8)
                      : null,
                  child: Text.rich(
                    TextSpan(
                      style:
                          style ??
                          (forGroup
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleSmall),
                      children: [
                        if (item.title.isNotEmpty) TextSpan(text: item.title),
                        if (isRequired)
                          TextSpan(
                            text: '${item.title.isNotEmpty ? ' ' : ''}*',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          if (helperTextAsButton && helperText.isNotEmpty)
            Container(
              color: forGroup ? theme.colorScheme.surface : null,
              padding: forGroup
                  ? const EdgeInsets.symmetric(horizontal: 4)
                  : null,
              child: helperButton,
            ),
        ],
      ),
    );
  }

  Widget? buildErrorManuallyView(BuildContext context) {
    if (!handleControllerErrorManually || !controller.hasError) return null;
    final inputBorderRadius =
        (theme.inputDecorationTheme.border is OutlineInputBorder)
        ? (theme.inputDecorationTheme.border as OutlineInputBorder).borderRadius
        : const BorderRadius.all(Radius.circular(4));
    return Padding(
      padding: EdgeInsets.only(
        left: inputBorderRadius.bottomLeft.x / 2,
        right: inputBorderRadius.bottomLeft.x / 2,
        top: 4.0,
      ),
      child: Text(
        '${controller.error}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  Widget? buildHintTextView(BuildContext context) {
    if (hintText.isEmpty) return null;
    final inputBorderRadius =
        (theme.inputDecorationTheme.border is OutlineInputBorder)
        ? (theme.inputDecorationTheme.border as OutlineInputBorder).borderRadius
        : const BorderRadius.all(Radius.circular(4));
    return Padding(
      padding: EdgeInsets.only(
        left: inputBorderRadius.bottomLeft.x / 2,
        right: inputBorderRadius.bottomLeft.x / 2,
        top: 4.0,
      ),
      child: Text(hintText ?? '', style: theme.textTheme.bodySmall),
    );
  }

  Widget? buildHelperTextView(BuildContext context) {
    if (helperText.isEmpty || helperTextAsButton) return null;
    final inputBorderRadius =
        (theme.inputDecorationTheme.border is OutlineInputBorder)
        ? (theme.inputDecorationTheme.border as OutlineInputBorder).borderRadius
        : const BorderRadius.all(Radius.circular(4));
    return Padding(
      padding: EdgeInsets.only(
        left: inputBorderRadius.bottomLeft.x / 2,
        right: inputBorderRadius.bottomLeft.x / 2,
        top: 4.0,
      ),
      child: Text(helperText ?? '', style: theme.textTheme.bodyMedium),
    );
  }

  void onSizeRendered(Size size, GlobalKey key) {
    controller.size = size;
    controller.key = key;
  }

  @override
  void dispose() {
    controller.removeListener(onControllerErrorChanged);
    enableWhenController?.dispose();
    super.dispose();
  }
}
