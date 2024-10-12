import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/country_codes.dart';
import 'package:meta/meta.dart';

/// {@template countries_provider}
/// CountriesProvider
///
/// This class provides a list of countries.
/// {@endtemplate}
@internal
class CountriesProvider {
  /// {@macro countries_provider}
  CountriesProvider() : _countries = countries.map(Country.fromJson).toList();

  final List<Country> _countries;

  /// Return list with all countries
  FutureOr<List<Country>> getAll() => _countries;

  /// Returns the first country that mach the given code.
  Country? findByCode(String? code) {
    final uppercaseCode = code?.toUpperCase();
    return _countries.firstWhereOrNull((c) => c.countryCode == uppercaseCode);
  }

  /// Returns the first country that mach the given name.
  Country? findByName(String? name) =>
      _countries.firstWhereOrNull((c) => c.name == name);

  /// Returns a list with all the countries that mach the given codes list.
  List<Country> findCountriesByCode(List<String> codes) {
    final $codes = codes.map((c) => c.toUpperCase()).toList();
    final countries = <Country>[];

    for (final code in $codes) {
      final country = findByCode(code);
      if (country != null) {
        countries.add(country);
      }
    }

    return countries;
  }
}
