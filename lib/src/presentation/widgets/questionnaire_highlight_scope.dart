import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Tells the item views of a [QuestionnaireView] which one is highlighted.
///
/// [QuestionnaireView] places it above its items when it is given a
/// [QuestionnaireFormController], whose [QuestionnaireFormController.highlight]
/// sets the highlighted view. Each item view compares the value with itself and
/// marks its content (see `QuestionnaireItemViewState.buildHighlight`).
///
/// Its notifier changes only with the highlight, not with every answer, so
/// typing does not rebuild every item.
class QuestionnaireHighlightScope
    extends InheritedNotifier<ValueListenable<QuestionnaireItemView?>> {
  const QuestionnaireHighlightScope({
    super.key,
    required ValueListenable<QuestionnaireItemView?> highlighted,
    required super.child,
  }) : super(notifier: highlighted);

  /// The highlighted view of the nearest scope, or null when [context] is not
  /// under one. Depending on it rebuilds [context] when the highlight changes.
  static ValueListenable<QuestionnaireItemView?>? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<QuestionnaireHighlightScope>()
      ?.notifier;
}
