import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ar.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/bg.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ca.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/cn.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/cs.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/da.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/de.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/en.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/es.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/et.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/fa.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/fr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/gr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/he.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/hr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ht.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/id.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/it.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ja.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ko.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ku.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/lt.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/lv.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/nb.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/nl.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/nn.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/np.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/pl.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/pt.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ro.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ru.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/sk.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/tr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/tw.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/uk.dart';
import 'package:meta/meta.dart';

/// {@template country_parser}
/// Used to parse simple string representations of countries, commonly used in
/// databases and other forms of storage, to a Country object.
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
  /// returns null if no matching element is found.
  static Country? tryParse(String country) =>
      tryParseCountryCode(country) ?? tryParseCountryName(country);

  /// Returns a single country if it matches the given [countryCode] (iso2_cc).
  ///
  /// Throws a [StateError] if no matching element is found.
  static Country parseCountryCode(String countryCode) =>
      _getFromCode(countryCode.toUpperCase());

  /// Returns a single country if it matches the given [phoneCode] (e164_cc).
  ///
  /// Throws a [StateError] if no matching element is found.
  static Country parsePhoneCode(String phoneCode, String e164Key) =>
      _getFromPhoneCode(phoneCode, e164Key);

  /// Returns a single country that matches the given [countryCode] (iso2_cc).
  ///
  /// Returns null if no matching element is found.
  static Country? tryParseCountryCode(String countryCode) {
    try {
      return parseCountryCode(countryCode);
    } on Object catch (_) {
      return null;
    }
  }

  /// Returns a single country that matches the given [phoneCode] (e164_cc).
  ///
  /// Returns null if no matching element is found.
  static Country? tryParsePhoneCode(String phoneCode, String e164Key) {
    try {
      return parsePhoneCode(phoneCode, e164Key);
    } on Object catch (_) {
      return null;
    }
  }

  /// Returns a single country if it matches the given [countryName].
  ///
  /// Uses the application [context] to determine what language is used in the
  /// app, if provided, and checks the country names for this locale if any.
  /// If no match is found and no [locales] are given, the default language is
  /// checked (english), followed by the rest of the available translations. If
  /// any [locales] are given, only those supported languages are used, in
  /// addition to the [context] language.
  ///
  /// Throws an [ArgumentError] if no matching element is found.
  static Country parseCountryName(
    String countryName, {
    BuildContext? context,
    List<Locale>? locales,
  }) {
    final countryNameLower = countryName.toLowerCase();

    final languageCode = _anyLocalizedNameToCode(
      countryNameLower,
      context != null ? Localizations.localeOf(context) : null,
      locales,
    );

    return _getFromCode(languageCode);
  }

  /// Returns a single country if it matches the given [countryName].
  ///
  /// Returns null if no matching element is found.
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

  /// Returns a country that matches
  /// the [countryCode] (e164_cc) and [e164Key] (e164Key)
  static Country _getFromPhoneCode(String phoneCode, String e164Key) =>
      Country.fromJson(
        countries.singleWhere(
          (j) => j['e164_cc'] == phoneCode && j['e164_key'] == e164Key,
        ),
      );

  /// Returns a country that matches the [countryCode] (iso2_cc).
  static Country _getFromCode(String countryCode) => Country.fromJson(
    countries.singleWhere((j) => j['iso2_cc'] == countryCode),
  );

  /// Returns a country code that matches a country with the given [name] for
  /// any language, or the ones given by [locales]. If no locale list is given,
  /// the language for the [locale] is prioritized, followed by the default
  /// language, english.
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

  /// Returns the code for the country that matches the given [name] in the
  /// language given by the [locale]. Defaults to english.
  ///
  /// Returns null if no match is found.
  static String? _localizedNameToCode(String name, Locale locale) {
    final loc = _getLocalization(locale);
    for (final entry in countries) {
      final code = entry['iso2_cc']?.toString();
      if (code == null) continue;
      if (loc.countryName(code)?.toLowerCase() == name) return code;
    }
    return null;
  }

  // TODO(ziqq): solution to prevent manual update on adding new localizations?
  /// Returns a [CountryLocalizations] instance for the given [locale].
  static CountryLocalizations _getLocalization(Locale locale) =>
      switch (locale.languageCode) {
        'ar' => const CountryLocalizationsAr(),
        'bg' => const CountryLocalizationsBg(),
        'ca' => const CountryLocalizationsCa(),
        'cs' => const CountryLocalizationsCs(),
        'da' => const CountryLocalizationsDa(),
        'de' => const CountryLocalizationsDe(),
        'el' => const CountryLocalizationsEl(),
        'es' => const CountryLocalizationsEs(),
        'et' => const CountryLocalizationsEt(),
        'fa' => const CountryLocalizationsFa(),
        'fr' => const CountryLocalizationsFr(),
        'he' => const CountryLocalizationsHe(),
        'hi' || 'ne' => const CountryLocalizationsNp(),
        'hr' => const CountryLocalizationsHr(),
        'ht' => const CountryLocalizationsHt(),
        'id' => const CountryLocalizationsId(),
        'it' => const CountryLocalizationsIt(),
        'ja' => const CountryLocalizationsJa(),
        'ko' => const CountryLocalizationsKo(),
        'ku' => const CountryLocalizationsKu(),
        'lt' => const CountryLocalizationsLt(),
        'lv' => const CountryLocalizationsLv(),
        'nb' => const CountryLocalizationsNb(),
        'nl' => const CountryLocalizationsNl(),
        'nn' => const CountryLocalizationsNn(),
        'pl' => const CountryLocalizationsPl(),
        'pt' => const CountryLocalizationsPt(),
        'ro' => const CountryLocalizationsRo(),
        'ru' => const CountryLocalizationsRu(),
        'sk' => const CountryLocalizationsSk(),
        'tr' => const CountryLocalizationsTr(),
        'uk' => const CountryLocalizationsUk(),
        'zh' =>
          locale.scriptCode == 'Hant'
              ? const CountryLocalizationsZhHant()
              : const CountryLocalizationsZhHans(),
        _ => const CountryLocalizationsEn(),
      };

  /// A list of the supported locales, except those included in the [exclude]
  /// list. Derived from [CountryLocalizations.supportedLocales].
  static List<Locale> _supportedLanguages({
    List<Locale> exclude = const <Locale>[],
  }) => CountryLocalizations.supportedLocales
      .where((l) => !exclude.contains(l))
      .toList();
}
