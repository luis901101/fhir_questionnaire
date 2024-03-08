import 'package:fhir/r4/r4.dart';

extension QuestionnaireItemUtils on QuestionnaireItem {
  String? get title => text ?? code?.firstOrNull?.display;
}
