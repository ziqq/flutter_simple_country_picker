import 'package:collection/collection.dart' show DeepCollectionEquality;
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

  /// Whether the controller should be initialized lazily.
  final bool lazy;

  /// Show phone code in countires list.
  final bool showPhoneCode;

  /// List of country codes to exclude.
  final List<String>? exclude;

  /// List of favorites country codes.
  final List<String>? favorites;

  /// List of filtered country codes.
  final List<String>? filter;

  /// The widget below this widget in the tree.
  final Widget child;

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
  late final CountryController _controller;
  late CountryState _state;

  List<Country> _countries = const <Country>[];
  Map<String, Country> _table = const <String, Country>{};

  @override
  void initState() {
    super.initState();
    _controller =
        CountryController(
            provider: CountryProvider(),
            favorites: widget.favorites,
            exclude: widget.exclude,
            filter: widget.filter,
            showPhoneCode: widget.showPhoneCode,
          )
          ..getCountries()
          ..addListener(_onStateChanded);
    _state = _controller.state;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localization = CountryLocalizations.of(context);
    _controller.initLocalization(localization);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanded)
      ..dispose();
    super.dispose();
  }

  void _onStateChanded() {
    if (!mounted) return;
    if (_controller.state.isLoading) return;
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
      !const DeepCollectionEquality().equals(oldWidget.countries, countries) ||
      !identical(oldWidget.table, table) ||
      !identical(oldWidget.state, state);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedCountries oldWidget,
    Set<_CountryScopeAspect> dependencies,
  ) {
    for (final d in dependencies) {
      switch (d) {
        case _CountryScopeAspect.countries
            when !const DeepCollectionEquality().equals(
              oldWidget.countries,
              countries,
            ):
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
}
