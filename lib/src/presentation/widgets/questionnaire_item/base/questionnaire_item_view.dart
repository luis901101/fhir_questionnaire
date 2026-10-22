import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:material_ui/material_ui.dart';

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

  /// Seeds [controller] from the item's `initial` values when it holds no value
  /// yet.
  ///
  /// It is called when the item's bundle is built, so an item that was never
  /// scrolled into view still answers and validates with its initial values,
  /// and again when the view's state is created, where it does nothing once a
  /// value is set. The default does nothing; override it in a custom view
  /// whose answer has an initial value.
  void applyInitialValue() {}
}

abstract class QuestionnaireItemViewState<SF extends QuestionnaireItemView>
    extends State<SF>
    with AutomaticKeepAliveClientMixin {
  ThemeData theme = ThemeData();
  bool isEnabled = true;
  String? lastControllerError;
  FieldController get controller => widget.controller;
  QuestionnaireItemEnableWhenController? get enableWhenController =>
      widget.enableWhenController;
  QuestionnaireItem get item => widget.item;
  List<QuestionnaireItemView>? get children => widget.children;

  /// The required validation registered on [controller] when the item's bundle
  /// was built, if any.
  EnhancedEmptyValidationController? requiredValidation;

  /// The answer last rendered, compared with the controller's on each change
  /// so a value set from code is shown.
  Object? _renderedValue;
  bool _valueCheckScheduled = false;

  @override
  bool get wantKeepAlive => false;

  bool get isRequired => item.isRequired;
  bool get isReadOnly => item.isReadOnly;
  int? get maxLength => item.maxLength?.value;

  /// Checks for minLength extension to provide minimum length validation
  /// Docs: http://hl7.org/fhir/R4/extension-minlength.html
  int? get minLength => item.minLength;

  /// Checks for minValue extension to provide minimum value validation
  /// Docs: http://hl7.org/fhir/R4/extension-minvalue.html
  dynamic get minValue => item.minValue;

  /// Checks for maxValue extension to provide maximum value validation
  /// Docs: http://hl7.org/fhir/R4/extension-maxvalue.html
  dynamic get maxValue => item.maxValue;

  /// Checks for questionnaire-hidden extension to hide the item
  /// Docs: http://hl7.org/fhir/R4/extension-questionnaire-hidden.html
  bool get isHidden => item.isHidden;

  /// Checks for entryFormat extension to provide hint text
  /// Docs: http://hl7.org/fhir/R4/extension-entryformat.html
  String? get hintText => item.hintText;

  /// Checks for questionnaire-displayCategory extension to provide helper text
  /// Docs: https://hl7.org/fhir/R4/extension-questionnaire-displaycategory.html
  QuestionnaireItem? get helperItem => item.helperItem;

  String? get helperText => item.helperText;

  bool get helperTextAsButton => item.helperTextAsButton;

  bool get handleControllerErrorManually => true;

  /// Whether the base [build] renders [children] below the item. A view that
  /// lays out its children itself (a group) returns false.
  bool get rendersChildren => true;

  Widget? get helperButton => !helperTextAsButton || helperText.isEmpty
      ? null
      : HelperButton(text: helperText ?? '');

  @override
  void initState() {
    super.initState();
    if (handleControllerErrorManually) {
      controller.addListener(onControllerErrorChanged);
    }
    widget.applyInitialValue();
    // Validations are registered when the item's bundle is built, not here,
    // so items never scrolled into view are validated too.
    requiredValidation = controller.validations
        .whereType<EnhancedEmptyValidationController>()
        .firstOrNull;
    // A text field repaints itself; any other view repaints when its value
    // changes, including when it is set from code.
    if (controller is! TextEditingController) {
      _renderedValue = _valueSnapshot();
      controller.addListener(_onControllerValueChanged);
    }
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

  Object? _valueSnapshot() {
    final value = controller.rawValue;
    return value is List ? List.of(value) : value;
  }

  void _onControllerValueChanged() {
    // Compared once the current work is done, not on each notification: a view
    // may write its controller while building (the drop down resets and
    // restores its value), which must not count as a change.
    if (_valueCheckScheduled) return;
    _valueCheckScheduled = true;
    scheduleMicrotask(() {
      _valueCheckScheduled = false;
      if (!mounted) return;
      final snapshot = _valueSnapshot();
      if (const DeepCollectionEquality().equals(snapshot, _renderedValue)) {
        return;
      }
      _renderedValue = snapshot;
      onControllerValueChanged();
      setState(() {});
    });
  }

  /// Called when [controller]'s value changed, by the user or from code, right
  /// before the view repaints. Override to update state derived from it.
  void onControllerValueChanged() {}

  void onEnabled(bool enabled) {
    if (isEnabled != enabled) {
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
    if (isHidden) return const SizedBox.shrink();
    final nestedViews = rendersChildren ? children : null;
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ?buildTitleView(context),
        buildBody(context),
        ?buildHintTextView(context),
        ?buildHelperTextView(context),
        ?buildErrorManuallyView(context),
        if (nestedViews?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: nestedViews!,
            ),
          ),
      ],
    );
    final highlighted = QuestionnaireHighlightScope.maybeOf(context);
    if (highlighted != null) {
      content = buildHighlight(
        context,
        isHighlighted: identical(highlighted.value, widget),
        child: content,
      );
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          height: isEnabled ? null : 0,
          child: SizeRenderer(
            onSizeRendered: onSizeRendered,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  /// Wraps the item's content when it is shown under a
  /// [QuestionnaireHighlightScope], marking it when [isHighlighted]. The
  /// highlight pads the item, so it grows; [QuestionnaireFormController.scrollTo]
  /// measures it once it has resized (see
  /// [QuestionnaireFormController.highlightAnimationDuration]).
  Widget buildHighlight(
    BuildContext context, {
    required bool isHighlighted,
    required Widget child,
  }) {
    double radius = 8;
    if (theme.inputDecorationTheme.border is OutlineInputBorder) {
      radius = (theme.inputDecorationTheme.border as OutlineInputBorder)
          .borderRadius
          .topLeft
          .x;
    }
    final borderRadius = BorderRadius.circular(radius);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: isHighlighted ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
            : null,
        borderRadius: borderRadius,
      ),
      foregroundDecoration: isHighlighted
          ? BoxDecoration(
              border: Border.all(color: theme.colorScheme.primary, width: 2),
              borderRadius: borderRadius,
            )
          : null,
      // List tiles (radio, check box, switch) paint their ink on the nearest
      // Material: this one sits above the tint, so the tint never hides it.
      child: Material(type: MaterialType.transparency, child: child),
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
    controller.removeListener(_onControllerValueChanged);
    enableWhenController?.dispose();
    super.dispose();
  }
}
