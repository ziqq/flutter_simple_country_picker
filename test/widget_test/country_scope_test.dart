import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() {
  group('CountryScope -', () {
    setUp(() {});

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

    testWidgets('should return <List<Country>> from countriesOf', (
      tester,
    ) async {
      final expectedArr = countries
          .map(Country.fromJson)
          .toList(growable: false);

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

      expect(CountryScope.countriesOf(context, listen: false), expectedArr);
    });

    testWidgets('should return <Country?> from getByCountryCode', (
      tester,
    ) async {
      final index = math.Random().nextInt(countries.length - 1);
      final expectedArr = countries
          .map(Country.fromJson)
          .toList(growable: false);
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

      expect(CountryScope.getByCountryCode(context, code), country);
    });
  });
}
