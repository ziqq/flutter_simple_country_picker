import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:meta/meta.dart';

/// {@template countries_state}
/// Countries state.
/// {@endtemplate}
@internal
sealed class CountriesState {
  /// {@macro countries_state}
  CountriesState._(this.countries);

  factory CountriesState.loading(List<Country> countries) =
      CountriesState$Loading;

  factory CountriesState.idle(List<Country> countries) = CountriesState$Idle;

  factory CountriesState.error(List<Country> countries) = CountriesState$Error;

  /// Is loading state.
  abstract final bool isLoading;

  /// Is idle state.
  abstract final bool isIdle;

  /// Is error state.
  abstract final bool isError;

  /// List of countries.
  final List<Country> countries;

  late final Map<String, Country> _table = {
    for (final country in countries) country.countryCode: country
  };

  /// Get country by [countryCode]
  Country? getByCountryCode(String countryCode) => _table[countryCode];
}

/// {@macro countries_state}
///
/// Loading state.
class CountriesState$Loading extends CountriesState {
  /// {@macro countries_state}
  CountriesState$Loading(super.countries) : super._();

  @override
  bool get isError => false;
  @override
  bool get isIdle => false;
  @override
  bool get isLoading => true;
}

/// {@macro countries_state}
///
/// Idle state.
class CountriesState$Idle extends CountriesState {
  /// {@macro countries_state}
  CountriesState$Idle(super.countries) : super._();

  @override
  bool get isError => false;
  @override
  bool get isIdle => true;
  @override
  bool get isLoading => false;
}

/// {@macro countries_state}
///
/// Error state.
class CountriesState$Error extends CountriesState {
  /// {@macro countries_state}
  CountriesState$Error(super.countries) : super._();

  @override
  bool get isError => true;
  @override
  bool get isIdle => false;
  @override
  bool get isLoading => false;
}
