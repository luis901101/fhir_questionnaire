import 'package:collection/collection.dart';
import 'package:fhir_r4/fhir_r4.dart' as fhir;
import 'package:fhir_r4_path/fhir_r4_path.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/foundation.dart';

class QuestionnaireController {
  /// Allows to override the function to generate individual item response
  /// either to generate a new [QuestionnaireResponseItem] or modify the generated one
  fhir.QuestionnaireResponseItem Function(
    QuestionnaireItemBundle itemBundle,
    fhir.QuestionnaireResponseItem questionnaireResponseItem,
  )?
  onGenerateItemResponse;

  /// Allows customizing the logic that maps [QuestionnaireItem] objects into
  /// [QuestionnaireItemView] widgets.
  ///
  /// [enableWhenController] needs to be passed to the returned [QuestionnaireItemView]
  /// otherwise the enableWhen functionality of for that QuestionnaireItem will not work.
  /// assuming that questionnaire item has enableWhen values
  QuestionnaireItemView? Function(
    fhir.QuestionnaireItem item,
    QuestionnaireItemEnableWhenController? enableWhenController,
    Future<fhir.Attachment?> Function()? onAttachmentLoaded,
  )?
  onBuildItemView;

  QuestionnaireController({this.onGenerateItemResponse, this.onBuildItemView});

  QuestionnaireItemView? buildChoiceItemView({
    required fhir.QuestionnaireItem item,
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
    required fhir.QuestionnaireItem item,
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
    required fhir.QuestionnaireItem item,
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
    required fhir.QuestionnaireItem item,
    QuestionnaireItemEnableWhenController? enableWhenController,
    Future<fhir.Attachment?> Function()? onAttachmentLoaded,
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
    List<fhir.QuestionnaireItem>? questionnaireItems, {
    required Future<fhir.Attachment?> Function()? onAttachmentLoaded,
    String? groupId,
    List<QuestionnaireItemBundle>? alreadyBuiltItemBundles,
  }) {
    List<QuestionnaireItemBundle> itemBundles = [];
    try {
      for (final fhir.QuestionnaireItem item in questionnaireItems ?? []) {
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
    fhir.Questionnaire questionnaire, {
    Future<fhir.Attachment?> Function()? onAttachmentLoaded,
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

  List<fhir.QuestionnaireResponseAnswer> generateChoiceAnswer(dynamic data) {
    final answers = <fhir.QuestionnaireResponseAnswer>[];
    if (data is fhir.QuestionnaireAnswerOption) {
      answers.add(
        fhir.QuestionnaireResponseAnswer(
          valueX: data.valueCoding ?? data.valueString ?? data.valueInteger,
        ),
      );
    } else if (data is List<fhir.QuestionnaireAnswerOption>) {
      for (final answerOption in data) {
        answers.addAll(generateChoiceAnswer(answerOption));
      }
    }

    return answers;
  }

  /// Retrieves all variable definitions defined at the Questionnaire's root
  /// level and calculates their value. Returns a map of variable name / value
  /// pairs that can be used as execution context to evaluate expressions at
  /// a deeper level.
  Future<Map<String, dynamic>> _fetchCalculatedExpressionRootVariables({
    required fhir.Questionnaire questionnaire,
    required fhir.QuestionnaireResponse questionnaireResponse,
  }) async {
    final calculatedResults = <String, dynamic>{};

    // capture all top-level variables as list, in order
    final rootExpressions = (questionnaire.extension_ ?? [])
        .where(
          (ext) =>
              ext.url.valueString ==
                  'http://hl7.org/fhir/StructureDefinition/variable' &&
              ext.valueExpression?.language ==
                  fhir.ExpressionLanguage.textFhirpath,
        )
        .toList();

    for (final exp in rootExpressions) {
      final expression = exp.valueExpression?.expression;
      final expressionName = exp.valueExpression?.name?.valueString;

      if (expression == null) {
        if (kDebugMode) {
          print('Calculated expression has no expression, skipping.');
        }
        continue;
      }

      if (expressionName == null) {
        if (kDebugMode) {
          print('Calculated expression has no name, skiping.');
        }
        continue;
      }

      try {
        final result = await walkFhirPath(
          environment: calculatedResults,
          pathExpression: expression.valueString!,
          context: questionnaireResponse,
          resource: questionnaireResponse,
        );

        if (result.isNotEmpty) {
          calculatedResults['%$expressionName'] = result.first;
        }
      } catch (e) {
        if (kDebugMode) {
          print(
            'Failed to compute fhirpath expression "$expression", subsequent evaluations may fail as well: $e',
          );
        }
      }
    }

    return calculatedResults;
  }

  /// Calculates the number of unresolved calculated expressions in an item
  /// list. Returns the number of all expression for which no answer value
  /// exists. The number will be the sum of all expressions in the entire
  /// sub tree of items.
  int _nrUnresolvedExpressionsInItemList({
    required List<fhir.QuestionnaireResponseItem>? itemList,
  }) {
    if (itemList == null) {
      return 0;
    }

    int result = 0;

    for (final item in itemList) {
      final childItems = item.item;

      if (childItems != null && childItems.isNotEmpty) {
        result += _nrUnresolvedExpressionsInItemList(itemList: childItems);
      }

      final calculatedExpressions = (item.extension_ ?? [])
          .where(
            (ext) =>
                ext.url.valueString ==
                    'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression' &&
                ext.valueExpression?.language ==
                    fhir.ExpressionLanguage.textFhirpath,
          )
          .toList()
          .length;

      if (calculatedExpressions > 0 && item.answer == null) {
        result++;
      }
    }

    return result;
  }

  /// Attempts to resolve exactly one unresolved calculated expression.
  /// Traverses the tree of items depth-first and will abort after it tried
  /// to resolve the first matching element.
  Future<List<fhir.QuestionnaireResponseItem>?>
  _resolveFirstCalculatedExpression({
    required Map<String, dynamic> environment,
    required List<fhir.QuestionnaireResponseItem>? itemList,
    required fhir.QuestionnaireResponse questionnaireResponse,
  }) async {
    if (itemList == null) {
      return null;
    }

    final updatedList = List<fhir.QuestionnaireResponseItem>.from(itemList);

    // go depth first
    for (int itemIndex = 0; itemIndex < updatedList.length; itemIndex++) {
      if (updatedList[itemIndex].item != null &&
          _nrUnresolvedExpressionsInItemList(
                itemList: updatedList[itemIndex].item,
              ) >
              0) {
        updatedList[itemIndex] = updatedList[itemIndex].copyWith(
          item: await _resolveFirstCalculatedExpression(
            environment: environment,
            itemList: updatedList[itemIndex].item,
            questionnaireResponse: questionnaireResponse,
          ),
        );

        return updatedList;
      }
    }

    // if we didn't resolve any child elements, find an element at current level
    for (int itemIndex = 0; itemIndex < updatedList.length; itemIndex++) {
      // skip items that already have an answer
      if (updatedList[itemIndex].answer != null) {
        // remove any extensions that we copied over from the build process
        updatedList[itemIndex] = updatedList[itemIndex].copyWith(
          extension_: null,
        );
        continue;
      }

      final calculatedExpressionExtensions =
          (updatedList[itemIndex].extension_ ?? [])
              .where(
                (ext) =>
                    ext.url.valueString ==
                        'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression' &&
                    ext.valueExpression?.language ==
                        fhir.ExpressionLanguage.textFhirpath,
              )
              .toList();

      if (calculatedExpressionExtensions.isNotEmpty) {
        final expression =
            calculatedExpressionExtensions.first.valueExpression?.expression;

        if (expression == null) {
          if (kDebugMode) {
            print('Calculated expression has no expression, skipping.');
          }
          continue;
        }

        try {
          final result = await walkFhirPath(
            environment: environment,
            pathExpression: expression.valueString ?? '',
            context: questionnaireResponse,
            resource: questionnaireResponse,
          );

          if (result.isNotEmpty) {
            final resultValue = result.first;

            fhir.QuestionnaireResponseAnswer? answer;

            if (resultValue is int) {
              answer = fhir.QuestionnaireResponseAnswer(
                valueX: fhir.FhirInteger(resultValue),
              );
            } else if (resultValue is num) {
              answer = fhir.QuestionnaireResponseAnswer(
                valueX: fhir.FhirDecimal(resultValue),
              );
            } else {
              answer = fhir.QuestionnaireResponseAnswer(
                valueX: fhir.FhirString(resultValue),
              );
            }

            updatedList[itemIndex] = itemList[itemIndex].copyWith(
              // insert calculation result as answer
              answer: [answer],
              // remove extensions again that were inserted in the builder
              extension_: null,
            );

            return updatedList;
          }
        } catch (e) {
          if (kDebugMode) {
            print(
              'Failed to compute fhirpath expression "$expression", subsequent evaluations may fail as well: $e',
            );
          }
        }
      }
    }

    return updatedList;
  }

  /// Takes a list of questionnaire items and calculates their answer value
  /// if their value is not user input but a calculated expression. Takes
  /// a map of variable name / value pairs as context input as well as the entire
  /// questionnaire response object to support entity-wide value lookups.
  /// The item list will be processed depth-first and then in order, as per
  /// the FHIR spec.
  /// Since items may reference each other, the method will try to resolve
  /// the first expression it finds, then restart at the top. It continues to
  /// do so until the number of unresolved expressions reaches zero or does
  /// not decrease anymore, indicating that it encountered an expression with
  /// an error.
  /// In case an expression with an error is encountered in the middle of
  /// processing, all other unresolved expressions will remain unresolved.
  Future<List<fhir.QuestionnaireResponseItem>?>
  _resolveItemsWithCalculatedExpressions({
    required Map<String, dynamic> environment,
    required List<fhir.QuestionnaireResponseItem>? itemList,
    required fhir.QuestionnaireResponse questionnaireResponse,
  }) async {
    if (itemList == null) {
      return null;
    }

    var currentNumberOfUnresolvedItems = 0;
    var newNumberOfUnresolvedItems = 0;

    // if we have unresolved items, try to resolve the first and repeat
    // until we reach 0 or calculations stop resolving
    do {
      currentNumberOfUnresolvedItems = _nrUnresolvedExpressionsInItemList(
        itemList: itemList,
      );

      if (currentNumberOfUnresolvedItems > 0) {
        itemList = await _resolveFirstCalculatedExpression(
          environment: environment,
          itemList: itemList,
          questionnaireResponse: questionnaireResponse,
        );
      }

      newNumberOfUnresolvedItems = _nrUnresolvedExpressionsInItemList(
        itemList: itemList,
      );
    } while (newNumberOfUnresolvedItems > 0 &&
        newNumberOfUnresolvedItems < currentNumberOfUnresolvedItems);

    return itemList;
  }

  Future<fhir.QuestionnaireResponse> generateResponse({
    required fhir.Questionnaire questionnaire,
    required List<QuestionnaireItemBundle> itemBundles,
  }) async {
    List<fhir.QuestionnaireResponseItem> itemResponses = generateItemResponses(
      itemBundles: itemBundles,
    );

    final questionnaireResponse = fhir.QuestionnaireResponse(
      questionnaire: questionnaire.asFhirCanonical,
      status: fhir.QuestionnaireResponseStatus.completed,
      item: itemResponses,
    );

    final environment = await _fetchCalculatedExpressionRootVariables(
      questionnaire: questionnaire,
      questionnaireResponse: questionnaireResponse,
    );

    final updatedQuestionnaireResponse = questionnaireResponse.copyWith(
      item: await _resolveItemsWithCalculatedExpressions(
        itemList: questionnaireResponse.item,
        environment: environment,
        questionnaireResponse: questionnaireResponse,
      ),
    );

    return updatedQuestionnaireResponse;
  }

  fhir.QuestionnaireResponseItem? generateItemResponse(
    QuestionnaireItemBundle itemBundle,
  ) {
    List<fhir.QuestionnaireResponseItem>? childItems;
    List<fhir.QuestionnaireResponseAnswer>? answers;
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
                if (itemType!.isString || itemType.isText)
                  fhir.QuestionnaireResponseAnswer(
                    valueX: fhir.FhirString(
                      itemBundle.controller.rawValue?.toString(),
                    ),
                  )
                else if (itemType.isUrl)
                  fhir.QuestionnaireResponseAnswer(
                    valueX: fhir.FhirUri(
                      itemBundle.controller.rawValue?.toString(),
                    ),
                  )
                else if (itemType.isInteger)
                  fhir.QuestionnaireResponseAnswer(
                    valueX: IntUtils.tryParse(
                      itemBundle.controller.rawValue?.toString(),
                    )?.asFhirInteger,
                  )
                else if (itemType.isDecimal)
                  fhir.QuestionnaireResponseAnswer(
                    valueX: DoubleUtils.tryParse(
                      itemBundle.controller.rawValue?.toString(),
                    )?.asFhirDecimal,
                  ),
              ];
        break;
      case QuestionnaireItemType.boolean:
        answers = itemBundle.controller.rawValue is! bool
            ? null
            : [
                fhir.QuestionnaireResponseAnswer(
                  valueX: fhir.FhirBoolean(
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
                if (itemType!.isDate)
                  fhir.QuestionnaireResponseAnswer(
                    valueX:
                        (itemBundle.controller.rawValue as DateTime).asFhirDate,
                  )
                else if (itemType.isTime)
                  fhir.QuestionnaireResponseAnswer(
                    valueX:
                        (itemBundle.controller.rawValue as DateTime).asFhirTime,
                  )
                else if (itemType.isDateTime)
                  fhir.QuestionnaireResponseAnswer(
                    valueX: (itemBundle.controller.rawValue as DateTime)
                        .asFhirDateTime,
                  ),
              ];
        break;
      case QuestionnaireItemType.quantity:
        answers =
            itemBundle.controller.rawValue is! fhir.Quantity ||
                (itemBundle.controller.rawValue as fhir.Quantity).value == null
            ? null
            : [
                fhir.QuestionnaireResponseAnswer(
                  valueX: itemBundle.controller.rawValue as fhir.Quantity,
                ),
              ];
        break;
      case QuestionnaireItemType.attachment:
        answers = itemBundle.controller.rawValue is! fhir.Attachment
            ? null
            : [
                fhir.QuestionnaireResponseAnswer(
                  valueX: itemBundle.controller.rawValue as fhir.Attachment,
                ),
              ];
        break;

      case QuestionnaireItemType.group:
        // The answers of a group are the answers of the children
        break;
      default:
    }

    var item = fhir.QuestionnaireResponseItem(
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

  List<fhir.QuestionnaireResponseItem> generateItemResponses({
    required List<QuestionnaireItemBundle> itemBundles,
  }) {
    List<fhir.QuestionnaireResponseItem> items = [];
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

  fhir.QuestionnaireResponseItem? findResponseForItem(
    fhir.QuestionnaireItem questionItem,
    List<fhir.QuestionnaireResponseItem> responseItems,
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

  fhir.QuestionnaireItem fillItemWithInitial(
    fhir.QuestionnaireItem questionItem,
    List<fhir.QuestionnaireResponseAnswer> answers,
  ) {
    List<fhir.QuestionnaireInitial> initials =
        questionItem.initial?.toList() ?? [];
    List<fhir.QuestionnaireAnswerOption> options =
        questionItem.answerOption?.toList() ?? [];
    for (final answer in answers) {
      if (answer.valueBoolean != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueBoolean!));
      } else if (answer.valueDecimal != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueDecimal!));
      } else if (answer.valueInteger != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueInteger!));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueInteger == answer.valueInteger)) {
            options.add(
              fhir.QuestionnaireAnswerOption(valueX: answer.valueInteger!),
            );
          }
        }
      } else if (answer.valueDate != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueDate!));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueDate == answer.valueDate)) {
            options.add(
              fhir.QuestionnaireAnswerOption(valueX: answer.valueDate!),
            );
          }
        }
      } else if (answer.valueDateTime != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueDateTime!));
      } else if (answer.valueTime != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueTime!));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueTime == answer.valueTime)) {
            options.add(
              fhir.QuestionnaireAnswerOption(valueX: answer.valueTime!),
            );
          }
        }
      } else if (answer.valueString != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueString!));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueString == answer.valueString)) {
            options.add(
              fhir.QuestionnaireAnswerOption(valueX: answer.valueString!),
            );
          }
        }
      } else if (answer.valueUri != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueUri!));
      } else if (answer.valueAttachment != null) {
        initials.add(
          fhir.QuestionnaireInitial(valueX: answer.valueAttachment!),
        );
      } else if (answer.valueCoding != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueCoding!));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueCoding == answer.valueCoding)) {
            options.add(
              fhir.QuestionnaireAnswerOption(valueX: answer.valueCoding!),
            );
          }
        }
      } else if (answer.valueQuantity != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueQuantity!));
      } else if (answer.valueReference != null) {
        initials.add(fhir.QuestionnaireInitial(valueX: answer.valueReference!));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueReference == answer.valueReference)) {
            options.add(
              fhir.QuestionnaireAnswerOption(valueX: answer.valueReference!),
            );
          }
        }
      }
    }

    return questionItem.copyWith(initial: initials, answerOption: options);
  }

  List<fhir.QuestionnaireItem> fillItemsWithResponse(
    List<fhir.QuestionnaireItem> questionItems,
    List<fhir.QuestionnaireResponseItem> responseItems,
  ) {
    List<fhir.QuestionnaireItem> result = [];
    for (fhir.QuestionnaireItem questionItem in questionItems) {
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

  Future<fhir.Questionnaire> fillWithResponse(
    fhir.Questionnaire questionnaire,
    fhir.QuestionnaireResponse response,
  ) async {
    return questionnaire.copyWith(
      item: fillItemsWithResponse(
        questionnaire.item ?? <fhir.QuestionnaireItem>[],
        response.item ?? <fhir.QuestionnaireResponseItem>[],
      ),
    );
  }
}
