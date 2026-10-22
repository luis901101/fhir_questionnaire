import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';

/// One item of a form driven by a [QuestionnaireFormController], with what is
/// needed to present and answer it. The root level signature is listed as an
/// item too (see [isSignature]).
class QuestionnaireFormItem {
  /// The controller driving the form this item belongs to.
  final QuestionnaireFormController form;

  /// The item's unique id in the form: its `linkId` prefixed by the link ids of
  /// the items it is nested under (see [QuestionnaireItemBundle.uid]), or
  /// [QuestionnaireFormController.rootSignatureUid].
  final String uid;

  /// The Questionnaire item. For the root level signature, a placeholder
  /// `display` item.
  final QuestionnaireItem item;

  /// The item's bundle; null for the root level signature.
  final QuestionnaireItemBundle? bundle;

  /// The view rendering the item.
  final QuestionnaireItemView view;

  /// How deep the item is nested; 0 at the top level.
  final int depth;

  /// The uid of the item this one is nested under, or null at the top level.
  final String? parentUid;

  /// The index in [QuestionnaireViewState.itemBundles] of the top level item
  /// this one is (or is nested under); the item count for the root signature.
  final int topLevelIndex;
  final SignatureController? _rootSignatureController;

  /// Built by [form] for each item of the view it is attached to (see
  /// [QuestionnaireFormController.items]). [signatureController] is given only
  /// for the root level signature, which has no [bundle].
  QuestionnaireFormItem({
    required this.form,
    required this.uid,
    required this.item,
    required this.view,
    this.bundle,
    required this.depth,
    this.parentUid,
    required this.topLevelIndex,
    SignatureController? signatureController,
  }) : _rootSignatureController = signatureController;

  /// Whether this is the root level signature.
  bool get isSignature => bundle == null;

  /// The item's `linkId`.
  String get linkId => item.linkId;

  /// The item type; null for the root level signature.
  QuestionnaireItemType? get type => isSignature ? null : item.itemType;

  /// The text the form displays for the item; null for the root level
  /// signature.
  String? get text => isSignature ? null : item.title;

  /// Whether the item must be answered. A signature always must.
  bool get required => isSignature || item.isRequired;

  /// Whether the item's answer cannot be changed.
  bool get readOnly => !isSignature && item.isReadOnly;

  /// Whether the item is never shown (see [QuestionnaireItemUtils.isHidden]).
  bool get hidden => !isSignature && item.isHidden;

  /// Whether the item may hold more than one answer.
  bool get repeats => item.isRepeating;

  /// The options a `choice` or `open-choice` item offers, in display order,
  /// free text answers added to an open choice included. Labels come from
  /// [QuestionnaireAnswerOptiontils.title]. Empty for other items.
  List<QuestionnaireAnswerOption> get options {
    final type = this.type;
    if (type == null || !(type.isChoice || type.isOpenChoice)) return const [];
    final controller = bundle!.controller;
    return controller is QuestionnaireChoiceController
        ? controller.options
        : (item.answerOption ?? const []);
  }

  /// Whether the item takes a free text answer besides its options.
  bool get allowsFreeText => type?.isOpenChoice ?? false;

  /// The item's helper text (see [QuestionnaireItemUtils.helperText]).
  String? get helperText => isSignature ? null : item.helperText;

  /// Whether the item asks for a hand written signature: the root level
  /// signature, or an item with the `questionnaire-signatureRequired`
  /// extension. Only the user can sign.
  bool get requiresSignature => isSignature || item.hasSignature;

  /// The controller holding the item's signature, if it asks for one.
  SignatureController? get signatureController =>
      _rootSignatureController ?? bundle?.signatureController;

  /// Whether the item's signature has been drawn.
  bool get signed => signatureController?.value != null;

  /// Whether the item is enabled now (see [QuestionnaireFormController.isEnabled]).
  bool get enabled => form.isEnabled(uid);

  /// Every controller holding a value of this item: its answer and signature
  /// controllers (see [QuestionnaireItemBundle.controllers]), or the root
  /// level signature's.
  List<FieldController> get controllers => [
    ...?bundle?.controllers,
    ?_rootSignatureController,
  ];
}
