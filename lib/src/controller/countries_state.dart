import 'package:flutter/foundation.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

/// {@template countries_state}
/// Countries state.
/// {@endtemplate}
@immutable
abstract base class CountriesState {
  /// {@macro countries_state}
  CountriesState._(this.countries);

  /// Create a [CountriesState] in loading state.
  ///
  /// {@macro countries_state}
  factory CountriesState.loading(List<Country> countries) =
      CountriesState$Loading;

  /// Create a [CountriesState] in idle state.
  ///
  /// {@macro countries_state}
  factory CountriesState.idle(List<Country> countries) = CountriesState$Idle;

  /// Create a [CountriesState] in error state.
  ///
  /// {@macro countries_state}
  factory CountriesState.error(List<Country> countries) = CountriesState$Error;

  /// Type of state
  abstract final String type;

  /// Check if is Processing.
  bool get isLoading => this is CountriesState$Loading;

  /// Check if is Failed.
  bool get isError => this is CountriesState$Error;

  /// Check if is Idle.
  bool get isIdle => this is CountriesState$Idle;

  /// List of countries.
  final List<Country> countries;

  late final Map<String, Country> _table = {
    for (final country in countries) country.countryCode: country
  };

  /// Get country by [countryCode]
  Country? getByCountryCode(String countryCode) => _table[countryCode];

  @override
  int get hashCode => Object.hash(type, countries);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountriesState &&
          type == other.type &&
          listEquals(countries, other.countries));

  @override
  String toString() => 'CountriesState.$type{countries: $countries}';
}

/// {@macro countries_state}
///
/// Loading state.
final class CountriesState$Loading extends CountriesState {
  /// {@macro countries_state}
  CountriesState$Loading(super.countries) : super._();

  @override
  String get type => 'loading';
}

/// {@macro countries_state}
///
/// Idle state.
final class CountriesState$Idle extends CountriesState {
  /// {@macro countries_state}
  CountriesState$Idle(super.countries) : super._();

  @override
  String get type => 'idle';
}

/// {@macro countries_state}
///
/// Error state.
final class CountriesState$Error extends CountriesState {
  /// {@macro countries_state}
  CountriesState$Error(super.countries) : super._();

  @override
  String get type => 'error';
}
