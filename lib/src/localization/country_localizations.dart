import 'package:flutter/material.dart';
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

/// {@template country_localizations}
/// CountryLocalizations
/// {@endtemplate}
final class CountryLocalizations {
  /// {@macro country_localizations}
  CountryLocalizations(this.locale);

  /// The locale for which the translations are provided.
  final Locale locale;

  /// The `CountryLocalizations` from the closest [Localizations] instance
  /// that encloses the given context.
  ///
  /// This method is just a convenient shorthand for:
  /// `Localizations.of<CountryLocalizations>(context, CountryLocalizations)`.
  ///
  /// References to the localized resources defined by this class are typically
  /// written in terms of this method. For example:
  ///
  /// ```dart
  /// CountryLocalizations.of(context).countryName(countryCode: country.countryCode),
  /// ```
  static CountryLocalizations? of(BuildContext context) =>
      Localizations.of<CountryLocalizations>(context, CountryLocalizations);

  /// A [LocalizationsDelegate] that uses [_CountryLocalizationsDelegate.load]
  /// to create an instance of this class.
  static const LocalizationsDelegate<CountryLocalizations> delegate =
      _CountryLocalizationsDelegate();

  /// Regular expression for localyzed country name.
  static RegExp countryNameRegExp = RegExp(r'\s+');

  /// Supported locales.
  static List<Locale> supportedLocales = <Locale>[
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
  ];

  /// The localized country name for the given country code.
  String? getCountryNameByCode(String countryCode) =>
      toLocalizedString(countryCode);

  /// The localized string for the given key.
  String? toLocalizedString(String key) {
    switch (locale.languageCode) {
      case 'zh':
        switch (locale.scriptCode) {
          case 'Hant':
            return tw[key];
          case 'Hans':
          default:
            return cn[key];
        }
      case 'el':
        return gr[key];
      case 'es':
        return es[key];
      case 'et':
        return et[key];
      case 'he':
        return he[key];
      case 'pt':
        return pt[key];
      case 'nb':
        return nb[key];
      case 'nn':
        return nn[key];
      case 'uk':
        return uk[key];
      case 'pl':
        return pl[key];
      case 'tr':
        return tr[key];
      case 'ro':
        return ro[key];
      case 'ru':
        return ru[key];
      case 'sk':
        return sk[key];
      case 'hi':
      case 'ne':
        return np[key];
      case 'ar':
        return ar[key];
      case 'bg':
        return bg[key];
      case 'ku':
        return ku[key];
      case 'hr':
        return hr[key];
      case 'ht':
        return ht[key];
      case 'fr':
        return fr[key];
      case 'de':
        return de[key];
      case 'lv':
        return lv[key];
      case 'lt':
        return lt[key];
      case 'nl':
        return nl[key];
      case 'it':
        return it[key];
      case 'ko':
        return ko[key];
      case 'ja':
        return ja[key];
      case 'id':
        return id[key];
      case 'cs':
        return cs[key];
      case 'da':
        return da[key];
      case 'ca':
        return ca[key];
      case 'fa':
        return fa[key];
      case 'en':
      default:
        return en[key];
    }
  }
}

class _CountryLocalizationsDelegate
    extends LocalizationsDelegate<CountryLocalizations> {
  const _CountryLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
    'en',
    'ar',
    'bg',
    'ku',
    'zh',
    'el',
    'es',
    'et',
    'he',
    'pl',
    'pt',
    'nb',
    'nn',
    'ro',
    'ru',
    'sk',
    'uk',
    'hi',
    'ne',
    'tr',
    'hr',
    'ht',
    'fr',
    'de',
    'lt',
    'lv',
    'nl',
    'it',
    'ko',
    'ja',
    'id',
    'cs',
    'ca',
    'fa',
    'da',
    'ca',
  ].contains(locale.languageCode);

  @override
  Future<CountryLocalizations> load(Locale locale) {
    final localizations = CountryLocalizations(locale);
    return Future.value(localizations);
  }

  @override
  bool shouldReload(_CountryLocalizationsDelegate old) => false;
}
