import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';

/// Docs: https://hl7.org/fhir/R4/valueset-item-type.html
enum QuestionnaireItemType {
  /// An item with no direct answer but should have at least one child item.
  group('group'),

  /// Text for display that will not capture an answer or have child items.
  display('display'),

  /// An item that defines a specific answer to be captured, and which may have child items. (the answer provided in the QuestionnaireResponse should be of the defined datatype).
  question('question'),

  /// Question with a yes/no answer (valueBoolean).
  boolean('boolean'),

  /// Question with is a real number answer (valueDecimal).
  decimal('decimal'),

  /// Question with an integer answer (valueInteger).
  integer('integer'),

  /// Question with a date answer (valueDate).
  date('date'),

  /// Time	Question with a date and time answer (valueDateTime).
  dateTime('dateTime'),

  /// Question with a time (hour:minute:second) answer independent of date. (valueTime).
  time('time'),

  /// Question with a short (few words to short sentence) free-text entry answer (valueString).
  string('string'),

  /// Question with a long (potentially multi-paragraph) free-text entry answer (valueString).
  text('text'),

  /// Question with a URL (website, FTP site, etc.) answer (valueUri).
  url('url'),

  /// Question with a Coding drawn from a list of possible answers (specified in either the answerOption property, or via the valueset referenced in the answerValueSet property) as an answer (valueCoding).
  choice('choice'),

  /// choice	Open Choice	Answer is a Coding drawn from a list of possible answers (as with the choice type) or a free-text entry in a string (valueCoding or valueString).
  openChoice('open-choice'),

  /// Question with binary content such as an image, PDF, etc. as an answer (valueAttachment).
  attachment('attachment'),

  /// Question with a reference to another resource (practitioner, organization, etc.) as an answer (valueReference).
  reference('reference'),

  /// Question with a combination of a numeric value and unit, potentially with a comparator (<, >, etc.) as an answer. (valueQuantity) There is an extension 'http://hl7.org/fhir/StructureDefinition/questionnaire-unit' that can be used to define what unit should be captured (or the unit that has a ucum conversion from the provided unit).
  quantity('quantity'),
  ;

  final String code;
  const QuestionnaireItemType(this.code);

  static const defaultValue = string;

  @override
  String toString() => code;
  FhirCode get asFhirCode => FhirCode(code);
  static QuestionnaireItemType? valueOf(String? code) =>
      QuestionnaireItemType.values
          .firstWhereOrNull((value) => value.code == code);
  String get locale => name;

  static List<String> get locales => values.map((e) => e.locale).toList();
}
