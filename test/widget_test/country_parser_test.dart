import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/country_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/widget_test_helper.dart';

const ValueKey<String> _key = ValueKey<String>('countries_parser');

void main() => group('CountryParser -', () {
  late Widget mockWidget;

  setUpAll(() {
    mockWidget = const Column(
      key: _key,
      children: [Text('Country'), Text('Country Code')],
    );
  });

  tearDownAll(() async {});

  testWidgets('should display selected country based on country name', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(builder: (_) => mockWidget));
    await tester.pumpAndSettle();

    expect(find.byKey(_key), findsOneWidget);

    final context = tester.firstElement(find.byKey(_key));

    // Using CountryParser to parse country by name
    final country = CountryParser.parseCountryName(
      'United States',
      context: context,
      locales: CountryLocalizations.supportedLocales,
    );

    expect(country.name, 'United States');
    expect(country.countryCode, 'US');
  });

  testWidgets('should throw error for invalid country name', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(builder: (_) => mockWidget));
    await tester.pumpAndSettle();

    expect(find.byKey(_key), findsOneWidget);

    final context = tester.firstElement(find.byKey(_key));

    Object? error;
    try {
      CountryParser.parseCountryName('Invalid Country', context: context);
    } on Object catch (err, stackTrace) {
      Error.safeToString(err);
      stackTrace.toString();
      error = err;
    }

    expect(error.toString(), 'Invalid argument: "No country found"');
  });

  testWidgets('should parse country name based on multiple locales', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        locale: const Locale.fromSubtags(languageCode: 'es'),
        builder: (_) => mockWidget,
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.firstElement(find.byKey(_key));

    // Using a list of locales to parse country name
    final country = CountryParser.parseCountryName(
      'Estados Unidos', // Spanish for United States
      context: context,
      locales: [const Locale('es')],
    );

    final nameLocalized = CountryLocalizations.of(context)
        ?.getCountryNameByCode(country.countryCode)
        ?.replaceAll(CountryLocalizations.countryNameRegExp, ' ');

    expect(nameLocalized, 'Estados Unidos');
    expect(country.name, 'United States');
    expect(country.countryCode, 'US');
  });

  testWidgets('should handle null locale and fallback to default (English)', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        locale: const Locale.fromSubtags(languageCode: 'de'),
        builder: (_) => mockWidget,
      ),
    );

    // Null locale should fallback to English
    final country = CountryParser.parseCountryName(
      'Germany',
      locales: null, // No locale provided
    );
    expect(country.name, 'Germany');
    expect(country.countryCode, 'DE');
  });

  testWidgets('should correctly parse country code using parseCountryCode', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        locale: const Locale.fromSubtags(languageCode: 'us'),
        builder: (_) => mockWidget,
      ),
    );

    final country = CountryParser.parseCountryCode('US');
    expect(country.name, 'United States');
    expect(country.countryCode, 'US');
  });

  testWidgets('should handle tryParseCountryCode with invalid code', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(builder: (_) => mockWidget));
    final country = CountryParser.tryParseCountryCode('InvalidCode');
    expect(country, isNull); // should return null for invalid country code
  });
});
