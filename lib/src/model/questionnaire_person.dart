import 'package:fhir_plus/r4.dart';

class QuestionnairePerson {
  final Reference reference;
  final String name;
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
