import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';
import 'package:meta/meta.dart';

/// {@template country_provider}
/// Provides access to the bundled country dataset.
/// {@endtemplate}
@internal
class CountryProvider {
  /// {@macro country_provider}
  CountryProvider();

  /// The parsed dataset, initialized on the first country lookup or fetch.
  late final List<Country> _countries = countries
      .map(Country.fromJson)
      .toList();

  /// Returns all bundled countries in dataset order.
  Future<List<Country>> getCountries() async =>
      Future<List<Country>>.value(_countries);

  /// Returns the first country matching [code], ignoring case.
  Country? findByCode(String? code) {
    final uppercaseCode = code?.toUpperCase();
    return _countries.firstWhereOrNull((c) => c.countryCode == uppercaseCode);
  }

  /// Returns the first country with the exact English [name].
  Country? findByName(String? name) =>
      _countries.firstWhereOrNull((c) => c.name == name);

  /// Looks up each of [codes] in order, skipping unmatched codes.
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
