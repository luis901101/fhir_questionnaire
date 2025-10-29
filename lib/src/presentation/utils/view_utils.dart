import 'package:flutter/rendering.dart' as rendering;
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/widgets.dart';

class ViewUtils {
  static double getTextHeightAfterRender({
    required BuildContext context,
    String? text,
    TextStyle? textStyle,
    EdgeInsets? padding,
    TextSpan? textSpan,
  }) {
    if (text.isEmpty && textSpan == null) return 0;
    final mediaQuery = MediaQuery.of(context);
    var renderParagraph = rendering.RenderParagraph(
      textSpan ?? TextSpan(style: textStyle, text: text),
      textDirection: rendering.TextDirection.ltr,
      // Important as the user can have increased text on his device
      textScaler: MediaQuery.textScalerOf(context),
    );
    final horizontalPadding = padding?.horizontal ?? 0;
    final verticalPadding = padding?.vertical ?? 0;
    var width = mediaQuery.size.width - horizontalPadding;
    var intrinsicHeight =
        renderParagraph.computeMinIntrinsicHeight(width) + verticalPadding;
    return intrinsicHeight;
  }
}
