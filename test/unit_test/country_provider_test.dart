import 'package:flutter_simple_country_picker/src/data/country_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryProvider -', () {
    late CountryProvider countriesProvider;

    setUp(() {
      countriesProvider = CountryProvider();
    });

    tearDownAll(() async {});

    group('getCountries() -', () {
      test('returns all countries', () async {
        final countries = await countriesProvider.getCountries();
        expect(countries.length, countries.length);
      });
    });

    group('findByCode() -', () {
      test('returns the correct country for a valid code', () {
        const validCode = 'RU';
        final country = countriesProvider.findByCode(validCode);
        expect(country?.countryCode, validCode);
        expect(country?.name, 'Russia');
      });
    });

    group('findByCode() -', () {
      test('returns null for an invalid code', () {
        const invalidCode = 'XX';
        final country = countriesProvider.findByCode(invalidCode);
        expect(country, isNull);
      });
    });

    group('findByName() -', () {
      test('returns the correct country for a valid name', () {
        const validName = 'Russia';
        final country = countriesProvider.findByName(validName);
        expect(country?.name, validName);
        expect(country?.countryCode, 'RU');
      });

      test('returns null for an invalid name', () {
        const invalidName = 'InvalidCountry';
        final country = countriesProvider.findByName(invalidName);
        expect(country, isNull);
      });
    });

    group('findCountriesByCode() -', () {
      test('returns correct countries for a list of valid codes', () {
        const codes = ['RU', 'KZ'];
        final countries = countriesProvider.findCountriesByCode(codes);
        expect(countries.length, codes.length);
        expect(countries.map((c) => c.countryCode), codes);
      });
    });

    group('findCountriesByCode() -', () {
      test('skips invalid codes', () {
        const codes = ['RU', 'INVALID'];
        final countries = countriesProvider.findCountriesByCode(codes);
        expect(countries.length, 1);
        expect(countries.first.countryCode, 'RU');
      });
    });
  });
}
