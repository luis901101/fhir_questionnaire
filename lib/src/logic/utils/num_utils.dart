import 'package:fhir_r4/fhir_r4.dart';

extension NumUtils on num {
  num percent(double value) => this * value / 100;

  static num? tryParse(String? input) {
    String source = input?.trim() ?? '';
    source = source.replaceAll(',', '.');
    return int.tryParse(source) ?? double.tryParse(source);
  }
}

extension DoubleUtils on double {
  double percent(double value) => this * value / 100;

  FhirDecimal get asFhirDecimal => FhirDecimal(this);

  static double? tryParse(String? input) {
    String source = input?.trim() ?? '';
    source = source.replaceAll(',', '.');
    return double.tryParse(source);
  }
}

extension IntUtils on int {
  double percent(double value) => this * value / 100;

  FhirInteger get asFhirInteger => FhirInteger(this);
  static int? tryParse(String? input) {
    String source = input?.trim() ?? '';
    return int.tryParse(source);
  }
}
