import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/utils/date_utils.dart';
import 'package:fhir_questionnaire/src/utils/num_utils.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart' as intl;

extension StringExtension on String {
  num? get asNum => NumUtils.tryParse(this);
  int? get asInt => int.tryParse(this);
  double? get asDouble => DoubleUtils.tryParse(this);
  String get removeHtmlTags => parse(this).documentElement?.text ?? this;

  Annotation asAnnotation({Reference? authorReference}) => Annotation(
      text: FhirMarkdown(this),
      authorReference: authorReference,
      time: DateTime.now().asFhirDateTime);
}

extension StringNullExtension on String? {
  bool get isEmpty => this == null || this!.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class TextUtils {
  static bool isEmpty(String? text) =>
      text == null || text.isEmpty || text.trim().isEmpty;

  static bool isNotEmpty(String? text) => !isEmpty(text);

  static String trySubstring(String text, int startIndex, [int? endIndex]) {
    if (startIndex < 0 || (endIndex ??= -1) >= text.length) return text;
    return text.substring(startIndex, endIndex);
  }

  static String formatNum(num value, {int decimals = 2}) {
    String decimalsParam = '';
    if (decimals > 0) decimalsParam = '0.';
    while (decimals-- > 0) {
      decimalsParam += '0';
    }
    return intl.NumberFormat('#$decimalsParam', 'en_US').format(value);
  }
}
