import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/foundation.dart';

class QuestionnaireController {
  QuestionnaireController();

  /// Allows modification on a [QuestionnaireResponseItem] when generating
  /// the [QuestionnaireResponse] object. This callback would be a great
  /// to add extensions on a [QuestionnaireResponseItem].
  QuestionnaireResponseItem Function(
    QuestionnaireItemBundle questionnaireItemBundle,
    QuestionnaireResponseItem item,
  )? questionnaireResponseItemMapper;

  QuestionnaireItemView? buildChoiceItemView(
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

  QuestionnaireItemView? buildOpenChoiceItemView(
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

  QuestionnaireItemEnableWhenController? getEnableWhenController({
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

  List<QuestionnaireItemBundle> buildQuestionnaireItemBundles(
      List<QuestionnaireItem>? questionnaireItems,
      {required Future<Attachment?> Function()? onAttachmentLoaded}) {
    List<QuestionnaireItemBundle> itemBundles = [];
    try {
      for (final QuestionnaireItem item in questionnaireItems ?? []) {
        QuestionnaireItemEnableWhenController? enableWhenController =
            getEnableWhenController(item: item, itemBundles: itemBundles);
        final itemType = QuestionnaireItemType.valueOf(item.type.value);

        QuestionnaireItemView? itemView;
        List<QuestionnaireItemBundle>? children;

        switch (itemType) {
          case QuestionnaireItemType.string:
            itemView = QuestionnaireStringItemView(
              item: item,
              enableWhenController: enableWhenController,
            );
            break;
          case QuestionnaireItemType.text:
            itemView = QuestionnaireTextItemView(
              item: item,
              enableWhenController: enableWhenController,
            );
            break;
          case QuestionnaireItemType.integer:
            itemView = QuestionnaireIntegerItemView(
              item: item,
              enableWhenController: enableWhenController,
            );
            break;
          case QuestionnaireItemType.decimal:
            itemView = QuestionnaireDecimalItemView(
              item: item,
              enableWhenController: enableWhenController,
            );
            break;
          case QuestionnaireItemType.boolean:
            itemView = QuestionnaireBooleanItemView(
              item: item,
              enableWhenController: enableWhenController,
            );
            break;
          case QuestionnaireItemType.choice:
            itemView = buildChoiceItemView(
                item: item, enableWhenController: enableWhenController);
            break;
          case QuestionnaireItemType.openChoice:
            itemView = buildOpenChoiceItemView(
                item: item, enableWhenController: enableWhenController);
            break;
          case QuestionnaireItemType.date:
          case QuestionnaireItemType.time:
          case QuestionnaireItemType.dateTime:
            itemView = QuestionnaireDateTimeItemView(
              item: item,
              enableWhenController: enableWhenController,
              type: DateTimeType.fromQuestionnaireItemType(itemType),
            );
            break;
          case QuestionnaireItemType.quantity:
            itemView = QuestionnaireQuantityItemView(
              item: item,
              enableWhenController: enableWhenController,
            );
            break;
          case QuestionnaireItemType.url:
            itemView = QuestionnaireUrlItemView(
              item: item,
              enableWhenController: enableWhenController,
            );
            break;
          case QuestionnaireItemType.display:
            itemView = QuestionnaireDisplayItemView(
              item: item,
              enableWhenController: enableWhenController,
            );
            break;
          case QuestionnaireItemType.attachment:
            itemView = QuestionnaireAttachmentItemView(
              item: item,
              onAttachmentLoaded: onAttachmentLoaded,
              enableWhenController: enableWhenController,
            );
            break;
          case QuestionnaireItemType.group:
            children = buildQuestionnaireItemBundles(item.item,
                onAttachmentLoaded: onAttachmentLoaded);
            itemView = QuestionnaireGroupItemView(
              item: item,
              enableWhenController: enableWhenController,
              children: children.map((itemBundle) => itemBundle.view).toList(),
            );
            break;
          default:
        }
        if (itemView != null) {
          itemBundles.add(QuestionnaireItemBundle(
            item: item,
            view: itemView,
            children: children,
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

  List<QuestionnaireItemBundle> buildQuestionnaireItems(
      Questionnaire questionnaire,
      {Future<Attachment?> Function()? onAttachmentLoaded}) {
    List<QuestionnaireItemBundle> itemBundles = [];
    try {
      itemBundles.addAll(buildQuestionnaireItemBundles(questionnaire.item,
          onAttachmentLoaded: onAttachmentLoaded));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return itemBundles;
  }

  List<QuestionnaireResponseAnswer> generateChoiceAnswer(dynamic data) {
    final answers = <QuestionnaireResponseAnswer>[];
    if (data is QuestionnaireAnswerOption) {
      answers.add(QuestionnaireResponseAnswer(
        valueCoding: data.valueCoding,
        valueString: data.valueString,
        valueInteger: data.valueInteger,
      ));
    } else if (data is List<QuestionnaireAnswerOption>) {
      for (final answerOption in data) {
        answers.addAll(generateChoiceAnswer(answerOption));
      }
    }

    return answers;
  }

  QuestionnaireResponse generateResponse(
      {required Questionnaire questionnaire,
      required List<QuestionnaireItemBundle> itemBundles}) {
    List<QuestionnaireResponseItem> itemResponses =
        generateItemResponses(itemBundles: itemBundles);

    return QuestionnaireResponse(
      questionnaire: questionnaire.asFhirCanonical,
      status: QuestionnaireResponseStatus.completed.asFhirCode,
      item: itemResponses,
    );
  }

  List<QuestionnaireResponseItem> generateItemResponses(
      {required List<QuestionnaireItemBundle> itemBundles}) {
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
          answers = generateChoiceAnswer(itemBundle.controller.rawValue);
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

        /// The answers of a group are the answers of the children
        case QuestionnaireItemType.group:
          if (itemBundle.children.isNotEmpty) {
            items.addAll(
                generateItemResponses(itemBundles: itemBundle.children!));
          }
          continue;
        default:
      }

      var item = QuestionnaireResponseItem(
        linkId: itemBundle.item.linkId,
        definition: itemBundle.item.definition,
        text: itemBundle.item.text,
        answer: answers.isEmpty ? null : answers,
      );

      if (questionnaireResponseItemMapper != null) {
        item = questionnaireResponseItemMapper!.call(itemBundle, item);
      }

      items.add(item);
    }

    return items;
  }
}
