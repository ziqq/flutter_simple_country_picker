import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart' show Locale;
import 'package:flutter/widgets.dart'
    show BuildContext, Localizations, LocalizationsDelegate;
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
/// Defines all localizable strings used by the flutter_simple_country_picker
/// widgets.
///
/// Use [CountryLocalizations.of] to access the current locale's strings
/// from any widget:
///
/// ```dart
/// final loc = CountryLocalizations.of(context);
/// print(loc.searchPlaceholder);
/// print(loc.countryName('RU'));
/// ```
///
/// Add [CountryLocalizations.delegate] to your app's
/// `localizationsDelegates` list and include the desired locales in
/// `supportedLocales` to enable translations:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: [
///     CountryLocalizations.delegate,
///     GlobalWidgetsLocalizations.delegate,
///     GlobalMaterialLocalizations.delegate,
///   ],
///   supportedLocales: CountryLocalizations.supportedLocales,
/// );
/// ```
///
/// To provide a custom translation or override a specific locale, extend this
/// class and register your delegate:
///
/// ```dart
/// class MyCountryLocalizations extends CountryLocalizations {
///   const MyCountryLocalizations();
///
///   @override String get searchPlaceholder => 'Search...';
///   @override String? countryName(String code) => _myNames[code];
/// }
/// ```
/// {@endtemplate}
abstract class CountryLocalizations {
  /// {@macro country_localizations}
  const CountryLocalizations();

  // ── UI strings ─────────────────────────────────────────────────────────────

  /// Label for the "Cancel" button.
  String get cancelButton;

  /// Placeholder for the phone-number input field.
  String get phonePlaceholder;

  /// Placeholder for the country search field.
  String get searchPlaceholder;

  /// Heading label of the country picker sheet.
  String get selectCountryLabel;

  // ── Country names ───────────────────────────────────────────────────────────

  /// Returns the localized country name for [countryCode] (ISO 3166-1 alpha-2),
  /// or `null` if the code is not found in this locale's data.
  String? countryName(String countryCode);

  /// Returns the localized country name for [countryCode].
  ///
  /// Equivalent to [countryName], kept for backward compatibility.
  String? getCountryNameByCode(String countryCode) => countryName(countryCode);

  /// Returns the formatted localized country name for [countryCode],
  /// collapsing consecutive whitespace to a single space.
  String? getFormatedCountryNameByCode(String countryCode) {
    final name = countryName(countryCode);
    if (name == null) return null;
    return name.replaceAll(_whitespaceRegExp, ' ');
  }

  // ── Static members (SDK-style) ──────────────────────────────────────────────

  static final RegExp _whitespaceRegExp = RegExp(r'\s+');

  /// Returns the [CountryLocalizations] from the nearest [Localizations]
  /// ancestor that matches this type.
  ///
  /// Falls back to English if no delegate is found in the widget tree.
  static CountryLocalizations of(BuildContext context) =>
      Localizations.of<CountryLocalizations>(context, CountryLocalizations) ??
      const CountryLocalizationsEn();

  /// A [LocalizationsDelegate] to register in
  /// `MaterialApp.localizationsDelegates`.
  static const LocalizationsDelegate<CountryLocalizations> delegate =
      _CountryLocalizationsDelegate();

  /// Regular expression for a localized country name (whitespace normalization).
  @Deprecated(
    'Use getFormatedCountryNameByCode instead. '
    'This field will be removed in v1.0.0 releases.',
  )
  // ignore: prefer_final_fields
  static RegExp countryNameRegExp = RegExp(r'\s+');

  /// All locales supported by the built-in translations.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('bg'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('es'),
    Locale('et'),
    Locale('fa'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('ht'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ku'),
    Locale('lt'),
    Locale('lv'),
    Locale('nb'),
    Locale('ne'),
    Locale('nl'),
    Locale('nn'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('tr'),
    Locale('uk'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];
}

// ── Delegate ─────────────────────────────────────────────────────────────────

class _CountryLocalizationsDelegate
    extends LocalizationsDelegate<CountryLocalizations> {
  const _CountryLocalizationsDelegate();

  static const Set<String> _supported = {
    'en',
    'ar',
    'bg',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'es',
    'et',
    'fa',
    'fr',
    'he',
    'hi',
    'hr',
    'ht',
    'id',
    'it',
    'ja',
    'ko',
    'ku',
    'lt',
    'lv',
    'nb',
    'ne',
    'nl',
    'nn',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'tr',
    'uk',
    'zh',
  };

  @override
  bool isSupported(Locale locale) => _supported.contains(locale.languageCode);

  @override
  Future<CountryLocalizations> load(Locale locale) =>
      SynchronousFuture<CountryLocalizations>(switch (locale.languageCode) {
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
      });

  @override
  bool shouldReload(covariant _CountryLocalizationsDelegate old) => false;
}
