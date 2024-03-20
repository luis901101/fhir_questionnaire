import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_questionnaire/src/logic/utils/iterable_utils.dart';
import 'package:fhir_questionnaire/src/model/questionnaire_item_enable_when_bundle.dart';
import 'package:fhir_questionnaire/src/model/questionnaire_item_enable_when_controller.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_check_box_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_drop_down_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/choice/questionnaire_radio_button_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/date/questionnaire_date_time_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/open_choice/questionnaire_check_box_open_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/open_choice/questionnaire_drop_down_open_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/open_choice/questionnaire_radio_button_open_choice_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/quantity/questionnaire_quantity_item_view.dart';
import 'package:flutter/foundation.dart';

class QuestionnaireController {
  static QuestionnaireItemView? _buildChoiceItemView(
      {required QuestionnaireItem item,
      QuestionnaireItemEnableWhenController? enableWhenController}) {
    if (item.repeats?.value == true) {
      return QuestionnaireCheckBoxChoiceItemView(
        item: item,
        enableWhenController: enableWhenController,
      );
    } else {
      if (QuestionnaireItemExtensionCode.valueOf(item.extension_?.firstOrNull
              ?.valueCodeableConcept?.coding?.firstOrNull?.code?.value) ==
          QuestionnaireItemExtensionCode.dropDown) {
        return QuestionnaireDropDownChoiceItemView(
          item: item,
          enableWhenController: enableWhenController,
        );
      } else {
        return QuestionnaireRadioButtonChoiceItemView(
          item: item,
          enableWhenController: enableWhenController,
        );
      }
    }
  }

  static QuestionnaireItemView? _buildOpenChoiceItemView(
      {required QuestionnaireItem item,
      QuestionnaireItemEnableWhenController? enableWhenController}) {
    if (item.repeats?.value == true) {
      return QuestionnaireCheckBoxOpenChoiceItemView(
        item: item,
        enableWhenController: enableWhenController,
      );
    } else {
      if (QuestionnaireItemExtensionCode.valueOf(item.extension_?.firstOrNull
              ?.valueCodeableConcept?.coding?.firstOrNull?.code?.value) ==
          QuestionnaireItemExtensionCode.dropDown) {
        return QuestionnaireDropDownOpenChoiceItemView(
          item: item,
          enableWhenController: enableWhenController,
        );
      } else {
        return QuestionnaireRadioButtonOpenChoiceItemView(
          item: item,
          enableWhenController: enableWhenController,
        );
      }
    }
  }

  static QuestionnaireItemEnableWhenController? getEnableWhenController({
    required QuestionnaireItem item,
    required List<QuestionnaireItemBundle> itemBundles,
  }) {
    QuestionnaireItemEnableWhenController? controller;
    if (item.enableWhen.isNotEmpty) {
      List<QuestionnaireItemEnableWhenBundle> list = [];
      for (final enableWhen in item.enableWhen!) {
        final controller = itemBundles
            .firstWhereOrNull(
                (itemBundle) => itemBundle.item.linkId == enableWhen.question)
            ?.controller;
        if (controller == null) {
          continue;
        }
        list.add(QuestionnaireItemEnableWhenBundle(
          controller: controller,
          expectedAnswer: enableWhen,
        ));
      }
      if (list.isNotEmpty) {
        controller = QuestionnaireItemEnableWhenController(
          enableWhenBundleList: list,
          behavior: item.enableBehavior,
        );
      }
    }
    return controller;
  }

  static Future<List<QuestionnaireItemBundle>> buildQuestionnaireItems(
      Questionnaire questionnaire) async {
    List<QuestionnaireItemBundle> itemBundles = [];
    try {
      for (final QuestionnaireItem item in questionnaire.item ?? []) {
        QuestionnaireItemEnableWhenController? enableWhenController =
            getEnableWhenController(item: item, itemBundles: itemBundles);
        final itemType = QuestionnaireItemType.valueOf(item.type.value);
        final itemView = switch (itemType) {
          QuestionnaireItemType.string => QuestionnaireStringItemView(
              item: item,
              enableWhenController: enableWhenController,
            ),
          QuestionnaireItemType.text => QuestionnaireTextItemView(
              item: item,
              enableWhenController: enableWhenController,
            ),
          QuestionnaireItemType.integer => QuestionnaireIntegerItemView(
              item: item,
              enableWhenController: enableWhenController,
            ),
          QuestionnaireItemType.decimal => QuestionnaireDecimalItemView(
              item: item,
              enableWhenController: enableWhenController,
            ),
          QuestionnaireItemType.choice => _buildChoiceItemView(
              item: item, enableWhenController: enableWhenController),
          QuestionnaireItemType.openChoice => _buildOpenChoiceItemView(
              item: item, enableWhenController: enableWhenController),
          QuestionnaireItemType.date ||
          QuestionnaireItemType.time ||
          QuestionnaireItemType.dateTime =>
            QuestionnaireDateTimeItemView(
              item: item,
              enableWhenController: enableWhenController,
              type: DateTimeType.fromQuestionnaireItemType(itemType),
            ),
          QuestionnaireItemType.quantity => QuestionnaireQuantityItemView(
              item: item,
              enableWhenController: enableWhenController,
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
            QuestionnaireItemType.string ||
            QuestionnaireItemType.text ||
            QuestionnaireItemType.integer ||
            QuestionnaireItemType.decimal =>
              TextUtils.isEmpty(itemBundle.controller.rawValue?.toString())
                  ? null
                  : [
                      QuestionnaireResponseAnswer(
                        valueString: itemType!.isString || itemType.isText
                            ? itemBundle.controller.rawValue?.toString()
                            : null,
                        valueInteger: itemType.isInteger
                            ? IntUtils.tryParse(
                                    itemBundle.controller.rawValue?.toString())
                                ?.asFhirInteger
                            : null,
                        valueDecimal: itemType.isDecimal
                            ? DoubleUtils.tryParse(
                                    itemBundle.controller.rawValue?.toString())
                                ?.asFhirDecimal
                            : null,
                      )
                    ],
            QuestionnaireItemType.choice ||
            QuestionnaireItemType.openChoice =>
              _generateChoiceAnswer(itemBundle.controller.rawValue),
            QuestionnaireItemType.date ||
            QuestionnaireItemType.time ||
            QuestionnaireItemType.dateTime =>
              itemBundle.controller.rawValue is! DateTime
                  ? null
                  : [
                      QuestionnaireResponseAnswer(
                        valueDate: !itemType!.isDate
                            ? null
                            : (itemBundle.controller.rawValue as DateTime)
                                .asFhirDate,
                        valueTime: !itemType.isTime
                            ? null
                            : (itemBundle.controller.rawValue as DateTime)
                                .asFhirTime,
                        valueDateTime: !itemType.isDateTime
                            ? null
                            : (itemBundle.controller.rawValue as DateTime)
                                .asFhirDateTime,
                      )
                    ],
            QuestionnaireItemType.quantity => itemBundle.controller.rawValue
                        is! Quantity ||
                    (itemBundle.controller.rawValue as Quantity).value == null
                ? null
                : [
                    QuestionnaireResponseAnswer(
                      valueQuantity: itemBundle.controller.rawValue as Quantity,
                    )
                  ],
            _ => null,
          };

          return QuestionnaireResponseItem(
            linkId: itemBundle.item.linkId,
            definition: itemBundle.item.definition,
            text: itemBundle.item.text,
            answer: answers.isEmpty ? null : answers,
          );
        }).toList());
  }
}
