/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/src/data/country_provider.dart';
import 'package:flutter_simple_country_picker/src/localization/country_localizations.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';

/// {@template country_state}
/// Countries state.
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

  /// Create a [CountryState] in loading state.
  ///
  /// {@macro country_state}
  factory CountryState.loading({
    required List<Country> countries,
    required bool showGroup,
    Object? error,
    StackTrace? stackTrace,
  }) = CountryState$Loading;

  /// Create a [CountryState] in idle state.
  ///
  /// {@macro country_state}
  factory CountryState.idle({
    required List<Country> countries,
    required bool showGroup,
    Object? error,
    StackTrace? stackTrace,
  }) = CountryState$Idle;

  /// Create a [CountryState] in error state.
  ///
  /// {@macro country_state}
  factory CountryState.error({
    required List<Country> countries,
    required bool showGroup,
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

  /// An unmodifiable snapshot of the countries in this state.
  final List<Country> countries;

  /// Show grouped countries by initial letter.
  final bool showGroup;

  /// Error object, if any.
  final Object? error;

  /// Stack trace of the error.
  final StackTrace? stackTrace;

  /// A cached table of countries by country code.
  late final Map<String, Country> _table = <String, Country>{
    for (final country in countries) country.countryCode: country,
  };

  /// Get country by [countryCode]
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
/// Countries controller.
/// Manages the state of countries
/// and provides methods to fetch and search countries.
/// {@endtemplate}
@internal
final class CountryController extends ValueNotifier<CountryState> {
  /// {@macro country_controller}
  CountryController({
    required CountryProvider provider,
    bool showPhoneCode = true,
    bool? showGroup,
    List<Country>? countries,
    List<String>? exclude,
    List<String>? favorites,
    List<String>? filter,
  }) : _provider = provider,
       _exclude = exclude,
       _favorites = favorites,
       _filter = filter,
       _showPhoneCode = showPhoneCode,
       search = TextEditingController(),
       super(
         CountryState.idle(
           countries: countries ?? <Country>[],
           showGroup: showGroup ?? false,
         ),
       );

  /// Countries provider.
  final CountryProvider _provider;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  List<String>? _exclude;

  /// An optional [favorites] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  List<String>? _favorites;

  /// An optional [filter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [filter] and [exclude]
  List<String>? _filter;

  /// Used to show phone code.
  bool _showPhoneCode;

  /// Search controller.
  TextEditingController? search;

  /// Current localization.
  CountryLocalizations? _localization;

  /// Cached countries list.
  List<Country> _cache = <Country>[];

  /// The latest load request, used to discard results superseded by a reload.
  int _loadRequest = 0;

  /// Current state.
  CountryState get state => value;

  /// Check if the controller is disposed.
  bool get isDisposed => _$isDisposed;
  bool _$isDisposed = false;

  /// Add listener to search controller and provide localization.
  ///
  /// Localization is used to search countries by localized name.
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

  /// Updates the selection options of a mounted country scope.
  void updateOptions({
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
    if (!lazy || _loadRequest > 0) getCountries().ignore();
  }

  /// Get countries
  Future<List<Country>?> getCountries() => _handle<List<Country>>(() async {
    final request = ++_loadRequest;
    String normalize(String value) => value.trim().toUpperCase();
    final stopwatch = Stopwatch()..start();
    try {
      final countries = await _provider.getCountries();
      final exclude = _exclude?.map(normalize).toSet();
      final filter = _filter?.map(normalize).toSet();
      final favoriteCodes = _favorites?.map(normalize).toList(growable: false);
      final showPhoneCode = _showPhoneCode;

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

      final result = <Country>[
        ..._localize(favorites),
        ..._localize($countries),
      ];
      if (request != _loadRequest || isDisposed) return result;
      _cache = List<Country>.unmodifiable(result);
      _setState(
        CountryState.idle(
          countries: _resolveFilteredCountries(),
          showGroup: state.showGroup,
        ),
      );
      return result;
    } finally {
      stopwatch.stop();
    }
  });

  /// Search countries by query.
  Future<void> _onSearch() => _handle(() async {
    _setState(
      CountryState.idle(
        countries: _resolveFilteredCountries(),
        showGroup: state.showGroup,
      ),
    );
  });

  List<Country> _resolveFilteredCountries() {
    final query = search?.text ?? '';
    if (query.isEmpty) return _cache;
    return _cache
        .where((country) => country.startsWith(query, _localization))
        .toList(growable: false);
  }

  /// Localize country names using the current localization.
  List<Country> _localize(List<Country> countries) {
    final l = _localization;

    // Important to tests and performance,
    // if localization is null,
    // we can skip localizing and sorting.
    if (l == null) return countries.toList(growable: false);

    final result = <Country>[];
    for (final country in countries) {
      final formatted = l.getFormatedCountryNameByCode(country.countryCode);

      // If localization is not available for a country,
      // we can use the original name.
      if (formatted == null || formatted.isEmpty) {
        result.add(country);
      } else {
        result.add(country.copyWith(nameLocalized: formatted));
      }
    }

    // Sorting countries by localized name,
    // if available, otherwise by original name.
    result.sort(
      (a, b) =>
          (a.nameLocalized ?? a.name).compareTo(b.nameLocalized ?? b.name),
    );

    return result.toList(growable: false);
  }

  /// Handles a given operation with error handling and completion tracking.
  ///
  /// [handler] - The is the $countries operation to be executed.
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

  /// Handle state update.
  void _setState(CountryState state) {
    if (isDisposed) return;
    if (state == value) return;
    value = state;
  }

  @override
  void dispose() {
    if (isDisposed) return;
    search
      ?..removeListener(_onSearch)
      ..dispose();
    _cache = <Country>[];
    _localization = null;
    _$isDisposed = true;
    super.dispose();
  }
}
