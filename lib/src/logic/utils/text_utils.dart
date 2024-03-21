import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/logic/utils/date_utils.dart';
import 'package:fhir_questionnaire/src/logic/utils/num_utils.dart';
import 'package:validators/validators.dart' as validators;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

typedef BoolCallback = bool Function();

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

typedef Validation = bool Function({FieldController? controller});

class ValidationController {
  final Validation? isValid;
  final String? message;

  ValidationController({this.isValid, this.message});
}

class EmptyValidationController extends ValidationController {
  EmptyValidationController({String message = 'This field is required'})
      : super(
          message: message,
          isValid: ({controller}) =>
              TextUtils.isNotEmpty(controller?.rawValue?.toString()),
        );
}

class LengthValidationController extends ValidationController {
  LengthValidationController(
      {int minLength = 0,
      int? maxLength,
      String message = 'Invalid length',
      bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isLength(textValue!, minLength, maxLength);
            });
}

class RepeatPasswordValidationController extends ValidationController {
  RepeatPasswordValidationController(
      {FieldController? passwordController,
      String message = "Passwords doesn't match"})
      : super(
          message: message,
          isValid: ({controller}) =>
              controller?.rawValue?.toString() ==
              passwordController?.rawValue?.toString(),
        );
}

class EmailValidationController extends ValidationController {
  EmailValidationController(
      {String message = 'Invalid email address', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isEmail(textValue!);
            });
}

class UrlValidationController extends ValidationController {
  UrlValidationController(
      {String message = 'Invalid url', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isURL(textValue);
            });
}

class IPValidationController extends ValidationController {
  IPValidationController(
      {String message = 'Invalid ip address', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isIP(textValue);
            });
}

class AlphanumericValidationController extends ValidationController {
  AlphanumericValidationController(
      {String message = 'Invalid alphanumeric', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isAlphanumeric(textValue!);
            });
}

class CreditCardValidationController extends ValidationController {
  CreditCardValidationController(
      {String message = 'Invalid credit card', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isCreditCard(textValue!);
            });
}

class DateValidationController extends ValidationController {
  DateValidationController(
      {String message = 'Invalid date', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isDate(textValue!);
            });
}

class AsciiValidationController extends ValidationController {
  AsciiValidationController(
      {String message = 'Invalid Ascii', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isAscii(textValue!);
            });
}

class Base64ValidationController extends ValidationController {
  Base64ValidationController(
      {String message = 'Invalid Base64', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isBase64(textValue!);
            });
}

class OnlyTextValidationController extends ValidationController {
  OnlyTextValidationController(
      {String message = 'Text should contain only text', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isAlpha(textValue!);
            });
}

class DNSValidationController extends ValidationController {
  DNSValidationController(
      {bool requireTld = true,
      bool allowUnderscores = false,
      String message = 'Invalid DNS',
      bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isFQDN(textValue!);
            });
}

class HexadecimalValidationController extends ValidationController {
  HexadecimalValidationController(
      {String message = 'Invalid hexadecimal', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isHexadecimal(textValue!);
            });
}

class HexColorValidationController extends ValidationController {
  HexColorValidationController(
      {String message = 'Invalid Hexcolor', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isHexColor(textValue!);
            });
}

class ISBNValidationController extends ValidationController {
  ISBNValidationController(
      {dynamic version, String message = 'Invalid ISBN', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isISBN(textValue, version);
            });
}

class JsonValidationController extends ValidationController {
  JsonValidationController(
      {String message = 'Invalid Json', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isJSON(textValue);
            });
}

class LowercaseValidationController extends ValidationController {
  LowercaseValidationController(
      {String message = 'Invalid lowercase', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isLowercase(textValue!);
            });
}

class UppercaseValidationController extends ValidationController {
  UppercaseValidationController(
      {String message = 'Invalid Uppercase', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isUppercase(textValue!);
            });
}

class MongoIdValidationController extends ValidationController {
  MongoIdValidationController(
      {String message = 'Invalid MongoId', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isMongoId(textValue!);
            });
}

class SurrogatePairValidationController extends ValidationController {
  SurrogatePairValidationController(
      {String message = 'Invalid SurrogatePair', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isSurrogatePair(textValue!);
            });
}

class UUIDValidationController extends ValidationController {
  UUIDValidationController(
      {dynamic version, String message = 'Invalid UUID', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return validators.isUUID(textValue, version);
            });
}

class NumericValidationController extends ValidationController {
  NumericValidationController(
      {String message = 'Text must be a number', bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return num.tryParse(textValue!) != null;
            });
}

class IntegerValidationController extends ValidationController {
  IntegerValidationController(
      {String message = 'Text must be an integer number',
      bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return int.tryParse(textValue!) != null;
            });
}

class DecimalValidationController extends ValidationController {
  DecimalValidationController(
      {String message = 'Text must be an decimal number',
      bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              return double.tryParse(textValue!) != null;
            });
}

class PositiveIntegerValidationController extends ValidationController {
  PositiveIntegerValidationController(
      {String message = 'Text must be an integer positive number',
      bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              int? value = int.tryParse(textValue!);
              return (value ?? -1) >= 0;
            });
}

class PositiveDecimalValidationController extends ValidationController {
  PositiveDecimalValidationController(
      {String message = 'Text must be a decimal positive number',
      bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              num? value = num.tryParse(textValue!);
              return (value ?? -1) >= 0;
            });
}

class IntegerRangeValidationController extends ValidationController {
  IntegerRangeValidationController(
      {int? minValue,
      int? maxValue,
      String message = 'Number must fall in the specified range',
      bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              int? value = int.tryParse(textValue!);
              return (value ?? 0) >= (minValue ?? 0) &&
                  (value ?? 0) <= (maxValue ?? 0);
            });
}

class DecimalRangeValidationController extends ValidationController {
  DecimalRangeValidationController(
      {num? minValue,
      num? maxValue,
      String message = 'Number must fall in the specified range',
      bool required = false})
      : super(
            message: message,
            isValid: ({controller}) {
              String? textValue = controller?.rawValue?.toString();
              if (!required && TextUtils.isEmpty(textValue)) return true;
              num? value = num.tryParse(textValue!);
              return (value ?? 0) >= (minValue ?? 0) &&
                  (value ?? 0) <= (maxValue ?? 0);
            });
}

mixin FieldController<T> {
  Set<ValidationController> validations = {};
  BoolCallback? validationsDependency;
  FocusNode? focusNode;
  String? error;

  bool get hasValidations => validations.isNotEmpty;

  /// Register a closure to be called when the object notifies its listeners.
  void addListener(VoidCallback listener);

  /// Remove a previously registered closure from the list of closures that the
  /// object notifies.
  void removeListener(VoidCallback listener);

  bool get isValidationsDependencySatisfied =>
      validationsDependency?.call() ?? true;

  bool get canValidate => hasValidations && isValidationsDependencySatisfied;

  bool validate({bool notify = true}) {
    clearError(notify: notify);
    if (!canValidate) return true;
    for (ValidationController validation in validations) {
      if (!(validation.isValid?.call(controller: this) ?? true)) {
        setError(validation.message, notify: notify);
        return false;
      }
    }
    return true;
  }

  bool get isValid {
    if (!canValidate) return true;
    for (ValidationController validation in validations) {
      if (!(validation.isValid?.call(controller: this) ?? true)) return false;
    }
    return true;
  }

  String? get validationMessage {
    if (!canValidate) return null;
    for (ValidationController validation in validations) {
      if (!(validation.isValid?.call(controller: this) ?? true)) {
        return validation.message;
      }
    }
    return null;
  }

  T get rawValue;

  dynamic get controllerValue => rawValue;

  bool get hasError => error?.isNotEmpty ?? false;

  bool get isEmpty;

  bool get isNotEmpty => !isEmpty;

  void setError(String? error, {bool notify = true});

  void clearError({bool notify = true});

  void clear();

  void _feedback() async {
    for (int i = 0; i < 3; ++i) {
      await Future.delayed(
          const Duration(milliseconds: 100), () => HapticFeedback.vibrate());
    }
  }
}

class CustomTextEditingController extends TextEditingController
    with FieldController<String> {
  CustomTextEditingController({
    super.text,
    FocusNode? focusNode,
    Set<ValidationController>? validations,
    BoolCallback? validationsDependency,
  }) {
    this.focusNode = focusNode;
    if (validations != null) this.validations = validations;
    this.validationsDependency = validationsDependency;
  }

  @override
  String get rawValue => text;

  @override
  get controllerValue => value;

  @override
  bool get isEmpty => text.isEmpty;

  @override
  void setError(String? error, {bool notify = true}) {
    this.error = error;
    if (notify) {
      if (hasError) _feedback();
      notifyListeners();
    }
  }

  @override
  void clearError({bool notify = false}) => setError(null, notify: notify);

  @override
  void clear() {
    clearError();
    super.clear();
  }
}

class CustomValueController<T> extends ValueNotifier<T?>
    with FieldController<T?> {
  CustomValueController({
    T? value,
    FocusNode? focusNode,
    Set<ValidationController>? validations,
    BoolCallback? validationsDependency,
  }) : super(value) {
    this.focusNode = focusNode;
    if (validations != null) this.validations = validations;
    this.validationsDependency = validationsDependency;
  }

  @override
  T? get rawValue => value;

  @override
  bool get isEmpty => value == null;

  @override
  void setError(String? error, {bool notify = true}) {
    this.error = error;
    if (notify) {
      if (hasError) _feedback();
      notifyListeners();
    }
  }

  @override
  void clearError({bool notify = false}) => setError(null, notify: notify);

  @override
  void clear() {
    clearError();
    value = null;
  }
}

class CustomValueNSController<T> extends ValueNotifier<T>
    with FieldController<T> {
  CustomValueNSController({
    required T value,
    FocusNode? focusNode,
    Set<ValidationController>? validations,
    BoolCallback? validationsDependency,
  }) : super(value) {
    this.focusNode = focusNode;
    if (validations != null) this.validations = validations;
    this.validationsDependency = validationsDependency;
  }

  @override
  T get rawValue => value;

  @override
  bool get isEmpty => value == null;

  @override
  void setError(String? error, {bool notify = true}) {
    this.error = error;
    if (notify) {
      if (hasError) _feedback();
      notifyListeners();
    }
  }

  @override
  void clearError({bool notify = false}) => setError(null, notify: notify);

  @override
  void clear() {
    clearError();
  }
}

class DummyController with FieldController {
  @override
  void addListener(VoidCallback listener) {}

  @override
  void clear() {}

  @override
  void clearError({bool notify = true}) {}

  @override
  bool get isEmpty => true;

  @override
  get rawValue => null;

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void setError(String? error, {bool notify = true}) {}
}
