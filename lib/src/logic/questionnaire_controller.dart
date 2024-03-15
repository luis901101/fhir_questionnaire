import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_check_box_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_drop_down_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_radio_button_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/date/questionnaire_date_time_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/open_choice/questionnaire_check_box_open_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/open_choice/questionnaire_drop_down_open_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/open_choice/questionnaire_radio_button_open_choice_item_view.dart';
import 'package:flutter/foundation.dart';

class QuestionnaireController {
  static QuestionnaireItemView? _buildChoiceItemView(
      {required QuestionnaireItem item}) {
    if (item.repeats?.value == true) {
      return QuestionnaireCheckBoxChoiceItemView(
        item: item,
      );
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
  }

  static QuestionnaireItemView? _buildOpenChoiceItemView(
      {required QuestionnaireItem item}) {
    if (item.repeats?.value == true) {
      return QuestionnaireCheckBoxOpenChoiceItemView(
        item: item,
      );
    } else {
      if (QuestionnaireItemExtensionCode.valueOf(item.extension_?.firstOrNull
              ?.valueCodeableConcept?.coding?.firstOrNull?.code?.value) ==
          QuestionnaireItemExtensionCode.dropDown) {
        return QuestionnaireDropDownOpenChoiceItemView(
          item: item,
        );
      } else {
        return QuestionnaireRadioButtonOpenChoiceItemView(
          item: item,
        );
      }
    }
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
          QuestionnaireItemType.choice => _buildChoiceItemView(item: item),
          QuestionnaireItemType.openChoice =>
            _buildOpenChoiceItemView(item: item),
          QuestionnaireItemType.date ||
          QuestionnaireItemType.time ||
          QuestionnaireItemType.dateTime =>
            QuestionnaireDateTimeItemView(
              item: item,
              type: DateTimeType.fromQuestionnaireItemType(itemType),
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

  static List<QuestionnaireResponseAnswer> _generateChoiceAnswer(dynamic data) {
    final answers = <QuestionnaireResponseAnswer>[];
    if (data is QuestionnaireAnswerOption) {
      answers.add(QuestionnaireResponseAnswer(
        valueCoding: data.valueCoding,
        valueString: data.valueString,
        valueInteger: data.valueInteger,
      ));
    } else if (data is List<QuestionnaireAnswerOption>) {
      for (final answerOption in data) {
        answers.addAll(_generateChoiceAnswer(answerOption));
      }
    }

    return answers;
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
          List<QuestionnaireResponseAnswer>? answers = switch (itemType) {
            QuestionnaireItemType.string || QuestionnaireItemType.text => [
                QuestionnaireResponseAnswer(
                  valueString: itemBundle.controller.rawValue?.toString(),
                )
              ],
            QuestionnaireItemType.integer => [
                QuestionnaireResponseAnswer(
                  valueInteger: IntUtils.tryParse(
                          itemBundle.controller.rawValue?.toString())
                      ?.asFhirInteger,
                )
              ],
            QuestionnaireItemType.decimal => [
                QuestionnaireResponseAnswer(
                  valueDecimal: DoubleUtils.tryParse(
                          itemBundle.controller.rawValue?.toString())
                      ?.asFhirDecimal,
                )
              ],
            QuestionnaireItemType.choice ||
            QuestionnaireItemType.openChoice =>
              _generateChoiceAnswer(itemBundle.controller.rawValue),
            QuestionnaireItemType.date =>
              itemBundle.controller.rawValue is! DateTime
                  ? null
                  : [
                      QuestionnaireResponseAnswer(
                        valueDate: (itemBundle.controller.rawValue as DateTime)
                            .asFhirDate,
                      )
                    ],
            QuestionnaireItemType.time =>
              itemBundle.controller.rawValue is! DateTime
                  ? null
                  : [
                      QuestionnaireResponseAnswer(
                        valueTime: (itemBundle.controller.rawValue as DateTime)
                            .asFhirTime,
                      )
                    ],
            QuestionnaireItemType.dateTime =>
              itemBundle.controller.rawValue is! DateTime
                  ? null
                  : [
                      QuestionnaireResponseAnswer(
                        valueDateTime:
                            (itemBundle.controller.rawValue as DateTime)
                                .asFhirDateTime,
                      )
                    ],
            _ => null,
          };

          return QuestionnaireResponseItem(
            linkId: itemBundle.item.linkId,
            definition: itemBundle.item.definition,
            text: itemBundle.item.text,
            answer: answers,
          );
        }).toList());
  }
}
