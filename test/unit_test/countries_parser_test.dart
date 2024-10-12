import 'package:flutter_simple_country_picker/src/controller/countries_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/mocks.dart';

void main() {
  group('CountriesParser -', () {
    group('parse() -', () {
      test('returns correct country by country code', () {
        const countryCode = 'RU';
        final country = CountriesParser.parse(countryCode);
        expect(country.countryCode, countryCode);
        expect(country.name, 'Russia');
      });

      test('throws an error when country code is invalid', () {
        const invalidCode = 'XX';
        expect(() => CountriesParser.parse(invalidCode), throwsArgumentError);
      });
    });

    group('tryParse() -', () {
      test('returns correct country by country code', () {
        const countryCode = 'RU';
        final country = CountriesParser.tryParse(countryCode);
        expect(country?.countryCode, countryCode);
        expect(country?.name, 'Russia');
      });

      test('returns null for invalid country code', () {
        const invalidCode = 'XX';
        final country = CountriesParser.tryParse(invalidCode);
        expect(country, isNull);
      });
    });

    group('parseCountryCode() -', () {
      test('returns correct country by country code', () {
        const countryCode = 'RU';
        final country = CountriesParser.parseCountryCode(countryCode);
        expect(country.countryCode, countryCode);
        expect(country.name, 'Russia');
      });

      test('throws an error when country code is invalid', () {
        const invalidCode = 'XX';
        expect(
          () => CountriesParser.parseCountryCode(invalidCode),
          throwsStateError,
        );
      });
    });

    group('parsePhoneCode() -', () {
      test('returns correct country by phone code', () {
        const phoneCode = '7';
        const e164Key = '7-RU-0';
        final country = CountriesParser.parsePhoneCode(phoneCode, e164Key);
        expect(country.phoneCode, phoneCode);
        expect(country.e164Key, e164Key);
        expect(country.countryCode, 'RU');
      });

      test('throws an error when phone code is invalid', () {
        const invalidPhoneCode = '000';
        const invalidE164Key = '000';
        expect(
          () => CountriesParser.parsePhoneCode(
            invalidPhoneCode,
            invalidE164Key,
          ),
          throwsStateError,
        );
      });
    });

    group('tryParsePhoneCode() -', () {});
    test('returns correct country by phone code', () {
      const phoneCode = '7';
      const e164Key = '7-KZ-0';
      final country = CountriesParser.tryParsePhoneCode(phoneCode, e164Key);
      expect(country?.phoneCode, phoneCode);
      expect(country?.e164Key, e164Key);
    });

    test('returns null for invalid phone code', () {
      const invalidPhoneCode = '000';
      const invalidE164Key = '000';
      final country = CountriesParser.tryParsePhoneCode(
        invalidPhoneCode,
        invalidE164Key,
      );
      expect(country, isNull);
    });

    group('parseCountryName() -', () {
      test(' returns correct country by name in default locale', () {
        const countryName = 'Russia';
        final country = CountriesParser.parseCountryName(
          countryName,
          locales: supportedLocales,
        );
        expect(country.countryCode, 'RU');
        expect(country.name, countryName);
      });

      test('throws an error when country name is invalid', () {
        const invalidCountryName = 'InvalidCountry';
        expect(
          () => CountriesParser.parseCountryName(
            invalidCountryName,
            locales: supportedLocales,
          ),
          throwsArgumentError,
        );
      });
    });

    group('tryParseCountryName() -', () {
      test('returns correct country by name in default locale', () {
        const countryName = 'Russia';
        final country = CountriesParser.tryParseCountryName(countryName);
        expect(country?.countryCode, 'RU');
        expect(country?.name, countryName);
      });

      test('returns null for invalid country name', () {
        const invalidCountryName = 'InvalidCountry';
        final country = CountriesParser.tryParseCountryName(invalidCountryName);
        expect(country, isNull);
      });
    });
  });
}
