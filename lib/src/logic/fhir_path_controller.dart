import 'package:fhir_r4/fhir_r4.dart' hide QuestionnaireItemType;
import 'package:fhir_r4_path/fhir_r4_path.dart';
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
              ext.url.valueString ==
                  'http://hl7.org/fhir/StructureDefinition/variable' &&
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
  /// list. Returns the number of all expression for which no answer value
  /// exists. The number will be the sum of all expressions in the entire
  /// sub tree of items.
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

      final calculatedExpressions = (item.extension_ ?? [])
          .where(
            (ext) =>
                ext.url.valueString ==
                    'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression' &&
                ext.valueExpression?.language.valueEnum ==
                    ExpressionLanguageEnum.textFhirpath,
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
                    ext.valueExpression?.language.valueEnum ==
                        ExpressionLanguageEnum.textFhirpath,
              )
              .toList();

      if (calculatedExpressionExtensions.isNotEmpty) {
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
            final resultValue = result.first;

            QuestionnaireResponseAnswer? answer =
                resultValue is ValueXQuestionnaireResponseAnswer
                ? QuestionnaireResponseAnswer(valueX: resultValue)
                : null;

            updatedList[itemIndex] = itemList[itemIndex].copyWith(
              // insert calculation result as answer
              answer: answer != null ? [answer] : null,
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
          questionnaireResponse: questionnaireResponse,
        );
      }

      newNumberOfUnresolvedItems = nrUnresolvedExpressionsInItemList(
        itemList: itemList,
      );
    } while (newNumberOfUnresolvedItems > 0 &&
        newNumberOfUnresolvedItems < currentNumberOfUnresolvedItems);

    return itemList;
  }
}
