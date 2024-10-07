import 'package:flutter/material.dart';

/// {@template scroll_to_top_status_bar}
/// Widget that that will make the [scrollController] to scroll the top
/// when tapped on the status bar
///
/// Extracted from [Scaffold] and used in [Sheet]
///
/// Example:
/// ```dart
/// StatusBarGestureDetector(
///   child: child,
///     onTap: (context) {
///       _scrollController.animateTo(
///         0.0,
///         curve: Curves.easeOutCirc,
///         duration: const Duration(milliseconds: 1000),
///       );
///     },
///   );
/// ```
/// {@endtemplate}
class StatusBarGestureDetector extends StatefulWidget {
  /// {@macro scroll_to_top_status_bar}
  const StatusBarGestureDetector({
    required this.child,
    required this.onTap,
    super.key,
  });

  /// Child widget
  final Widget child;

  /// On tap to status bar callback
  final void Function(BuildContext context) onTap;

  @override
  State<StatusBarGestureDetector> createState() =>
      _StatusBarGestureDetectorState();
}

/// State of [StatusBarGestureDetector].
class _StatusBarGestureDetectorState extends State<StatusBarGestureDetector> {
  final OverlayPortalController _controller = OverlayPortalController();

  @override
  void initState() {
    _controller.show();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final view = View.of(context);
    return OverlayPortal.targetsRootOverlay(
      controller: _controller,
      overlayChildBuilder: (context) => Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: view.padding.top / view.devicePixelRatio,
          width: double.infinity,
          child: GestureDetector(
            // iOS accessibility automatically adds scroll-to-top to the clock in the status bar
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onTap(context),
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
