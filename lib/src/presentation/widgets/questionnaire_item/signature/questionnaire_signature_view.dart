import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Renders a hand written signature field for a Questionnaire that declares the
/// `questionnaire-signatureRequired` extension, either at root level or on an
/// item.
///
/// It is used under the same logic as any other Questionnaire item view: it
/// extends [QuestionnaireItemView] so it gets required-marker, error display,
/// enableWhen gating, validation and size tracking for free.
///
/// The field shows a tappable preview: initially a placeholder inviting the user
/// to sign, and, once signed, the drawn signature image. Tapping opens a dialog
/// with the actual drawing pad; the signature is committed to the [controller]
/// when the user taps "Done". Drawing in a dialog (instead of inline) avoids the
/// pad's gesture being stolen by the surrounding scrolling list.
///
/// For an item level signature (typically a `group`), the item's normal view is
/// passed as [child] and rendered above the field, so the group still shows its
/// children. For a root level signature [child] is `null`.
///
/// The signature is ALWAYS required whenever the marker is present, regardless
/// of the item's own `required` flag.
class QuestionnaireSignatureView extends QuestionnaireItemView {
  /// The normal inner view rendered above the signature field (e.g. a group with
  /// its children). Null for a root level signature.
  final Widget? child;

  QuestionnaireSignatureView({
    super.key,
    SignatureController? controller,
    required super.item,
    this.child,
    super.enableWhenController,
  }) : super(
         controller: controller ?? SignatureController(focusNode: FocusNode()),
       );

  @override
  State createState() => QuestionnaireSignatureViewState();
}

class QuestionnaireSignatureViewState
    extends QuestionnaireItemViewState<QuestionnaireSignatureView> {
  static const double _fieldHeight = 180;

  @override
  SignatureController get controller => super.controller as SignatureController;

  /// A signature is always required whenever the marker is present, independent
  /// of the item's own `required` flag.
  @override
  bool get isRequired => true;

  /// The inner view (e.g. group) renders its own title; a "Signature" label is
  /// rendered inside [buildBody] instead, so don't duplicate a title here.
  @override
  Widget? buildTitleView(
    BuildContext context, {
    bool? forGroup,
    bool? noPadding,
    TextStyle? style,
  }) => null;

  BorderRadius get _borderRadius =>
      (theme.inputDecorationTheme.border is OutlineInputBorder)
      ? (theme.inputDecorationTheme.border as OutlineInputBorder).borderRadius
      : const BorderRadius.all(Radius.circular(4));

  /// Builds the dialog shown when the field is tapped. Override to provide a
  /// custom [SignaturePadDialog] subclass.
  Widget buildSignatureDialog(BuildContext context) =>
      SignaturePadDialog(controller: controller);

  /// Opens the drawing pad in a dialog. When the user taps "Done" the drawn
  /// signature is exported to PNG and stored on [controller], which refreshes
  /// the preview and clears any required error.
  Future<void> openSignatureDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: buildSignatureDialog,
    );
    if (saved == true) setState(() {});
  }

  @override
  Widget buildBody(BuildContext context) {
    final localization = QuestionnaireLocalization.instance.localization;
    final borderColor = controller.hasError
        ? theme.colorScheme.error
        : theme.dividerColor;
    final signatureBytes = controller.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.child != null) ...[widget.child!, const SizedBox(height: 8)],
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
          child: Text.rich(
            TextSpan(
              style: theme.textTheme.titleSmall,
              children: [
                TextSpan(text: localization.textSignature),
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: isReadOnly ? null : openSignatureDialog,
          borderRadius: _borderRadius,
          child: Container(
            height: _fieldHeight,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 0.5),
              borderRadius: _borderRadius,
            ),
            clipBehavior: Clip.hardEdge,
            child: signatureBytes != null
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.memory(signatureBytes, fit: BoxFit.contain),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gesture, size: 32, color: theme.hintColor),
                      const SizedBox(height: 8),
                      Text(
                        localization.textTapToSign,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (signatureBytes != null && !isReadOnly)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => controller.clear()),
              icon: const Icon(Icons.clear),
              label: Text(localization.btnClearSignature),
            ),
          ),
      ],
    );
  }
}
