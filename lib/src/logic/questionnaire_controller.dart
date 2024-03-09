import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_drop_down_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_radio_button_choice_item_view.dart';
import 'package:flutter/foundation.dart';

class QuestionnaireController {
  static QuestionnaireItemView? _choiceItemView(
      {required QuestionnaireItem item}) {
    if (item.repeats?.value == true) {
      // return QuestionnaireCheckBoxChoiceItemView(item: item,);
    } else {
      if (QuestionnaireItemExtensionCode.valueOf(item.extension_?.firstOrNull
              ?.valueCodeableConcept?.coding?.firstOrNull?.code?.value) ==
          QuestionnaireItemExtensionCode.dropDown) {
        return QuestionnaireDropDownChoiceItemView(
          item: item,
        );
      } else {
        return QuestionnaireRadioButtonChoiceItemView(
          item: item,
        );
      }
    }
    return null;
  }

  static QuestionnaireItemView? _openChoiceItemView(
      {required QuestionnaireItem item}) {
    if (item.repeats?.value == true) {
      // TODO: This case is unlikely and the UI logic is complex, postpone it.
      // return QuestionnaireCheckBoxOpenChoiceItemView(item: item,);
    } else {
      if (QuestionnaireItemExtensionCode.valueOf(item.extension_?.firstOrNull
              ?.valueCodeableConcept?.coding?.firstOrNull?.code?.value) ==
          QuestionnaireItemExtensionCode.dropDown) {
        // TODO:
        // return QuestionnaireDropDownOpenChoiceItemView(item: item,);
      } else {
        // TODO:
        // return QuestionnaireRadioButtonOpenChoiceItemView(item: item,);
      }
    }

    return null;
  }

  static Future<List<QuestionnaireItemBundle>> buildQuestionnaireItems(
      Questionnaire questionnaire) async {
    List<QuestionnaireItemBundle> itemBundles = [];
    try {
      for (final QuestionnaireItem item in questionnaire.item ?? []) {
        final itemType = QuestionnaireItemType.valueOf(item.type.value);
        final itemView = switch (itemType) {
          QuestionnaireItemType.string => QuestionnaireStringItemView(
              item: item,
            ),
          QuestionnaireItemType.text => QuestionnaireTextItemView(
              item: item,
            ),
          QuestionnaireItemType.integer => QuestionnaireIntegerItemView(
              item: item,
            ),
          QuestionnaireItemType.decimal => QuestionnaireDecimalItemView(
              item: item,
            ),
          QuestionnaireItemType.choice => _choiceItemView(item: item),
          QuestionnaireItemType.openChoice => _openChoiceItemView(item: item),
          _ => null,
        };
        if (itemView != null) {
          itemBundles.add(QuestionnaireItemBundle(
            item: item,
            view: itemView,
            controller: itemView.controller,
          ));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return itemBundles;
  }

  static QuestionnaireResponse generateResponse(
      {required Questionnaire questionnaire,
      required List<QuestionnaireItemBundle> itemBundles}) {
    return QuestionnaireResponse(
        questionnaire: questionnaire.asFhirCanonical,
        status: QuestionnaireResponseStatus.completed.asFhirCode,
        item: itemBundles.map((itemBundle) {
          final itemType =
              QuestionnaireItemType.valueOf(itemBundle.item.type.value);
          QuestionnaireResponseAnswer? answer = switch (itemType) {
            QuestionnaireItemType.string ||
            QuestionnaireItemType.text =>
              QuestionnaireResponseAnswer(
                valueString: itemBundle.controller.rawValue?.toString(),
              ),
            QuestionnaireItemType.integer => QuestionnaireResponseAnswer(
                valueInteger: IntUtils.tryParse(
                        itemBundle.controller.rawValue?.toString())
                    ?.asFhirInteger,
              ),
            QuestionnaireItemType.decimal => QuestionnaireResponseAnswer(
                valueDecimal: DoubleUtils.tryParse(
                        itemBundle.controller.rawValue?.toString())
                    ?.asFhirDecimal,
              ),
            QuestionnaireItemType.choice => QuestionnaireResponseAnswer(
                valueCoding: (itemBundle.controller
                        as CustomValueController<QuestionnaireAnswerOption>)
                    .value
                    ?.valueCoding,
                valueString: (itemBundle.controller
                        as CustomValueController<QuestionnaireAnswerOption>)
                    .value
                    ?.valueString,
                valueInteger: (itemBundle.controller
                        as CustomValueController<QuestionnaireAnswerOption>)
                    .value
                    ?.valueInteger,
              ),
            _ => null,
          };

          return QuestionnaireResponseItem(
            linkId: itemBundle.item.linkId,
            definition: itemBundle.item.definition,
            text: itemBundle.item.text,
            answer: answer != null ? [answer] : null,
          );
        }).toList());
  }
}
