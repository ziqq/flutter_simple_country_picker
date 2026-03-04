import 'package:flutter/widgets.dart';
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
// Helpers
// ---------------------------------------------------------------------------

/// Builds a bare [Localizations] widget that only registers
/// [CountryLocalizations.delegate], avoiding Material/Cupertino locale
/// warnings for exotic locales (ku, nn, ht, …) that those delegates do not
/// support.
Widget _app({required Locale locale, required WidgetBuilder builder}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: Localizations(
        locale: locale,
        delegates: const [
          CountryLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Builder(builder: builder),
      ),
    );

/// Pumps a widget tree and captures [CountryLocalizations.of(context)].
Future<CountryLocalizations> _pump(WidgetTester tester, Locale locale) async {
  late CountryLocalizations captured;
  await tester.pumpWidget(
    _app(
      locale: locale,
      builder: (ctx) {
        captured = CountryLocalizations.of(ctx);
        return const SizedBox.shrink();
      },
    ),
  );
  await tester.pumpAndSettle();
  return captured;
}

Locale _l(String lang) => Locale(lang);
Locale _lScript(String lang, String script) =>
    Locale.fromSubtags(languageCode: lang, scriptCode: script);

void main() {
  group('CountryLocalizations.of -', () {
    // ── Fallback behaviour ─────────────────────────────────────────────────
    group('fallback -', () {
      testWidgets(
        'returns CountryLocalizationsEn when no delegate is registered',
        (tester) async {
          late CountryLocalizations loc;
          await tester.pumpWidget(
            // Bare Localizations widget with NO CountryLocalizations delegate
            // → of() should fall back to the English default.
            Directionality(
              textDirection: TextDirection.ltr,
              child: Localizations(
                locale: const Locale('en'),
                delegates: const [DefaultWidgetsLocalizations.delegate],
                child: Builder(
                  builder: (ctx) {
                    loc = CountryLocalizations.of(ctx);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(loc, isA<CountryLocalizationsEn>());
        },
      );

      testWidgets('returns CountryLocalizationsEn for unsupported locale', (
        tester,
      ) async {
        final loc = await _pump(tester, _l('xx'));
        expect(loc, isA<CountryLocalizationsEn>());
      });

      testWidgets('English fallback provides correct UI strings', (
        tester,
      ) async {
        final loc = await _pump(tester, _l('xx'));
        expect(loc.cancelButton, 'Cancel');
        expect(loc.searchPlaceholder, 'Search');
      });
    });

    // ── All supported locales ──────────────────────────────────────────────
    group('returns correct subclass for each locale -', () {
      final cases = <(Locale, Type)>[
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

      for (final (locale, expectedType) in cases) {
        testWidgets('of($locale) returns $expectedType', (tester) async {
          final loc = await _pump(tester, locale);
          expect(loc.runtimeType, expectedType);
        });
      }
    });

    // ── zh script variants ─────────────────────────────────────────────────
    group('zh script variants -', () {
      testWidgets('zh-Hant returns ZhHant', (tester) async {
        final loc = await _pump(tester, _lScript('zh', 'Hant'));
        expect(loc, isA<CountryLocalizationsZhHant>());
      });

      testWidgets('zh-Hans returns ZhHans', (tester) async {
        final loc = await _pump(tester, _lScript('zh', 'Hans'));
        expect(loc, isA<CountryLocalizationsZhHans>());
      });

      testWidgets('zh without script defaults to ZhHans', (tester) async {
        final loc = await _pump(tester, _l('zh'));
        expect(loc, isA<CountryLocalizationsZhHans>());
      });

      testWidgets('Hant and Hans have different selectCountryLabel', (
        tester,
      ) async {
        final hans = await _pump(tester, _lScript('zh', 'Hans'));
        final hant = await _pump(tester, _lScript('zh', 'Hant'));
        expect(hans.selectCountryLabel, isNot(hant.selectCountryLabel));
      });
    });

    // ── Content correctness ────────────────────────────────────────────────
    group('content correctness -', () {
      testWidgets('ru locale provides Russian UI strings', (tester) async {
        final loc = await _pump(tester, _l('ru'));
        expect(loc.cancelButton, 'Отмена');
        expect(loc.searchPlaceholder, 'Поиск');
        expect(loc.selectCountryLabel, 'Выберите страну');
        expect(loc.phonePlaceholder, 'Номер телефона');
      });

      testWidgets('de locale provides German UI strings', (tester) async {
        final loc = await _pump(tester, _l('de'));
        expect(loc.cancelButton, 'Abbrechen');
        expect(loc.searchPlaceholder, 'Suche');
      });

      testWidgets('ar locale provides Arabic UI strings', (tester) async {
        final loc = await _pump(tester, _l('ar'));
        expect(loc.cancelButton, 'إلغاء');
        expect(loc.searchPlaceholder, 'بحث');
      });

      testWidgets('ru locale returns correct country name for RU', (
        tester,
      ) async {
        final loc = await _pump(tester, _l('ru'));
        expect(loc.countryName('RU'), 'Россия');
      });

      testWidgets('en locale returns correct country name for US', (
        tester,
      ) async {
        final loc = await _pump(tester, _l('en'));
        expect(loc.countryName('US'), 'United States');
      });

      testWidgets(
        'of() returns instance with non-empty UI strings for all locales',
        (tester) async {
          for (final locale in CountryLocalizations.supportedLocales) {
            final loc = await _pump(tester, locale);
            expect(
              loc.cancelButton,
              isNotEmpty,
              reason: '${locale.toLanguageTag()} cancelButton is empty',
            );
            expect(
              loc.searchPlaceholder,
              isNotEmpty,
              reason: '${locale.toLanguageTag()} searchPlaceholder is empty',
            );
            expect(
              loc.selectCountryLabel,
              isNotEmpty,
              reason: '${locale.toLanguageTag()} selectCountryLabel is empty',
            );
            expect(
              loc.phonePlaceholder,
              isNotEmpty,
              reason: '${locale.toLanguageTag()} phonePlaceholder is empty',
            );
          }
        },
      );

      testWidgets(
        'of() returns instance where countryName("US") is non-null for all locales',
        (tester) async {
          for (final locale in CountryLocalizations.supportedLocales) {
            final loc = await _pump(tester, locale);
            expect(
              loc.countryName('US'),
              isNotNull,
              reason: '${locale.toLanguageTag()} missing US country name',
            );
          }
        },
      );
    });

    // ── Multiple calls consistency ─────────────────────────────────────────
    group('multiple calls -', () {
      testWidgets('calling of() twice in the same context returns same type', (
        tester,
      ) async {
        late CountryLocalizations loc1;
        late CountryLocalizations loc2;
        await tester.pumpWidget(
          _app(
            locale: _l('ru'),
            builder: (ctx) {
              loc1 = CountryLocalizations.of(ctx);
              loc2 = CountryLocalizations.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(loc1.runtimeType, loc2.runtimeType);
      });
    });
  });
}
