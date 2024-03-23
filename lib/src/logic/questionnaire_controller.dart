import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
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
      Questionnaire questionnaire,
      {Future<Attachment?> Function()? onAttachmentLoaded}) async {
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
          QuestionnaireItemType.boolean => QuestionnaireBooleanItemView(
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
          QuestionnaireItemType.url => QuestionnaireUrlItemView(
              item: item,
              enableWhenController: enableWhenController,
            ),
          QuestionnaireItemType.display => QuestionnaireDisplayItemView(
              item: item,
              enableWhenController: enableWhenController,
            ),
          QuestionnaireItemType.attachment => QuestionnaireAttachmentItemView(
              item: item,
              onAttachmentLoaded: onAttachmentLoaded,
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
    List<QuestionnaireResponseItem> items = [];
    for (final itemBundle in itemBundles) {
      List<QuestionnaireResponseAnswer>? answers;
      final itemType =
          QuestionnaireItemType.valueOf(itemBundle.item.type.value);
      switch (itemType) {
        case QuestionnaireItemType.display:

          /// Exclude this type as it doesn't require an answer from the user.
          continue;
        case QuestionnaireItemType.string:
        case QuestionnaireItemType.text:
        case QuestionnaireItemType.url:
        case QuestionnaireItemType.integer:
        case QuestionnaireItemType.decimal:
          answers = TextUtils.isEmpty(
                  itemBundle.controller.rawValue?.toString())
              ? null
              : [
                  QuestionnaireResponseAnswer(
                    valueString: itemType!.isString || itemType.isText
                        ? itemBundle.controller.rawValue?.toString()
                        : null,
                    valueUri: itemType.isUrl
                        ? FhirUri(itemBundle.controller.rawValue!.toString())
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
                ];
          break;
        case QuestionnaireItemType.boolean:
          answers = itemBundle.controller.rawValue is! bool
              ? null
              : [
                  QuestionnaireResponseAnswer(
                      valueBoolean:
                          FhirBoolean(itemBundle.controller.rawValue as bool))
                ];
          break;
        case QuestionnaireItemType.choice:
        case QuestionnaireItemType.openChoice:
          answers = _generateChoiceAnswer(itemBundle.controller.rawValue);
          break;
        case QuestionnaireItemType.date:
        case QuestionnaireItemType.time:
        case QuestionnaireItemType.dateTime:
          answers = itemBundle.controller.rawValue is! DateTime
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
                ];
          break;
        case QuestionnaireItemType.quantity:
          answers = itemBundle.controller.rawValue is! Quantity ||
                  (itemBundle.controller.rawValue as Quantity).value == null
              ? null
              : [
                  QuestionnaireResponseAnswer(
                    valueQuantity: itemBundle.controller.rawValue as Quantity,
                  )
                ];
          break;
        case QuestionnaireItemType.attachment:
          answers = itemBundle.controller.rawValue is! Attachment
              ? null
              : [
                  QuestionnaireResponseAnswer(
                    valueAttachment:
                        itemBundle.controller.rawValue as Attachment,
                  )
                ];
          break;
        default:
      }

      items.add(QuestionnaireResponseItem(
        linkId: itemBundle.item.linkId,
        definition: itemBundle.item.definition,
        text: itemBundle.item.text,
        answer: answers.isEmpty ? null : answers,
      ));
    }

    return QuestionnaireResponse(
        questionnaire: questionnaire.asFhirCanonical,
        status: QuestionnaireResponseStatus.completed.asFhirCode,
        item: items);
  }
}
