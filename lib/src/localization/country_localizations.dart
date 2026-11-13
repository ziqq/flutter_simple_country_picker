import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart' show Locale;
import 'package:flutter/widgets.dart'
    show BuildContext, Localizations, LocalizationsDelegate;
import 'package:flutter_simple_country_picker/src/localization/translations/af.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/am.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ar.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/az.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/be.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/bg.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/bn.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ca.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/cn.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/cs.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/da.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/de.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/en.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/eo.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/es.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/et.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/eu.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/fa.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/fi.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/fil.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/fr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ga.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/gl.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/gr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/gu.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/he.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/hi.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/hr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ht.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/hu.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/hy.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/id.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/it.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ja.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ka.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/kk.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/km.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/kn.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ko.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ku.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/lt.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/lv.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ml.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/mr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ms.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/mt.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/my.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/nb.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/nl.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/nn.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/np.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/or.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/pl.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/pt.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/pt_br.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/pt_pt.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ro.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ru.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/sk.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/sl.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/sq.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/sr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/sv.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/sw.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ta.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/te.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/tg.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/th.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/tk.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/tr.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/tw.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/uk.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/ur.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/uz.dart';
import 'package:flutter_simple_country_picker/src/localization/translations/vi.dart';
import 'package:meta/meta.dart';

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
    Locale('af'),
    Locale('am'),
    Locale('ar'),
    Locale('az'),
    Locale('be'),
    Locale('bg'),
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('eo'),
    Locale('es'),
    Locale('et'),
    Locale('eu'),
    Locale('fa'),
    Locale('fi'),
    Locale('fil'),
    Locale('fr'),
    Locale('ga'),
    Locale('gl'),
    Locale('gu'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('ht'),
    Locale('hu'),
    Locale('hy'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ka'),
    Locale('kk'),
    Locale('km'),
    Locale('kn'),
    Locale('ko'),
    Locale('ku'),
    Locale('lt'),
    Locale('lv'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('mt'),
    Locale('my'),
    Locale('nb'),
    Locale('ne'),
    Locale('nl'),
    Locale('nn'),
    Locale('or'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('pt', 'PT'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sq'),
    Locale('sr'),
    Locale('sv'),
    Locale('sw'),
    Locale('ta'),
    Locale('te'),
    Locale('tg'),
    Locale('th'),
    Locale('tk'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('uz'),
    Locale('vi'),
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
    'af',
    'am',
    'ar',
    'az',
    'be',
    'bg',
    'bn',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'eo',
    'es',
    'et',
    'eu',
    'fa',
    'fi',
    'fil',
    'fr',
    'ga',
    'gl',
    'gu',
    'he',
    'hi',
    'hr',
    'ht',
    'hu',
    'hy',
    'id',
    'it',
    'ja',
    'ka',
    'kk',
    'km',
    'kn',
    'ko',
    'ku',
    'lt',
    'lv',
    'ml',
    'mr',
    'ms',
    'mt',
    'my',
    'nb',
    'ne',
    'nl',
    'nn',
    'or',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sq',
    'sr',
    'sv',
    'sw',
    'ta',
    'te',
    'tg',
    'th',
    'tk',
    'tr',
    'uk',
    'ur',
    'uz',
    'vi',
    'zh',
  };

  @override
  bool isSupported(Locale locale) => _supported.contains(locale.languageCode);

  @override
  Future<CountryLocalizations> load(Locale locale) =>
      SynchronousFuture<CountryLocalizations>(
        resolveCountryLocalizations(locale),
      );

  @override
  bool shouldReload(covariant _CountryLocalizationsDelegate old) => false;
}

/// Resolves built-in translations for the picker and country name parser.
@internal
CountryLocalizations resolveCountryLocalizations(Locale locale) =>
    switch (locale.languageCode) {
      'af' => const CountryLocalizationsAf(),
      'am' => const CountryLocalizationsAm(),
      'ar' => const CountryLocalizationsAr(),
      'az' => const CountryLocalizationsAz(),
      'be' => const CountryLocalizationsBe(),
      'bg' => const CountryLocalizationsBg(),
      'bn' => const CountryLocalizationsBn(),
      'ca' => const CountryLocalizationsCa(),
      'cs' => const CountryLocalizationsCs(),
      'da' => const CountryLocalizationsDa(),
      'de' => const CountryLocalizationsDe(),
      'el' => const CountryLocalizationsEl(),
      'eo' => const CountryLocalizationsEo(),
      'es' => const CountryLocalizationsEs(),
      'et' => const CountryLocalizationsEt(),
      'eu' => const CountryLocalizationsEu(),
      'fa' => const CountryLocalizationsFa(),
      'fi' => const CountryLocalizationsFi(),
      'fil' => const CountryLocalizationsFil(),
      'fr' => const CountryLocalizationsFr(),
      'ga' => const CountryLocalizationsGa(),
      'gl' => const CountryLocalizationsGl(),
      'gu' => const CountryLocalizationsGu(),
      'he' => const CountryLocalizationsHe(),
      'hi' => const CountryLocalizationsHi(),
      'hr' => const CountryLocalizationsHr(),
      'ht' => const CountryLocalizationsHt(),
      'hu' => const CountryLocalizationsHu(),
      'hy' => const CountryLocalizationsHy(),
      'id' => const CountryLocalizationsId(),
      'it' => const CountryLocalizationsIt(),
      'ja' => const CountryLocalizationsJa(),
      'ka' => const CountryLocalizationsKa(),
      'kk' => const CountryLocalizationsKk(),
      'km' => const CountryLocalizationsKm(),
      'kn' => const CountryLocalizationsKn(),
      'ko' => const CountryLocalizationsKo(),
      'ku' => const CountryLocalizationsKu(),
      'lt' => const CountryLocalizationsLt(),
      'lv' => const CountryLocalizationsLv(),
      'ml' => const CountryLocalizationsMl(),
      'mr' => const CountryLocalizationsMr(),
      'ms' => const CountryLocalizationsMs(),
      'mt' => const CountryLocalizationsMt(),
      'my' => const CountryLocalizationsMy(),
      'nb' => const CountryLocalizationsNb(),
      'ne' => const CountryLocalizationsNp(),
      'nl' => const CountryLocalizationsNl(),
      'nn' => const CountryLocalizationsNn(),
      'or' => const CountryLocalizationsOr(),
      'pl' => const CountryLocalizationsPl(),
      'pt' => switch (locale.countryCode) {
        'BR' => const CountryLocalizationsPtBr(),
        'PT' => const CountryLocalizationsPtPt(),
        _ => const CountryLocalizationsPt(),
      },
      'ro' => const CountryLocalizationsRo(),
      'ru' => const CountryLocalizationsRu(),
      'sk' => const CountryLocalizationsSk(),
      'sl' => const CountryLocalizationsSl(),
      'sq' => const CountryLocalizationsSq(),
      'sr' => const CountryLocalizationsSr(),
      'sv' => const CountryLocalizationsSv(),
      'sw' => const CountryLocalizationsSw(),
      'ta' => const CountryLocalizationsTa(),
      'te' => const CountryLocalizationsTe(),
      'tg' => const CountryLocalizationsTg(),
      'th' => const CountryLocalizationsTh(),
      'tk' => const CountryLocalizationsTk(),
      'tr' => const CountryLocalizationsTr(),
      'uk' => const CountryLocalizationsUk(),
      'ur' => const CountryLocalizationsUr(),
      'uz' => const CountryLocalizationsUz(),
      'vi' => const CountryLocalizationsVi(),
      'zh' =>
        locale.scriptCode == 'Hant'
            ? const CountryLocalizationsZhHant()
            : const CountryLocalizationsZhHans(),
      _ => const CountryLocalizationsEn(),
    };
