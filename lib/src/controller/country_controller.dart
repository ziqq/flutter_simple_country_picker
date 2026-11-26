/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/src/data/country_provider.dart';
import 'package:flutter_simple_country_picker/src/localization/country_localizations.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';
import 'package:flutter_simple_country_picker/src/util/country_util.dart';

/// {@template country_state}
/// A snapshot of the countries displayed by the picker.
/// {@endtemplate}
@immutable
abstract base class CountryState {
  /// {@macro country_state}
  CountryState._({
    required List<Country> countries,
    required this.showGroup,
    this.error,
    this.stackTrace,
  }) : countries = List<Country>.unmodifiable(countries);

  /// Creates a [CountryState] while countries are loading.
  ///
  /// {@macro country_state}
  factory CountryState.loading({
    required List<Country> countries,
    required bool showGroup,
    Object? error,
    StackTrace? stackTrace,
  }) = CountryState$Loading;

  /// Creates a [CountryState] with the current results.
  ///
  /// {@macro country_state}
  factory CountryState.idle({
    required List<Country> countries,
    required bool showGroup,
    Object? error,
    StackTrace? stackTrace,
  }) = CountryState$Idle;

  /// Creates a [CountryState] after a country operation fails.
  ///
  /// {@macro country_state}
  factory CountryState.error({
    required List<Country> countries,
    required bool showGroup,
    Object? error,
    StackTrace? stackTrace,
  }) = CountryState$Error;

  /// A stable name for this state.
  abstract final String type;

  /// An unmodifiable snapshot of the countries in this state.
  final List<Country> countries;

  /// Whether the picker groups countries by their initial letter.
  final bool showGroup;

  /// The error from the failed operation, if available.
  final Object? error;

  /// The stack trace of [error], if available.
  final StackTrace? stackTrace;

  /// A cached table of countries by country code.
  late final Map<String, Country> _table = <String, Country>{
    for (final country in countries) country.countryCode: country,
  };

  /// Whether an operation is in progress.
  bool get isLoading => this is CountryState$Loading;

  /// Whether the current results are ready.
  bool get isIdle => this is CountryState$Idle;

  /// Whether an operation failed.
  bool get isError => this is CountryState$Error;

  /// Returns the last entry with this [countryCode], or `null` if absent.
  Country? getCountryByCode(String countryCode) => _table[countryCode];

  @override
  int get hashCode => Object.hash(
    type,
    error,
    showGroup,
    stackTrace,
    Object.hashAll(countries),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountryState &&
          type == other.type &&
          error == other.error &&
          showGroup == other.showGroup &&
          stackTrace == other.stackTrace &&
          listEquals(countries, other.countries));

  @override
  String toString() =>
      'CountryState.$type{countries: ${countries.length}, showGroup: $showGroup}';
}

/// Loading state.
/// {@macro country_state}
final class CountryState$Loading extends CountryState {
  /// {@macro country_state}
  CountryState$Loading({
    required super.countries,
    required super.showGroup,
    super.error,
    super.stackTrace,
  }) : super._();

  @override
  String get type => 'loading';
}

/// Idle state.
/// {@macro country_state}
final class CountryState$Idle extends CountryState {
  /// {@macro country_state}
  CountryState$Idle({
    required super.countries,
    required super.showGroup,
    super.error,
    super.stackTrace,
  }) : super._();

  @override
  String get type => 'idle';
}

/// Error state.
/// {@macro country_state}
final class CountryState$Error extends CountryState {
  /// {@macro country_state}
  CountryState$Error({
    required super.countries,
    required super.showGroup,
    super.error,
    super.stackTrace,
  }) : super._();

  @override
  String get type => 'error';
}

/// {@template country_controller}
/// Loads, filters, and searches countries for the picker.
/// {@endtemplate}
@internal
final class CountryController extends ValueNotifier<CountryState> {
  /// {@macro country_controller}
  CountryController({
    required CountryProvider provider,
    List<Country>? countries,
    List<String>? exclude,
    List<String>? favorites,
    List<String>? filter,
    bool showPhoneCode = true,
    bool showWorldWide = false,
    bool? showGroup,
  }) : _provider = provider,
       _exclude = exclude,
       _favorites = favorites,
       _filter = filter,
       _showPhoneCode = showPhoneCode,
       _showWorldWide = showWorldWide,
       search = TextEditingController(),
       super(
         CountryState.idle(
           countries: countries ?? <Country>[],
           showGroup: showGroup ?? false,
         ),
       );

  /// Search text controller owned by this country controller.
  TextEditingController? search;

  /// Provides the bundled countries.
  final CountryProvider _provider;

  /// ISO alpha-2 codes to omit from the country list.
  List<String>? _exclude;

  /// ISO alpha-2 codes to place before the other countries.
  List<String>? _favorites;

  /// ISO alpha-2 codes to include in the country list, if restricted.
  List<String>? _filter;

  /// Whether to retain distinct dialing entries for the same country.
  bool _showPhoneCode;

  /// Used to show the "World Wide" option at the beginning of the list.
  final bool _showWorldWide;

  /// The localization used for search and display.
  CountryLocalizations? _localization;

  /// The prepared country list before applying the search query.
  List<Country> _cache = <Country>[];

  /// The most recent fetch, or null before the first load.
  Future<List<Country>>? _countriesLoad;

  /// Whether this controller has finished disposal.
  bool _$isDisposed = false;

  /// The current picker state.
  CountryState get state => value;

  /// Whether the controller has been disposed.
  bool get isDisposed => _$isDisposed;

  /// Installs [localization] and listens for search text changes.
  ///
  /// Rebuilds the cached results when the active localization changes.
  @mustCallSuper
  void initLocalization(CountryLocalizations? localization) {
    if (isDisposed) return;
    final changed = !identical(_localization, localization);
    _localization = localization;
    search
      ?..removeListener(_onSearch)
      ..addListener(_onSearch);
    if (changed && _cache.isNotEmpty) getCountries().ignore();
  }

  /// Applies the selection options of a mounted country scope.
  ///
  /// With [lazy], updates an existing load or cache without fetching for an
  /// uninitialized scope.
  void apply({
    required List<String>? exclude,
    required List<String>? favorites,
    required List<String>? filter,
    required bool showPhoneCode,
    required bool lazy,
  }) {
    _exclude = exclude;
    _favorites = favorites;
    _filter = filter;
    _showPhoneCode = showPhoneCode;
    if (!lazy || _countriesLoad != null) getCountries().ignore();
  }

  /// Refreshes the country list and returns it before search filtering.
  ///
  /// Returns `null` if loading fails.
  Future<List<Country>?> getCountries() {
    final load = Future<List<Country>>.microtask(_provider.getCountries);
    _countriesLoad = load;
    return _handle(() => _getCountries(load));
  }

  @override
  void dispose() {
    if (isDisposed) return;
    search
      ?..removeListener(_onSearch)
      ..dispose();
    _cache = <Country>[];
    _countriesLoad = null;
    _localization = null;
    _$isDisposed = true;
    super.dispose();
  }

  /// Prepares a load and publishes it only if it is still current.
  Future<List<Country>?> _getCountries(Future<List<Country>> load) async {
    String normalize(String value) => value.trim().toUpperCase();
    final stopwatch = Stopwatch()..start();
    try {
      final countries = await load;
      final exclude = _exclude?.map(normalize).toSet();
      final filter = _filter?.map(normalize).toSet();
      final favoriteCodes = _favorites?.map(normalize).toList(growable: false);
      final showPhoneCode = _showPhoneCode;

      // Use the same identity for favorites and regular entries so a favorite
      // cannot appear a second time in the regular list.
      final seenCountries = <(String, String?)>{};

      final byCode = <String, List<Country>>{};
      for (final country in countries) {
        final countryCode = normalize(country.countryCode);
        (byCode[countryCode] ??= <Country>[]).add(country);
      }

      final favorites = <Country>[];
      if (favoriteCodes != null) {
        for (final code in favoriteCodes) {
          final list = byCode[code];
          if (list == null) continue;

          for (final country in list) {
            final countryCode = normalize(country.countryCode);

            if (exclude != null && exclude.contains(countryCode)) continue;
            if (filter != null && !filter.contains(countryCode)) continue;

            if (!seenCountries.add((
              countryCode,
              showPhoneCode ? country.e164Key : null,
            ))) {
              continue;
            }

            favorites.add(country);
          }
        }
      }

      final $countries = <Country>[];
      for (var i = 0; i < countries.length; i++) {
        final country = countries[i];
        final countryCode = normalize(country.countryCode);

        // Yield during long refreshes so input and rendering can proceed.
        if (stopwatch.elapsedMilliseconds > 8) {
          await Future<void>.delayed(.zero);
          stopwatch
            ..reset()
            ..start();
        }
        if (exclude != null && exclude.contains(countryCode)) continue;
        if (filter != null && !filter.contains(countryCode)) continue;

        if (!seenCountries.add((
          countryCode,
          showPhoneCode ? country.e164Key : null,
        ))) {
          continue;
        }

        $countries.add(country);
      }

      const worldWide = Country.worldWide;
      final showWorldWide =
          _showWorldWide &&
          !(exclude?.contains(worldWide.countryCode) ?? false);
      final result = <Country>[
        if (showWorldWide) ..._localize(<Country>[worldWide]),
        ..._localize(favorites),
        ..._localize($countries),
      ];
      if (!identical(load, _countriesLoad) || isDisposed) return result;
      _cache = List<Country>.unmodifiable(result);
      _setState(
        CountryState.idle(
          countries: _resolveFilteredCountries(),
          showGroup: state.showGroup,
        ),
      );
      return result;
    } on Object {
      if (!identical(load, _countriesLoad) || isDisposed) return null;
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  /// Publishes the results for the current search query.
  Future<void> _onSearch() => _handle(() async {
    _setState(
      CountryState.idle(
        countries: _resolveFilteredCountries(),
        showGroup: state.showGroup,
      ),
    );
  });

  /// Applies the current query to the prepared country list.
  List<Country> _resolveFilteredCountries() {
    final query = search?.text ?? '';
    if (query.isEmpty) return _cache;
    return _cache
        .where((country) => country.startsWith(query, _localization))
        .toList(growable: false);
  }

  /// Localizes and sorts one section independently of the other sections.
  List<Country> _localize(List<Country> countries) {
    final l = _localization;

    // Preserve the provider order when no localization has been set.
    if (l == null) return countries.toList(growable: false);

    final result = <({Country country, String name, String sortKey})>[];
    for (final country in countries) {
      final formatted = l.getFormatedCountryNameByCode(country.countryCode);
      final name = switch (formatted) {
        String name when name.isNotEmpty => name,
        _ => country.name,
      };
      result.add((
        country: country.copyWith(nameLocalized: name),
        name: name,
        sortKey: CountryUtil.foldDiacritics(name).toLowerCase(),
      ));
    }

    // Normalize each name once, keeping the original spelling as a tie-breaker.
    result.sort((a, b) {
      final order = a.sortKey.compareTo(b.sortKey);
      return order != 0 ? order : a.name.compareTo(b.name);
    });

    return result.map((entry) => entry.country).toList(growable: false);
  }

  /// Runs [handler] while exposing loading and failure states to listeners.
  Future<T?> _handle<T>(Future<T?> Function() handler) async {
    try {
      _setState(
        CountryState.loading(
          countries: state.countries,
          showGroup: state.showGroup,
        ),
      );
      return await handler();
    } on Object catch (e, s) {
      _setState(
        CountryState.error(
          countries: value.countries,
          showGroup: state.showGroup,
          error: e,
          stackTrace: s,
        ),
      );
      return null;
    }
  }

  /// Notifies listeners only when an active controller changes state.
  void _setState(CountryState state) {
    if (isDisposed) return;
    if (state == value) return;
    value = state;
  }
}
