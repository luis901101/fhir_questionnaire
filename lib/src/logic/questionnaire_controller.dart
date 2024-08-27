import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_path/fhir_path.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/foundation.dart';

class QuestionnaireController {
  /// Allows to override the function to generate individual item response
  /// either to generate a new [QuestionnaireResponseItem] or modify the generated one
  QuestionnaireResponseItem Function(
    QuestionnaireItemBundle itemBundle,
    QuestionnaireResponseItem questionnaireResponseItem,
  )? onGenerateItemResponse;

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
  )? onBuildItemView;

  QuestionnaireController({
    this.onGenerateItemResponse,
    this.onBuildItemView,
  });

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

  QuestionnaireItemBundle? buildQuestionnaireItemBundle({
    required QuestionnaireItem item,
    QuestionnaireItemEnableWhenController? enableWhenController,
    Future<Attachment?> Function()? onAttachmentLoaded,
    String? groupId,
  }) {
    final itemViewOverride = onBuildItemView?.call(
      item,
      enableWhenController,
      onAttachmentLoaded,
    );

    if (itemViewOverride != null) {
      return QuestionnaireItemBundle(
        groupId: groupId,
        item: item,
        controller: itemViewOverride.controller,
        view: itemViewOverride,
      );
    }

    QuestionnaireItemView? itemView;
    List<QuestionnaireItemBundle>? children;
    final itemType = QuestionnaireItemType.valueOf(item.type.value);

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
        final groupIdForChildren =
            '${groupId != null ? "$groupId/" : ""}${item.linkId}';

        children = buildQuestionnaireItemBundles(
          item.item,
          onAttachmentLoaded: onAttachmentLoaded,
          groupId: groupIdForChildren,
        );
        itemView = QuestionnaireGroupItemView(
          item: item,
          enableWhenController: enableWhenController,
          children: children.map((itemBundle) => itemBundle.view).toList(),
        );
        break;
      default:
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
  }) {
    List<QuestionnaireItemBundle> itemBundles = [];
    try {
      for (final QuestionnaireItem item in questionnaireItems ?? []) {
        QuestionnaireItemEnableWhenController? enableWhenController =
            getEnableWhenController(item: item, itemBundles: itemBundles);
        final itemBundle = buildQuestionnaireItemBundle(
          item: item,
          enableWhenController: enableWhenController,
          onAttachmentLoaded: onAttachmentLoaded,
          groupId: groupId,
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

  /// Retrieves all variable definitions defined at the Questionnaire's root
  /// level and calculates their value. Returns a map of variable name / value
  /// pairs that can be used as execution context to evaluate expressions at
  /// a deeper level.
  Map<String, dynamic> _fetchCalculatedExpressionRootVariables({
    required Questionnaire questionnaire,
    required QuestionnaireResponse questionnaireResponse,
  }) {
    final calculatedResults = <String, dynamic>{};

    // capture all top-level variables as list, in order
    final rootExpressions = (questionnaire.extension_ ?? [])
        .where((ext) =>
            ext.url ==
                FhirUri('http://hl7.org/fhir/StructureDefinition/variable') &&
            ext.valueExpression?.language ==
                FhirExpressionLanguage.text_fhirpath)
        .toList();

    for (final exp in rootExpressions) {
      final expression = exp.valueExpression?.expression;
      final expressionName = exp.valueExpression?.name?.value;

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
        final result = walkFhirPath(
          environment: calculatedResults,
          pathExpression: expression,
          context: questionnaireResponse.toJson(),
          resource: questionnaireResponse.toJson(),
        );

        if (result.isNotEmpty) {
          calculatedResults['%$expressionName'] = result.first;
        }
      } catch (e) {
        if (kDebugMode) {
          print(
              'Failed to compute fhirpath expression "$expression", subsequent evaluations may fail as well: $e');
        }
      }
    }

    return calculatedResults;
  }

  /// Calculates the number of unresolved calculated expressions in an item
  /// list. Returns the number of all expression for which no answer value
  /// exists. The number will be the sum of all expressions in the entire
  /// sub tree of items.
  int _nrUnresolvedExpressionsInItemList(
      {required List<QuestionnaireResponseItem>? itemList}) {
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
          .where((ext) =>
              ext.url ==
                  FhirUri(
                      'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression') &&
              ext.valueExpression?.language ==
                  FhirExpressionLanguage.text_fhirpath)
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
  List<QuestionnaireResponseItem>? _resolveFirstCalculatedExpression({
    required Map<String, dynamic> environment,
    required List<QuestionnaireResponseItem>? itemList,
    required QuestionnaireResponse questionnaireResponse,
  }) {
    if (itemList == null) {
      return null;
    }

    final updatedList = List<QuestionnaireResponseItem>.from(itemList);

    // go depth first
    for (int itemIndex = 0; itemIndex < updatedList.length; itemIndex++) {
      if (updatedList[itemIndex].item != null &&
          _nrUnresolvedExpressionsInItemList(
                  itemList: updatedList[itemIndex].item) >
              0) {
        updatedList[itemIndex] = updatedList[itemIndex].copyWith(
            item: _resolveFirstCalculatedExpression(
          environment: environment,
          itemList: updatedList[itemIndex].item,
          questionnaireResponse: questionnaireResponse,
        ));

        return updatedList;
      }
    }

    // if we didn't resolve any child elements, find an element at current level
    for (int itemIndex = 0; itemIndex < updatedList.length; itemIndex++) {
      // skip items that already have an answer
      if (updatedList[itemIndex].answer != null) {
        // remove any extensions that we copied over from the build process
        updatedList[itemIndex] =
            updatedList[itemIndex].copyWith(extension_: null);
        continue;
      }

      final calculatedExpressionExtensions = (updatedList[itemIndex]
                  .extension_ ??
              [])
          .where((ext) =>
              ext.url ==
                  FhirUri(
                      'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression') &&
              ext.valueExpression?.language ==
                  FhirExpressionLanguage.text_fhirpath)
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
          final result = walkFhirPath(
            environment: environment,
            pathExpression: expression,
            context: questionnaireResponse.toJson(),
            resource: questionnaireResponse.toJson(),
          );

          if (result.isNotEmpty) {
            final resultValue = result.first;

            QuestionnaireResponseAnswer? answer;

            if (resultValue is int) {
              answer = QuestionnaireResponseAnswer(
                valueInteger: FhirInteger(resultValue),
              );
            } else if (resultValue is num) {
              answer = QuestionnaireResponseAnswer(
                valueDecimal: FhirDecimal(resultValue),
              );
            } else {
              answer = QuestionnaireResponseAnswer(valueString: resultValue);
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
                'Failed to compute fhirpath expression "$expression", subsequent evaluations may fail as well: $e');
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
  List<QuestionnaireResponseItem>? _resolveItemsWithCalculatedExpressions({
    required Map<String, dynamic> environment,
    required List<QuestionnaireResponseItem>? itemList,
    required QuestionnaireResponse questionnaireResponse,
  }) {
    if (itemList == null) {
      return null;
    }

    var currentNumberOfUnresolvedItems = 0;
    var newNumberOfUnresolvedItems = 0;

    // if we have unresolved items, try to resolve the first and repeat
    // until we reach 0 or calculations stop resolving
    do {
      currentNumberOfUnresolvedItems =
          _nrUnresolvedExpressionsInItemList(itemList: itemList);

      if (currentNumberOfUnresolvedItems > 0) {
        itemList = _resolveFirstCalculatedExpression(
            environment: environment,
            itemList: itemList,
            questionnaireResponse: questionnaireResponse);
      }

      newNumberOfUnresolvedItems =
          _nrUnresolvedExpressionsInItemList(itemList: itemList);
    } while (newNumberOfUnresolvedItems > 0 &&
        newNumberOfUnresolvedItems < currentNumberOfUnresolvedItems);

    return itemList;
  }

  QuestionnaireResponse generateResponse(
      {required Questionnaire questionnaire,
      required List<QuestionnaireItemBundle> itemBundles}) {
    List<QuestionnaireResponseItem> itemResponses =
        generateItemResponses(itemBundles: itemBundles);

    final questionnaireResponse = QuestionnaireResponse(
      questionnaire: questionnaire.asFhirCanonical,
      status: QuestionnaireResponseStatus.completed.asFhirCode,
      item: itemResponses,
    );

    final environment = _fetchCalculatedExpressionRootVariables(
      questionnaire: questionnaire,
      questionnaireResponse: questionnaireResponse,
    );

    final updatedQuestionnaireResponse = questionnaireResponse.copyWith(
      item: _resolveItemsWithCalculatedExpressions(
        itemList: questionnaireResponse.item,
        environment: environment,
        questionnaireResponse: questionnaireResponse,
      ),
    );

    return updatedQuestionnaireResponse;
  }

  QuestionnaireResponseItem? generateItemResponse(
      QuestionnaireItemBundle itemBundle) {
    List<QuestionnaireResponseItem>? childItems;
    List<QuestionnaireResponseAnswer>? answers;
    final itemType = QuestionnaireItemType.valueOf(itemBundle.item.type.value);
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
                      : (itemBundle.controller.rawValue as DateTime).asFhirDate,
                  valueTime: !itemType.isTime
                      ? null
                      : (itemBundle.controller.rawValue as DateTime).asFhirTime,
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
                  valueAttachment: itemBundle.controller.rawValue as Attachment,
                )
              ];
        break;

      /// The answers of a group are the answers of the children
      case QuestionnaireItemType.group:
        if (itemBundle.children.isNotEmpty) {
          childItems = generateItemResponses(itemBundles: itemBundle.children!);
        }
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

  List<QuestionnaireResponseItem> generateItemResponses(
      {required List<QuestionnaireItemBundle> itemBundles}) {
    List<QuestionnaireResponseItem> items = [];
    for (final itemBundle in itemBundles) {
      final item = generateItemResponse(itemBundle);
      if (item != null) {
        items.add(item);
      }
    }

    return items;
  }
}
