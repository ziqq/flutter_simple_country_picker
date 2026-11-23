import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() => group('CountryScope -', () {
  testWidgets('changing the filter refreshes the existing controller', (
    tester,
  ) async {
    const child = _CountryName();
    Future<void> show(String code) => tester.pumpWidget(
      createWidgetUnderTest(
        locale: const Locale('en'),
        builder: (_) => CountryScope(filter: [code], child: child),
      ),
    );
    await show('RU');
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(_CountryName));
    final controller = CountryScope.of(context);
    expect(controller.state.countries.single.countryCode, 'RU');

    await show('US');
    await tester.pumpAndSettle();
    expect(CountryScope.of(context), same(controller));
    expect(CountryScope.countriesOf(context).single.countryCode, 'US');
  });

  testWidgets('scope listeners receive newly localized country names', (
    tester,
  ) async {
    final locale = ValueNotifier(const Locale('en'));
    addTearDown(locale.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        child: const CountryScope(filter: ['RU'], child: _CountryName()),
        builder: (context, locale, child) => MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ru')],
          localizationsDelegates: const [
            CountryLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Russia'), findsOneWidget);

    locale.value = const Locale('ru');
    await tester.pumpAndSettle();
    expect(find.text('Россия'), findsOneWidget);
  });

  testWidgets('lazy scope waits for an explicit load', (tester) async {
    const childKey = ValueKey<String>('lazy-scope-child');
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => const CountryScope(
          lazy: true,
          filter: ['RU'],
          child: SizedBox(key: childKey),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byKey(childKey));
    expect(CountryScope.countriesOf(context, listen: false), isEmpty);

    final loading = CountryScope.of(context).getCountries();
    await tester.pumpAndSettle();
    await loading;
    expect(CountryScope.countriesOf(context, listen: false), [Country.ru()]);
  });

  testWidgets('should filter countries by name in scope', (tester) async {
    final expectedCountry = Country.fromJson(
      countries[0],
    ).copyWith(countryCode: 'CA', name: 'Canada');
    final expected = countries
        .map(Country.fromJson)
        .firstWhere((e) => e.countryCode == expectedCountry.countryCode);

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => const Scaffold(
          body: CountryScope(showPhoneCode: true, child: SizedBox()),
        ),
      ),
    );

    // Ждем завершения асинхронных операций
    await tester.pumpAndSettle();

    // Получаем контроллер из скоупа
    final context = tester.element(find.byType(SizedBox));
    final controller = CountryScope.of(context);

    // Выполняем поиск
    controller.search?.text = 'Can';
    await tester.pumpAndSettle();

    expect(controller.state.countries, [expected]);
  });

  testWidgets('should return <List<Country>> from countriesOf', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => const Scaffold(
          body: CountryScope(showPhoneCode: true, child: SizedBox()),
        ),
      ),
    );

    // Ждем завершения асинхронных операций
    await tester.pumpAndSettle();

    // Получаем контроллер из скоупа
    final context = tester.element(find.byType(SizedBox));

    expect(CountryScope.countriesOf(context, listen: false), isNotEmpty);
  });

  testWidgets('should return <Country?> from getCountryByCode', (tester) async {
    final index = math.Random().nextInt(countries.length - 1);
    final expectedArr = countries.map(Country.fromJson).toList(growable: false);
    final country = expectedArr[index];
    final code = country.countryCode;

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => const Scaffold(
          body: CountryScope(showPhoneCode: true, child: SizedBox()),
        ),
      ),
    );

    // Ждем завершения асинхронных операций
    await tester.pumpAndSettle();

    // Получаем контроллер из скоупа
    final context = tester.element(find.byType(SizedBox));

    expect(CountryScope.getCountryByCode(context, code), country);
  });

  testWidgets('CountryScope.of throws ArgumentError when no ancestor', (
    tester,
  ) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) {
          capturedContext = context;
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(() => CountryScope.of(capturedContext), throwsArgumentError);
  });

  testWidgets('CountryScope.countriesOf with listen:true subscribes to updates', (
    tester,
  ) async {
    final snapshots = <int>[];

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => CountryScope(
          showPhoneCode: true,
          child: Builder(
            builder: (context) {
              // listen:true uses InheritedModel.inheritFrom (aspect: countries)
              final cs = CountryScope.countriesOf(context);
              snapshots.add(cs.length);
              return const Scaffold(body: SizedBox(key: Key('inner_scope')));
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // After settling the full list should have been loaded.
    expect(snapshots.last, greaterThan(0));
  });

  testWidgets(
    'CountryScope.getCountryByCode with listen:false returns correct country',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => const Scaffold(
            body: CountryScope(showPhoneCode: true, child: SizedBox()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SizedBox));
      // listen:false → _CountryScopeAspect.none (no subscription).
      final country = CountryScope.getCountryByCode(
        context,
        'RU',
        listen: false,
      );
      expect(country, isNotNull);
      expect(country!.countryCode, 'RU');
    },
  );
});

class _CountryName extends StatelessWidget {
  const _CountryName();

  @override
  Widget build(BuildContext context) =>
      Text(CountryScope.countriesOf(context).firstOrNull?.nameLocalized ?? '');
}
