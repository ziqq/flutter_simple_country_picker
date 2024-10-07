import 'package:flutter/material.dart';

/// {@template example_navigator}
/// ExampleNavigator widget.
/// {@endtemplate}
class ExampleNavigator extends StatefulWidget {
  /// {@macro example_navigator}
  const ExampleNavigator({
    required this.child,
    super.key, // ignore: unused_element
  });

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<ExampleNavigator> createState() => _ExampleNavigatorState();
}

/// State for widget ExampleNavigator.
class _ExampleNavigatorState extends State<ExampleNavigator> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void didUpdateWidget(covariant ExampleNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget configuration changed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The configuration of InheritedWidgets has changed
    // Also called after initState but before build
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => widget.child;
}
