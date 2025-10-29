import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_radio_button_choice_item_view.dart';

/// Created by luis901101 on 3/13/24.
class QuestionnaireRadioButtonOpenChoiceItemView
    extends QuestionnaireRadioButtonChoiceItemView {
  QuestionnaireRadioButtonOpenChoiceItemView({
    super.key,
    super.controller,
    required super.item,
    super.isOpen = true,
    super.enableWhenController,
  });
}
