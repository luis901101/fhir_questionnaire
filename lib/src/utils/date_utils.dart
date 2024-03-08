import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

extension CustomDateUtils on DateTime {
  static const formattedDateFormat = 'EEE, d MMM yyyy';
  static const formattedTimeFormat = 'h:mm a';

  DateTime get flatMonth => DateTime(year, month);
  DateTime get flatDay => DateTime(year, month, day);

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  String formatAsHumanReadableTimeCount(
          {bool lessThanMin = false,
          bool abbreviated = false,
          String? spacer,
          bool first = false}) =>
      toHumanReadableTimeCount(millisecondsSinceEpoch,
          lessThanMin: lessThanMin,
          abbreviated: abbreviated,
          spacer: spacer,
          first: first);

  static String toHumanReadableTimeCount(int timeMillis,
      {bool lessThanMin = false,
      bool abbreviated = false,
      String? spacer,
      bool first = false}) {
    String humanReadable = '$timeMillis';
    try {
      var duration = Duration(seconds: timeMillis ~/ 1000);
      if (duration.inSeconds == 0) return 'Now';
      if (lessThanMin && duration < const Duration(minutes: 1)) {
        // return R.strings.text_less_than_a_minute;
        return '< ${toHumanReadableTimeCount(const Duration(minutes: 1).inMilliseconds)}';
      }
      humanReadable = prettyDuration(duration,
          delimiter: ', ',
          conjunction: ' and ',
          abbreviated: abbreviated,
          spacer: spacer,
          first: first,
          locale: DurationLocale.fromLanguageCode('en') ??
              const EnglishDurationLocale());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return humanReadable;
  }

  String formatAsHumanReadablePastTime(
          {bool lessThanMin = false,
          bool abbreviated = false,
          String? spacer,
          bool first = false}) =>
      toHumanReadablePastTime(
        dateTime: this,
        lessThanMin: lessThanMin,
        abbreviated: abbreviated,
        spacer: spacer,
        first: first,
      );

  static String toHumanReadablePastTime(
      {DateTime? dateTime,
      int? timeMillis,
      bool lessThanMin = false,
      bool abbreviated = false,
      String? spacer,
      bool first = false}) {
    assert(dateTime != null || timeMillis != null);
    dateTime ??= DateTime.fromMillisecondsSinceEpoch(timeMillis ?? 0);
    final now = DateTime.now();

    //Checking if date is before this year
    if (dateTime.year < now.year) {
      return dateTime.format(format: 'MMMM d, yyyy');
    }
    //Checking if date is before this year
    final difference = now.difference(dateTime);
    if (difference.inWeeks > 4) {
      return dateTime.format(format: 'MMMM d');
    }

    String humanReadable = '';
    try {
      // var duration = Duration(seconds: timeMillis ~/ 1000);
      if (difference < const Duration(minutes: 1)) return 'Now';
      humanReadable = '${prettyDuration(difference,
          delimiter: ', ',
          conjunction: ' and ',
          abbreviated: abbreviated,
          spacer: spacer,
          first: first,
          locale: DurationLocale.fromLanguageCode('en') ??
              const EnglishDurationLocale())} ago';
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return humanReadable;
  }

  String formattedDate() => format();
  String formattedTime() => format(format: formattedTimeFormat);

  String format({String format = formattedDateFormat}) {
    try {
      return intl.DateFormat(format).format(this);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      try {
        return intl.DateFormat(format).format(this);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        return intl.DateFormat().format(this);
      }
    }
  }

  DateTime addDays(int value) => _addSubtract(days: value);
  DateTime addWeeks(int value) => _addSubtract(days: value * 7);
  DateTime addMonths(int value) => _addSubtract(months: value);
  DateTime addYears(int value) => _addSubtract(years: value);

  DateTime subtractDays(int value) => _addSubtract(add: false, days: value);

  DateTime subtractWeeks(int value) =>
      _addSubtract(add: false, days: value * 7);
  DateTime subtractMonths(int value) => _addSubtract(add: false, months: value);
  DateTime subtractYears(int value) => _addSubtract(add: false, years: value);
  DateTime _addSubtract({
    bool add = true,
    int years = 0,
    int months = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int milliseconds = 0,
    int microseconds = 0,
  }) =>
      copyWith(
        year: year + (years * (add ? 1 : -1)),
        month: month + (months * (add ? 1 : -1)),
        day: day + (days * (add ? 1 : -1)),
        hour: hour + (hours * (add ? 1 : -1)),
        minute: minute + (minutes * (add ? 1 : -1)),
        second: second + (seconds * (add ? 1 : -1)),
        millisecond: millisecond + (milliseconds * (add ? 1 : -1)),
        microsecond: microsecond + (microseconds * (add ? 1 : -1)),
      );

  FhirDateTime get asFhirDateTime => FhirDateTime(this);
}
