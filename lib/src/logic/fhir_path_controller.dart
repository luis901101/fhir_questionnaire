import 'package:fhir_r4/fhir_r4.dart' hide QuestionnaireItemType;
import 'package:fhir_r4_path/fhir_r4_path.dart';
import 'package:fhir_questionnaire_r4/src/logic/utils/fhir_constants.dart';
import 'package:flutter/foundation.dart';

class FhirPathController {
  /// Retrieves all variable definitions defined at the Questionnaire's root
  /// level and calculates their value. Returns a map of variable name / value
  /// pairs that can be used as execution context to evaluate expressions at
  /// a deeper level.
  Future<Map<String, dynamic>> fetchCalculatedExpressionRootVariables({
    required Questionnaire questionnaire,
    required QuestionnaireResponse questionnaireResponse,
  }) async {
    final calculatedResults = <String, dynamic>{};

    // capture all top-level variables as list, in order
    final rootExpressions = (questionnaire.extension_ ?? [])
        .where(
          (ext) =>
              ext.url.valueString == FhirConstants.variableExtensionUrl &&
              ext.valueExpression?.language.valueEnum ==
                  ExpressionLanguageEnum.textFhirpath,
        )
        .toList();

    for (final exp in rootExpressions) {
      final expression = exp.valueExpression?.expression?.valueString;
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
          pathExpression: expression,
          context: questionnaireResponse,
          resource: questionnaireResponse,
        );

        if (result.isNotEmpty) {
          calculatedResults[expressionName] = result;
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
  /// list. Returns the number of all expressions that have not been computed
  /// yet, i.e. items that still carry a calculatedExpression extension. The
  /// number will be the sum of all expressions in the entire sub tree of items.
  ///
  /// Note that an already present answer does NOT mark an expression as
  /// resolved: the answer of an item with a calculatedExpression is owned by
  /// the expression, not by the user input, so whatever the item view produced
  /// gets replaced by the calculated value. Otherwise item types whose view
  /// always yields a value, such as `boolean` which defaults to `false`, would
  /// never let their expression run.
  int nrUnresolvedExpressionsInItemList({
    required List<QuestionnaireResponseItem>? itemList,
  }) {
    if (itemList == null) {
      return 0;
    }

    int result = 0;

    for (final item in itemList) {
      final childItems = item.item;

      if (childItems != null && childItems.isNotEmpty) {
        result += nrUnresolvedExpressionsInItemList(itemList: childItems);
      }

      if (calculatedExpressionsOf(item).isNotEmpty) {
        result++;
      }
    }

    return result;
  }

  /// Returns the calculatedExpression extensions of [item] that this controller
  /// knows how to evaluate.
  List<FhirExtension> calculatedExpressionsOf(QuestionnaireResponseItem item) =>
      (item.extension_ ?? [])
          .where(
            (ext) =>
                ext.url.valueString ==
                    FhirConstants.calculatedExpressionExtensionUrl &&
                ext.valueExpression?.language.valueEnum ==
                    ExpressionLanguageEnum.textFhirpath,
          )
          .toList();

  /// The Questionnaire extension URLs this controller needs to see on the
  /// generated [QuestionnaireResponseItem]s while it resolves expressions.
  ///
  /// They are scratch data: the response builder copies them over from the
  /// [QuestionnaireItem] and [stripExpressionExtensions] removes them again
  /// once every expression has been resolved, so no extension coming from the
  /// Questionnaire ever reaches the emitted [QuestionnaireResponse]. Override
  /// to widen the set when adding support for further expression based
  /// extensions.
  Set<String> get expressionExtensionUrls => {
    FhirConstants.calculatedExpressionExtensionUrl,
  };

  /// Whether [ext] is one of the [expressionExtensionUrls] a response item has
  /// to carry while expressions are being resolved.
  ///
  /// Matches on the url alone, unlike [calculatedExpressionsOf], so that an
  /// extension carried over can never be left behind for lack of a supported
  /// expression language.
  bool isExpressionExtension(FhirExtension ext) =>
      expressionExtensionUrls.contains(ext.url.valueString);

  /// The subset of [extensions] a [QuestionnaireResponseItem] has to carry for
  /// this controller to evaluate it.
  ///
  /// Returns `null` rather than an empty list when there is nothing to carry,
  /// as an empty list would serialize as an empty `extension` array.
  List<FhirExtension>? expressionExtensionsOf(
    Iterable<FhirExtension>? extensions,
  ) {
    final result = extensions?.where(isExpressionExtension).toList();
    return result == null || result.isEmpty ? null : result;
  }

  /// [extensions] without the ones this controller carried for its own use,
  /// leaving the ones the response owns untouched, such as the signature of a
  /// signed item. Returns `null` when nothing is left.
  List<FhirExtension>? withoutExpressionExtensions(
    Iterable<FhirExtension>? extensions,
  ) {
    final result = extensions
        ?.where((ext) => !isExpressionExtension(ext))
        .toList();
    return result == null || result.isEmpty ? null : result;
  }

  /// Recursively removes every extension this controller carried for its own
  /// use from [itemList] and its sub items.
  List<QuestionnaireResponseItem>? stripExpressionExtensions(
    List<QuestionnaireResponseItem>? itemList,
  ) => itemList
      ?.map(
        (item) => item.copyWith(
          extension_: withoutExpressionExtensions(item.extension_),
          item: stripExpressionExtensions(item.item),
        ),
      )
      .toList();

  /// Maps the value a FHIRPath calculated expression evaluated to onto the
  /// matching `answer.value[x]` of a [QuestionnaireResponseAnswer].
  ///
  /// Returns `null` when the value has no [QuestionnaireResponseAnswer]
  /// counterpart, in which case the expression is left unresolved.
  QuestionnaireResponseAnswer? buildAnswerFromCalculatedValue(FhirBase value) {
    // Expressions evaluate to already typed FHIR values, so anything an answer
    // can hold is used as it is. Types that merely extend a valid value[x]
    // are narrowed down to it first, since the answer is serialized after the
    // runtime type of its value and a `FhirCode` would otherwise end up as an
    // invalid `valueCode`.
    final ValueXQuestionnaireResponseAnswer? valueX = switch (value) {
      FhirCode() || FhirMarkdown() => FhirString(value.primitiveValue),
      FhirId() || FhirCanonical() || FhirUrl() => FhirUri(value.primitiveValue),
      FhirPositiveInt() ||
      FhirUnsignedInt() => FhirInteger(value.primitiveValue),
      FhirInstant() => FhirDateTime.fromString(value.primitiveValue ?? ''),
      ValueXQuestionnaireResponseAnswer() => value,
      _ => null,
    };

    if (valueX != null) {
      return QuestionnaireResponseAnswer(valueX: valueX);
    }

    if (kDebugMode) {
      print(
        'Calculated expression resolved to an unsupported answer value of type '
        '${value.runtimeType}, skipping.',
      );
    }

    return null;
  }

  /// Attempts to resolve exactly one unresolved calculated expression.
  /// Traverses the tree of items depth-first and will abort after it tried
  /// to resolve the first matching element.
  Future<List<QuestionnaireResponseItem>?> resolveFirstCalculatedExpression({
    required Map<String, dynamic> environment,
    required List<QuestionnaireResponseItem>? itemList,
    required QuestionnaireResponse questionnaireResponse,
  }) async {
    if (itemList == null) {
      return null;
    }

    final updatedList = List<QuestionnaireResponseItem>.from(itemList);

    // go depth first
    for (int itemIndex = 0; itemIndex < updatedList.length; itemIndex++) {
      if (updatedList[itemIndex].item != null &&
          nrUnresolvedExpressionsInItemList(
                itemList: updatedList[itemIndex].item,
              ) >
              0) {
        updatedList[itemIndex] = updatedList[itemIndex].copyWith(
          item: await resolveFirstCalculatedExpression(
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
      final calculatedExpressionExtensions = calculatedExpressionsOf(
        updatedList[itemIndex],
      );

      if (calculatedExpressionExtensions.isEmpty) {
        continue;
      }

      final expression = calculatedExpressionExtensions
          .first
          .valueExpression
          ?.expression
          ?.valueString;

      if (expression == null) {
        if (kDebugMode) {
          print('Calculated expression has no expression, skipping.');
        }
        continue;
      }

      try {
        final List<FhirBase> result = await walkFhirPath(
          environment: environment,
          pathExpression: expression,
          context: questionnaireResponse,
          resource: questionnaireResponse,
        );

        if (result.isNotEmpty) {
          final answer = buildAnswerFromCalculatedValue(result.first);

          if (answer != null) {
            updatedList[itemIndex] = updatedList[itemIndex].copyWith(
              // insert calculation result as answer, replacing whatever the
              // item view produced, as the expression owns this item's value
              answer: [answer],
              // dropping the expression extension marks the item resolved for
              // the loop above; extensions the response owns are kept
              extension_: withoutExpressionExtensions(
                updatedList[itemIndex].extension_,
              ),
            );

            return updatedList;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(
            'Failed to compute fhirpath expression "$expression", subsequent evaluations may fail as well: $e',
          );
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
  Future<List<QuestionnaireResponseItem>?>
  resolveItemsWithCalculatedExpressions({
    required Map<String, dynamic> environment,
    required List<QuestionnaireResponseItem>? itemList,
    required QuestionnaireResponse questionnaireResponse,
  }) async {
    if (itemList == null) {
      return null;
    }

    var currentNumberOfUnresolvedItems = 0;
    var newNumberOfUnresolvedItems = 0;

    // if we have unresolved items, try to resolve the first and repeat
    // until we reach 0 or calculations stop resolving
    do {
      currentNumberOfUnresolvedItems = nrUnresolvedExpressionsInItemList(
        itemList: itemList,
      );

      if (currentNumberOfUnresolvedItems > 0) {
        itemList = await resolveFirstCalculatedExpression(
          environment: environment,
          itemList: itemList,
          // Expressions may reference items that were calculated in a previous
          // pass, so each pass evaluates against the response as resolved so far.
          questionnaireResponse: questionnaireResponse.copyWith(item: itemList),
        );
      }

      newNumberOfUnresolvedItems = nrUnresolvedExpressionsInItemList(
        itemList: itemList,
      );
    } while (newNumberOfUnresolvedItems > 0 &&
        newNumberOfUnresolvedItems < currentNumberOfUnresolvedItems);

    // The expression extensions were only carried so the items above could be
    // evaluated. Nothing that came from the Questionnaire belongs in the
    // emitted response, including the expressions that failed to resolve.
    return stripExpressionExtensions(itemList);
  }
}
