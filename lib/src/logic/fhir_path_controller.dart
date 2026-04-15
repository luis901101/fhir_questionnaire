import 'package:fhir_plus/r4.dart';
import 'package:fhir_path_plus/fhir_path.dart';
import 'package:flutter/foundation.dart';

class FhirPathController {
  /// Retrieves all variable definitions defined at the Questionnaire's root
  /// level and calculates their value. Returns a map of variable name / value
  /// pairs that can be used as execution context to evaluate expressions at
  /// a deeper level.
  Map<String, dynamic> fetchCalculatedExpressionRootVariables({
    required Questionnaire questionnaire,
    required QuestionnaireResponse questionnaireResponse,
  }) {
    final calculatedResults = <String, dynamic>{};

    // capture all top-level variables as list, in order
    final rootExpressions = (questionnaire.extension_ ?? [])
        .where(
          (ext) =>
              ext.url ==
                  FhirUri('http://hl7.org/fhir/StructureDefinition/variable') &&
              ext.valueExpression?.language ==
                  FhirExpressionLanguage.text_fhirpath,
        )
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
            'Failed to compute fhirpath expression "$expression", subsequent evaluations may fail as well: $e',
          );
        }
      }
    }

    return calculatedResults;
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
  List<QuestionnaireResponseItem>? resolveItemsWithCalculatedExpressions({
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
      currentNumberOfUnresolvedItems = _nrUnresolvedExpressionsInItemList(
        itemList: itemList,
      );

      if (currentNumberOfUnresolvedItems > 0) {
        itemList = _resolveFirstCalculatedExpression(
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

  /// Calculates the number of unresolved calculated expressions in an item
  /// list. Returns the number of all expression for which no answer value
  /// exists. The number will be the sum of all expressions in the entire
  /// sub tree of items.
  int _nrUnresolvedExpressionsInItemList({
    required List<QuestionnaireResponseItem>? itemList,
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
                ext.url ==
                    FhirUri(
                      'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression',
                    ) &&
                ext.valueExpression?.language ==
                    FhirExpressionLanguage.text_fhirpath,
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
                itemList: updatedList[itemIndex].item,
              ) >
              0) {
        updatedList[itemIndex] = updatedList[itemIndex].copyWith(
          item: _resolveFirstCalculatedExpression(
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
                    ext.url ==
                        FhirUri(
                          'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression',
                        ) &&
                    ext.valueExpression?.language ==
                        FhirExpressionLanguage.text_fhirpath,
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
              'Failed to compute fhirpath expression "$expression", subsequent evaluations may fail as well: $e',
            );
          }
        }
      }
    }

    return updatedList;
  }
}
