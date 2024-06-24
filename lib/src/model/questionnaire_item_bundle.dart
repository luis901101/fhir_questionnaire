import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_item_view.dart';

class QuestionnaireItemBundle {
  /// Use it just to group views
  final String? groupId;
  final QuestionnaireItem item;
  final List<QuestionnaireItemBundle>? children;
  final FieldController controller;
  final QuestionnaireItemView view;

  const QuestionnaireItemBundle({
    this.groupId,
    required this.item,
    this.children,
    required this.controller,
    required this.view,
  });
}
