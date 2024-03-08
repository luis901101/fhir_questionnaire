import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/enumerator/questionnaire_item_type.dart';
import 'package:fhir_questionnaire/src/enumerator/questionnaire_response_status.dart';
import 'package:fhir_questionnaire/src/item/questionnaire_decimal_item_view.dart';
import 'package:fhir_questionnaire/src/item/questionnaire_integer_item_view.dart';
import 'package:fhir_questionnaire/src/item/questionnaire_string_item_view.dart';
import 'package:fhir_questionnaire/src/item/questionnaire_text_item_view.dart';
import 'package:fhir_questionnaire/src/utils/questionnaire_item_bundle.dart';
import 'package:fhir_questionnaire/src/utils/questionnaire_utils.dart';
import 'package:fhir_questionnaire/src/utils/num_utils.dart';
import 'package:flutter/foundation.dart';

class QuestionnaireController {
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
