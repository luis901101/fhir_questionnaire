import 'package:fhir/r4.dart';
import 'package:collection/collection.dart';

/// Docs: https://hl7.org/fhir/R4/valueset-questionnaire-answers-status.html
enum QuestionnaireResponseStatus {
  /// This QuestionnaireResponse has been partially filled out with answers but changes or additions are still expected to be made to it.
  inProgress('in-progress'),

  /// This QuestionnaireResponse has been filled out with answers and the current content is regarded as definitive.
  completed('completed'),

  /// This QuestionnaireResponse has been filled out with answers, then marked as complete, yet changes or additions have been made to it afterwards.
  amended('amended'),

  /// This QuestionnaireResponse was entered in error and voided.
  enteredInError('entered-in-error'),

  /// This QuestionnaireResponse has been partially filled out with answers but has been abandoned. It is unknown whether changes or additions are expected to be made to it.
  stopped('stopped'),
  ;

  final String name;
  const QuestionnaireResponseStatus(this.name);

  FhirCode get asFhirCode => FhirCode(name);

  static QuestionnaireResponseStatus? valueOf(String? name) =>
      QuestionnaireResponseStatus.values
          .firstWhereOrNull((value) => value.name == name);
}
