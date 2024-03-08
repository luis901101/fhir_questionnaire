import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_item_view.dart';

class QuestionnaireItemBundle {
  final QuestionnaireItem item;
  final FieldController controller;
  final QuestionnaireItemView view;

  const QuestionnaireItemBundle({
    required this.item,
    required this.controller,
    required this.view,
  });
}
