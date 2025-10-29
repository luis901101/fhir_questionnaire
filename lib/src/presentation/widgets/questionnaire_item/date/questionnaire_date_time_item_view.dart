import 'package:collection/collection.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

enum DateTimeType {
  date,
  time,
  dateTime;

  static DateTimeType fromQuestionnaireItemType(
          QuestionnaireItemType? itemType) =>
      switch (itemType) {
        QuestionnaireItemType.date => date,
        QuestionnaireItemType.time => time,
        QuestionnaireItemType.dateTime || _ => dateTime,
      };
  bool get requiresDate => this == date || this == dateTime;
  bool get requiresTime => this == time || this == dateTime;
  bool get isDateTime => this == dateTime;
}

/// Created by luis901101 on 3/15/24.
class QuestionnaireDateTimeItemView extends QuestionnaireItemView {
  final DateTimeType type;
  QuestionnaireDateTimeItemView({
    super.key,
    CustomValueController<DateTime>? controller,
    required super.item,
    required this.type,
    super.enableWhenController,
  }) : super(
            controller: controller ??
                CustomValueController<DateTime>(
                  focusNode: FocusNode(),
                ));

  @override
  State createState() => QuestionnaireDateTimeItemViewState();
}

class QuestionnaireDateTimeItemViewState
    extends QuestionnaireItemViewState<QuestionnaireDateTimeItemView> {
  @override
  CustomValueController<DateTime> get controller =>
      super.controller as CustomValueController<DateTime>;
  DateTimeType get type => widget.type;
  DateTime? get dateTime => controller.value;
  set dateTime(DateTime? value) => controller.value = value;

  @override
  void initState() {
    super.initState();
    if (dateTime == null) {
      final DateTime? initial = switch (type) {
        DateTimeType.date => item.initial
            ?.firstWhereOrNull((item) => item.valueDate != null)
            ?.valueDate
            ?.asDateTime,
        DateTimeType.time => item.initial
            ?.firstWhereOrNull((item) => item.valueTime != null)
            ?.valueTime
            ?.asDateTime,
        DateTimeType.dateTime => item.initial
            ?.firstWhereOrNull((item) => item.valueDateTime != null)
            ?.valueDateTime
            ?.asDateTime,
      };
      if (initial != null) {
        dateTime = initial;
      }
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (type.requiresDate)
          Expanded(
            flex: 60,
            child: StatefulBuilder(builder: (context, setState) {
              return ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(dateTime?.formattedDate() ??
                      QuestionnaireLocalization
                          .instance.localization.textDate),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: openDatePicker);
            }),
          ),
        if (type.isDateTime)
          const Spacer(
            flex: 2,
          ),
        if (type.requiresTime)
          Expanded(
            flex: 40,
            child: StatefulBuilder(builder: (context, setState) {
              return ElevatedButton.icon(
                  icon: const Icon(Icons.access_time_rounded),
                  label: Text(dateTime?.formattedTime() ??
                      QuestionnaireLocalization
                          .instance.localization.textTime),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: openTimePicker);
            }),
          ),
      ],
    );
  }

  Future<void> openDatePicker() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: dateTime ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (newDate != null) {
      dateTime = dateTime?.copyWith(
            year: newDate.year,
            month: newDate.month,
            day: newDate.day,
          ) ??
          newDate;
      controller.validate();
      setState(() {});
      if (type.requiresTime) {
        openTimePicker();
      }
    }
  }

  Future<void> openTimePicker() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: dateTime?.timeOfDay ?? DateTime.now().timeOfDay,
    );
    if (newTime != null) {
      dateTime = (dateTime ?? DateTime.now()).copyWith(
        hour: newTime.hour,
        minute: newTime.minute,
      );
      controller.validate();
      setState(() {});
    }
  }
}
