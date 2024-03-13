import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class InputMethodUtils {
  static void hideInputMethod({bool force = false}) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (force) SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static void showInputMethod() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }
}
