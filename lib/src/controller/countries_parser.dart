import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/country_codes.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/ar.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/cn.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/de.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/en.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/es.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/et.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/fr.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/gr.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/hr.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/it.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/ku.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/lt.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/lv.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/nb.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/nl.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/nn.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/np.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/pl.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/pt.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/ru.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/tr.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/tw.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/strings/uk.dart';

/// {@template countries_parser}
/// Used to parse simple string representations of countries, commonly used in
/// databases and other forms of storage, to a Country object.
/// {@endtemplate}
abstract final class CountriesParser {
  /// {@macro countries_parser}
  const CountriesParser._();

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
  static Country parsePhoneCode(String phoneCode) =>
      _getFromPhoneCode(phoneCode);

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
  static Country? tryParsePhoneCode(String phoneCode) {
    try {
      return parsePhoneCode(phoneCode);
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

    final localizations =
        context != null ? CountriesLocalization.of(context) : null;

    final languageCode = _anyLocalizedNameToCode(
      countryNameLower,
      localizations?.locale,
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

  /// Returns a country that matches the [countryCode] (e164_cc).
  static Country _getFromPhoneCode(String phoneCode) => Country.fromJson(
        countryCodes.singleWhere(
          (j) => j['e164_cc'] == phoneCode,
        ),
      );

  /// Returns a country that matches the [countryCode] (iso2_cc).
  static Country _getFromCode(String countryCode) => Country.fromJson(
        countryCodes.singleWhere(
          (j) => j['iso2_cc'] == countryCode,
        ),
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
    final translation = _getTranslation(locale);

    String? code;

    translation.forEach((key, value) {
      if (value.toLowerCase() == name) code = key;
    });

    return code;
  }

  // TODO(ziqq): solution to prevent manual update on adding new localizations?
  /// Returns a translation for the given [locale]. Defaults to english.
  static Map<String, String> _getTranslation(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        switch (locale.scriptCode) {
          case 'Hant':
            return tw;
          case 'Hans':
          default:
            return cn;
        }
      case 'el':
        return gr;
      case 'ar':
        return ar;
      case 'ku':
        return ku;
      case 'es':
        return es;
      case 'et':
        return et;
      case 'pt':
        return pt;
      case 'nb':
        return nb;
      case 'nn':
        return nn;
      case 'uk':
        return uk;
      case 'pl':
        return pl;
      case 'tr':
        return tr;
      case 'hr':
        return hr;
      case 'ru':
        return ru;
      case 'hi':
      case 'ne':
        return np;
      case 'fr':
        return fr;
      case 'de':
        return de;
      case 'lv':
        return lv;
      case 'lt':
        return lt;
      case 'nl':
        return nl;
      case 'it':
        return it;
      case 'en':
      default:
        return en;
    }
  }

  // TODO(ziqq): solution to prevent manual update on adding new localizations?
  /// A list of the supported locales, except those included in the [exclude]
  /// list.
  static List<Locale> _supportedLanguages({
    List<Locale> exclude = const <Locale>[],
  }) =>
      <Locale>[
        const Locale('en'),
        const Locale('ar'),
        const Locale('ku'),
        const Locale('es'),
        const Locale('el'),
        const Locale('et'),
        const Locale('fr'),
        const Locale('nb'),
        const Locale('nn'),
        const Locale('pl'),
        const Locale('pt'),
        const Locale('ru'),
        const Locale('hi'),
        const Locale('ne'),
        const Locale('uk'),
        const Locale('tr'),
        const Locale('hr'),
        const Locale('de'),
        const Locale('lv'),
        const Locale('lv'),
        const Locale('nl'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ]..removeWhere((l) => exclude.contains(l));
}
