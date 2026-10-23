import 'package:collection/collection.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart';

/// A [CustomValueController] for a `choice` or `open-choice` item that also
/// holds the options the item offers: its `answerOption`s plus, for an open
/// choice, the free text answers added to it.
///
/// The options live here rather than in the view's state, so a free text
/// answer set from code (see [QuestionnaireFormController.setAnswer]) is shown
/// as an option, and the options survive the view being rebuilt while the list
/// scrolls.
///
/// [T] is [QuestionnaireAnswerOption] for a single answer, or a
/// `List<QuestionnaireAnswerOption>` when the item repeats.
class QuestionnaireChoiceController<T> extends CustomValueController<T> {
  /// The options the item offers, in display order.
  final List<QuestionnaireAnswerOption> options;

  QuestionnaireChoiceController({
    super.value,
    super.focusNode,
    List<QuestionnaireAnswerOption>? options,
  }) : options = options ?? [];

  /// Returns the option whose `valueString` is [text], adding a new option for
  /// it at the end of [options] when there is none.
  QuestionnaireAnswerOption optionForText(String text) {
    final existing = options.firstWhereOrNull(
      (option) => option.valueString?.valueString == text,
    );
    if (existing != null) return existing;
    final option = QuestionnaireAnswerOption(valueX: FhirString(text));
    options.add(option);
    return option;
  }
}
