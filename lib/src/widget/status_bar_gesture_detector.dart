import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

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
@internal
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

  /// Duration of the scroll animation
  static Duration duration = const Duration(milliseconds: 1000);

  /// Scroll to top
  static void scrollToTop(ScrollController controller) {
    controller.animateTo(
      0.0, // ignore: prefer_int_literals
      curve: Curves.easeOutCirc,
      duration: duration,
    );
  }
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
            // iOS accessibility automatically
            // adds scroll-to-top to the click in the status bar
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
