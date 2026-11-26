import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/country_controller.dart';
import 'package:flutter_simple_country_picker/src/data/country_provider.dart';

/// {@template country_scope}
/// Makes a shared country controller and its list available to descendants.
///
/// Use [of] for direct controller access and [countriesOf] to watch list changes.
/// Set [lazy] to load the list on demand.
/// {@endtemplate}
class CountryScope extends StatefulWidget {
  /// {@macro country_scope}
  const CountryScope({
    required this.child,

    // Country selection.
    this.exclude,
    this.favorites,
    this.filter,
    this.showPhoneCode = false,

    // Loading.
    this.lazy = false,
    super.key, // ignore: unused_element
  });

  /// The widget subtree that can read this scope's countries.
  final Widget child;

  // Country selection.

  /// The country codes omitted from this scope.
  final List<String>? exclude;

  /// The country codes shown first in this scope.
  final List<String>? favorites;

  /// The country codes allowed in this scope.
  final List<String>? filter;

  /// Whether the list includes separate entries for each calling code.
  final bool showPhoneCode;

  // Loading.

  /// Whether to defer loading countries until [CountryController.getCountries]
  /// is called explicitly.
  ///
  /// When `false` (the default) [CountryScope] immediately fetches and caches
  /// the full country list on initialization. Set to `true` when the list
  /// is only needed conditionally (e.g. behind a navigation gate) to avoid
  /// the upfront async work.
  ///
  /// Trigger loading manually when ready:
  ///
  /// ```dart
  /// CountryScope.of(context).getCountries();
  /// ```
  final bool lazy;

  /// Get the [CountryController] from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `CountryScope.of(context)`.
  static CountryController of(BuildContext context) => _InheritedCountries.of(
    context,
    aspect: _CountryScopeAspect.none,
  ).scope._controller;

  /// Get the [List<Country>] from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `CountryScope.countriesOf(context)`.
  static List<Country> countriesOf(
    BuildContext context, {
    bool listen = true,
  }) => _InheritedCountries.of(
    context,
    aspect: listen ? _CountryScopeAspect.countries : _CountryScopeAspect.none,
  ).countries;

  /// Get the [Country] from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `CountryScope.getCountryByCode(context, countryCode)`.
  static Country? getCountryByCode(
    BuildContext context,
    String countryCode, {
    bool listen = true,
  }) => _InheritedCountries.of(
    context,
    aspect: listen ? _CountryScopeAspect.countries : _CountryScopeAspect.none,
  ).getCountryByCode(countryCode);

  @override
  State<CountryScope> createState() => _CountriesScopeState();
}

/// State for widget [CountryScope].
class _CountriesScopeState extends State<CountryScope> {
  /// The controller shared with descendants for the lifetime of this scope.
  late final CountryController _controller;

  /// The latest non-loading state exposed to descendants.
  late CountryState _state;

  @override
  void initState() {
    super.initState();
    _controller = CountryController(
      provider: CountryProvider(),
      favorites: widget.favorites,
      exclude: widget.exclude,
      filter: widget.filter,
      showPhoneCode: widget.showPhoneCode,
    )..addListener(_onStateChanged);
    _state = _controller.state;
    if (!widget.lazy) _controller.getCountries().ignore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localization = CountryLocalizations.of(context);
    _controller.initLocalization(localization);
  }

  @override
  void didUpdateWidget(covariant CountryScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.exclude, widget.exclude) ||
        !listEquals(oldWidget.favorites, widget.favorites) ||
        !listEquals(oldWidget.filter, widget.filter) ||
        oldWidget.showPhoneCode != widget.showPhoneCode ||
        (oldWidget.lazy && !widget.lazy)) {
      _controller.apply(
        exclude: widget.exclude,
        favorites: widget.favorites,
        filter: widget.filter,
        showPhoneCode: widget.showPhoneCode,
        lazy: widget.lazy,
      );
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    super.dispose();
  }

  /// Keeps the last stable country list while the controller reloads.
  void _onStateChanged() {
    final state = _controller.state;
    if (!mounted || state.isLoading || identical(state, _state)) return;
    setState(() {
      _state = state;
    });
  }

  @override
  Widget build(BuildContext context) =>
      _InheritedCountries(scope: this, state: _state, child: widget.child);
}

/// Aspect for country scope.
enum _CountryScopeAspect {
  /// Notify when the country list changes.
  countries,

  /// Look up the scope without registering a dependency.
  none,
}

/// Inherited widget for quick access in the element tree.
class _InheritedCountries extends InheritedModel<_CountryScopeAspect> {
  _InheritedCountries({
    required this.scope,
    required this.state,
    required super.child,
  });

  /// The latest non-loading state.
  final CountryState state;

  /// The list of countries.
  List<Country> get countries => state.countries;

  /// Countries indexed by code when the first lookup is requested.
  late final Map<String, Country> _table = <String, Country>{
    for (final country in countries) country.countryCode: country,
  };

  /// Owns the controller for this inherited widget.
  final _CountriesScopeState scope;

  /// Returns the country associated with [countryCode].
  Country? getCountryByCode(String countryCode) => _table[countryCode];

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// For example: `CountryScope.maybeOf(context)`.
  static _InheritedCountries? maybeOf(
    BuildContext context, {
    _CountryScopeAspect aspect = _CountryScopeAspect.none,
  }) => switch (aspect) {
    // Do not notify about changes.
    _CountryScopeAspect.none =>
      context.getInheritedWidgetOfExactType<_InheritedCountries>(),

    // Notify about countries list changes.
    _CountryScopeAspect.countries =>
      InheritedModel.inheritFrom<_InheritedCountries>(
        context,
        aspect: _CountryScopeAspect.countries,
      ),
  };

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a _InheritedCountries of the exact type',
    'out_of_scope',
  );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `CountryScope.of(context)`.
  static _InheritedCountries of(
    BuildContext context, {
    _CountryScopeAspect aspect = _CountryScopeAspect.none,
  }) =>
      maybeOf(context, aspect: aspect) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant _InheritedCountries oldWidget) =>
      !identical(oldWidget.state, state);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedCountries oldWidget,
    Set<_CountryScopeAspect> dependencies,
  ) =>
      dependencies.contains(_CountryScopeAspect.countries) &&
      _countriesChanged(oldWidget.countries);

  /// Compares the displayed lists, including translations on locale changes.
  bool _countriesChanged(List<Country> previous) {
    final current = countries;
    if (identical(previous, current)) return false;
    if (previous.length != current.length) return true;
    for (var i = 0; i < current.length; i++) {
      final before = previous[i];
      final after = current[i];
      if (before != after || before.nameLocalized != after.nameLocalized) {
        return true;
      }
    }
    return false;
  }
}
