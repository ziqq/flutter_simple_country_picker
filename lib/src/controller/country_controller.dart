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
    required this.countries,
    required this.showGroup,
    this.error,
    this.stackTrace,
  });

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

  /// List of countries.
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
  int get hashCode => Object.hashAll([countries, showGroup, type]);

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
  final List<String>? _exclude;

  /// An optional [favorites] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? _favorites;

  /// An optional [filter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [filter] and [exclude]
  final List<String>? _filter;

  /// Used to show phone code.
  final bool _showPhoneCode;

  /// Search controller.
  TextEditingController? search;

  /// Current localization.
  CountryLocalizations? _localization;

  /// Cached countries list.
  List<Country> _cache = <Country>[];

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
    if (_localization != null) search?.removeListener(_onSearch);
    _localization = localization;
    search?.addListener(_onSearch);
  }

  /// Get countries
  Future<List<Country>?> getCountries() => _handle<List<Country>>(() async {
    String normalize(String value) => value.trim().toUpperCase();
    final stopwatch = Stopwatch()..start();
    try {
      final countries = await _provider.getCountries();

      final exclude = _exclude?.map(normalize).toSet();
      final filter = _filter?.map(normalize).toSet();
      final favoritesCodes = (_favorites == null || _favorites.isEmpty)
          ? null
          : _favorites.map(normalize).toList(growable: false);

      final seenCountryCodes = !_showPhoneCode ? <String>{} : null;

      final byCode = <String, List<Country>>{};
      for (final country in countries) {
        final cc = normalize(country.countryCode);
        (byCode[cc] ??= <Country>[]).add(country);
      }

      final favorites = <Country>[];
      if (favoritesCodes != null) {
        for (final code in favoritesCodes) {
          final list = byCode[code];
          if (list == null) continue;

          for (final country in list) {
            final cc = normalize(country.countryCode);

            if (exclude != null && exclude.contains(cc)) continue;
            if (filter != null && !filter.contains(cc)) continue;

            if (seenCountryCodes != null && !seenCountryCodes.add(cc)) continue;

            favorites.add(country);
          }
        }
      }

      final $countries = <Country>[];
      for (var i = 0; i < countries.length; i++) {
        final country = countries[i];
        final cc = normalize(country.countryCode);

        if (stopwatch.elapsedMilliseconds > 8) {
          await Future<void>.delayed(Duration.zero);
          stopwatch
            ..reset()
            ..start();
        }
        if (exclude != null && exclude.contains(cc)) continue;
        if (filter != null && !filter.contains(cc)) continue;

        if (seenCountryCodes != null && !seenCountryCodes.add(cc)) continue;

        $countries.add(country);
      }

      final result = <Country>[
        ..._localize(favorites),
        ..._localize($countries),
      ];
      _cache = List<Country>.unmodifiable(result);
      _setState(
        CountryState.idle(
          countries: result.toList(growable: false),
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
    final query = search?.text ?? '';
    var countries = <Country>[];

    if (query.isEmpty) {
      countries = [..._cache];
    } else {
      countries = _cache
          .where((c) => c.startsWith(query, _localization))
          .toList();
    }

    _setState(
      CountryState.idle(
        countries: countries.toList(growable: false),
        showGroup: state.showGroup,
      ),
    );
  });

  /// Localize country names using the current localization.
  List<Country> _localize(List<Country> countries) {
    final localization = _localization;

    // Important to tests and performance,
    // if localization is null,
    // we can skip localizing and sorting.
    if (localization == null) return countries.toList(growable: false);

    final result = <Country>[];
    for (final country in countries) {
      final formatted = localization.getFormatedCountryNameByCode(
        country.countryCode,
      );

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
