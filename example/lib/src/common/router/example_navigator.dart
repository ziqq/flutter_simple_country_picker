// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:collection';

import 'package:flutter/foundation.dart' show listEquals, SynchronousFuture;
import 'package:material_ui/material_ui.dart';

/// An ordered stack of pages shown by [ExampleNavigator].
typedef ExampleNavigatorState = List<ExamplePage>;

/// {@template example_navigator}
/// Maintains the page stack for the example app.
/// {@endtemplate}
class ExampleNavigator extends StatefulWidget {
  /// Creates a navigator that owns its page stack.
  ExampleNavigator({
    required this.pages,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(pages.isNotEmpty, 'pages cannot be empty'),
       controller = null;

  /// Creates a navigator whose page stack is driven by [controller].
  ExampleNavigator.controlled({
    required ValueNotifier<ExampleNavigatorState> this.controller,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(controller.value.isNotEmpty, 'controller cannot be empty'),
       pages = controller.value;

  /// Initial pages to display.
  final ExampleNavigatorState pages;

  /// Optional external controller.
  final ValueNotifier<ExampleNavigatorState>? controller;

  /// Functions that can filter or redirect a proposed page stack.
  final List<
    ExampleNavigatorState Function(
      BuildContext context,
      ExampleNavigatorState state,
    )
  >
  guards;

  /// Observers to attach to the Navigator.
  final List<NavigatorObserver> observers;

  /// The delegate that determines how page additions and removals animate.
  final TransitionDelegate<Object?> transitionDelegate;

  /// Optional external signal to re-run guards.
  final Listenable? revalidate;

  /// The callback function that will be called when the back button is pressed.
  ///
  /// It must return a boolean with true if this navigator
  /// will handle the request, otherwise, return a boolean with false.
  ///
  /// Also you can mutate the [ExampleNavigatorState]
  /// to change the navigation stack.
  final ({ExampleNavigatorState state, bool handled}) Function(
    ExampleNavigatorState state,
  )?
  onBackButtonPressed;

  /// The [AuthenticationNavigatorState] from the closest instance of this class
  /// that encloses the given context, if any.
  static AuthenticationNavigatorState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<AuthenticationNavigatorState>();

  /// The [ExampleNavigatorState] from the closest instance of this class
  /// that encloses the given context, if any.
  static ExampleNavigatorState? stateOf(BuildContext context) =>
      maybeOf(context)?.state;

  /// The [NavigatorState] from the closest instance of this class
  /// that encloses the given context, if any.
  static NavigatorState? navigatorOf(BuildContext context) =>
      maybeOf(context)?.navigator;

  /// Applies a transformation to the nearest navigator’s page stack.
  static void change(
    BuildContext context,
    ExampleNavigatorState Function(ExampleNavigatorState pages) fn,
  ) => maybeOf(context)?.change(fn);

  /// Add a new page onto the stack.
  static void push(BuildContext context, ExamplePage page) =>
      change(context, (state) => [...state, page]);

  /// Removes the top page from the stack.
  static void pop(BuildContext context) => change(context, (state) {
    if (state.isNotEmpty) state.removeLast();
    return state;
  });

  /// Reset to the initial pages.
  static void reset(BuildContext context) {
    final navigator = maybeOf(context);
    if (navigator == null) return;
    navigator.change((_) => navigator.widget.pages);
  }

  @override
  AuthenticationNavigatorState createState() => AuthenticationNavigatorState();
}

/// State for the [ExampleNavigator] widget.
class AuthenticationNavigatorState extends State<ExampleNavigator>
    with WidgetsBindingObserver {
  /// The navigator observed by this widget, once it has been mounted.
  NavigatorState? get navigator => _observer.navigator;
  final NavigatorObserver _observer = NavigatorObserver();

  /// The current stack of example pages.
  ExampleNavigatorState get state => _state.value;

  late final ValueNotifier<ExampleNavigatorState> _state;

  /// The internal observer followed by the observers supplied by the app.
  late List<NavigatorObserver> _observers;

  @override
  void initState() {
    super.initState();
    _state = ValueNotifier<ExampleNavigatorState>(widget.pages);
    widget.revalidate?.addListener(revalidate);
    _observers = <NavigatorObserver>[_observer, ...widget.observers];
    widget.controller?.addListener(_controllerListener);
    _controllerListener();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    revalidate();
  }

  @override
  void didUpdateWidget(ExampleNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revalidate != widget.revalidate) {
      oldWidget.revalidate?.removeListener(revalidate);
      widget.revalidate?.addListener(revalidate);
    }
    if (!identical(oldWidget.observers, widget.observers)) {
      _observers = [_observer, ...widget.observers];
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerListener);
      widget.controller?.addListener(_controllerListener);
      _controllerListener();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerListener);
    widget.revalidate?.removeListener(revalidate);
    WidgetsBinding.instance.removeObserver(this);
    _state.dispose();
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() {
    final backButtonHandler = widget.onBackButtonPressed;
    if (backButtonHandler != null) {
      final result = backButtonHandler(_state.value.toList());
      change((pages) => result.state);
      return SynchronousFuture(result.handled);
    }

    // Let the host handle back when the example is already at its root.
    if (_state.value.length < 2) return SynchronousFuture(false);
    _onDidRemovePage(_state.value.last);
    return SynchronousFuture(true);
  }

  /// Reruns guards on the current stack after dependencies change.
  void revalidate() {
    if (!mounted) return;
    final ctx = context;
    final next = widget.guards.fold(_state.value.toList(), (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state.value)) return;
    _state.value = UnmodifiableListView<ExamplePage>(next);
    _setStateToController();
  }

  /// Applies a programmatic change to the navigation stack.
  void change(ExampleNavigatorState Function(ExampleNavigatorState pages) fn) {
    final prev = _state.value.toList();
    var next = fn(prev);
    if (next.isEmpty) return;
    if (!mounted) return;
    final ctx = context;
    next = widget.guards.fold(next, (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state.value)) return;
    _state.value = UnmodifiableListView<ExamplePage>(next);
    _setStateToController();
  }

  /// Writes the guarded stack back without notifying its own listener.
  void _setStateToController() {
    if (widget.controller
        case ValueNotifier<ExampleNavigatorState> controller) {
      controller
        ..removeListener(_controllerListener)
        ..value = _state.value
        ..addListener(_controllerListener);
    }
  }

  void _controllerListener() {
    final controller = widget.controller;
    if (controller == null || !mounted) return;
    final newValue = controller.value;
    if (identical(newValue, _state.value)) return;
    final ctx = context;
    final next = widget.guards.fold(newValue.toList(), (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state.value)) {
      _setStateToController();
    } else {
      _state.value = UnmodifiableListView<ExamplePage>(next);
      _setStateToController();
    }
  }

  void _onDidRemovePage(Page<Object?> page) {
    change((pages) => pages..removeWhere((p) => p.key == page.key));
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _state,
    builder: (_, pages, _) => Navigator(
      transitionDelegate: widget.transitionDelegate,
      reportsRouteUpdateToEngine: false,
      onDidRemovePage: _onDidRemovePage,
      observers: _observers,
      pages: pages,
    ),
  );
}

/// {@template example_page}
/// A page whose stable key identifies it in the example navigation stack.
/// {@endtemplate}
@immutable
sealed class ExamplePage extends MaterialPage<Object?> {
  /// Creates a page with a route name, arguments, and stable key.
  const ExamplePage({
    required String super.name,
    required Map<String, Object?>? super.arguments,
    required super.child,
    required LocalKey super.key,
  });

  @override
  String get name => super.name ?? 'unknown';

  @override
  Map<String, Object?>? get arguments => switch (super.arguments) {
    Map<String, Object?> args when args.isNotEmpty => args,
    _ => const <String, Object?>{},
  };

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExamplePage && other.key == key;
}

/// Home page of the example app.
final class HomePage<T> extends ExamplePage {
  /// Wraps the example’s root screen in the initial page.
  const HomePage({required super.child})
    : super(
        name: 'home',
        arguments: const <String, Object?>{},
        key: const ValueKey<String>('home_page'),
      );
}
