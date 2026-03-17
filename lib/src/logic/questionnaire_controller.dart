import 'package:collection/collection.dart';
import 'package:fhir_r4/fhir_r4.dart' hide QuestionnaireItemType;
import 'package:fhir_questionnaire/fhir_questionnaire.dart'
    hide QuestionnaireResponseStatus;
import 'package:flutter/foundation.dart';

class QuestionnaireController {
  /// Allows to override the function to generate individual item response
  /// either to generate a new [QuestionnaireResponseItem] or modify the generated one
  QuestionnaireResponseItem Function(
    QuestionnaireItemBundle itemBundle,
    QuestionnaireResponseItem questionnaireResponseItem,
  )?
  onGenerateItemResponse;

  /// Allows customizing the logic that maps [QuestionnaireItem] objects into
  /// [QuestionnaireItemView] widgets.
  ///
  /// [enableWhenController] needs to be passed to the returned [QuestionnaireItemView]
  /// otherwise the enableWhen functionality of for that QuestionnaireItem will not work.
  /// assuming that questionnaire item has enableWhen values
  QuestionnaireItemView? Function(
    QuestionnaireItem item,
    QuestionnaireItemEnableWhenController? enableWhenController,
    Future<Attachment?> Function()? onAttachmentLoaded,
  )?
  onBuildItemView;

  /// Controller responsible for evaluating FHIRPath calculated expressions.
  /// Defaults to a standard [FhirPathController] but can be injected for
  /// testing or custom behaviour.
  final FhirPathController fhirPathController;

  QuestionnaireController({
    this.onGenerateItemResponse,
    this.onBuildItemView,
    FhirPathController? fhirPathController,
  }) : fhirPathController = fhirPathController ?? FhirPathController();

  QuestionnaireItemView? buildChoiceItemView({
    required QuestionnaireItem item,
    QuestionnaireItemEnableWhenController? enableWhenController,
  }) {
    if (item.repeats?.valueBoolean == true) {
      return QuestionnaireCheckBoxChoiceItemView(
        item: item,
        enableWhenController: enableWhenController,
      );
    } else {
      if (QuestionnaireItemExtensionCode.valueOf(
            item
                .extension_
                ?.firstOrNull
                ?.valueCodeableConcept
                ?.coding
                ?.firstOrNull
                ?.code
                ?.valueString,
          ) ==
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

  QuestionnaireItemView? buildOpenChoiceItemView({
    required QuestionnaireItem item,
    QuestionnaireItemEnableWhenController? enableWhenController,
  }) {
    if (item.repeats?.valueBoolean == true) {
      return QuestionnaireCheckBoxOpenChoiceItemView(
        item: item,
        enableWhenController: enableWhenController,
      );
    } else {
      if (QuestionnaireItemExtensionCode.valueOf(
            item
                .extension_
                ?.firstOrNull
                ?.valueCodeableConcept
                ?.coding
                ?.firstOrNull
                ?.code
                ?.valueString,
          ) ==
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
    itemBundles = _flattenItemBundles(itemBundles);

    QuestionnaireItemEnableWhenController? controller;
    if (item.enableWhen.isNotEmpty) {
      List<QuestionnaireItemEnableWhenBundle> list = [];
      for (final enableWhen in item.enableWhen!) {
        final controller = itemBundles
            .firstWhereOrNull(
              (itemBundle) => itemBundle.item.linkId == enableWhen.question,
            )
            ?.controller;
        if (controller == null) {
          continue;
        }
        list.add(
          QuestionnaireItemEnableWhenBundle(
            controller: controller,
            expectedAnswer: enableWhen,
          ),
        );
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

  QuestionnaireItemBundle? buildQuestionnaireItemBundle({
    required QuestionnaireItem item,
    QuestionnaireItemEnableWhenController? enableWhenController,
    Future<Attachment?> Function()? onAttachmentLoaded,
    String? groupId,
    List<QuestionnaireItemBundle>? alreadyBuiltItemBundles,
  }) {
    QuestionnaireItemView? itemView;
    List<QuestionnaireItemBundle>? children;
    final itemType = QuestionnaireItemType.valueOf(item.type.valueString);

    final groupIdForChildren =
        '${groupId != null ? "$groupId/" : ""}${item.linkId}';

    children = buildQuestionnaireItemBundles(
      item.item,
      onAttachmentLoaded: onAttachmentLoaded,
      groupId: groupIdForChildren,
      alreadyBuiltItemBundles: alreadyBuiltItemBundles,
    );

    itemView = onBuildItemView?.call(
      item,
      enableWhenController,
      onAttachmentLoaded,
    );

    if (itemView == null) {
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
            item: item,
            enableWhenController: enableWhenController,
          );
          break;
        case QuestionnaireItemType.openChoice:
          itemView = buildOpenChoiceItemView(
            item: item,
            enableWhenController: enableWhenController,
          );
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
          itemView = QuestionnaireGroupItemView(
            item: item,
            enableWhenController: enableWhenController,
            children: children.map((itemBundle) => itemBundle.view).toList(),
          );
          break;
        default:
      }
    }

    return itemView != null
        ? QuestionnaireItemBundle(
            item: item,
            view: itemView,
            children: children,
            controller: itemView.controller,
            groupId: groupId,
          )
        : null;
  }

  List<QuestionnaireItemBundle> buildQuestionnaireItemBundles(
    List<QuestionnaireItem>? questionnaireItems, {
    required Future<Attachment?> Function()? onAttachmentLoaded,
    String? groupId,
    List<QuestionnaireItemBundle>? alreadyBuiltItemBundles,
  }) {
    List<QuestionnaireItemBundle> itemBundles = [];
    try {
      for (final QuestionnaireItem item in questionnaireItems ?? []) {
        QuestionnaireItemEnableWhenController? enableWhenController =
            getEnableWhenController(
              item: item,
              itemBundles: [...(alreadyBuiltItemBundles ?? []), ...itemBundles],
            );

        final itemBundle = buildQuestionnaireItemBundle(
          item: item,
          enableWhenController: enableWhenController,
          onAttachmentLoaded: onAttachmentLoaded,
          groupId: groupId,
          alreadyBuiltItemBundles: [
            ...(alreadyBuiltItemBundles ?? []),
            ...itemBundles,
          ],
        );
        if (itemBundle != null) {
          itemBundles.add(itemBundle);
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
    Questionnaire questionnaire, {
    Future<Attachment?> Function()? onAttachmentLoaded,
  }) {
    List<QuestionnaireItemBundle> itemBundles = [];
    try {
      itemBundles.addAll(
        buildQuestionnaireItemBundles(
          questionnaire.item,
          onAttachmentLoaded: onAttachmentLoaded,
        ),
      );
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
      answers.add(
        QuestionnaireResponseAnswer(
          valueCoding: data.valueCoding,
          valueString: data.valueString,
          valueInteger: data.valueInteger,
        ),
      );
    } else if (data is List<QuestionnaireAnswerOption>) {
      for (final answerOption in data) {
        answers.addAll(generateChoiceAnswer(answerOption));
      }
    }

    return answers;
  }

  Future<QuestionnaireResponse> generateResponse({
    required Questionnaire questionnaire,
    required List<QuestionnaireItemBundle> itemBundles,
  }) async {
    List<QuestionnaireResponseItem> itemResponses = generateItemResponses(
      itemBundles: itemBundles,
    );

    final questionnaireResponse = QuestionnaireResponse(
      questionnaire: questionnaire.asFhirCanonical,
      status: QuestionnaireResponseStatus.completed,
      item: itemResponses,
    );

    final environment = await fhirPathController
        .fetchCalculatedExpressionRootVariables(
          questionnaire: questionnaire,
          questionnaireResponse: questionnaireResponse,
        );

    final itemsWithCalculatedExpressions = await fhirPathController
        .resolveItemsWithCalculatedExpressions(
          itemList: questionnaireResponse.item,
          environment: environment,
          questionnaireResponse: questionnaireResponse,
        );

    final updatedQuestionnaireResponse = questionnaireResponse.copyWith(
      item: itemsWithCalculatedExpressions,
    );

    return updatedQuestionnaireResponse;
  }

  QuestionnaireResponseItem? generateItemResponse(
    QuestionnaireItemBundle itemBundle,
  ) {
    List<QuestionnaireResponseItem>? childItems;
    List<QuestionnaireResponseAnswer>? answers;
    final itemType = QuestionnaireItemType.valueOf(
      itemBundle.item.type.valueString,
    );
    if (itemBundle.children.isNotEmpty) {
      childItems = generateItemResponses(itemBundles: itemBundle.children!);
    }

    switch (itemType) {
      case QuestionnaireItemType.display:

        /// Exclude this type as it doesn't require an answer from the user.
        return null;
      case QuestionnaireItemType.string:
      case QuestionnaireItemType.text:
      case QuestionnaireItemType.url:
      case QuestionnaireItemType.integer:
      case QuestionnaireItemType.decimal:
        answers = TextUtils.isEmpty(itemBundle.controller.rawValue?.toString())
            ? null
            : [
                QuestionnaireResponseAnswer(
                  valueString: itemType!.isString || itemType.isText
                      ? FhirString(itemBundle.controller.rawValue?.toString())
                      : null,
                  valueUri: itemType.isUrl
                      ? FhirUri(itemBundle.controller.rawValue!.toString())
                      : null,
                  valueInteger: itemType.isInteger
                      ? IntUtils.tryParse(
                          itemBundle.controller.rawValue?.toString(),
                        )?.asFhirInteger
                      : null,
                  valueDecimal: itemType.isDecimal
                      ? DoubleUtils.tryParse(
                          itemBundle.controller.rawValue?.toString(),
                        )?.asFhirDecimal
                      : null,
                ),
              ];
        break;
      case QuestionnaireItemType.boolean:
        answers = itemBundle.controller.rawValue is! bool
            ? null
            : [
                QuestionnaireResponseAnswer(
                  valueBoolean: FhirBoolean(
                    itemBundle.controller.rawValue as bool,
                  ),
                ),
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
                      : (itemBundle.controller.rawValue as DateTime).asFhirDate,
                  valueTime: !itemType.isTime
                      ? null
                      : (itemBundle.controller.rawValue as DateTime).asFhirTime,
                  valueDateTime: !itemType.isDateTime
                      ? null
                      : (itemBundle.controller.rawValue as DateTime)
                            .asFhirDateTime,
                ),
              ];
        break;
      case QuestionnaireItemType.quantity:
        answers =
            itemBundle.controller.rawValue is! Quantity ||
                (itemBundle.controller.rawValue as Quantity).value == null
            ? null
            : [
                QuestionnaireResponseAnswer(
                  valueQuantity: itemBundle.controller.rawValue as Quantity,
                ),
              ];
        break;
      case QuestionnaireItemType.attachment:
        answers = itemBundle.controller.rawValue is! Attachment
            ? null
            : [
                QuestionnaireResponseAnswer(
                  valueAttachment: itemBundle.controller.rawValue as Attachment,
                ),
              ];
        break;

      case QuestionnaireItemType.group:
        // The answers of a group are the answers of the children
        break;
      default:
    }

    var item = QuestionnaireResponseItem(
      linkId: itemBundle.item.linkId,
      definition: itemBundle.item.definition,
      text: itemBundle.item.text,
      answer: answers.isEmpty ? null : answers,
      item: childItems,
      extension_: itemBundle.item.extension_,
    );

    if (onGenerateItemResponse != null) {
      item = onGenerateItemResponse!.call(itemBundle, item);
    }

    return item;
  }

  List<QuestionnaireResponseItem> generateItemResponses({
    required List<QuestionnaireItemBundle> itemBundles,
  }) {
    List<QuestionnaireResponseItem> items = [];
    for (final itemBundle in itemBundles) {
      final item = generateItemResponse(itemBundle);
      if (item != null) {
        items.add(item);
      }
    }

    return items;
  }

  /// Takes a list [QuestionnaireItemBundle] flattens it by extracting all the
  /// child items and putting them all in one list.
  ///
  /// Can be used for searching/filtering a list of [QuestionnaireItemBundle] objects.
  List<QuestionnaireItemBundle> _flattenItemBundles(
    List<QuestionnaireItemBundle> itemBundles,
  ) {
    final flattenedList = <QuestionnaireItemBundle>[];

    for (var itemBundle in itemBundles) {
      flattenedList.add(itemBundle);
      if (itemBundle.children?.isNotEmpty == true) {
        flattenedList.addAll(_flattenItemBundles(itemBundle.children!));
      }
    }

    return flattenedList;
  }

  QuestionnaireResponseItem? findResponseForItem(
    QuestionnaireItem questionItem,
    List<QuestionnaireResponseItem> responseItems,
  ) {
    for (final responseItem in responseItems) {
      if (questionItem.linkId == responseItem.linkId) {
        return responseItem;
      }
      if (responseItem.item.isNotEmpty) {
        final found = findResponseForItem(questionItem, responseItem.item!);
        if (found != null) return found;
      }
    }

    return null;
  }

  QuestionnaireItem fillItemWithInitial(
    QuestionnaireItem questionItem,
    List<QuestionnaireResponseAnswer> answers,
  ) {
    List<QuestionnaireInitial> initials = questionItem.initial?.toList() ?? [];
    List<QuestionnaireAnswerOption> options =
        questionItem.answerOption?.toList() ?? [];
    for (final answer in answers) {
      if (answer.valueBoolean != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueBoolean!));
      } else if (answer.valueDecimal != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueDecimal!));
      } else if (answer.valueInteger != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueInteger!));
        if (questionItem.type.valueString ==
            QuestionnaireItemType.openChoice.code) {
          if (answer.valueInteger != null &&
              !options.any(
                (e) =>
                    e.valueInteger?.valueInt == answer.valueInteger?.valueInt,
              )) {
            options.add(
              QuestionnaireAnswerOption(valueX: answer.valueInteger!),
            );
          }
        }
      } else if (answer.valueDate != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueDate!));
        if (questionItem.type.valueString ==
            QuestionnaireItemType.openChoice.code) {
          if (answer.valueDate != null &&
              !options.any((e) => e.valueDate == answer.valueDate)) {
            options.add(QuestionnaireAnswerOption(valueX: answer.valueDate!));
          }
        }
      } else if (answer.valueDateTime != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueDateTime!));
      } else if (answer.valueTime != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueTime!));
        if (questionItem.type.valueString ==
            QuestionnaireItemType.openChoice.code) {
          if (answer.valueTime != null &&
              !options.any((e) => e.valueTime == answer.valueTime)) {
            options.add(QuestionnaireAnswerOption(valueX: answer.valueTime!));
          }
        }
      } else if (answer.valueString != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueString!));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (answer.valueString != null &&
              !options.any((e) => e.valueString == answer.valueString)) {
            options.add(QuestionnaireAnswerOption(valueX: answer.valueString!));
          }
        }
      } else if (answer.valueUri != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueUri!));
      } else if (answer.valueAttachment != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueAttachment!));
      } else if (answer.valueCoding != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueCoding!));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (answer.valueCoding != null &&
              !options.any((e) => e.valueCoding == answer.valueCoding)) {
            options.add(QuestionnaireAnswerOption(valueX: answer.valueCoding!));
          }
        }
      } else if (answer.valueQuantity != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueQuantity!));
      } else if (answer.valueReference != null) {
        initials.add(QuestionnaireInitial(valueX: answer.valueReference!));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (answer.valueReference != null &&
              !options.any((e) => e.valueReference == answer.valueReference)) {
            options.add(
              QuestionnaireAnswerOption(valueX: answer.valueReference!),
            );
          }
        }
      }
    }

    return questionItem.copyWith(initial: initials, answerOption: options);
  }

  List<QuestionnaireItem> fillItemsWithResponse(
    List<QuestionnaireItem> questionItems,
    List<QuestionnaireResponseItem> responseItems,
  ) {
    List<QuestionnaireItem> result = [];
    for (QuestionnaireItem questionItem in questionItems) {
      final responseItem = findResponseForItem(questionItem, responseItems);
      if (responseItem != null && responseItem.answer.isNotEmpty) {
        questionItem = fillItemWithInitial(
          questionItem,
          responseItem.answer ?? [],
        );
      }
      if (questionItem.item != null && questionItem.item!.isNotEmpty) {
        questionItem = questionItem.copyWith(
          item: fillItemsWithResponse(questionItem.item!, responseItems),
        );
      }
      result.add(questionItem);
    }

    return result;
  }

  Future<Questionnaire> fillWithResponse(
    Questionnaire questionnaire,
    QuestionnaireResponse response,
  ) async {
    return questionnaire.copyWith(
      item: fillItemsWithResponse(
        questionnaire.item ?? <QuestionnaireItem>[],
        response.item ?? <QuestionnaireResponseItem>[],
      ),
    );
  }
}
