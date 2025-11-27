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

    final localizations = context != null
        ? CountryLocalizations.of(context)
        : null;

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
      case 'es':
        return es;
      case 'et':
        return et;
      case 'he':
        return he;
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
      case 'ro':
        return ro;
      case 'ru':
        return ru;
      case 'sk':
        return sk;
      case 'hi':
      case 'ne':
        return np;
      case 'ar':
        return ar;
      case 'bg':
        return bg;
      case 'ku':
        return ku;
      case 'hr':
        return hr;
      case 'ht':
        return ht;
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
      case 'ko':
        return ko;
      case 'ja':
        return ja;
      case 'id':
        return id;
      case 'cs':
        return cs;
      case 'da':
        return da;
      case 'ca':
        return ca;
      case 'fa':
        return fa;
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
  }) => <Locale>[
    const Locale('en'),
    const Locale('ar'),
    const Locale('es'),
    const Locale('de'),
    const Locale('fr'),
    const Locale('el'),
    const Locale('et'),
    const Locale('nb'),
    const Locale('nn'),
    const Locale('pl'),
    const Locale('pt'),
    const Locale('ru'),
    const Locale('hi'),
    const Locale('ne'),
    const Locale('uk'),
    const Locale('hr'),
    const Locale('tr'),
    const Locale('lv'),
    const Locale('lt'),
    const Locale('ku'),
    const Locale('nl'),
    const Locale('it'),
    const Locale('ko'),
    const Locale('ja'),
    const Locale('id'),
    const Locale('cs'),
    const Locale('ht'),
    const Locale('sk'),
    const Locale('ro'),
    const Locale('bg'),
    const Locale('ca'),
    const Locale('he'),
    const Locale('fa'),
    const Locale('da'),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
    ), // Generic Simplified Chinese 'zh_Hans'
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
    ), // Generic traditional Chinese 'zh_Hant'
  ]..removeWhere((l) => exclude.contains(l));
}
