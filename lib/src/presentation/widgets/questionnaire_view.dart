import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/5/24.
class QuestionnaireView extends StatefulWidget {
  final Questionnaire questionnaire;
  final ValueChanged<QuestionnaireResponse> onSubmit;
  final bool isLoading;
  final QuestionnaireBaseLocalization? defaultLocalization;
  final List<QuestionnaireBaseLocalization>? localizations;
  final String? locale;
  const QuestionnaireView({
    super.key,
    required this.questionnaire,
    required this.onSubmit,
    this.isLoading = false,
    this.defaultLocalization,
    this.localizations,
    this.locale,
  });

  @override
  State createState() => QuestionnaireViewState();
}

class QuestionnaireViewState extends State<QuestionnaireView>
    with WidgetsBindingObserver {
  static const fabSize = kFloatingActionButtonMargin + 56;
  ScrollController? scrollController;

  bool isKeyboardVisible = false;
  bool scrollReachedBottom = false;
  final showFAB = ValueNotifier<bool>(false);
  Questionnaire get questionnaire => widget.questionnaire;
  List<QuestionnaireItem> get questionnaireItems => questionnaire.item ?? [];

  late final double bottomPadding;
  List<QuestionnaireItemBundle> itemBundles = [];

  bool _isLoading = true;

  void loading(bool value) {
    if (_isLoading != value) setState(() => _isLoading = value);
  }

  bool get isLoading => widget.isLoading || _isLoading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(onCreated);
    bottomPadding = FlutterViewUtils.get().padding.bottom;
    if (!widget.isLoading) {
      String? locale;
      try {
        locale = widget.locale ??
            FlutterViewUtils.get().platformDispatcher.locale.languageCode;
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

  void onCreated(_) {
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

  Future<void> buildQuestionnaireItems() async {
    itemBundles =
        await QuestionnaireController.buildQuestionnaireItems(questionnaire);
    loading(false);
  }

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
              onPressed: isLoading ? null : onSubmit,
              label: Text(
                  QuestionnaireLocalization.instance.localization.btnSubmit),
            ),
          ),
        ),
      ),
      body: UnfocusView(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: isLoading
              ? const QuestionnaireLoadingView()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (questionnaire.title.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          questionnaire.title!,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                    ],
                    Expanded(
                      child: Scrollbar(
                        child: ListView.builder(
                            addAutomaticKeepAlives: true,
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: fabSize + 64),
                            shrinkWrap: true,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemBuilder: (context, index) {
                              return itemBundles[index].view;
                            },
                            // separatorBuilder: (context, index) =>
                            //     const SizedBox(height: 24.0),
                            itemCount: itemBundles.length),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  bool validate() {
    setState(() {});
    bool isValid = true;
    FieldController? controller;
    double tempOffset = 0;
    double indexOffset = 0;
    for (int i = 0; i < itemBundles.length; ++i) {
      final item = itemBundles[i];
      if (!item.controller.validate() && isValid) {
        isValid = false;
        indexOffset = tempOffset;
        controller = item.controller;
      }
      tempOffset += item.controller.size.height;
    }
    scrollToField(controller: controller, indexOffset: indexOffset);
    return isValid;
  }

  Future<void> scrollToField(
      {required FieldController? controller,
      required double indexOffset}) async {
    if (controller == null) return;
    scrollController?.animateTo(indexOffset,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
    Future.delayed(const Duration(milliseconds: 200), () {
      final fieldContext = controller.key.currentContext;
      if (fieldContext == null) return;
      Scrollable.ensureVisible(fieldContext,
          duration: const Duration(milliseconds: 100), curve: Curves.ease);
    });
    // controller.focusNode?.requestFocus();
  }

  void onSubmit() {
    if (validate()) {
      final questionnaireResponse = QuestionnaireController.generateResponse(
          questionnaire: questionnaire, itemBundles: itemBundles);
      // if (kDebugMode) {
      //   var prettyString = const JsonEncoder.withIndent('  ')
      //       .convert(questionnaireResponse.toJson());
      //   print('''
      //   ========================================================================
      //   $prettyString
      //   ========================================================================
      //   ''');
      //   return;
      // }
      widget.onSubmit(questionnaireResponse);
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
    super.dispose();
  }
}
