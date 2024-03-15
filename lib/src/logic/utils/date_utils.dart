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

  FhirDateTime get asFhirDateTime => FhirDateTime(this);
  FhirDate get asFhirDate =>
      FhirDate.fromUnits(year: year, month: month, day: day, isUtc: isUtc);
  FhirTime get asFhirTime =>
      FhirTime.fromUnits(hour: hour, minute: minute, second: 0, millisecond: 0);
}
