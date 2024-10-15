import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_controller.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_provider.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_state.dart';
import 'package:meta/meta.dart';

/// {@template countries_scope}
/// CountriesScope widget.
///
/// This widget is used to provide a [CountriesController] to its descendants.
///
/// The [CountriesScope] arguments:
///
/// The [lazy] argument can be used to initialize the controller lazily.
///
/// The [exclude] argument can be used to exclude(remove) one ore more
/// country from the countries list. It takes a list of country code(iso2).
///
/// The [favorite] argument can be used to show countries
/// at the top of the list. It takes a list of country code(iso2).
///
/// The [filter] argument can be used to filter the
/// list of countries. It takes a list of country code(iso2).
///
/// The [showPhoneCode] argument can be used to show phone code.
/// {@endtemplate}
@experimental
class CountriesScope extends StatefulWidget {
  /// {@macro countries_scope}
  const CountriesScope({
    required this.child,
    this.exclude,
    this.favorite,
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

  /// List of favorite country codes.
  final List<String>? favorite;

  /// List of filtered country codes.
  final List<String>? filter;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Get the [CountriesController] from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `CountriesScope.of(context)`.
  static CountriesController of(BuildContext context, {bool listen = false}) =>
      _InheritedCountries.of(context, listen: listen).scope._controller;

  /// Get the [List<Country>] from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `CountriesScope.countriesOf(context)`.
  static List<Country> countriesOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _InheritedCountries.of(context, listen: listen).countries;

  /// Get the [Country?] from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `CountriesScope.getByCountryCode(context, countryCode)`.
  static Country? getByCountryCode(
    BuildContext context,
    String countryCode, {
    bool listen = true,
  }) =>
      _InheritedCountries.of(context, listen: listen)
          .state
          .getByCountryCode(countryCode);

  @override
  State<CountriesScope> createState() => _CountriesScopeState();
}

/// State for widget [CountriesScope].
class _CountriesScopeState extends State<CountriesScope> {
  late final CountriesController _controller;

  List<Country> _countries = const <Country>[];
  Map<String, Country> _table = const <String, Country>{};

  @override
  void initState() {
    super.initState();
    _controller = CountriesController(
      provider: CountriesProvider(),
      favorite: widget.favorite,
      exclude: widget.exclude,
      filter: widget.filter,
      showPhoneCode: widget.showPhoneCode,
    )
      ..getCountries()
      ..addListener(_onStateChanded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.initListeners(CountriesLocalization.of(context));
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
    final state = _controller.state;
    if (identical(state.countries, _countries)) return;
    _countries = state.countries.toList(growable: false);
    _table = {for (final country in _countries) country.countryCode: country};
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<CountriesState>(
        valueListenable: _controller,
        builder: (context, state, _) => _InheritedCountries(
          scope: this,
          state: state,
          countries: _countries,
          table: _table,
          child: widget.child,
        ),
      );
}

/// Inherited widget for quick access in the element tree.
class _InheritedCountries extends InheritedModel<String> {
  const _InheritedCountries({
    required this.scope,
    required this.state,
    required this.countries,
    required this.table,
    required super.child,
  });

  final _CountriesScopeState scope;
  final CountriesState state;
  final List<Country> countries;
  final Map<String, Country> table;

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
  bool updateShouldNotify(
    covariant _InheritedCountries oldWidget,
  ) =>
      !listEquals(oldWidget.countries, countries) ||
      !mapEquals(oldWidget.table, table) ||
      !identical(oldWidget.state, state);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedCountries oldWidget,
    Set<String> aspects,
  ) {
    for (final code in aspects) {
      // final expectOne = state.getByCountryCode(code) !=
      // oldWidget.state.getByCountryCode(code);
      if (table[code] != oldWidget.table[code]) return true;
    }
    return false;
  }
}
