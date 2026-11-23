import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/country_controller.dart';
import 'package:flutter_simple_country_picker/src/data/country_provider.dart';

/// {@template country_scope}
/// CountryScope widget.
///
/// This widget is used to provide a [CountryController] to its descendants.
///
/// The [CountryScope] arguments:
///
/// The [lazy] argument can be used to initialize the controller lazily.
///
/// The [exclude] argument can be used to exclude(remove) one ore more
/// country from the countries list. It takes a list of country code(iso2).
///
/// The [favorites] argument can be used to show countries
/// at the top of the list. It takes a list of country code(iso2).
///
/// The [filter] argument can be used to filter the
/// list of countries. It takes a list of country code(iso2).
///
/// The [showPhoneCode] argument can be used to show phone code.
/// {@endtemplate}
class CountryScope extends StatefulWidget {
  /// {@macro country_scope}
  const CountryScope({
    required this.child,
    this.exclude,
    this.favorites,
    this.filter,
    this.lazy = false,
    this.showPhoneCode = false,
    super.key, // ignore: unused_element
  });

  /// The widget subtree that can read this scope's countries.
  final Widget child;

  /// The country codes omitted from this scope.
  final List<String>? exclude;

  /// The country codes shown first in this scope.
  final List<String>? favorites;

  /// The country codes allowed in this scope.
  final List<String>? filter;

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

  /// Whether the list includes separate entries for each calling code.
  final bool showPhoneCode;

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
  ).state.getCountryByCode(countryCode);

  @override
  State<CountryScope> createState() => _CountriesScopeState();
}

/// State for widget [CountryScope].
class _CountriesScopeState extends State<CountryScope> {
  /// The controller shared with descendants for the lifetime of this scope.
  late final CountryController _controller;

  /// The latest non-loading state exposed to descendants.
  late CountryState _state;

  /// The countries used to rebuild the lookup table.
  List<Country> _countries = const <Country>[];

  /// The lookup table for the countries in [_state].
  Map<String, Country> _table = const <String, Country>{};

  @override
  void initState() {
    super.initState();
    _controller = CountryController(
      provider: CountryProvider(),
      favorites: widget.favorites,
      exclude: widget.exclude,
      filter: widget.filter,
      showPhoneCode: widget.showPhoneCode,
    )..addListener(_handleStateChanged);
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
      _controller.updateOptions(
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
      ..removeListener(_handleStateChanged)
      ..dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    if (!mounted || _controller.state.isLoading) return;
    if (identical(_controller.state, _state)) return;
    _state = _controller.state;
    _countries = _controller.state.countries.toList(growable: false);
    _table = {for (final country in _countries) country.countryCode: country};
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _InheritedCountries(
    scope: this,
    state: _state,
    table: _table,
    child: widget.child,
  );
}

/// Aspect for country scope.
enum _CountryScopeAspect {
  /// Notify when a countries is changed.
  countries,

  /// Notify when a state is changed.
  state,

  /// Do not notify.
  none,
}

/// Inherited widget for quick access in the element tree.
class _InheritedCountries extends InheritedModel<_CountryScopeAspect> {
  const _InheritedCountries({
    required this.scope,
    required this.state,
    required this.table,
    required super.child,
  });

  final CountryState state;

  /// The list of countries.
  List<Country> get countries => state.countries;

  /// A table of countries by country code.
  final Map<String, Country> table;

  /// This country scope state.
  /// This is the state of the country scope.
  final _CountriesScopeState scope;

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

    // Notify about every change.
    _CountryScopeAspect.state =>
      context.dependOnInheritedWidgetOfExactType<_InheritedCountries>(),

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
      !identical(oldWidget.table, table) || !identical(oldWidget.state, state);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedCountries oldWidget,
    Set<_CountryScopeAspect> dependencies,
  ) {
    for (final d in dependencies) {
      switch (d) {
        case _CountryScopeAspect.countries
            when _countriesChanged(oldWidget.countries):
          // Notify about changes in countries list.
          return true;
        case _CountryScopeAspect.state when !identical(oldWidget.state, state):
          // Notify about changes in countries state.
          return true;
        default:
          continue;
      }
    }
    return false;
  }

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
