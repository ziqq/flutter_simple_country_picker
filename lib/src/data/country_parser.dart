import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:flutter_simple_country_picker/src/localization/country_localizations.dart'
    show CountryLocalizations, resolveCountryLocalizations;
import 'package:flutter_simple_country_picker/src/model/country.dart';
import 'package:meta/meta.dart';

/// {@template country_parser}
/// Looks up a [Country] by a stored code or name.
/// {@endtemplate}
@internal
abstract final class CountryParser {
  /// {@macro country_parser}
  const CountryParser._();

  /// Returns a single country if [country] matches a country code or name.
  ///
  /// Throws an [ArgumentError] if no matching element is found.
  static Country parse(String country) =>
      tryParseCountryCode(country) ?? parseCountryName(country);

  /// Returns a single country if [country] matches a country code or name.
  ///
  /// Returns `null` if no match is found.
  static Country? tryParse(String country) =>
      tryParseCountryCode(country) ?? tryParseCountryName(country);

  /// Returns the country matching [countryCode], ignoring case.
  ///
  /// Throws a [StateError] if no matching element is found.
  static Country parseCountryCode(String countryCode) =>
      _getFromCode(countryCode.toUpperCase());

  /// Returns the country matching [countryCode], or `null` if unmatched.
  static Country? tryParseCountryCode(String countryCode) {
    try {
      return parseCountryCode(countryCode);
    } on Object catch (_) {
      return null;
    }
  }

  /// Returns the country matching [phoneCode] and the dialing entry [e164Key].
  ///
  /// Throws a [StateError] if there is no matching entry.
  static Country parsePhoneCode(String phoneCode, String e164Key) =>
      _getFromPhoneCode(phoneCode, e164Key);

  /// Returns the country matching [phoneCode] and [e164Key], or `null`.
  static Country? tryParsePhoneCode(String phoneCode, String e164Key) {
    try {
      return parsePhoneCode(phoneCode, e164Key);
    } on Object catch (_) {
      return null;
    }
  }

  /// Returns the country matching [countryName], ignoring case.
  ///
  /// Tries the locale from [context] first, when supplied. Then tries the given
  /// [locales] in order. Without [locales], tries English before the remaining
  /// available translations.
  ///
  /// Throws an [ArgumentError] if no matching element is found.
  static Country parseCountryName(
    String countryName, {
    BuildContext? context,
    List<Locale>? locales,
  }) {
    final countryNameLower = countryName.toLowerCase();

    final countryCode = _anyLocalizedNameToCode(
      countryNameLower,
      context != null ? Localizations.localeOf(context) : null,
      locales,
    );

    return _getFromCode(countryCode);
  }

  /// Returns the country matching [countryName], or `null` if unmatched.
  ///
  /// Uses the same locale order as [parseCountryName].
  static Country? tryParseCountryName(
    String countryName, {
    BuildContext? context,
    List<Locale>? locales,
  }) {
    try {
      return parseCountryName(countryName, context: context, locales: locales);
    } on Object catch (_) {
      return null;
    }
  }

  /// Identifies one dialing entry even when several share a calling code.
  static Country _getFromPhoneCode(String phoneCode, String e164Key) =>
      Country.fromJson(
        countries.singleWhere(
          (j) => j['e164_cc'] == phoneCode && j['e164_key'] == e164Key,
        ),
      );

  /// Resolves an exact lookup against the stored ISO code.
  static Country _getFromCode(String countryCode) => Country.fromJson(
    countries.singleWhere((j) => j['iso2_cc'] == countryCode),
  );

  /// Resolves [name] in [locale] before checking the fallback locales.
  static String _anyLocalizedNameToCode(
    String name,
    Locale? locale,
    List<Locale>? locales,
  ) {
    String? code;

    if (locale != null) code = _localizedNameToCode(name, locale);
    if (code == null && locales == null) {
      code = _localizedNameToCode(name, const Locale('en'));
    }
    if (code != null) return code;

    final localeList = locales ?? <Locale>[];

    if (locales == null) {
      final exclude = <Locale>[const Locale('en')];
      if (locale != null) exclude.add(locale);
      localeList.addAll(_supportedLanguages(exclude: exclude));
    }

    return _nameToCodeFromGivenLocales(name, localeList);
  }

  /// Returns the country code that matches the given [name] for any of the
  /// [locales].
  ///
  /// Throws an [ArgumentError] if no matching element is found.
  static String _nameToCodeFromGivenLocales(String name, List<Locale> locales) {
    String? code;

    for (var i = 0; i < locales.length && code == null; i++) {
      code = _localizedNameToCode(name, locales[i]);
    }

    if (code == null) {
      throw ArgumentError.value('No country found');
    }

    return code;
  }

  /// Returns the code for [name] using the available translation for [locale].
  ///
  /// Returns null if no match is found.
  static String? _localizedNameToCode(String name, Locale locale) {
    final loc = resolveCountryLocalizations(locale);
    for (final entry in countries) {
      final code = entry['iso2_cc']?.toString();
      if (code == null) continue;
      if (loc.countryName(code)?.toLowerCase() == name) return code;
    }
    return null;
  }

  /// A list of the supported locales, except those included in the [exclude]
  /// list. Derived from [CountryLocalizations.supportedLocales].
  static List<Locale> _supportedLanguages({
    List<Locale> exclude = const <Locale>[],
  }) => CountryLocalizations.supportedLocales
      .where((l) => !exclude.contains(l))
      .toList();
}
