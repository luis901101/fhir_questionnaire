import 'package:fhir_r4/fhir_r4.dart';
import 'package:collection/collection.dart';

enum QuestionnaireCustomQuantityComparator {
  equals('=', null),
  greaterThan('>', QuantityComparator.gt),
  lessThan('<', QuantityComparator.lt),
  greaterThanOrEqual('>=', QuantityComparator.ge),
  lessThanOrEqual('<=', QuantityComparator.le);

  final String symbol;
  final QuantityComparator? asQuantityComparator;
  const QuestionnaireCustomQuantityComparator(
    this.symbol,
    this.asQuantityComparator,
  );

  static const defaultValue = equals;

  static QuestionnaireCustomQuantityComparator? valueOf({
    String? name,
    String? symbol,
    QuantityComparator? asQuantityComparator,
  }) => QuestionnaireCustomQuantityComparator.values.firstWhereOrNull(
    (value) =>
        value.name == name ||
        value.symbol == symbol ||
        value.asQuantityComparator == asQuantityComparator,
  );
}
