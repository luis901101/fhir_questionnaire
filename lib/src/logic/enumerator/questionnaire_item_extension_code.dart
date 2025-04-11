import 'package:collection/collection.dart';
import 'package:fhir_r4/fhir_r4.dart';

/// Docs: https://hl7.org/fhir/extensions/CodeSystem-questionnaire-item-control.html
enum QuestionnaireItemExtensionCode {
  ///Controls relevant to organizing groups of questions
  group('group'),

  ///	Questions within the group should be listed sequentially
  list('list'),

  ///Questions within the group are rows in the table with possible answers as columns. Used for 'choice' questions. The questions within a group marked with this controlType SHALL provide an enumerated list of options and SHOULD refer to the same set of options, same value set or same expression. In the case of a 'sparse' table where some options aren't available for some questions, the order of the answers in the table is not defined and some rendering tools may refuse to display the group as a table.
  table('table'),

  ///Questions within the group are columns in the table with possible answers as rows. Used for 'choice' questions. The questions within a group marked with this controlType SHALL provide an enumerated list of options and SHOULD refer to the same set of options, same value set or same expression. In the case of a 'sparse' table where some options aren't available for some questions, the order of the answers in the table is not defined and some rendering tools may refuse to display the group as a table.
  htable('htable'),

  ///Questions within the group are columns in the table with each group repetition as a row. Used for single-answer questions.
  gtable('gtable'),

  ///Child items of type='group' within the a 'grid' group are rows, and questions beneath the 'row' groups are organized as columns in the grid. The grid might be fully populated, but could be sparse. Questions may support different data types and/or different answer choices.
  grid('grid'),

  ///	The group is to be continuously visible at the top of the questionnaire
  header('header'),

  ///	The group is to be continuously visible at the bottom of the questionnaire
  footer('footer'),

  ///	Indicates that the content within the group should appear as a logical "page" when rendering the form, such that all enabled items within the page are displayed at once, but items in subsequent groups are not displayed until the user indicates a desire to move to the 'next' group. (Header and footer items may still be displayed.) This designation may also influence pagination when printing questionnaires. If there are items at the same level as a 'page' group that are listed before the 'page' group, they will be treated as a separate page. Header and footer groups for a questionnaire will be rendered on all pages.
  page('page'),

  ///Indicates that the group represents a collection of tabs. All child items SHALL be of type 'group' and SHALL NOT declare any item controls themselves. Each child group represents one tab within the tab container, where the item.title is the label for the tab.
  tab('tab-container'),

  ///Controls relevant to rendering questionnaire display items		true
  display('display'),

  ///Display item is rendered as a paragraph in a sequential position between sibling items (default behavior)
  inline('inline'),

  ///Display item is rendered to the left of the set of answer choices or a scaling control for the parent question item to indicate the meaning of the 'lower' bound. E.g. 'Strongly disagree'
  lower('lower'),

  ///Display item is rendered to the right of the set of answer choices or a scaling control for the parent question item to indicate the meaning of the 'upper' bound. E.g. 'Strongly agree'
  upper('upper'),

  ///Display item is temporarily visible over top of an item if the mouse is positioned over top of the text for the containing item
  flyover('flyover'),

  ///Display item is rendered in a dialog box or similar control if invoked by pushing a button or some other UI-appropriate action to request 'help' for a question, group or the questionnaire as a whole (depending what the display item is nested within)
  help('help'),

  ///Display item is rendered in a dialog box or similar control if invoked by pushing a button or some other UI-appropriate action to request 'legal' info for a question, group or the questionnaire as a whole (depending what the display item is nested within)
  legal('legal'),

  ///Controls relevant to capturing question data		true
  question('question'),

  ///	A control which provides a list of potential matches based on text entered into a control. Used for large choice sets where text-matching is an appropriate discovery mechanism.
  autocomplete('autocomplete'),

  ///Drop down	A control where an item (or multiple items) can be selected from a list that is only displayed when the user is editing the field. This control is best used for small-to-medium sized lists of options that can reasonably be scanned and selected in a drop-down control. If the list of options is managed by ValueSet, the designer should be confident that the set of codes will both be fully available and appropriately sized. For larger lists, the autocomplete control is more appropriate.
  dropDown('drop-down'),

  ///Check-box	A control where choices are listed with a box beside them. The box can be toggled to select or de-select a given choice. Multiple selections may be possible. Commonly useful for repeating items of type constrained by answerOption, answerValueset or answerExpression, however can also be used for boolean (if the checkbox is a 3-state control that allows 'unanswered' as a possibility).
  checkBox('check-box'),

  ///	A control where editing an item spawns a separate dialog box or screen permitting a user to navigate, filter or otherwise discover an appropriate match. Useful for large choice sets where text matching is not an appropriate discovery mechanism. Such screens must generally be tuned for the specific choice list structure.
  lookup('lookup'),

  ///A control where choices are listed with a button beside them. The button can be toggled to select or de-select a given choice. Selecting one item deselects all others. Used for non-repeating items with 'closed' answerOption, answerValueset or answerExpression constraints. Can also be used for boolean so long as there is a button for 'unanswered' or it's possible to deselect all items.
  radioButton('radio-button'),

  ///	A control where an axis is displayed between the high and low values and the control can be visually manipulated to select a value anywhere on the axis.
  slider('slider'),

  ///	A control where a list of numeric or other ordered values can be scrolled through via arrows.
  spinner('spinner'),

  ///A control where a user can type in their answer freely.
  textBox('text-box'),
  ;

  final String code;
  const QuestionnaireItemExtensionCode(this.code);

  static const defaultValue = dropDown;

  @override
  String toString() => code;
  FhirCode get asFhirCode => FhirCode(code);
  static QuestionnaireItemExtensionCode? valueOf(String? code) =>
      QuestionnaireItemExtensionCode.values
          .firstWhereOrNull((value) => value.code == code);
  String get locale => name;

  static List<String> get locales => values.map((e) => e.locale).toList();
}
