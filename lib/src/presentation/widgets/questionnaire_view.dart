import 'dart:math' as math;

import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Created by luis901101 on 3/5/24.
class QuestionnaireView extends StatefulWidget {
  /// The Questionnaire definition.
  final Questionnaire questionnaire;

  /// Get the QuestionnaireResponse once the user taps on Submit button.
  final ValueChanged<QuestionnaireResponse>? onSubmit;

  /// Necessary callback when Questionnaire has items of type = `attachment`
  /// so the logic of loading an Attachment is handled outside of the logic
  /// of QuestionnaireView
  final Future<Attachment?> Function()? onAttachmentLoaded;

  /// To indicate there is an ongoing loading process
  final bool isLoading;

  /// Indicates what should be the fallback localization if loalce is not
  /// supported.
  /// Defaults to English
  final QuestionnaireBaseLocalization? defaultLocalization;

  /// Indicates the definition of extra supported localizations.
  /// By default Spanish and English are supported, but you can set
  /// other localizations on this List to be considered.
  final List<QuestionnaireBaseLocalization>? localizations;

  /// The expected locale to show, by default Platform locale is used.
  final Locale? locale;

  /// The QuestionnaireController to use for item view and response generation.
  final QuestionnaireController? controller;

  /// The subject of the questionnaire response
  final QuestionnairePerson? subject;

  /// The author of the questionnaire response
  final QuestionnairePerson? author;

  /// The individual providing the information reflected in the questionnaire respose
  final QuestionnairePerson? source;

  /// Who signed the questionaire response or item
  final QuestionnairePerson? whoSigns;

  /// The party on behalf of which the questionnaire response or item was signed
  final QuestionnairePerson? signsOnBehalfOf;

  /// Reads and drives the rendered form from code: answers, scrolling,
  /// highlight, validation, response and submit. It is attached once the items
  /// are built and detached when this view's state is disposed.
  final QuestionnaireFormController? formController;

  const QuestionnaireView({
    super.key,
    required this.questionnaire,
    this.onSubmit,
    this.controller,
    this.onAttachmentLoaded,
    this.isLoading = false,
    this.defaultLocalization,
    this.localizations,
    this.locale,
    this.subject,
    this.author,
    this.source,
    this.whoSigns,
    this.signsOnBehalfOf,
    this.formController,
  });

  @override
  State createState() => QuestionnaireViewState();
}

class QuestionnaireViewState extends State<QuestionnaireView>
    with WidgetsBindingObserver {
  late final QuestionnaireController controller;
  static const fabSize = kFloatingActionButtonMargin + 56;
  double questionnaireTitleHeight = 0;
  ScrollController? scrollController;
  bool isKeyboardVisible = false;
  bool scrollReachedBottom = false;
  final showFAB = ValueNotifier<bool>(false);
  Questionnaire get questionnaire => widget.questionnaire;
  List<QuestionnaireItem> get questionnaireItems => questionnaire.item ?? [];

  late final double bottomPadding;
  List<QuestionnaireItemBundle> itemBundles = [];

  /// Controller and view for a root level signature (declared by the
  /// `questionnaire-signatureRequired` extension on the Questionnaire). Rendered
  /// as the trailing item, so the user signs at the end.
  SignatureController? rootSignatureController;
  QuestionnaireSignatureView? rootSignatureView;

  bool _isLoading = true;

  /// One key per list index, to tell which list children are built and where.
  final Map<int, GlobalKey> _listIndexKeys = {};

  void loading(bool value) {
    if (_isLoading != value) setState(() => _isLoading = value);
  }

  bool get isLoading => widget.isLoading || _isLoading;

  @override
  void initState() {
    super.initState();
    controller =
        widget.controller ??
        QuestionnaireController(
          subjectProvider: () => widget.subject,
          authorProvider: () => widget.author,
          sourceProvider: () => widget.source,
          whoSignsProvider: () => widget.whoSigns,
          signsOnBehalfOfProvider: () => widget.signsOnBehalfOf,
        );
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(onCreated);
    bottomPadding = FlutterViewUtils.get().padding.bottom;
    if (!widget.isLoading) {
      Locale? locale;
      try {
        locale =
            widget.locale ?? FlutterViewUtils.get().platformDispatcher.locale;
      } catch (_) {}
      QuestionnaireLocalization.instance.init(
        defaultLocalization: widget.defaultLocalization,
        localizations: widget.localizations,
        locale: locale,
      );
      buildQuestionnaireItems();
      checkScrollOnInit();
      widget.formController?.attach(this);
    }
  }

  @override
  void didUpdateWidget(covariant QuestionnaireView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.formController, widget.formController) &&
        !widget.isLoading) {
      oldWidget.formController?.detach(this);
      widget.formController?.attach(this);
    }
  }

  void onCreated(Duration _) {
    if (!widget.isLoading) {
      calculateQuestionnaireTitleHeight();
    }
    if (!widget.isLoading && scrollController == null) {
      scrollController = PrimaryScrollController.of(context);
      scrollController?.addListener(onScrollListener);
    }
    checkScrollOnInit();
  }

  void checkScrollOnInit() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController?.hasClients ?? false) {
        onScrollListener();
      }
    });
  }

  void onScrollListener() {
    if (scrollController!.hasClients &&
        scrollController!.position.pixels >=
            scrollController!.position.maxScrollExtent - fabSize) {
      if (!scrollReachedBottom) {
        scrollReachedBottom = true;
        updateFABVisibility();
      }
    } else {
      if (scrollReachedBottom) {
        scrollReachedBottom = false;
        updateFABVisibility();
      }
    }
  }

  void calculateQuestionnaireTitleHeight() {
    try {
      questionnaireTitleHeight = ViewUtils.getTextHeightAfterRender(
        context: context,
        text: questionnaire.title!,
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 24.0,
        ),
        textStyle: Theme.of(context).textTheme.titleLarge,
      );
    } catch (_) {}
  }

  Future<void> buildQuestionnaireItems() async {
    itemBundles = controller.buildQuestionnaireItems(
      questionnaire,
      onAttachmentLoaded: widget.onAttachmentLoaded,
    );
    if (questionnaire.hasSignature) {
      final sigController = SignatureController(focusNode: FocusNode());
      // A signature is always required whenever the marker is present.
      sigController.validations.add(ValidationUtils.requiredFieldValidation);
      rootSignatureController = sigController;
      rootSignatureView = QuestionnaireSignatureView(
        controller: sigController,
        whoSigns: controller.whoSignsProvider?.call(),
        signsOnBehalfOf: controller.signsOnBehalfOfProvider?.call(),
        item: QuestionnaireItem(
          linkId: 'signature',
          type: QuestionnaireItemType.display.asFhirCode,
        ),
      );
    }
    loading(false);
  }

  int get listViewCount =>
      itemBundles.length +
      (questionnaire.title.isNotEmpty ? 1 : 0) +
      (rootSignatureView != null ? 1 : 0);

  bool get allowSubmit => !isLoading && widget.onSubmit != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: showFAB,
        builder: (context, value, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !showFAB.value ? const SizedBox() : child,
          );
        },
        child: FractionallySizedBox(
          key: ValueKey('showFAB: ${showFAB.value}'),
          widthFactor: 0.8,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 16),
            child: FloatingActionButton.extended(
              shape: const StadiumBorder(),
              backgroundColor: allowSubmit ? null : theme.disabledColor,
              foregroundColor: allowSubmit ? null : theme.disabledColor,
              onPressed: allowSubmit ? onSubmit : null,
              label: Text(
                QuestionnaireLocalization.instance.localization.btnSubmit,
              ),
            ),
          ),
        ),
      ),
      body: UnfocusView(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: QuestionnaireLoadingView(),
              )
            : buildHighlightScope(
                Scrollbar(
                  child: ListView.builder(
                    primary: true,
                    addAutomaticKeepAlives: true,
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: fabSize + 64,
                    ),
                    shrinkWrap: true,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemBuilder: (context, index) => KeyedSubtree(
                      key: _listIndexKeys.putIfAbsent(
                        index,
                        () => GlobalKey(debugLabel: 'questionnaire[$index]'),
                      ),
                      child: buildListItem(context, index),
                    ),
                    // separatorBuilder: (context, index) =>
                    //     const SizedBox(height: 24.0),
                    itemCount: listViewCount,
                  ),
                ),
              ),
      ),
    );
  }

  /// Places a [QuestionnaireHighlightScope] above [child] when a
  /// [QuestionnaireView.formController] is given.
  Widget buildHighlightScope(Widget child) {
    final formController = widget.formController;
    return formController == null
        ? child
        : QuestionnaireHighlightScope(
            highlighted: formController.highlightedView,
            child: child,
          );
  }

  /// The list child at [index]: the title, an item or the root signature.
  Widget buildListItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    if (index == 0 && questionnaire.title.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Text(
          questionnaire.title!,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    final itemIndex = index - (questionnaire.title.isNotEmpty ? 1 : 0);
    if (itemIndex < itemBundles.length) {
      return itemBundles[itemIndex].view;
    }
    // Trailing root level signature (last element).
    return rootSignatureView!;
  }

  bool validate() {
    setState(() {});
    final invalid = validateItems();
    if (invalid.isNotEmpty) {
      setState(() {});
      scrollToInvalidItem(invalid.first);
    }
    return invalid.isEmpty;
  }

  /// Validates every item, nested ones and the root level signature included,
  /// so each invalid one shows its error. Returns the views of the invalid
  /// items in display order; empty when the form is valid.
  List<QuestionnaireItemView> validateItems() {
    final invalid = <QuestionnaireItemView>[];
    void validateAll(List<QuestionnaireItemBundle> bundles) {
      for (final bundle in bundles) {
        bool isValid = true;
        for (final controller in bundle.controllers) {
          isValid = controller.validate() && isValid;
        }
        if (!isValid) invalid.add(bundle.view);
        validateAll(bundle.children ?? []);
      }
    }

    validateAll(itemBundles);
    if (!(rootSignatureController?.validate() ?? true)) {
      invalid.add(rootSignatureView!);
    }
    return invalid;
  }

  /// Scrolls to the invalid item [view] (see [validateItems]) and focuses it.
  Future<void> scrollToInvalidItem(QuestionnaireItemView view) async {
    final topLevelIndex = identical(view, rootSignatureView)
        ? itemBundles.length
        : itemBundles.indexWhere(
            (bundle) =>
                _flattenItemBundles([bundle])
                    .any((nested) => identical(nested.view, view)),
          );
    if (topLevelIndex < 0) return;
    await scrollToItem(view, topLevelIndex: topLevelIndex);
    if (!mounted) return;
    final focusNode = view.controller.focusNode;
    if (focusNode != null && focusNode.context != null) {
      focusNode.requestFocus();
    }
  }

  /// Scrolls until [view] is entirely visible, clear of the floating Submit
  /// button, and completes once it is. [view] is the view of one of
  /// [itemBundles] (nested ones included) or [rootSignatureView];
  /// [topLevelIndex] is the index in [itemBundles] of the item it is, or is
  /// nested under ([itemBundles]' length for the root signature).
  ///
  /// An item that is not built yet is reached by moving the list towards it
  /// first. An item taller than the screen is aligned to its top. Returns
  /// whether the item could be reached.
  Future<bool> scrollToItem(
    QuestionnaireItemView view, {
    required int topLevelIndex,
  }) async {
    final listIndex = topLevelIndex + (questionnaire.title.isNotEmpty ? 1 : 0);
    if (!await _buildListIndex(listIndex)) return false;
    // An item's size renderer publishes its key in the frame after the item
    // is built.
    var target = _mountedContext(view.controller.key);
    if (target == null) {
      await _nextFrame();
      target = _mountedContext(view.controller.key);
    }
    if (target == null) {
      if (kDebugMode) {
        debugPrint(
          'QuestionnaireView.scrollToItem: no key for item '
          '"${view.item.linkId}", revealing list index $listIndex instead',
        );
      }
      target = _mountedContext(_listIndexKeys[listIndex]);
    }
    if (target == null || !target.mounted) return false;
    return _revealEntirely(target);
  }

  BuildContext? _mountedContext(GlobalKey? key) {
    final context = key?.currentContext;
    return context != null && context.mounted ? context : null;
  }

  Future<void> _nextFrame() async {
    WidgetsBinding.instance.scheduleFrame();
    await WidgetsBinding.instance.endOfFrame;
  }

  List<int> get _builtListIndices => [
    for (final entry in _listIndexKeys.entries)
      if (_mountedContext(entry.value) != null) entry.key,
  ]..sort();

  /// Moves the list until the child at [listIndex] is built.
  Future<bool> _buildListIndex(int listIndex) async {
    for (int attempt = 0; attempt < 60; ++attempt) {
      if (!mounted) return false;
      if (_mountedContext(_listIndexKeys[listIndex]) != null) return true;
      final built = _builtListIndices;
      final position = built.isEmpty
          ? null
          : Scrollable.maybeOf(_mountedContext(_listIndexKeys[built.first])!)
                ?.position;
      if (position == null || !position.hasContentDimensions) {
        await _nextFrame();
        continue;
      }
      // Estimate the distance from the extent of the children built now.
      double builtExtent = 0;
      for (final index in built) {
        final box = _mountedContext(_listIndexKeys[index])?.findRenderObject();
        if (box is RenderBox && box.hasSize) builtExtent += box.size.height;
      }
      final averageExtent = builtExtent / built.length;
      final minStep = position.viewportDimension / 2;
      final distance = listIndex > built.last
          ? math.max(minStep, (listIndex - built.last) * averageExtent)
          : -math.max(minStep, (built.first - listIndex) * averageExtent);
      final target = (position.pixels + distance).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if ((target - position.pixels).abs() < 1) {
        // At the end of the list already: the extent may grow with the next
        // layout, so give it one frame before giving up.
        await _nextFrame();
        if (_mountedContext(_listIndexKeys[listIndex]) != null) return true;
        final again = position.maxScrollExtent;
        if ((again - position.pixels).abs() < 1) return false;
        continue;
      }
      position.jumpTo(target);
      await _nextFrame();
    }
    return _mountedContext(_listIndexKeys[listIndex]) != null;
  }

  /// Scrolls the least needed so the box of [target] is entirely visible,
  /// clear of [QuestionnaireFormController.revealTopMargin] above and of
  /// [QuestionnaireFormController.revealBottomMargin] below.
  Future<bool> _revealEntirely(BuildContext target) async {
    for (int pass = 0; pass < 3; ++pass) {
      // A highlight change resizes the items: measure once they have.
      await widget.formController?.highlightSettled;
      if (!target.mounted) return false;
      final renderObject = target.findRenderObject();
      final viewport = RenderAbstractViewport.maybeOf(renderObject);
      final position = Scrollable.maybeOf(target)?.position;
      if (renderObject == null || viewport == null || position == null) {
        return false;
      }
      final topAligned = viewport.getOffsetToReveal(renderObject, 0).offset;
      final bottomAligned = viewport.getOffsetToReveal(renderObject, 1).offset;
      // The scroll offsets between which the whole box shows.
      final lowest =
          bottomAligned + QuestionnaireFormController.revealBottomMargin;
      final highest = topAligned - QuestionnaireFormController.revealTopMargin;
      double? offset;
      if (lowest > highest) {
        offset = highest; // Taller than the screen: align its top.
      } else if (position.pixels < lowest) {
        offset = lowest;
      } else if (position.pixels > highest) {
        offset = highest;
      }
      if (offset == null) return true;
      offset = offset.clamp(position.minScrollExtent, position.maxScrollExtent);
      if ((offset - position.pixels).abs() < 0.5) return true;
      await position.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    return target.mounted;
  }

  /// Builds the response exactly as the Submit button does, root level
  /// signature included, without validating.
  QuestionnaireResponse buildResponse() {
    var questionnaireResponse = controller.generateResponse(
      questionnaire: questionnaire,
      itemBundles: itemBundles,
    );
    final rootBytes = rootSignatureController?.value;
    if (rootBytes != null) {
      questionnaireResponse = questionnaireResponse.copyWith(
        extension_: [
          ...?questionnaireResponse.extension_,
          controller.buildSignatureExtension(
            rootBytes,
            type: questionnaire.signatureTypeCoding,
          ),
        ],
      );
    }
    return questionnaireResponse;
  }

  /// Flattens the (possibly nested) [itemBundles] tree into a single list.
  List<QuestionnaireItemBundle> _flattenItemBundles(
    List<QuestionnaireItemBundle> bundles,
  ) {
    final result = <QuestionnaireItemBundle>[];
    for (final bundle in bundles) {
      result.add(bundle);
      if (bundle.children?.isNotEmpty == true) {
        result.addAll(_flattenItemBundles(bundle.children!));
      }
    }
    return result;
  }

  /// Every signature controller in the questionnaire: item level ones (anywhere
  /// in the nested tree) plus the root level one.
  List<SignatureController> get signatureControllers => {
    for (final bundle in _flattenItemBundles(itemBundles))
      ...bundle.controllers.whereType<SignatureController>(),
    ?rootSignatureController,
  }.toList();

  ({bool isValid, double offset, FieldController? controller})
  validateRecursive({required List<QuestionnaireItemBundle> fieldBundles}) {
    bool isValid = true;
    FieldController? controller;
    double tempOffset = 0;
    double indexOffset = 0;
    for (int i = 0; i < fieldBundles.length; ++i) {
      final fieldBundle = fieldBundles[i];
      for (final fieldController in fieldBundle.controllers) {
        if (!fieldController.validate() && isValid) {
          isValid = false;
          indexOffset = tempOffset;
          controller = fieldController;
        }
      }
      tempOffset += fieldBundle.controller.size.height;
      if (fieldBundle.children.isNotEmpty) {
        final result = validateRecursive(
          fieldBundles: fieldBundle.children ?? [],
        );
        if (!result.isValid && isValid) {
          isValid = false;
          indexOffset += result.offset;
          controller = result.controller;
        }
      }
    }
    return (isValid: isValid, offset: indexOffset, controller: controller);
  }

  Future<void> scrollToField({
    required FieldController? controller,
    required double indexOffset,
  }) async {
    if (controller == null) return;
    scrollController?.animateTo(
      indexOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      final fieldContext = controller.key.currentContext;
      if (fieldContext == null || !fieldContext.mounted) return;
      Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 100),
        curve: Curves.ease,
      );
    }).whenComplete(
      () => Future.delayed(
        const Duration(milliseconds: 100),
        () => controller.focusNode?.requestFocus(),
      ),
    );
  }

  void onSubmit() {
    // Signature drawings are already committed to their controllers when the
    // user taps "Done" in the signature dialog, so nothing needs flushing here.
    if (validate()) {
      widget.onSubmit?.call(buildResponse());
    }
  }

  void updateFABVisibility() {
    final temp = !isKeyboardVisible && scrollReachedBottom;
    if (showFAB.value != temp) {
      showFAB.value = temp;
      setState(() {});
    }
  }

  void checkKeyboardVisibility() {
    bool keyboardVisible =
        FlutterViewUtils.get(context: context).viewInsets.bottom > 0.0;
    if (isKeyboardVisible != keyboardVisible) {
      isKeyboardVisible = keyboardVisible;
      updateFABVisibility();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    checkKeyboardVisibility();
  }

  @override
  void dispose() {
    widget.formController?.detach(this);
    showFAB.dispose();
    WidgetsBinding.instance.removeObserver(this);
    scrollController?.removeListener(onScrollListener);
    for (final item in itemBundles) {
      item.controller.focusNode?.dispose();
    }
    // Release the heavier HandSignatureControl owned by each signature
    // controller (item level, across the whole tree, plus root level).
    for (final controller in signatureControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
