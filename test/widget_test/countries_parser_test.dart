import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/mocks.dart';
import '../util/widget_test_helper.dart';

const ValueKey<String> _key = ValueKey<String>('countries_parser');

void main() => group('CountriesParser -', () {
      late Widget mockWidget;

      setUpAll(() {
        mockWidget = const Column(
          key: _key,
          children: [Text('Country'), Text('Country Code')],
        );
      });

      tearDownAll(() async {});

      testWidgets('should display selected country based on country name',
          (tester) async {
        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            builder: (_) => mockWidget,
          ),
        );

        expect(find.byKey(_key), findsOneWidget);

        final context = tester.firstElement(find.byKey(_key));

        // Using CountriesParser to parse country by name
        final country = CountriesParser.parseCountryName(
          'United States',
          context: context,
          locales: supportedLocales,
        );

        expect(country.name, 'United States');
        expect(country.countryCode, 'US');
      });

      testWidgets('should throw error for invalid country name',
          (tester) async {
        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            builder: (_) => mockWidget,
          ),
        );

        expect(find.byKey(_key), findsOneWidget);

        final context = tester.firstElement(find.byKey(_key));

        Object? error;
        try {
          CountriesParser.parseCountryName(
            'Invalid Country',
            context: context,
          );
        } on Object catch (err, stackTrace) {
          Error.safeToString(err);
          stackTrace.toString();
          error = err;
        }

        expect(error.toString(), 'Invalid argument: "No country found"');
      });

      testWidgets('should parse country name based on multiple locales',
          (tester) async {
        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            locale: const Locale.fromSubtags(languageCode: 'es'),
            builder: (_) => mockWidget,
          ),
        );

        final context = tester.firstElement(find.byKey(_key));

        // Using a list of locales to parse country name
        final country = CountriesParser.parseCountryName(
          'Estados Unidos', // Spanish for United States
          context: context,
          locales: [const Locale('es')],
        );

        final nameLocalized = CountriesLocalization.of(context)
            .getCountryNameByCode(country.countryCode)
            ?.replaceAll(CountriesLocalization.countryNameRegExp, ' ');

        expect(nameLocalized, 'Estados Unidos');
        expect(country.name, 'United States');
        expect(country.countryCode, 'US');
      });

      testWidgets('should handle null locale and fallback to default (English)',
          (tester) async {
        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            locale: const Locale.fromSubtags(languageCode: 'de'),
            builder: (_) => mockWidget,
          ),
        );

        // Null locale should fallback to English
        final country = CountriesParser.parseCountryName(
          'Germany',
          locales: null, // No locale provided
        );

        expect(country.name, 'Germany');
        expect(country.countryCode, 'DE');
      });

      testWidgets('should correctly parse country code using parseCountryCode',
          (tester) async {
        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            locale: const Locale.fromSubtags(languageCode: 'us'),
            builder: (_) => mockWidget,
          ),
        );

        final country = CountriesParser.parseCountryCode('US');

        expect(country.name, 'United States');
        expect(country.countryCode, 'US');
      });

      testWidgets('should handle tryParseCountryCode with invalid code',
          (tester) async {
        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            builder: (_) => mockWidget,
          ),
        );

        final country = CountriesParser.tryParseCountryCode('InvalidCode');

        expect(country, isNull); // should return null for invalid country code
      });
    });
