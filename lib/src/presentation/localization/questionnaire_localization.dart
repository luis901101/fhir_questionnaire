import 'package:collection/collection.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:fhir_questionnaire/src/presentation/localization/questionnaire_localization_data.dart';
import 'package:flutter/material.dart';

class QuestionnaireLocalization extends InheritedWidget {
  final QuestionnaireLocalizationData data;
  static QuestionnaireLocalizationData? _currentInstance;
  static QuestionnaireLocalizationData get current {
    if (_currentInstance == null) {
      throw Exception(
        'The QuestionnaireLocalizationData has not been set yet '
        'It will be done after an instance of QuestionnaireLocalization widget has been instantiated',
      );
    }

    return _currentInstance!;
  }

  QuestionnaireLocalization({
    super.key,
    required this.data,
    required super.child,
  }) {
    _currentInstance = data;
  }

  static QuestionnaireLocalizationData of(final BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<QuestionnaireLocalization>()
        ?.data;
    if (result == null) {
      throw Exception(
        'Could not find an instance of QuestionnaireLocalizationData when called '
        'QuestionnaireLocalization.of(context) in the widget tree. '
        'One can be inserted into the widget tree using QuestionnaireLocalization widget',
      );
    }

    return result;
  }

  @override
  bool updateShouldNotify(final QuestionnaireLocalization oldWidget) {
    return oldWidget.data.localization.locale != data.localization.locale ||
        !const DeepCollectionEquality().equals(
          data.fallbackLocalization,
          oldWidget.data.fallbackLocalization,
        ) ||
        !const DeepCollectionEquality().equals(
          data.localization,
          oldWidget.data.localization,
        );
  }
}
