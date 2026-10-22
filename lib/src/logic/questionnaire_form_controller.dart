import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fhir_plus/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Reads and drives a rendered [QuestionnaireView] from code: lists its items,
/// reads and sets their answers, scrolls to and highlights an item, validates,
/// builds the response and submits.
///
/// Pass it as [QuestionnaireView.formController]. The view attaches it once its
/// items are built and detaches it when it is disposed, so one controller can
/// outlive the view state it drives (for example when the state is recreated
/// after loading). Every method other than [isAttached] needs it attached.
///
/// Everything set here goes through the item's own controller, so the form
/// shows it at once and the user can change it by hand, and the response is
/// exactly what the Submit button would build.
///
/// It notifies its listeners once for each answer that changes, whether the
/// user changed it or [setAnswer]/[clearAnswer] did; [lastChangedUid] and
/// [lastChangeByCode] tell which and how.
///
/// ```dart
/// final form = QuestionnaireFormController();
/// // QuestionnaireView(questionnaire: questionnaire, formController: form)
/// final question = form.items.firstWhere((item) => item.type?.isChoice ?? false);
/// form.highlight(question.uid);
/// await form.scrollTo(question.uid);
/// form.setAnswer(question.uid, question.options.first);
/// ```
class QuestionnaireFormController extends ChangeNotifier {
  /// The [QuestionnaireFormItem.uid] of the root level signature, listed last
  /// in [items] when the Questionnaire declares one.
  static const rootSignatureUid = '#signature';

  /// How long a just enabled item takes to expand (the item views'
  /// `AnimatedSize`), waited for before measuring it in [scrollTo].
  static const enableAnimationDuration = Duration(milliseconds: 350);

  /// How long the items take to resize when the highlight moves (the item
  /// views' `AnimatedSize`, which outlasts the highlight's own padding
  /// animation), waited for before [scrollTo] measures an item. A
  /// `buildHighlight` override that resizes for longer is measured before it
  /// ends.
  static const highlightAnimationDuration = Duration(milliseconds: 350);

  /// Space kept free above an item revealed by [scrollTo].
  static const double revealTopMargin = 8;

  /// Space kept free below an item revealed by [scrollTo], so it is not
  /// covered by the floating Submit button.
  static const double revealBottomMargin = QuestionnaireViewState.fabSize + 16;

  QuestionnaireViewState? _state;
  List<QuestionnaireFormItem> _items = const [];
  Map<String, QuestionnaireFormItem> _itemsByUid = const {};
  final Map<String, Object?> _snapshots = {};
  final Map<String, bool> _enabled = {};
  final Map<String, Completer<void>> _expanding = {};
  final Map<String, Timer> _expandingTimers = {};
  final Set<String> _codeWrites = {};
  final _highlightedView = ValueNotifier<QuestionnaireItemView?>(null);
  String? _highlightedUid;
  Completer<void>? _highlightResizing;
  Timer? _highlightResizingTimer;
  String? _lastChangedUid;
  bool _lastChangeByCode = false;
  bool _checkScheduled = false;
  bool _disposed = false;

  /// Whether a [QuestionnaireView] is attached.
  bool get isAttached => _state != null;

  /// The Questionnaire the attached view renders.
  Questionnaire get questionnaire => _attached.questionnaire;

  /// Every item of the form in display order: depth first, nested items right
  /// after the item they are nested under, and the root level signature (see
  /// [rootSignatureUid]) last. Hidden and disabled items are included; see
  /// [QuestionnaireFormItem.hidden] and [isEnabled].
  List<QuestionnaireFormItem> get items => _items;

  /// The item whose [QuestionnaireFormItem.uid] is [uid], or null.
  QuestionnaireFormItem? itemOf(String uid) => _itemsByUid[uid];

  /// The uid of the item whose answer changed last.
  String? get lastChangedUid => _lastChangedUid;

  /// Whether the last change came from [setAnswer] or [clearAnswer] rather than
  /// from the user.
  bool get lastChangeByCode => _lastChangeByCode;

  /// The uid of the highlighted item, or null.
  String? get highlightedUid => _highlightedUid;

  /// The highlighted item view, which [QuestionnaireView] passes down to its
  /// items through a [QuestionnaireHighlightScope].
  ValueListenable<QuestionnaireItemView?> get highlightedView =>
      _highlightedView;

  /// Completes once the items have resized after the last highlight change
  /// (see [highlightAnimationDuration]), or at once when none is under way.
  /// [QuestionnaireView] waits for it before measuring an item to scroll to.
  Future<void> get highlightSettled =>
      _highlightResizing?.future ?? Future<void>.value();

  QuestionnaireViewState get _attached {
    final state = _state;
    if (state == null) {
      throw StateError('No QuestionnaireView is attached to this controller.');
    }
    return state;
  }

  /// Attaches the view [state] drives. Called by [QuestionnaireViewState] once
  /// its items are built; attaching another state detaches the previous one.
  void attach(QuestionnaireViewState state) {
    if (identical(_state, state)) return;
    final previous = _state;
    if (previous != null) detach(previous);
    _state = state;
    _items = _buildItems(state);
    _itemsByUid = {for (final item in _items) item.uid: item};
    for (final item in _items) {
      for (final controller in item.controllers) {
        controller.addListener(_onControllerChanged);
      }
      _snapshots[item.uid] = _snapshotOf(item);
      _enabled[item.uid] = isEnabled(item.uid);
    }
  }

  /// Detaches [state]. Does nothing when another state is attached, so a
  /// state disposed after its replacement attached leaves the new one alone.
  void detach(QuestionnaireViewState state) {
    if (!identical(_state, state)) return;
    for (final item in _items) {
      for (final controller in item.controllers) {
        controller.removeListener(_onControllerChanged);
      }
    }
    for (final timer in _expandingTimers.values) {
      timer.cancel();
    }
    _expandingTimers.clear();
    for (final completer in _expanding.values) {
      if (!completer.isCompleted) completer.complete();
    }
    _expanding.clear();
    _highlightResizingTimer?.cancel();
    _highlightResizingTimer = null;
    final resizing = _highlightResizing;
    _highlightResizing = null;
    if (resizing != null && !resizing.isCompleted) resizing.complete();
    _snapshots.clear();
    _enabled.clear();
    _codeWrites.clear();
    _items = const [];
    _itemsByUid = const {};
    _highlightedUid = null;
    _highlightedView.value = null;
    _state = null;
  }

  QuestionnaireFormItem _require(String uid) {
    _attached;
    final item = _itemsByUid[uid];
    if (item == null) {
      throw ArgumentError.value(uid, 'uid', 'No item with this uid');
    }
    return item;
  }

  /// Whether the item [uid] is enabled: its own `enableWhen` conditions and
  /// those of every item it is nested under hold. A condition whose source item
  /// is disabled counts as unanswered. The item does not need to be rendered.
  bool isEnabled(String uid) {
    for (
      QuestionnaireFormItem? item = _require(uid);
      item != null;
      item = item.parentUid == null ? null : _itemsByUid[item.parentUid]
    ) {
      if (item.bundle?.enableWhenController?.checkIfEnabled(notify: false) ==
          false) {
        return false;
      }
    }
    return true;
  }

  /// The answers the item [uid] would submit now, as the Submit button would
  /// build them. Empty when it has none, and for a disabled, display, group or
  /// signature item.
  List<QuestionnaireResponseAnswer> answerOf(String uid) {
    final bundle = _require(uid).bundle;
    if (bundle == null || !isEnabled(uid)) return [];
    return _attached.controller.generateItemResponse(bundle)?.answer ?? [];
  }

  /// Sets the answer of the item [uid], exactly as if the user had entered it.
  /// The form shows it at once.
  ///
  /// [value] by item type:
  /// - `string`, `text`, `url`: a [String];
  /// - `integer`: an [int] (or a whole [num]); `decimal`: a [num];
  /// - `boolean`: a [bool];
  /// - `date`, `time`, `dateTime`: a [DateTime];
  /// - `quantity`: a [Quantity], or a [num] in the item's fixed unit;
  /// - `choice`: one of the item's [QuestionnaireFormItem.options] (an equal
  ///   option is replaced by the item's own object), or a [List] of them when
  ///   the item repeats;
  /// - `open-choice`: as `choice`, and a [String] for a free text answer, added
  ///   to the options when new.
  ///
  /// A null [value] clears the answer (see [clearAnswer]).
  ///
  /// Throws an [ArgumentError] for an item that cannot be answered this way
  /// (`attachment`, `display`, `group`, a signature, a read only item) and for
  /// a value of the wrong type or outside the item's options.
  void setAnswer(String uid, Object? value) {
    if (value == null) return clearAnswer(uid);
    final item = _requireAnswerable(uid);
    final controller = item.bundle!.controller;
    final type = item.type!;
    switch (type) {
      case QuestionnaireItemType.string:
      case QuestionnaireItemType.text:
      case QuestionnaireItemType.url:
        if (value is! String) throw _wrongType(uid, value, 'a String');
        (controller as TextEditingController).text = value;
      case QuestionnaireItemType.integer:
        if (value is! num || value != value.roundToDouble()) {
          throw _wrongType(uid, value, 'a whole number');
        }
        (controller as TextEditingController).text = value.toInt().toString();
      case QuestionnaireItemType.decimal:
        if (value is! num) throw _wrongType(uid, value, 'a number');
        (controller as TextEditingController).text = value.toString();
      case QuestionnaireItemType.boolean:
        if (value is! bool) throw _wrongType(uid, value, 'a bool');
        (controller as CustomValueController<bool>).value = value;
      case QuestionnaireItemType.date:
      case QuestionnaireItemType.time:
      case QuestionnaireItemType.dateTime:
        if (value is! DateTime) throw _wrongType(uid, value, 'a DateTime');
        (controller as CustomValueController<DateTime>).value = value;
      case QuestionnaireItemType.quantity:
        final quantityController =
            controller as CustomValueController<Quantity>;
        if (value is Quantity) {
          quantityController.value = value;
        } else if (value is num) {
          final fixedUnit = (item.bundle!.view is QuestionnaireQuantityItemView)
              ? (item.bundle!.view as QuestionnaireQuantityItemView).fixedUnit
              : null;
          quantityController.value = (quantityController.value ?? Quantity())
              .copyWith(
                value: value.toDouble().asFhirDecimal,
                unit: fixedUnit ?? quantityController.value?.unit,
              );
        } else {
          throw _wrongType(uid, value, 'a Quantity or a number');
        }
      case QuestionnaireItemType.choice:
      case QuestionnaireItemType.openChoice:
        if (item.repeats) {
          if (value is! List) throw _wrongType(uid, value, 'a List');
          final options = [for (final entry in value) _option(item, entry)];
          (controller as CustomValueController<List<QuestionnaireAnswerOption>>)
                  .value =
              options;
        } else {
          (controller as CustomValueController<QuestionnaireAnswerOption>)
              .value = _option(
            item,
            value,
          );
        }
      default:
        throw ArgumentError.value(uid, 'uid', 'This item cannot be answered');
    }
    if (controller.hasError) controller.clearError(notify: true);
    _codeWrites.add(uid);
  }

  /// Clears the answer of the item [uid]. A `boolean` item shows `false`
  /// again, which is then its answer.
  ///
  /// Throws an [ArgumentError] for an item [setAnswer] rejects.
  void clearAnswer(String uid) {
    final item = _requireAnswerable(uid);
    item.bundle!.controller.clear();
    _codeWrites.add(uid);
  }

  QuestionnaireFormItem _requireAnswerable(String uid) {
    final item = _require(uid);
    final type = item.type;
    if (item.bundle == null ||
        item.readOnly ||
        type == null ||
        type.isAttachment ||
        type.isDisplay ||
        type.isGroup) {
      throw ArgumentError.value(uid, 'uid', 'This item cannot be answered');
    }
    return item;
  }

  ArgumentError _wrongType(String uid, Object value, String expected) =>
      ArgumentError.value(
        value,
        'value',
        'The item $uid takes $expected, not a ${value.runtimeType}',
      );

  QuestionnaireAnswerOption _option(QuestionnaireFormItem item, Object? value) {
    final options = item.options;
    if (value is QuestionnaireAnswerOption) {
      final option = options.firstWhereOrNull((option) => option == value);
      if (option != null) return option;
      if (item.allowsFreeText && value.valueString != null) {
        return _freeTextOption(item, value.valueString!);
      }
    } else if (value is String && item.allowsFreeText) {
      return _freeTextOption(item, value);
    }
    throw ArgumentError.value(
      value,
      'value',
      'Not one of the options of the item ${item.uid}',
    );
  }

  QuestionnaireAnswerOption _freeTextOption(
    QuestionnaireFormItem item,
    String text,
  ) {
    final controller = item.bundle!.controller;
    if (controller is QuestionnaireChoiceController) {
      return controller.optionForText(text);
    }
    return item.options.firstWhereOrNull(
          (option) => option.valueString == text,
        ) ??
        QuestionnaireAnswerOption(valueString: text);
  }

  /// Scrolls the form until the whole item [uid] is visible, clear of the
  /// floating Submit button, and completes once it is. An item taller than the
  /// screen is aligned to its top.
  ///
  /// The item does not need to be built yet: the list first moves to the item
  /// it is nested under. An item that was just enabled is measured once it has
  /// expanded, and after a [highlight] change once the items have resized.
  Future<void> scrollTo(String uid) async {
    final item = _require(uid);
    // Let pending changes be processed, so an item enabled by an answer set
    // right before this call is known to be expanding.
    await Future<void>.delayed(Duration.zero);
    if (!identical(_itemsByUid[uid], item)) return;
    final expanding = [
      for (
        QuestionnaireFormItem? current = item;
        current != null;
        current = current.parentUid == null
            ? null
            : _itemsByUid[current.parentUid]
      )
        ?_expanding[current.uid]?.future,
    ];
    if (expanding.isNotEmpty) await Future.wait(expanding);
    final state = _state;
    if (state == null || !state.mounted) return;
    await state.scrollToItem(item.view, topLevelIndex: item.topLevelIndex);
  }

  /// Highlights the item [uid], replacing any other highlight.
  ///
  /// The highlight pads the item, so it grows and the item highlighted before
  /// shrinks back. Highlight an item before scrolling to it: [scrollTo] waits
  /// for the items to resize, then reveals the item at its highlighted size.
  void highlight(String uid) {
    final item = _require(uid);
    _highlightedUid = uid;
    _setHighlightedView(item.view);
  }

  /// Removes the highlight.
  void clearHighlight() {
    _highlightedUid = null;
    _setHighlightedView(null);
  }

  void _setHighlightedView(QuestionnaireItemView? view) {
    if (identical(_highlightedView.value, view)) return;
    _highlightedView.value = view;
    if (_state == null) return;
    _highlightResizingTimer?.cancel();
    final previous = _highlightResizing;
    final completer = Completer<void>();
    _highlightResizing = completer;
    _highlightResizingTimer = Timer(highlightAnimationDuration, () {
      _highlightResizingTimer = null;
      if (identical(_highlightResizing, completer)) _highlightResizing = null;
      completer.complete();
    });
    // Anyone waiting on the earlier change waits for this one.
    if (previous != null && !previous.isCompleted) {
      previous.complete(completer.future);
    }
  }

  /// Validates the form exactly as the Submit button does: every invalid item
  /// shows its error and the form scrolls to the first one. Returns the uids
  /// of the invalid items, in display order; empty when the form is valid.
  List<String> validate() {
    final state = _attached;
    final invalid = state.validateItems();
    if (invalid.isNotEmpty) state.scrollToInvalidItem(invalid.first);
    return [
      for (final view in invalid)
        ?_items.firstWhereOrNull((item) => identical(item.view, view))?.uid,
    ];
  }

  /// Builds the response exactly as the Submit button would, root level
  /// signature included, without validating.
  QuestionnaireResponse buildResponse() => _attached.buildResponse();

  /// Does what tapping the Submit button does: validates and, when valid,
  /// passes the response to [QuestionnaireView.onSubmit].
  void submit() {
    final state = _attached;
    if (state.allowSubmit) state.onSubmit();
  }

  List<QuestionnaireFormItem> _buildItems(QuestionnaireViewState state) {
    final items = <QuestionnaireFormItem>[];
    void walk(
      List<QuestionnaireItemBundle> bundles, {
      required int depth,
      required int topLevelIndex,
      String? parentUid,
    }) {
      for (int i = 0; i < bundles.length; ++i) {
        final bundle = bundles[i];
        final topIndex = depth == 0 ? i : topLevelIndex;
        items.add(
          QuestionnaireFormItem(
            form: this,
            uid: bundle.uid,
            item: bundle.item,
            bundle: bundle,
            view: bundle.view,
            depth: depth,
            parentUid: parentUid,
            topLevelIndex: topIndex,
          ),
        );
        walk(
          bundle.children ?? [],
          depth: depth + 1,
          topLevelIndex: topIndex,
          parentUid: bundle.uid,
        );
      }
    }

    walk(state.itemBundles, depth: 0, topLevelIndex: 0);
    final rootSignatureView = state.rootSignatureView;
    if (rootSignatureView != null) {
      items.add(
        QuestionnaireFormItem(
          form: this,
          uid: rootSignatureUid,
          item: rootSignatureView.item,
          view: rootSignatureView,
          signatureController: state.rootSignatureController,
          depth: 0,
          topLevelIndex: state.itemBundles.length,
        ),
      );
    }
    return items;
  }

  Object? _snapshotOf(QuestionnaireFormItem item) => [
    for (final controller in item.controllers)
      switch (controller.rawValue) {
        final List list => List.of(list),
        final value => value,
      },
  ];

  void _onControllerChanged() {
    // Compared once the current work is done, not on each notification: a
    // view may write its controller while building (the drop down resets and
    // restores its value), and that is not a change.
    if (_checkScheduled) return;
    _checkScheduled = true;
    scheduleMicrotask(_checkChanges);
  }

  void _checkChanges() {
    _checkScheduled = false;
    if (_disposed || !isAttached) return;
    final changed = <String>[];
    for (final item in _items) {
      final snapshot = _snapshotOf(item);
      if (!const DeepCollectionEquality().equals(
        snapshot,
        _snapshots[item.uid],
      )) {
        _snapshots[item.uid] = snapshot;
        changed.add(item.uid);
      }
    }
    if (changed.isEmpty) {
      _codeWrites.clear();
      return;
    }
    for (final item in _items) {
      final enabled = isEnabled(item.uid);
      if (_enabled[item.uid] == false && enabled) _markExpanding(item.uid);
      _enabled[item.uid] = enabled;
    }
    final byCode = {..._codeWrites};
    _codeWrites.clear();
    for (final uid in changed) {
      _lastChangedUid = uid;
      _lastChangeByCode = byCode.contains(uid);
      notifyListeners();
      if (_disposed || !isAttached) return;
    }
  }

  void _markExpanding(String uid) {
    _expandingTimers.remove(uid)?.cancel();
    final previous = _expanding[uid];
    final completer = Completer<void>();
    _expanding[uid] = completer;
    _expandingTimers[uid] = Timer(enableAnimationDuration, () {
      _expandingTimers.remove(uid);
      if (identical(_expanding[uid], completer)) _expanding.remove(uid);
      if (!completer.isCompleted) completer.complete();
    });
    // Anyone waiting on the earlier expansion waits for this one.
    if (previous != null && !previous.isCompleted) {
      previous.complete(completer.future);
    }
  }

  @override
  void dispose() {
    final state = _state;
    if (state != null) detach(state);
    _disposed = true;
    _highlightedView.dispose();
    super.dispose();
  }
}
