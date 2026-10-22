import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/src/model/questionnaire_item_enable_when_controller.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_item_view.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/signature/signature_controller.dart';

class QuestionnaireItemBundle {
  /// Use it just to group views
  final String? groupId;
  final QuestionnaireItem item;
  final List<QuestionnaireItemBundle>? children;

  /// The controller holding this item's answer.
  ///
  /// For a `group` that requires a signature it is the [signatureController],
  /// since a group has no answer of its own.
  final FieldController controller;

  /// The controller holding the signature this item requires, or null when the
  /// item requires none.
  final SignatureController? signatureController;

  /// The controller evaluating this item's `enableWhen` conditions, or null when
  /// the item declares none.
  final QuestionnaireItemEnableWhenController? enableWhenController;
  final QuestionnaireItemView view;

  const QuestionnaireItemBundle({
    required this.groupId,
    required this.item,
    this.children,
    required this.controller,
    required this.view,
    this.signatureController,
    this.enableWhenController,
  });

  /// Returns linkId of the questionnaire [item] prefixed by its parent item
  /// link ids, showing a unique id for this questionnaire [item].
  String get uid =>
      groupId.isNotEmpty ? '$groupId/${item.linkId}' : item.linkId;

  /// Every controller that holds a value of this item: [controller] and, when
  /// it is a different one, [signatureController].
  List<FieldController> get controllers => [
    controller,
    if (signatureController != null &&
        !identical(signatureController, controller))
      signatureController!,
  ];
}
