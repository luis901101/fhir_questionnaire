import 'package:fhir/r4/r4.dart';

extension CodingUtils on Coding {
  String? get title => display ?? code?.value ?? system?.value?.toString();
}
