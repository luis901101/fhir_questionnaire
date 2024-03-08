import 'package:flutter/widgets.dart';

/// Hides keyboard when user taps on any widget without any gesture detector.
///
/// How to use: Just set the widget tree containing any [TextField] as a child
/// of [UnfocusView], then when the user taps outside the focused [TextField],
/// keyboard will be hidden automatically.
class UnfocusView extends StatelessWidget {
  const UnfocusView({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Makes clickable on everywhere even if the widget is not opaque
      behavior: HitTestBehavior.opaque,
      // Magic happens here
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
