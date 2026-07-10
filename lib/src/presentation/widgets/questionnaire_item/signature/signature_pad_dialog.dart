import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

/// Modal drawing pad used to capture a signature. Draws on the persistent
/// [HandSignatureControl] owned by [controller], so it opens showing the last
/// drawing (if any) ready to continue. On "Done" the drawing is committed to
/// [controller]; on "Cancel" the committed [controller] value is left unchanged.
///
/// Drawing happens in a dialog (instead of inline in the form) so the pad's
/// gesture is not stolen by the surrounding scrolling list.
///
/// It is public and its [State] is public and generic so it can be extended and
/// overridden — subclasses may override the individual `build*` seams, [done] or
/// [cancel] without copying the whole [build] method. See
/// [QuestionnaireSignatureViewState.buildSignatureDialog] to swap in a subclass.
class SignaturePadDialog extends StatefulWidget {
  /// Controller owning the drawing [HandSignatureControl] and the committed
  /// signature [value].
  final SignatureController controller;

  const SignaturePadDialog({super.key, required this.controller});

  @override
  State<SignaturePadDialog> createState() => SignaturePadDialogState();
}

class SignaturePadDialogState<T extends SignaturePadDialog> extends State<T> {
  SignatureController get controller => widget.controller;

  static const dialogConstraints = BoxConstraints(
    maxWidth: 800,
    maxHeight: 800,
  );

  /// Whether a commit is in progress (guards against double taps while the PNG
  /// is exported).
  bool committing = false;

  @override
  void initState() {
    super.initState();
    // Rebuild as the drawing changes so the Clear / Done buttons enable when
    // there is something drawn.
    controller.control.addListener(onControlChanged);
  }

  void onControlChanged() => setState(() {});

  /// Exports the drawing to [controller] and closes the dialog with `true`.
  Future<void> done() async {
    setState(() => committing = true);
    await controller.commit();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  /// Closes the dialog with `false`, leaving the committed value unchanged.
  void cancel() => Navigator.of(context).pop(false);

  @override
  void dispose() {
    controller.control.removeListener(onControlChanged);
    super.dispose();
  }

  /// The bordered drawing pad bound to [controller].
  Widget buildSignaturePad(
    BoxConstraints constraints,
    ThemeData theme,
    BorderRadius borderRadius,
  ) {
    return Container(
      height: constraints.biggest.shortestSide.percent(80),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor, width: 0.5),
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned.fill(
            child: HandSignature(
              control: controller.control,
              drawer: controller.drawer,
            ),
          ),
          Positioned(bottom: 4, right: 4, child: buildClearButton(theme)),
        ],
      ),
    );
  }

  /// The Clear button that empties the pad while drawing.
  Widget buildClearButton(ThemeData theme) {
    final localization = QuestionnaireLocalization.instance.localization;
    final enabled = controller.control.isFilled && !committing;
    return TextButton.icon(
      onPressed: enabled ? () => controller.control.clear() : null,
      icon: const Icon(Icons.gesture),
      style: TextButton.styleFrom(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
      ),
      label: Text(localization.btnClearSignature),
    );
  }

  /// The dialog actions: Cancel and Done. Done is enabled only when something is
  /// drawn and no commit is in progress.
  List<Widget> buildActions(ThemeData theme) {
    final localization = QuestionnaireLocalization.instance.localization;
    return [
      Expanded(
        child: TextButton(
          onPressed: committing ? null : cancel,
          child: Text(localization.btnCancel),
        ),
      ),
      Expanded(
        child: ElevatedButton(
          onPressed: controller.control.isFilled && !committing ? done : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: Text(localization.btnDone),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localization = QuestionnaireLocalization.instance.localization;
    final theme = Theme.of(context);
    final borderRadius =
        (theme.inputDecorationTheme.border is OutlineInputBorder)
        ? (theme.inputDecorationTheme.border as OutlineInputBorder).borderRadius
        : const BorderRadius.all(Radius.circular(4));
    final dialogTheme = DialogTheme.of(context);
    return Dialog(
      // title: Text(localization.textSignature),
      insetPadding: const EdgeInsets.all(16),
      constraints: dialogConstraints,
      shape: dialogTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Text(
                    localization.textSignature,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                buildSignaturePad(constraints, theme, borderRadius),
                const SizedBox(height: 16),
                Row(spacing: 16, children: buildActions(theme)),
              ],
            );
          },
        ),
      ),
    );
  }
}
