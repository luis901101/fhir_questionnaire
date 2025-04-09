import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  double? groupTitleHeight;
  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
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
                  children: children!.map((itemView) => itemView).toList(),
                ),
        ),
        if (item.title.isNotEmpty)
          Positioned(
              left: 16,
              right: 16,
              top: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizeRenderer(
                    onSizeRendered: onGroupTitleSizeRendered,
                    child: Text(
                      '${item.extension_?.translation(Intl.defaultLocale) ?? item.title}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
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
