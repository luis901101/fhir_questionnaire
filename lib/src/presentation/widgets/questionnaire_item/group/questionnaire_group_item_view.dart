import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 06/24/24.
class QuestionnaireGroupItemView extends QuestionnaireItemView {
  QuestionnaireGroupItemView({
    super.key,
    required super.item,
    super.children,
    super.enableWhenController,
  }) : super(controller: DummyController());

  @override
  State createState() => QuestionnaireGroupItemViewState();
}

class QuestionnaireGroupItemViewState
    extends QuestionnaireItemViewState<QuestionnaireGroupItemView> {
  @override
  bool get handleControllerErrorManually => false;

  @override
  Widget? buildTitleView(BuildContext context, {bool forGroup = false}) => null;
  @override
  Widget? buildHintTextView(BuildContext context) => null;
  @override
  Widget? buildHelperTextView(BuildContext context) => null;

  double? groupTitleHeight;
  @override
  Widget buildBody(BuildContext context) {
    double borderRadius = 0;
    if (theme.inputDecorationTheme.border is OutlineInputBorder) {
      borderRadius = (theme.inputDecorationTheme.border as OutlineInputBorder)
          .borderRadius
          .topLeft
          .x;
    }
    // TODO: support for different ways of presenting the group UI, like using card or container with custom border radius, etc. by using some FHIR extension definition.
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(width: 0.5),
              borderRadius: BorderRadius.circular(borderRadius)),
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: groupTitleHeight != null ? groupTitleHeight! : 24),
          margin: const EdgeInsets.only(top: 14),
          child: children == null
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ?super.buildHintTextView(context),
                    ?super.buildHelperTextView(context),
                    ...children!.map((itemView) => itemView)
                  ],
                ),
        ),
        if (item.title.isNotEmpty || isRequired || (helperTextAsButton && helperText.isNotEmpty))
          Positioned(
              left: 16,
              right: 16,
              top: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizeRenderer(
                  onSizeRendered: onGroupTitleSizeRendered,
                  child: super.buildTitleView(context, forGroup: true)!,
                ),
              )),
      ],
    );
  }

  void onGroupTitleSizeRendered(Size size, GlobalKey key) {
    if (groupTitleHeight == null) {
      setState(() => groupTitleHeight = size.height);
    }
  }
}
