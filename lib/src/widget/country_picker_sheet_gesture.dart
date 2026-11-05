/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 4 November 2026
 */

import 'package:flutter/foundation.dart' show internal;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Coordinates list scrolling and a separately started sheet-dismiss gesture.
@internal
class CountryPickerSheetGesture extends StatefulWidget {
  /// Creates the sheet coordinator without installing another drag recognizer.
  const CountryPickerSheetGesture({
    required this.initialSize,
    required this.minSize,
    required this.canDismiss,
    required this.onDismiss,
    required this.builder,
    super.key,
  });

  /// Initial height as a fraction of the available route height.
  final double initialSize;

  /// Minimum height of the sheet detents.
  final double minSize;

  /// Expands the enclosing picker for search without exposing a public API.
  static bool expandOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_SheetGestureState>();
    if (state == null) return false;
    // A full-height sheet may have equal animation bounds. Animating it again
    // would divide by a zero range when calculating the animation duration.
    if (state._size.value == 1) return true;
    state._size.animateTo(1, curve: Curves.easeOutCubic).ignore();
    return true;
  }

  /// Whether a downward gesture started at the top may dismiss the route.
  final bool canDismiss;

  /// Dismisses the enclosing route after a deliberate sheet drag.
  final VoidCallback onDismiss;

  /// Builds the sheet using the single coordinated list controller.
  final ScrollableWidgetBuilder builder;

  @override
  State<CountryPickerSheetGesture> createState() => _SheetGestureState();
}

/// Owns the translation animation; the sheet subtree stays stable while moving.
class _SheetGestureState extends State<CountryPickerSheetGesture>
    with TickerProviderStateMixin {
  late final AnimationController _offset = AnimationController.unbounded(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  late final AnimationController _size = AnimationController(
    vsync: this,
    value: widget.initialSize,
    lowerBound: widget.minSize,
    duration: const Duration(milliseconds: 250),
  );
  double _availableHeight = 1;
  late final _SheetScrollController _scroll = _SheetScrollController(this);

  /// Consumes only the portion of a top-started gesture moving the sheet.
  void pull(double delta) {
    _offset.stop();
    _offset.value = (_offset.value + delta).clamp(0.0, double.infinity);
  }

  /// Uses sheet-drag velocity only, never momentum from a list fling.
  void release(double velocity) {
    final height = _availableHeight * _size.value;
    if (widget.canDismiss &&
        (_offset.value > height * .25 ||
            (_offset.value > kTouchSlop && velocity > 700))) {
      widget.onDismiss();
    } else {
      _offset.animateTo(0, curve: Curves.easeOutCubic).ignore();
      settleSize(-velocity);
    }
  }

  /// Returns an interrupted resize to the initial or full detent.
  void settleSize(double velocity) {
    if (_size.value == 1) return;
    final midpoint = (widget.initialSize + 1) / 2;
    _size
        .animateTo(
          velocity > 0 || (velocity == 0 && _size.value >= midpoint)
              ? 1
              : widget.initialSize,
          curve: Curves.easeOutCubic,
        )
        .ignore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _offset.dispose();
    _size.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _availableHeight = constraints.maxHeight;
      return AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_offset, _size]),
        child: GestureDetector(
          onVerticalDragStart: widget.canDismiss ? (_) => _offset.stop() : null,
          onVerticalDragUpdate: widget.canDismiss
              ? (details) => pull(details.primaryDelta ?? 0)
              : null,
          onVerticalDragEnd: widget.canDismiss
              ? (details) => release(details.velocity.pixelsPerSecond.dy)
              : null,
          onVerticalDragCancel: widget.canDismiss ? () => release(0) : null,
          child: widget.builder(context, _scroll),
        ),
        builder: (context, child) => Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: _size.value,
            widthFactor: 1,
            child: Transform.translate(
              offset: Offset(0, _offset.value),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

/// Creates list positions sharing the coordinator's drag ownership rules.
class _SheetScrollController extends ScrollController {
  _SheetScrollController(this.owner);

  final _SheetGestureState owner;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => _SheetScrollPosition(
    owner: owner,
    physics: physics,
    context: context,
    oldPosition: oldPosition,
  );
}

/// Locks dismissal eligibility at drag start and keeps ballistic scrolling local.
class _SheetScrollPosition extends ScrollPositionWithSingleContext {
  _SheetScrollPosition({
    required this.owner,
    required super.physics,
    required super.context,
    super.oldPosition,
  });

  final _SheetGestureState owner;
  bool _startedAtTop = false;
  bool _dragging = false;

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    _startedAtTop =
        pixels <= minScrollExtent + physics.toleranceFor(this).distance;
    _dragging = true;
    owner._offset.stop();
    owner._size.stop();
    return super.drag(details, dragCancelCallback);
  }

  @override
  void applyUserOffset(double delta) {
    var effectiveDelta = delta;
    if (_dragging &&
        _startedAtTop &&
        effectiveDelta > 0 &&
        owner._offset.value == 0 &&
        owner._size.value > owner.widget.minSize) {
      final resize = effectiveDelta.clamp(
        0.0,
        (owner._size.value - owner.widget.minSize) * owner._availableHeight,
      );
      owner._size.value = (owner._size.value - resize / owner._availableHeight)
          .clamp(owner.widget.minSize, 1.0);
      effectiveDelta -= resize;
      if (effectiveDelta == 0) return;
    }
    if (_dragging &&
        _startedAtTop &&
        owner.widget.canDismiss &&
        (owner._offset.value > 0 ||
            (effectiveDelta > 0 && pixels <= minScrollExtent))) {
      final before = owner._offset.value;
      owner.pull(effectiveDelta);
      final remaining = effectiveDelta - (owner._offset.value - before);
      if (remaining == 0) return;
      super.applyUserOffset(remaining);
      return;
    }
    if (effectiveDelta < 0 &&
        owner._size.value < 1 &&
        pixels <= minScrollExtent) {
      owner._size.value =
          (owner._size.value - effectiveDelta / owner._availableHeight).clamp(
            owner.widget.minSize,
            1.0,
          );
      return;
    }
    super.applyUserOffset(effectiveDelta);
  }

  @override
  void goBallistic(double velocity) {
    final wasDragging = _dragging;
    final pulledSheet = wasDragging && owner._offset.value > 0;
    _dragging = false;
    _startedAtTop = false;
    if (pulledSheet) {
      owner.release(-velocity);
    } else if (wasDragging && owner._size.value < 1) {
      owner.settleSize(velocity);
    }
    super.goBallistic(pulledSheet ? 0 : velocity);
  }
}
