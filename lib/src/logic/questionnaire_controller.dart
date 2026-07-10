import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
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

  final FhirPathController fhirPathController;

  /// The subject of the questionnaire response
  final ValueGetter<QuestionnairePerson?>? subjectProvider;

  /// The author of the questionnaire response
  final ValueGetter<QuestionnairePerson?>? authorProvider;

  /// The individual providing the information reflected in the questionnaire respose
  final ValueGetter<QuestionnairePerson?>? sourceProvider;

  /// Who signs the questionaire response or item
  final ValueGetter<QuestionnairePerson?>? whoSignsProvider;

  /// The party on behalf of which the questionnaire response or item is going to be signed
  final ValueGetter<QuestionnairePerson?>? signsOnBehalfOfProvider;

  QuestionnaireController({
    this.onGenerateItemResponse,
    this.onBuildItemView,
    FhirPathController? fhirPathController,
    this.subjectProvider,
    this.authorProvider,
    this.sourceProvider,
    this.whoSignsProvider,
    this.signsOnBehalfOfProvider,
  }) : fhirPathController = fhirPathController ?? FhirPathController();

  QuestionnaireItemView? buildChoiceItemView({
    required QuestionnaireItem item,
    QuestionnaireItemEnableWhenController? enableWhenController,
  }) {
    if (item.repeats?.value == true) {
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
                ?.value,
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
    if (item.repeats?.value == true) {
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
                ?.value,
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
    final itemType = QuestionnaireItemType.valueOf(item.type.value);

    final groupIdForChildren =
        '${groupId != null ? "$groupId/" : ""}${item.linkId}';

    children = buildQuestionnaireItemBundles(
      item.item,
      onAttachmentLoaded: onAttachmentLoaded,
      groupId: groupIdForChildren,
      alreadyBuiltItemBundles: alreadyBuiltItemBundles,
    );

    // When the item requires a signature, the signature field placement depends
    // on the item type:
    //  - group: the signature is rendered INSIDE the group's container as its
    //    last child, so the group view owns the enableWhen gating.
    //  - non-group: the signature view WRAPS the item's normal content and owns
    //    the enableWhen gating.
    // The view that owns the gating gets the real enableWhenController; the other
    // gets null to avoid double init.
    final bool requiresSignature = item.hasSignature;
    final bool isGroupSignature =
        requiresSignature && itemType == QuestionnaireItemType.group;
    final innerEnableWhenController = (requiresSignature && !isGroupSignature)
        ? null
        : enableWhenController;

    // When the signature is rendered inside a group (see the group case below),
    // this holds that field so its controller can drive validation + response.
    QuestionnaireSignatureView? groupSignatureView;

    itemView = onBuildItemView?.call(
      item,
      innerEnableWhenController,
      onAttachmentLoaded,
    );

    if (itemView == null) {
      switch (itemType) {
        case QuestionnaireItemType.string:
          itemView = QuestionnaireStringItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.text:
          itemView = QuestionnaireTextItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.integer:
          itemView = QuestionnaireIntegerItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.decimal:
          itemView = QuestionnaireDecimalItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.boolean:
          itemView = QuestionnaireBooleanItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.choice:
          itemView = buildChoiceItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.openChoice:
          itemView = buildOpenChoiceItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.date:
        case QuestionnaireItemType.time:
        case QuestionnaireItemType.dateTime:
          itemView = QuestionnaireDateTimeItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
            type: DateTimeType.fromQuestionnaireItemType(itemType),
          );
          break;
        case QuestionnaireItemType.quantity:
          itemView = QuestionnaireQuantityItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.url:
          itemView = QuestionnaireUrlItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.display:
          itemView = QuestionnaireDisplayItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.attachment:
          itemView = QuestionnaireAttachmentItemView(
            item: item,
            onAttachmentLoaded: onAttachmentLoaded,
            enableWhenController: innerEnableWhenController,
          );
          break;
        case QuestionnaireItemType.group:
          if (isGroupSignature) {
            groupSignatureView = QuestionnaireSignatureView(
              item: item,
              whoSigns: whoSignsProvider?.call(),
              signsOnBehalfOf: signsOnBehalfOfProvider?.call(),
            );
          }
          itemView = QuestionnaireGroupItemView(
            item: item,
            enableWhenController: innerEnableWhenController,
            children: [
              ...children.map((itemBundle) => itemBundle.view),
              // The signature field is shown inside the group's container, after
              // the group's own items.
              ?groupSignatureView,
            ],
          );
          break;
        default:
      }
    }

    // The controller that drives validation + response for this bundle. For a
    // signature it must be the SignatureController so the existing validation
    // recursion and response generation pick it up automatically.
    FieldController? bundleController = itemView?.controller;

    if (requiresSignature) {
      if (groupSignatureView != null) {
        // The signature field was rendered inside the group's container above;
        // its controller becomes the bundle controller.
        bundleController = groupSignatureView.controller;
      } else {
        // Non-group item (or a custom group view): wrap the built inner view
        // with the signature pad, rendered below the item's normal content. The
        // wrapper owns the enableWhen gating only if the inner view did not
        // already receive it (avoids double init).
        final signatureView = QuestionnaireSignatureView(
          item: item,
          whoSigns: whoSignsProvider?.call(),
          signsOnBehalfOf: signsOnBehalfOfProvider?.call(),
          enableWhenController: innerEnableWhenController == null
              ? enableWhenController
              : null,
          child: itemView,
        );
        itemView = signatureView;
        bundleController = signatureView.controller;
      }
    }

    return itemView != null && bundleController != null
        ? QuestionnaireItemBundle(
            item: item,
            view: itemView,
            children: children,
            controller: bundleController,
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

  /// Builds the `questionnaireresponse-signature` extension holding the captured
  /// signature as a PNG image.
  ///
  /// [type] is the coding declared by the corresponding
  /// `questionnaire-signatureRequired` extension (root or item level) and is
  /// reused verbatim as [Signature.type]. Falls back to a default coding only
  /// when the marker declares none.
  FhirExtension buildSignatureExtension(
    Uint8List pngBytes, {
    List<Coding>? type,
  }) {
    final whoSigns = whoSignsProvider?.call()?.reference ?? Reference();
    final signsOnBehalfOf = signsOnBehalfOfProvider?.call()?.reference;
    return FhirExtension(
      url: FhirUri(FhirConstants.responseSignatureExtensionUrl),
      valueSignature: Signature(
        type: (type == null || type.isEmpty)
            ? [
                Coding(
                  system: FhirUri(FhirConstants.signatureCodingSystem),
                  code: FhirCode(FhirConstants.defaultSignatureCode),
                  display: FhirConstants.defaultSignatureDisplay,
                ),
              ]
            : type,
        when: FhirInstant(DateTime.now().toUtc()),
        who: whoSigns,
        onBehalfOf: whoSigns != signsOnBehalfOf ? signsOnBehalfOf : null,
        sigFormat: FhirCode('image/png'),
        data: FhirBase64Binary(base64.encode(pngBytes)),
      ),
    );
  }

  QuestionnaireResponse generateResponse({
    required Questionnaire questionnaire,
    required List<QuestionnaireItemBundle> itemBundles,
  }) {
    List<QuestionnaireResponseItem> itemResponses = generateItemResponses(
      itemBundles: itemBundles,
    );

    final questionnaireResponse = QuestionnaireResponse(
      questionnaire: questionnaire.asFhirCanonical,
      status: QuestionnaireResponseStatus.completed.asFhirCode,
      item: itemResponses,
      subject: subjectProvider?.call()?.reference,
      author: authorProvider?.call()?.reference,
      source: sourceProvider?.call()?.reference,
    );

    final environment = fhirPathController
        .fetchCalculatedExpressionRootVariables(
          questionnaire: questionnaire,
          questionnaireResponse: questionnaireResponse,
        );

    final updatedQuestionnaireResponse = questionnaireResponse.copyWith(
      item: fhirPathController.resolveItemsWithCalculatedExpressions(
        itemList: questionnaireResponse.item,
        environment: environment,
        questionnaireResponse: questionnaireResponse,
      ),
    );

    return updatedQuestionnaireResponse;
  }

  QuestionnaireResponseItem? generateItemResponse(
    QuestionnaireItemBundle itemBundle,
  ) {
    List<QuestionnaireResponseItem>? childItems;
    List<QuestionnaireResponseAnswer>? answers;
    final itemType = QuestionnaireItemType.valueOf(itemBundle.item.type.value);
    if (itemBundle.children.isNotEmpty) {
      childItems = generateItemResponses(itemBundles: itemBundle.children!);
    }

    // Signature items store the captured signature in the response item's
    // `questionnaireresponse-signature` extension rather than as an `answer`.
    // Handled before the type switch so it works regardless of the item type
    // (typically `group` or `display`).
    if (itemBundle.item.hasSignature) {
      final bytes = itemBundle.controller is SignatureController
          ? (itemBundle.controller as SignatureController).value
          : null;
      final extensions = <FhirExtension>[
        ...?itemBundle.item.extension_,
        if (bytes != null)
          buildSignatureExtension(
            bytes,
            type: itemBundle.item.signatureTypeCoding,
          ),
      ];
      var item = QuestionnaireResponseItem(
        linkId: itemBundle.item.linkId,
        definition: itemBundle.item.definition,
        text: itemBundle.item.text,
        item: childItems,
        extension_: extensions.isEmpty ? null : extensions,
      );
      if (onGenerateItemResponse != null) {
        item = onGenerateItemResponse!.call(itemBundle, item);
      }
      return item;
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
                      ? itemBundle.controller.rawValue?.toString()
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
        initials.add(QuestionnaireInitial(valueBoolean: answer.valueBoolean));
      } else if (answer.valueDecimal != null) {
        initials.add(QuestionnaireInitial(valueDecimal: answer.valueDecimal));
      } else if (answer.valueInteger != null) {
        initials.add(QuestionnaireInitial(valueInteger: answer.valueInteger));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueInteger == answer.valueInteger)) {
            options.add(
              QuestionnaireAnswerOption(valueInteger: answer.valueInteger),
            );
          }
        }
      } else if (answer.valueDate != null) {
        initials.add(QuestionnaireInitial(valueDate: answer.valueDate));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueDate == answer.valueDate)) {
            options.add(QuestionnaireAnswerOption(valueDate: answer.valueDate));
          }
        }
      } else if (answer.valueDateTime != null) {
        initials.add(QuestionnaireInitial(valueDateTime: answer.valueDateTime));
      } else if (answer.valueTime != null) {
        initials.add(QuestionnaireInitial(valueTime: answer.valueTime));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueTime == answer.valueTime)) {
            options.add(QuestionnaireAnswerOption(valueTime: answer.valueTime));
          }
        }
      } else if (answer.valueString != null) {
        initials.add(QuestionnaireInitial(valueString: answer.valueString));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueString == answer.valueString)) {
            options.add(
              QuestionnaireAnswerOption(valueString: answer.valueString),
            );
          }
        }
      } else if (answer.valueUri != null) {
        initials.add(QuestionnaireInitial(valueUri: answer.valueUri));
      } else if (answer.valueAttachment != null) {
        initials.add(
          QuestionnaireInitial(valueAttachment: answer.valueAttachment),
        );
      } else if (answer.valueCoding != null) {
        initials.add(QuestionnaireInitial(valueCoding: answer.valueCoding));
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueCoding == answer.valueCoding)) {
            options.add(
              QuestionnaireAnswerOption(valueCoding: answer.valueCoding),
            );
          }
        }
      } else if (answer.valueQuantity != null) {
        initials.add(QuestionnaireInitial(valueQuantity: answer.valueQuantity));
      } else if (answer.valueReference != null) {
        initials.add(
          QuestionnaireInitial(valueReference: answer.valueReference),
        );
        if (questionItem.type == QuestionnaireItemType.openChoice.asFhirCode) {
          if (!options.any((e) => e.valueReference == answer.valueReference)) {
            options.add(
              QuestionnaireAnswerOption(valueReference: answer.valueReference),
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
