import 'package:fhir_plus/r4.dart';

/// A person related to a `QuestionnaireResponse` (its subject, author, source,
/// signer, etc.).
///
/// It pairs the FHIR [reference] written into the response with a human readable
/// [name] and optional [title] shown in the UI (e.g. beneath a signature pad).
class QuestionnairePerson {
  /// The FHIR [Reference] to this person, written into the response (as
  /// `QuestionnaireResponse.subject` / `author` / `source`, or as
  /// `Signature.who` / `onBehalfOf`). Its `display` defaults to [name] when not
  /// already set.
  final Reference reference;

  /// Human readable name of the person, shown in the UI and used as the
  /// [reference]'s `display` fallback.
  final String name;

  /// Optional subtitle for the person, such as a role or job title, shown
  /// beneath the [name].
  final String? title;

  QuestionnairePerson({
    required Reference reference,
    required this.name,
    this.title,
  }) : reference = reference.copyWith(display: reference.display ?? name);

  @override
  bool operator ==(Object other) =>
      other is QuestionnairePerson && other.reference == reference;

  @override
  int get hashCode => reference.hashCode;
}
