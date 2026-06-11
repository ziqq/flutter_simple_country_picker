// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart'
    show Country;

/// Resolves bundled [Country] values from locale and region inputs.
abstract final class CountryResolver {
  /// Resolves a country from [locale], or returns `null` when it cannot be
  /// mapped to a bundled ISO2 country code.
  static Country? tryFromLocale(Locale locale) => Country.tryFromLocale(locale);

  /// Resolves a country from [locale].
  ///
  /// Throws an [ArgumentError] when [locale] has no region code or when the
  /// normalized region is not present in the bundled dataset.
  static Country fromLocale(Locale locale) => Country.fromLocale(locale);

  /// Resolves a country from [countryCode], applying bundled alias mappings.
  static Country? tryFromCountryCode(String countryCode) =>
      Country.tryFromCountryCode(countryCode);

  /// Resolves a country from [countryCode], applying bundled alias mappings.
  ///
  /// Throws an [ArgumentError] when the normalized code is not present in the
  /// bundled dataset.
  static Country fromCountryCode(String countryCode) =>
      Country.fromCountryCode(countryCode);

  /// Normalizes [countryCode] to the ISO2 code used by the bundled dataset.
  static String normalizeRegionCode(String countryCode) =>
      Country.normalizeRegionCode(countryCode);
}
