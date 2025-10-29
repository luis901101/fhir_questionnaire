import 'package:flutter/material.dart';

/// Created by luis901101 on 10/28/25.
/// A button styled text widget typically used for displaying helper text that can be interacted with.
class HelperButton extends StatelessWidget {
  /// Text to display as tooltip or on button press.
  final String text;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Optional color for the icon.
  final Color? color;

  const HelperButton({super.key, required this.text, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: text,
      child: Tooltip(
        message: text,
        triggerMode: TooltipTriggerMode.tap,
        child: Icon(Icons.help_outline, color: color ?? theme.colorScheme.primary),
      ),
    );
  }
}
