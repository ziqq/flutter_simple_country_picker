import 'package:flutter/material.dart';
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

/// {@template countries_localization}
/// Countries localization.
/// {@endtemplate}
class CountriesLocalization {
  /// {@macro countries_localization}
  CountriesLocalization(this.locale);

  /// Current locale
  final Locale locale;

  /// The `CountriesLocalization` from the closest [Localizations] instance
  /// that encloses the given context.
  ///
  /// This method is just a convenient shorthand for:
  /// `Localizations.of<CountriesLocalization>(context, CountriesLocalization)`.
  ///
  /// References to the localized resources defined by this class are typically
  /// written in terms of this method. For example:
  ///
  /// ```dart
  /// CountriesLocalization.of(context).countryName(
  ///   countryCode: country.countryCode,
  /// ),
  /// ```
  static CountriesLocalization? of(BuildContext context) =>
      Localizations.of<CountriesLocalization>(context, CountriesLocalization);

  /// A [LocalizationsDelegate] that uses [_CountriesLocalizationDelegate.load]
  /// to create an instance of this class.
  static const LocalizationsDelegate<CountriesLocalization> delegate =
      _CountriesLocalizationDelegate();

  /// The localized country name for the given country code.
  String? countryName({required String countryCode}) {
    switch (locale.languageCode) {
      case 'zh':
        switch (locale.scriptCode) {
          case 'Hant':
            return tw[countryCode];
          case 'Hans':
          default:
            return cn[countryCode];
        }
      case 'el':
        return gr[countryCode];
      case 'es':
        return es[countryCode];
      case 'et':
        return et[countryCode];
      case 'pt':
        return pt[countryCode];
      case 'nb':
        return nb[countryCode];
      case 'nn':
        return nn[countryCode];
      case 'uk':
        return uk[countryCode];
      case 'pl':
        return pl[countryCode];
      case 'tr':
        return tr[countryCode];
      case 'ru':
        return ru[countryCode];
      case 'hi':
      case 'ne':
        return np[countryCode];
      case 'ar':
        return ar[countryCode];
      case 'ku':
        return ku[countryCode];
      case 'hr':
        return hr[countryCode];
      case 'fr':
        return fr[countryCode];
      case 'de':
        return de[countryCode];
      case 'lv':
        return lv[countryCode];
      case 'lt':
        return lt[countryCode];
      case 'nl':
        return nl[countryCode];
      case 'it':
        return it[countryCode];
      case 'en':
      default:
        return en[countryCode];
    }
  }
}

class _CountriesLocalizationDelegate
    extends LocalizationsDelegate<CountriesLocalization> {
  const _CountriesLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
        'ar',
        'ku',
        'zh',
        'el',
        'es',
        'et',
        'pl',
        'pt',
        'nb',
        'nn',
        'ru',
        'uk',
        'hi',
        'ne',
        'tr',
        'hr',
        'fr',
        'de',
        'lt',
        'lv',
        'nl',
        'it',
      ].contains(locale.languageCode);

  @override
  Future<CountriesLocalization> load(Locale locale) {
    final localizations = CountriesLocalization(locale);
    return Future.value(localizations);
  }

  @override
  bool shouldReload(_CountriesLocalizationDelegate old) => false;
}
