import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_controller.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_provider.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_state.dart';
import 'package:meta/meta.dart';

/// {@template countries_scope}
/// CountriesScope widget.
/// {@endtemplate}
@experimental
@internal
class CountriesScope extends StatefulWidget {
  /// {@macro countries_scope}
  const CountriesScope({
    required this.child,
    super.key, // ignore: unused_element
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// The [CountriesController] from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `CountriesScope.of(context)`.
  static CountriesController of(BuildContext context, {bool listen = false}) =>
      _InheritedCountries.of(context, listen: listen).scope._controller;

  /// The [CountriesState] from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `CountriesScope.getState(context)`.
  static CountriesState getState(BuildContext context, {bool listen = true}) =>
      _InheritedCountries.of(context, listen: listen).state;

  @override
  State<CountriesScope> createState() => _CountriesScopeState();
}

/// State for widget [CountriesScope].
class _CountriesScopeState extends State<CountriesScope> {
  late final CountriesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CountriesController(provider: CountriesProvider());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<CountriesState>(
        valueListenable: _controller,
        builder: (context, state, _) => _InheritedCountries(
          scope: this,
          state: state,
          child: widget.child,
        ),
      );
}

/// Inherited widget for quick access in the element tree.
class _InheritedCountries extends InheritedModel<String> {
  const _InheritedCountries({
    required this.scope,
    required this.state,
    required super.child,
  });

  final _CountriesScopeState scope;
  final CountriesState state;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// For example: `CountriesScope.maybeOf(context)`.
  static _InheritedCountries? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      listen
          ? context.dependOnInheritedWidgetOfExactType<_InheritedCountries>()
          : context.getInheritedWidgetOfExactType<_InheritedCountries>();

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a _InheritedCountries of the exact type',
        'out_of_scope',
      );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `CountriesScope.of(context)`.
  static _InheritedCountries of(
    BuildContext context, {
    bool listen = true,
  }) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant _InheritedCountries oldWidget) => false;

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedCountries oldWidget,
    Set<String> aspects,
  ) {
    // ignore: unused_local_variable
    for (final id in aspects) {
      return false;
      // if (state.getById(id) != oldWidget.state.getById(id)) return true;
    }
    return false;
  }
}
