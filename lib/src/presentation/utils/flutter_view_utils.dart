import 'dart:ui';

import 'package:material_ui/material_ui.dart';

extension FlutterViewUtils on FlutterView {
  /// It's recommended to use a context when using this function.
  /// Check docs: https://docs.flutter.dev/release/breaking-changes/window-singleton#migration-guide
  static FlutterView get({BuildContext? context}) => context != null
      ? View.of(context)
      : WidgetsBinding.instance.platformDispatcher.implicitView ??
            WidgetsBinding.instance.platformDispatcher.views.first;
}
