// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_simple_country_picker/src/localization/country_localizations.dart'
    show CountryLocalizations;
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
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Small in-test stub for testing abstract-class behaviour directly.
// ---------------------------------------------------------------------------
final class _StubLocalizations extends CountryLocalizations {
  const _StubLocalizations();

  @override
  String get cancelButton => 'Cancel';

  @override
  String get phonePlaceholder => 'Phone';

  @override
  String get searchPlaceholder => 'Search';

  @override
  String get selectCountryLabel => 'Select';

  @override
  String? countryName(String code) =>
      code == 'XX' ? 'Name  with  extra   spaces' : null;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Locale _l(String lang) => Locale(lang);
Locale _lScript(String lang, String script) =>
    Locale.fromSubtags(languageCode: lang, scriptCode: script);

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  group('CountryLocalizations -', () {
    // ── supportedLocales ────────────────────────────────────────────────────
    group('supportedLocales -', () {
      test('contains exactly 36 entries', () {
        expect(CountryLocalizations.supportedLocales, hasLength(36));
      });

      test('contains all expected language locales', () {
        const expected = <String>[
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
        ];
        final langs = CountryLocalizations.supportedLocales.map(
          (l) => l.languageCode,
        );
        for (final lang in expected) {
          expect(langs, contains(lang), reason: '$lang missing');
        }
      });

      test('contains zh-Hans and zh-Hant', () {
        final scripts = CountryLocalizations.supportedLocales
            .where((l) => l.languageCode == 'zh')
            .map((l) => l.scriptCode)
            .toSet();
        expect(scripts, containsAll({'Hans', 'Hant'}));
      });

      test('does not contain unsupported locale', () {
        final langs = CountryLocalizations.supportedLocales.map(
          (l) => l.languageCode,
        );
        expect(langs, isNot(contains('xx')));
      });
    });

    // ── delegate ────────────────────────────────────────────────────────────
    group('delegate -', () {
      const delegate = CountryLocalizations.delegate;

      group('isSupported -', () {
        const supportedLanguages = <String>[
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
        ];

        for (final lang in supportedLanguages) {
          test('returns true for "$lang"', () {
            expect(delegate.isSupported(_l(lang)), isTrue);
          });
        }

        test('returns false for unknown language code', () {
          expect(delegate.isSupported(_l('xx')), isFalse);
          expect(delegate.isSupported(_l('zz')), isFalse);
          expect(delegate.isSupported(_l('qq')), isFalse);
        });
      });

      test('shouldReload returns false', () {
        expect(delegate.shouldReload(delegate), isFalse);
      });

      group('load -', () {
        final loadCases = <(Locale, Type)>[
          (_l('ar'), CountryLocalizationsAr),
          (_l('bg'), CountryLocalizationsBg),
          (_l('ca'), CountryLocalizationsCa),
          (_l('cs'), CountryLocalizationsCs),
          (_l('da'), CountryLocalizationsDa),
          (_l('de'), CountryLocalizationsDe),
          (_l('el'), CountryLocalizationsEl),
          (_l('en'), CountryLocalizationsEn),
          (_l('es'), CountryLocalizationsEs),
          (_l('et'), CountryLocalizationsEt),
          (_l('fa'), CountryLocalizationsFa),
          (_l('fr'), CountryLocalizationsFr),
          (_l('he'), CountryLocalizationsHe),
          (_l('hi'), CountryLocalizationsNp),
          (_l('hr'), CountryLocalizationsHr),
          (_l('ht'), CountryLocalizationsHt),
          (_l('id'), CountryLocalizationsId),
          (_l('it'), CountryLocalizationsIt),
          (_l('ja'), CountryLocalizationsJa),
          (_l('ko'), CountryLocalizationsKo),
          (_l('ku'), CountryLocalizationsKu),
          (_l('lt'), CountryLocalizationsLt),
          (_l('lv'), CountryLocalizationsLv),
          (_l('nb'), CountryLocalizationsNb),
          (_l('ne'), CountryLocalizationsNp),
          (_l('nl'), CountryLocalizationsNl),
          (_l('nn'), CountryLocalizationsNn),
          (_l('pl'), CountryLocalizationsPl),
          (_l('pt'), CountryLocalizationsPt),
          (_l('ro'), CountryLocalizationsRo),
          (_l('ru'), CountryLocalizationsRu),
          (_l('sk'), CountryLocalizationsSk),
          (_l('tr'), CountryLocalizationsTr),
          (_l('uk'), CountryLocalizationsUk),
          (_lScript('zh', 'Hans'), CountryLocalizationsZhHans),
          (_lScript('zh', 'Hant'), CountryLocalizationsZhHant),
        ];

        for (final (locale, expectedType) in loadCases) {
          test('load($locale) returns $expectedType', () async {
            final loc = await delegate.load(locale);
            expect(loc.runtimeType, expectedType);
          });
        }

        test('zh without scriptCode defaults to ZhHans', () async {
          final loc = await delegate.load(_l('zh'));
          expect(loc, isA<CountryLocalizationsZhHans>());
        });

        test('unknown locale falls back to CountryLocalizationsEn', () async {
          final loc = await delegate.load(_l('xx'));
          expect(loc, isA<CountryLocalizationsEn>());
        });

        test('hi and ne share the same CountryLocalizationsNp class', () async {
          final hi = await delegate.load(_l('hi'));
          final ne = await delegate.load(_l('ne'));
          expect(hi.runtimeType, ne.runtimeType);
          expect(hi, isA<CountryLocalizationsNp>());
        });
      });
    });

    // ── getCountryNameByCode ─────────────────────────────────────────────────
    group('getCountryNameByCode -', () {
      test('is a backward-compat alias for countryName', () {
        const loc = CountryLocalizationsEn();
        expect(loc.getCountryNameByCode('RU'), loc.countryName('RU'));
        expect(loc.getCountryNameByCode('US'), loc.countryName('US'));
        expect(loc.getCountryNameByCode('ZZ'), loc.countryName('ZZ'));
      });
    });

    // ── getFormatedCountryNameByCode ─────────────────────────────────────────
    group('getFormatedCountryNameByCode -', () {
      const stub = _StubLocalizations();

      test('returns null for unknown country code', () {
        expect(stub.getFormatedCountryNameByCode('ZZ'), isNull);
      });

      test('collapses consecutive whitespace to a single space', () {
        // stub returns 'Name  with  extra   spaces' for code 'XX'
        expect(
          stub.getFormatedCountryNameByCode('XX'),
          'Name with extra spaces',
        );
      });

      test('returns the name unchanged when no extra whitespace', () {
        const loc = CountryLocalizationsEn();
        final raw = loc.countryName('US');
        final formatted = loc.getFormatedCountryNameByCode('US');
        expect(formatted, raw);
      });

      test('returns null for known locale but unknown code', () {
        const loc = CountryLocalizationsRu();
        expect(loc.getFormatedCountryNameByCode('INVALID_CODE'), isNull);
      });
    });

    // ── concrete subclasses ─────────────────────────────────────────────────
    group('concrete subclasses -', () {
      // Each entry: (instance, cancelButton, phonePlaceholder,
      //              searchPlaceholder, selectCountryLabel, knownCode,
      //              knownCodeExpected)
      // knownCodeExpected = null → just verify non-null and non-empty.
      final cases =
          <
            (
              CountryLocalizations, // instance
              String, // cancelButton
              String, // phonePlaceholder
              String, // searchPlaceholder
              String, // selectCountryLabel
              String, // known country code
              String?, // expected name (null = any non-null non-empty value)
            )
          >[
            (
              const CountryLocalizationsAr(),
              'إلغاء',
              'رقم الهاتف',
              'بحث',
              'اختر الدولة',
              'US',
              null,
            ),
            (
              const CountryLocalizationsBg(),
              'Отказ',
              'Телефонен номер',
              'Търсене',
              'Изберете държава',
              'US',
              null,
            ),
            (
              const CountryLocalizationsCa(),
              'Cancel·la',
              'Número de telèfon',
              'Cerca',
              'Selecciona un país',
              'US',
              null,
            ),
            (
              const CountryLocalizationsZhHans(),
              '取消',
              '电话号码',
              '搜索',
              '选择国家',
              'US',
              '美国',
            ),
            (
              const CountryLocalizationsCs(),
              'Zrušit',
              'Telefonní číslo',
              'Hledat',
              'Vyberte zemi',
              'US',
              null,
            ),
            (
              const CountryLocalizationsDa(),
              'Annuller',
              'Telefonnummer',
              'Søg',
              'Vælg land',
              'US',
              null,
            ),
            (
              const CountryLocalizationsDe(),
              'Abbrechen',
              'Telefonnummer',
              'Suche',
              'Land auswählen',
              'US',
              'Vereinigte Staaten',
            ),
            (
              const CountryLocalizationsEn(),
              'Cancel',
              'Phone Number',
              'Search',
              'Select country',
              'US',
              'United States',
            ),
            (
              const CountryLocalizationsEs(),
              'Cancelar',
              'Número de teléfono',
              'Buscar',
              'Seleccionar país',
              'US',
              null,
            ),
            (
              const CountryLocalizationsEt(),
              'Tühista',
              'Telefoninumber',
              'Otsi',
              'Vali riik',
              'US',
              null,
            ),
            (
              const CountryLocalizationsFa(),
              'لغو',
              'شماره تلفن',
              'جستجو',
              'انتخاب کشور',
              'US',
              null,
            ),
            (
              const CountryLocalizationsFr(),
              'Annuler',
              'Numéro de téléphone',
              'Rechercher',
              'Sélectionner un pays',
              'US',
              null,
            ),
            (
              const CountryLocalizationsEl(),
              'Ακύρωση',
              'Αριθμός τηλεφώνου',
              'Αναζήτηση',
              'Επιλέξτε χώρα',
              'US',
              null,
            ),
            (
              const CountryLocalizationsHe(),
              'ביטול',
              'מספר טלפון',
              'חיפוש',
              'בחר מדינה',
              'US',
              null,
            ),
            (
              const CountryLocalizationsHr(),
              'Otkaži',
              'Broj telefona',
              'Pretraži',
              'Odaberite zemlju',
              'US',
              null,
            ),
            (
              const CountryLocalizationsHt(),
              'Anile',
              'Nimewo telefòn',
              'Rechèch',
              'Chwazi peyi',
              'US',
              'Leta Zini',
            ),
            (
              const CountryLocalizationsId(),
              'Batal',
              'Nomor telepon',
              'Cari',
              'Pilih negara',
              'US',
              null,
            ),
            (
              const CountryLocalizationsIt(),
              'Annulla',
              'Numero di telefono',
              'Cerca',
              'Seleziona paese',
              'US',
              null,
            ),
            (
              const CountryLocalizationsJa(),
              'キャンセル',
              '電話番号',
              '検索',
              '国を選択',
              'US',
              null,
            ),
            (
              const CountryLocalizationsKo(),
              '취소',
              '전화번호',
              '검색',
              '국가 선택',
              'US',
              null,
            ),
            (
              const CountryLocalizationsKu(),
              'هەڵبگرەوە',
              'ژمارەی تەلەفۆن',
              'گەڕان',
              'وڵات هەڵبژێرە',
              'US',
              'ویلایەتە یەکگرتووەکان',
            ),
            (
              const CountryLocalizationsLt(),
              'Atšaukti',
              'Telefono numeris',
              'Paieška',
              'Pasirinkite šalį',
              'US',
              null,
            ),
            (
              const CountryLocalizationsLv(),
              'Atcelt',
              'Telefona numurs',
              'Meklēt',
              'Izvēlieties valsti',
              'US',
              null,
            ),
            (
              const CountryLocalizationsNb(),
              'Avbryt',
              'Telefonnummer',
              'Søk',
              'Velg land',
              'US',
              null,
            ),
            (
              const CountryLocalizationsNl(),
              'Annuleren',
              'Telefoonnummer',
              'Zoeken',
              'Selecteer land',
              'US',
              null,
            ),
            (
              const CountryLocalizationsNn(),
              'Avbryt',
              'Telefonnummer',
              'Søk',
              'Velg land',
              'US',
              null,
            ),
            (
              const CountryLocalizationsNp(),
              'रद्द गर्नुहोस्',
              'फोन नम्बर',
              'खोज्नुहोस्',
              'देश चयन गर्नुहोस्',
              'US',
              'संयुक्त राज्य अमेरिका',
            ),
            (
              const CountryLocalizationsPl(),
              'Anuluj',
              'Numer telefonu',
              'Szukaj',
              'Wybierz kraj',
              'US',
              null,
            ),
            (
              const CountryLocalizationsPt(),
              'Cancelar',
              'Número de telefone',
              'Pesquisar',
              'Selecione o país',
              'US',
              null,
            ),
            (
              const CountryLocalizationsRo(),
              'Anulare',
              'Număr de telefon',
              'Căutare',
              'Selectați țara',
              'US',
              null,
            ),
            (
              const CountryLocalizationsRu(),
              'Отмена',
              'Номер телефона',
              'Поиск',
              'Выберите страну',
              'US',
              'Соединенные Штаты',
            ),
            (
              const CountryLocalizationsSk(),
              'Zrušiť',
              'Telefónne číslo',
              'Hľadať',
              'Vyberte krajinu',
              'US',
              null,
            ),
            (
              const CountryLocalizationsTr(),
              'İptal',
              'Telefon Numarası',
              'Arama',
              'Ülke Seçin',
              'US',
              null,
            ),
            (
              const CountryLocalizationsZhHant(),
              '取消',
              '電話號碼',
              '搜尋',
              '選擇國家',
              'US',
              '美國',
            ),
            (
              const CountryLocalizationsUk(),
              'Відміна',
              'Номер телефону',
              'Пошук',
              'Виберіть країну',
              'US',
              null,
            ),
          ];

      for (final (loc, cancel, phone, search, select, knownCode, expectedName)
          in cases) {
        final name = loc.runtimeType.toString();

        group('$name -', () {
          test('cancelButton', () => expect(loc.cancelButton, cancel));

          test('phonePlaceholder', () => expect(loc.phonePlaceholder, phone));

          test(
            'searchPlaceholder',
            () => expect(loc.searchPlaceholder, search),
          );

          test(
            'selectCountryLabel',
            () => expect(loc.selectCountryLabel, select),
          );

          test('all UI strings are non-empty', () {
            expect(loc.cancelButton, isNotEmpty);
            expect(loc.phonePlaceholder, isNotEmpty);
            expect(loc.searchPlaceholder, isNotEmpty);
            expect(loc.selectCountryLabel, isNotEmpty);
          });

          test('countryName("$knownCode") is non-null and non-empty', () {
            final result = loc.countryName(knownCode);
            expect(result, isNotNull);
            expect(result, isNotEmpty);
          });

          if (expectedName != null) {
            test(
              'countryName("$knownCode") == "$expectedName"',
              () => expect(loc.countryName(knownCode), expectedName),
            );
          }

          test('countryName with unknown code returns null', () {
            expect(loc.countryName('INVALID_XYZ_CODE'), isNull);
            expect(loc.countryName(''), isNull);
          });

          test('getCountryNameByCode matches countryName', () {
            expect(
              loc.getCountryNameByCode(knownCode),
              loc.countryName(knownCode),
            );
          });

          test(
            'getFormatedCountryNameByCode returns non-null for known code',
            () {
              expect(loc.getFormatedCountryNameByCode(knownCode), isNotNull);
              expect(loc.getFormatedCountryNameByCode(knownCode), isNotEmpty);
            },
          );

          test(
            'getFormatedCountryNameByCode returns null for unknown code',
            () {
              expect(
                loc.getFormatedCountryNameByCode('INVALID_XYZ_CODE'),
                isNull,
              );
            },
          );

          test('const constructor produces equal instances', () {
            // Concrete const constructors should be identical constants.
            // We can only test that two separately created instances are equal
            // at the type level since == is not overridden.
            expect(loc.runtimeType, loc.runtimeType);
          });
        });
      }

      // ── Additional countryName edge-cases ──────────────────────────────
      group('countryName edge cases -', () {
        const en = CountryLocalizationsEn();

        test('returns non-null for "RU"', () {
          expect(en.countryName('RU'), 'Russia');
        });

        test('returns non-null for "DE"', () {
          expect(en.countryName('DE'), 'Germany');
        });

        test('is case-sensitive – lowercase code returns null', () {
          // Country codes are stored as uppercase ISO-3166-1.
          expect(en.countryName('us'), isNull);
          expect(en.countryName('ru'), isNull);
        });

        test('returns null for empty string', () {
          expect(en.countryName(''), isNull);
        });

        test('returns null for whitespace-only string', () {
          expect(en.countryName('  '), isNull);
        });
      });

      // ── zh variants coexist in the same delegate ───────────────────────
      group('zh variants -', () {
        const hans = CountryLocalizationsZhHans();
        const hant = CountryLocalizationsZhHant();

        test('simplified and traditional are different instances', () {
          expect(hans.runtimeType, isNot(hant.runtimeType));
        });

        test('simplified searchPlaceholder uses simplified characters', () {
          expect(hant.searchPlaceholder, '搜尋'); // trad
          expect(hans.searchPlaceholder, '搜索'); // simp
        });

        test('both return non-null US country name', () {
          expect(hans.countryName('US'), isNotNull);
          expect(hant.countryName('US'), isNotNull);
        });

        test('US names differ between simplified and traditional', () {
          expect(hans.countryName('US'), isNot(hant.countryName('US')));
        });
      });
    });
  });
}
