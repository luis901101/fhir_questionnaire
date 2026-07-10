import 'dart:typed_data';

import 'package:fhir_questionnaire_r4/fhir_questionnaire_r4.dart';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

/// [FieldController] for a hand written signature. Its [value] holds the
/// exported PNG bytes of the committed signature.
///
/// The signature is drawn in a modal dialog (see `QuestionnaireSignatureView`)
/// and committed to [value] when the user taps "Done". The form itself only
/// shows a preview of [value], so there is no drawing pad competing with the
/// list scroll.
///
/// The underlying [HandSignatureControl] is owned here (not in the widget
/// [State]) on purpose: it keeps the last drawn strokes so re-opening the dialog
/// shows and lets the user continue editing the previous drawing, and it
/// survives the item view being recycled while scrolling (the base item view
/// uses `wantKeepAlive => false`).
class SignatureController extends CustomValueController<Uint8List> {
  /// The underlying hand_signature drawing control.
  final HandSignatureControl control;

  /// Pen color used both on-screen and when exporting the PNG.
  final Color penColor;

  /// Minimal stroke width for the drawer.
  final double strokeWidth;

  /// Maximal stroke width for the drawer.
  final double maxStrokeWidth;

  SignatureController({
    super.focusNode,
    HandSignatureControl? control,
    this.penColor = Colors.black,
    this.strokeWidth = 1.0,
    this.maxStrokeWidth = 10.0,
  }) : control = control ?? HandSignatureControl();

  /// The drawer used to render the on-screen signature, matching the PNG export.
  ShapeSignatureDrawer get drawer => ShapeSignatureDrawer(
    color: penColor,
    width: strokeWidth,
    maxWidth: maxStrokeWidth,
  );

  /// Exports the current drawing to PNG bytes and stores them in [value]. Called
  /// when the user taps "Done" in the signature dialog. Setting [value] notifies
  /// listeners, which refreshes the preview and clears any required error.
  Future<void> commit() async {
    if (!control.isFilled) {
      value = null;
      return;
    }
    final data = await control.toImage(color: penColor, fit: true);
    value = data?.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  void clear() {
    control.clear();
    super.clear();
  }

  @override
  void dispose() {
    control.dispose();
    super.dispose();
  }
}
