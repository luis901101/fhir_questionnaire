import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/localization/questionnaire_base_localization.dart';
import 'package:fhir_questionnaire/src/localization/questionnaire_localization.dart';
import 'package:flutter/material.dart';
import 'package:fhir_questionnaire/src/controller/questionnaire_controller.dart';
import 'package:fhir_questionnaire/src/utils/flutter_view_utils.dart';
import 'package:fhir_questionnaire/src/utils/questionnaire_item_bundle.dart';
import 'package:fhir_questionnaire/src/utils/questionnaire_loading_view.dart';
import 'package:fhir_questionnaire/src/utils/text_utils.dart';
import 'package:fhir_questionnaire/src/utils/unfocus_view.dart';

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
  final isKeyboardVisible = ValueNotifier<bool>(false);
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
    bottomPadding = FlutterViewUtils.get().padding.bottom;
    if (!widget.isLoading) {
      QuestionnaireLocalization.instance.init(
        defaultLocalization: widget.defaultLocalization,
        localizations: widget.localizations,
        locale: widget.locale,
      );
      buildQuestionnaireItems();
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
        valueListenable: isKeyboardVisible,
        builder: (context, value, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isKeyboardVisible.value ? const SizedBox() : child,
          );
        },
        child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 16),
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: Text(
                    QuestionnaireLocalization.instance.localization.btnSubmit),
              ),
            )),
      ),
      body: UnfocusView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const QuestionnaireLoadingView()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (questionnaire.title.isNotEmpty) ...[
                      Text(
                        questionnaire.title!,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24.0),
                    ],
                    Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(
                              bottom: kFloatingActionButtonMargin + 72),
                          shrinkWrap: true,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemBuilder: (context, index) {
                            return itemBundles[index].view;
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16.0),
                          itemCount: itemBundles.length),
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
    FocusNode? focusNode;
    for (final item in itemBundles) {
      if (!item.controller.validate() && isValid) {
        isValid = false;
        focusNode = item.controller.focusNode;
      }
    }
    focusNode?.requestFocus();
    return isValid;
  }

  void onSubmit() {
    if (validate()) {
      final questionnaireResponse = QuestionnaireController.generateResponse(
          questionnaire: questionnaire, itemBundles: itemBundles);
      widget.onSubmit(questionnaireResponse);
    }
  }

  void checkKeyboardVisibility() {
    bool keyboardVisible =
        FlutterViewUtils.get(context: context).viewInsets.bottom > 0.0;
    if (isKeyboardVisible.value != keyboardVisible) {
      isKeyboardVisible.value = keyboardVisible;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    checkKeyboardVisibility();
  }

  @override
  void dispose() {
    isKeyboardVisible.dispose();
    WidgetsBinding.instance.removeObserver(this);
    for (final item in itemBundles) {
      item.controller.focusNode?.dispose();
    }
    super.dispose();
  }
}
