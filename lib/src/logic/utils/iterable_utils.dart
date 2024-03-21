import 'dart:async';

///
/// Converts each element to a [String] and concatenates the strings.
///
/// Iterates through elements of this iterable,
/// converts each one to a [String] by calling [Object.toString],
/// and then concatenates the strings, with the
/// [separator] string interleaved between the elements.
/// This join function allows takes into account null values, ignoring it and
/// respecting the separator
extension ListUtils on List {
  String tryJoin<E>([String separator = '']) {
    Iterator<E> iterator = this.iterator as Iterator<E>;
    if (!iterator.moveNext()) return '';
    StringBuffer buffer = StringBuffer();
    if (separator == '') {
      do {
        if (iterator.current?.toString().isNotEmpty ?? false) {
          buffer.write(iterator.current.toString());
        }
      } while (iterator.moveNext());
    } else {
      do {
        if (iterator.current?.toString().isNotEmpty ?? false) {
          buffer.write(iterator.current.toString());
          break;
        }
      } while (iterator.moveNext());
      while (iterator.moveNext()) {
        if (iterator.current?.toString().isEmpty ?? true) continue;
        buffer.write(separator);
        buffer.write(iterator.current.toString());
      }
    }
    return buffer.toString();
  }

  void insertAllRemovingDuplicates<E>(List<E> elements, int index,
      {bool Function(E element1, E element2)? checkDuplicate}) {
    checkDuplicate ??= (element1, element2) => element1 == element2;
    for (final element2 in elements) {
      removeWhere((element1) => checkDuplicate!(element1, element2));
    }
    if (index >= length) index = length - 1;
    insertAll(index, elements);
  }

  void addAllIgnoringDuplicates<E>(List<E> elements,
      {bool Function(E element1, E element2)? checkDuplicate}) {
    checkDuplicate ??= (element1, element2) => element1 == element2;
    List<E> temp = [];
    for (final element2 in elements) {
      if (!any((element1) => checkDuplicate!(element1, element2))) {
        temp.add(element2);
      }
    }
    addAll(temp);
  }

  void addIgnoringDuplicates<E>(E element,
      {bool Function(E element1, E element2)? checkDuplicate}) {
    checkDuplicate ??= (element1, element2) => element1 == element2;
    if (!any((element1) => checkDuplicate!(element1, element))) {
      add(element);
    }
  }

  void addCountIgnoringDuplicates<E>(List<E> elements, int count,
      {bool Function(E element1, E element2)? checkDuplicate}) {
    checkDuplicate ??= (element1, element2) => element1 == element2;
    List<E> temp = [];
    for (int i = 0, added = 0; i < elements.length && added < count; ++i) {
      final element2 = elements[i];
      if (!any((element1) => checkDuplicate!(element1, element2))) {
        ++added;
        temp.add(element2);
      }
    }
    for (final element in temp) {
      add(element);
    }
    // addAll(temp); //For some reason this throws exception
  }

  void removeDuplicates<E>(
      {bool Function(E element1, E element2)? checkDuplicate}) {
    checkDuplicate ??= (element1, element2) => element1 == element2;
    List<E> temp = [];
    for (final element1 in this) {
      if (!temp.any((element2) => checkDuplicate!(element1, element2))) {
        temp.add(element1);
      }
    }
    clear();
    for (final element in temp) {
      add(element);
    }
    // addAll(temp); //For some reason this throws exception
  }

  List<E> difference<E>(Iterable<E> other) {
    List<E> diff = [];
    for (final e in this) {
      if (!other.contains(e)) diff.add(e);
    }
    return diff;
  }

  void cancelAll() {
    if (this is List<StreamSubscription>) {
      for (final subscription in this) {
        unawaited(subscription.cancel());
      }
      clear();
    }
  }
}

extension IterableExtension<E> on Iterable<E> {
  List<T> mapWhere<T>(T Function(E e) f, bool Function(E e) test) {
    List<T> result = [];
    forEach((element) {
      if (test(element)) result.add(f(element));
    });
    return result;
  }
}

extension IterableNullExtension on Iterable? {
  bool get isEmpty => this == null || (this as Iterable).isEmpty;
  bool get isNotEmpty => !isEmpty;
}

extension MapExtension on Map {
  void removeNulls() =>
      removeWhere((key, value) => key == null || value == null);

  Map<String, dynamic>? get asMap {
    if (this is Map<String, dynamic>) return this as Map<String, dynamic>;
    // final castMap = _parseFullMap(entity as Map);
    return parseFullMap;
  }

  Map<String, dynamic> get parseFullMap {
    final castMap = map((key, value) {
      if (value is Map) value = value.parseFullMap;
      return MapEntry<String, dynamic>('$key', value);
    });
    return castMap;
  }
}

extension MapNullExtension on Map? {
  bool get isEmpty => this == null || (this as Map).isEmpty;
  bool get isNotEmpty => !isEmpty;
}
