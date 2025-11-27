/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/src/controller/country_provider.dart';
import 'package:flutter_simple_country_picker/src/localization/country_localizations.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';

/// {@template country_state}
/// Countries state.
/// {@endtemplate}
@immutable
abstract base class CountryState {
  /// {@macro country_state}
  CountryState._({
    required this.countries,
    required this.useGroup,
    this.error,
    this.stackTrace,
  });

  /// Create a [CountryState] in loading state.
  ///
  /// {@macro country_state}
  factory CountryState.loading({
    required List<Country> countries,
    required bool useGroup,
    Object? error,
    StackTrace? stackTrace,
  }) = CountryState$Loading;

  /// Create a [CountryState] in idle state.
  ///
  /// {@macro country_state}
  factory CountryState.idle({
    required List<Country> countries,
    required bool useGroup,
    Object? error,
    StackTrace? stackTrace,
  }) = CountryState$Idle;

  /// Create a [CountryState] in error state.
  ///
  /// {@macro country_state}
  factory CountryState.error({
    required List<Country> countries,
    required bool useGroup,
    Object? error,
    StackTrace? stackTrace,
  }) = CountryState$Error;

  /// Type of state
  abstract final String type;

  /// Check if is Processing.
  bool get isLoading => this is CountryState$Loading;

  /// Check if is Failed.
  bool get isError => this is CountryState$Error;

  /// Check if is Idle.
  bool get isIdle => this is CountryState$Idle;

  /// List of countries.
  final List<Country> countries;

  /// Check if use group in countries list.
  final bool useGroup;

  /// Error object, if any.
  final Object? error;

  /// Stack trace of the error.
  final StackTrace? stackTrace;

  late final Map<String, Country> _table = {
    for (final country in countries) country.countryCode: country,
  };

  /// Get country by [countryCode]
  Country? getByCountryCode(String countryCode) => _table[countryCode];

  @override
  int get hashCode => Object.hash(countries, useGroup, type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountryState &&
          type == other.type &&
          listEquals(countries, other.countries));

  @override
  String toString() => 'CountryState.$type{countries: $countries}';
}

/// {@macro country_state}
///
/// Loading state.
final class CountryState$Loading extends CountryState {
  /// {@macro country_state}
  CountryState$Loading({
    required super.countries,
    required super.useGroup,
    super.error,
    super.stackTrace,
  }) : super._();

  @override
  String get type => 'loading';
}

/// {@macro country_state}
///
/// Idle state.
final class CountryState$Idle extends CountryState {
  /// {@macro country_state}
  CountryState$Idle({
    required super.countries,
    required super.useGroup,
    super.error,
    super.stackTrace,
  }) : super._();

  @override
  String get type => 'idle';
}

/// {@macro country_state}
///
/// Error state.
final class CountryState$Error extends CountryState {
  /// {@macro country_state}
  CountryState$Error({
    required super.countries,
    required super.useGroup,
    super.error,
    super.stackTrace,
  }) : super._();

  @override
  String get type => 'error';
}

/// {@template country_controller}
/// Countries controller.
/// {@endtemplate}
@internal
final class CountryController extends ValueNotifier<CountryState> {
  /// {@macro country_controller}
  CountryController({
    required CountryProvider provider,
    bool showPhoneCode = true,
    List<Country>? countries,
    List<String>? exclude,
    List<String>? favorite,
    List<String>? filter,
  }) : _provider = provider,
       _exclude = exclude,
       _favorite = favorite,
       _filter = filter,
       _showPhoneCode = showPhoneCode,
       search = TextEditingController(),
       super(CountryState.idle(countries: countries ?? [], useGroup: false));

  /// Countries provider.
  final CountryProvider _provider;

  /// Used to show phone code.
  final bool _showPhoneCode;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? _exclude;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? _favorite;

  /// An optional [filter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [filter] and [exclude]
  final List<String>? _filter;

  /// Search controller.
  TextEditingController? search;

  /// Search listener.
  void Function()? _listener;

  /// Original countries list.
  List<Country> _original = <Country>[];

  /// Current state.
  CountryState get state => value;

  /// Add listener to search controller and provide localization.
  ///
  /// Localization is used to search countries by localized name.
  void initListeners(CountryLocalizations? localization) {
    if (_listener != null) {
      search?.removeListener(_listener!);
      _listener = null;
    }
    _listener = () => _onSearch(localization);
    search?.addListener(_listener!);
  }

  /// Get countries
  Future<void> getCountries() => _handle(() async {
    final stopwatch = Stopwatch()..start();
    try {
      final countries = await _provider.getAll();
      _original = List.unmodifiable(countries);

      // Get favorite countries
      if (_favorite != null && _favorite.isNotEmpty) {
        // final favorites = _provider.findCountriesByCode(_favorite!);
      }

      final $countries = <Country>[];
      final seenCountryCodes = <String>{};

      for (var i = 0; i < countries.length; i++) {
        final country = countries[i];

        // Check elapsed time and yield control if necessary
        // coverage:ignore-start
        if (stopwatch.elapsedMilliseconds > 8) {
          await Future<void>.delayed(Duration.zero);
          stopwatch.reset();
        }
        // coverage:ignore-end

        // Remove excluded countries
        if (_exclude != null && _exclude.contains(country.countryCode)) {
          continue;
        }

        // Remove duplicates if not using phone code
        if (!_showPhoneCode) {
          if (!seenCountryCodes.add(country.countryCode)) continue;
        }

        // Filter countries
        if (_filter != null && !_filter.contains(country.countryCode)) {
          continue;
        }

        // Add country to the filtered list
        $countries.add(country);
      }

      _setState(
        CountryState.idle(
          countries: $countries.toList(growable: false),
          useGroup: $countries.length > 8,
        ),
      );
    } finally {
      stopwatch.stop();
      if (kDebugMode) {
        /* dev.log(
              '${(stopwatch..stop()).elapsedMicroseconds} μs',
              name: 'get_countries',
              level: 100,
            ); */
      }
    }
  });

  /// Search countries
  Future<void> _onSearch([CountryLocalizations? localization]) =>
      _handle(() async {
        final searchText = search?.text ?? '';
        var newCountries = <Country>[];

        if (searchText.isEmpty) {
          newCountries.addAll(_original);
        } else {
          newCountries = _original
              .where((c) => c.startsWith(searchText, localization))
              .toList();
        }

        _setState(
          CountryState.idle(
            countries: newCountries.toList(growable: false),
            useGroup: state.useGroup,
          ),
        );
      });

  Future<void> _handle(Future<void> Function() fn) async {
    _setState(
      CountryState.loading(
        countries: state.countries,
        useGroup: state.useGroup,
      ),
    );
    try {
      await fn();
    } on Object catch (e, s) {
      _setState(
        CountryState.error(
          countries: value.countries,
          useGroup: state.useGroup,
          error: e,
          stackTrace: s,
        ),
      );
    }
  }

  void _setState(CountryState state) {
    if (state == value) return;
    value = state;
    notifyListeners();
  }

  @override
  void dispose() {
    final listener = _listener;
    if (listener != null) search?.removeListener(listener);
    search?.dispose();
    super.dispose();
  }
}
