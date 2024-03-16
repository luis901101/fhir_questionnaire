import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_drop_down_choice_item_view.dart';

/// Created by luis901101 on 3/13/24.
class QuestionnaireDropDownOpenChoiceItemView
    extends QuestionnaireDropDownChoiceItemView {
  QuestionnaireDropDownOpenChoiceItemView(
      {super.key,
      super.controller,
      required super.item,
      super.isOpen = true,
      super.enableWhenController});
}
