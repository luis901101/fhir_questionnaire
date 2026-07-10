import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart'
    hide QuestionnaireItemType;
import 'package:flutter/material.dart';

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
        text: questionnaire.title?.valueString,
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
      rootSignatureController = sigController;
      rootSignatureView = QuestionnaireSignatureView(
        controller: sigController,
        whoSigns: controller.whoSignsProvider?.call(),
        signsOnBehalfOf: controller.signsOnBehalfOfProvider?.call(),
        item: QuestionnaireItem(
          linkId: FhirString('signature'),
          type: QuestionnaireItemType.display_,
        ),
      );
    }
    loading(false);
  }

  int get listViewCount =>
      itemBundles.length +
      (questionnaire.title?.valueString.isNotEmpty == true ? 1 : 0) +
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
            : Scrollbar(
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
                  itemBuilder: (context, index) {
                    if (index == 0 &&
                        questionnaire.title?.valueString.isNotEmpty == true) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          questionnaire.title?.valueString ?? '',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final itemIndex =
                        index -
                        (questionnaire.title?.valueString.isNotEmpty == true
                            ? 1
                            : 0);
                    if (itemIndex < itemBundles.length) {
                      return itemBundles[itemIndex].view;
                    }
                    // Trailing root level signature (last element).
                    return rootSignatureView!;
                  },
                  // separatorBuilder: (context, index) =>
                  //     const SizedBox(height: 24.0),
                  itemCount: listViewCount,
                ),
              ),
      ),
    );
  }

  bool validate() {
    setState(() {});
    final validation = validateRecursive(fieldBundles: itemBundles);
    bool isValid = validation.isValid;
    FieldController? invalidController = validation.controller;
    double offset = validation.offset;

    // The root level signature lives outside itemBundles, validate it too.
    final rootSignatureValid = rootSignatureController?.validate() ?? true;
    if (!rootSignatureValid && isValid) {
      isValid = false;
      invalidController = rootSignatureController;
      offset = (scrollController?.hasClients ?? false)
          ? scrollController!.position.maxScrollExtent
          : validation.offset;
    }

    if (!isValid) {
      setState(() {});
      scrollToField(controller: invalidController, indexOffset: offset);
    }
    return isValid;
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
  List<SignatureController> get signatureControllers => [
    ..._flattenItemBundles(
      itemBundles,
    ).map((bundle) => bundle.controller).whereType<SignatureController>(),
    ?rootSignatureController,
  ];

  ({bool isValid, double offset, FieldController? controller})
  validateRecursive({required List<QuestionnaireItemBundle> fieldBundles}) {
    bool isValid = true;
    FieldController? controller;
    double tempOffset = 0;
    double indexOffset = 0;
    for (int i = 0; i < fieldBundles.length; ++i) {
      final fieldBundle = fieldBundles[i];
      if (!fieldBundle.controller.validate() && isValid) {
        isValid = false;
        indexOffset = tempOffset;
        controller = fieldBundle.controller;
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

  Future<void> onSubmit() async {
    // Signature drawings are already committed to their controllers when the
    // user taps "Done" in the signature dialog, so nothing needs flushing here.
    if (validate()) {
      var questionnaireResponse = await controller.generateResponse(
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
      widget.onSubmit?.call(questionnaireResponse);
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
