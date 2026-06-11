import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryResolver -', () {
    group('normalizeRegionCode() -', () {
      test('maps known aliases to bundled ISO2 codes', () {
        expect(CountryResolver.normalizeRegionCode('AC'), 'SH');
        expect(CountryResolver.normalizeRegionCode('ta'), 'SH');
        expect(CountryResolver.normalizeRegionCode('ic'), 'ES');
      });

      test('returns uppercase code when alias is not needed', () {
        expect(CountryResolver.normalizeRegionCode('ru'), 'RU');
      });
    });

    group('tryFromCountryCode() -', () {
      test('returns bundled country for direct ISO2 code', () {
        final country = CountryResolver.tryFromCountryCode('ru');

        expect(country?.countryCode, 'RU');
        expect(country?.name, 'Russia');
      });

      test('returns bundled country for aliased region code', () {
        final country = CountryResolver.tryFromCountryCode('AC');

        expect(country?.countryCode, 'SH');
      });

      test('returns null for unknown region code', () {
        final country = CountryResolver.tryFromCountryCode('ZZ');

        expect(country, isNull);
      });
    });

    group('fromCountryCode() -', () {
      test('throws for unknown region code', () {
        expect(
          () => CountryResolver.fromCountryCode('ZZ'),
          throwsArgumentError,
        );
      });
    });

    group('tryFromLocale() -', () {
      test('returns bundled country for locale region code', () {
        final country = CountryResolver.tryFromLocale(const Locale('en', 'US'));

        expect(country?.countryCode, 'US');
      });

      test('applies alias normalization to locale region code', () {
        final country = CountryResolver.tryFromLocale(const Locale('en', 'AC'));

        expect(country?.countryCode, 'SH');
      });

      test('returns null when locale has no region code', () {
        final country = CountryResolver.tryFromLocale(const Locale('en'));

        expect(country, isNull);
      });
    });

    group('fromLocale() -', () {
      test('throws when locale has no region code', () {
        expect(
          () => CountryResolver.fromLocale(const Locale('en')),
          throwsArgumentError,
        );
      });
    });
  });

  group('Country locale helpers -', () {
    test('Country.tryFromLocale delegates to resolver behavior', () {
      final country = Country.tryFromLocale(const Locale('en', 'TA'));

      expect(country?.countryCode, 'SH');
    });

    test('Country.fromCountryCode resolves aliases', () {
      final country = Country.fromCountryCode('IC');

      expect(country.countryCode, 'ES');
    });
  });
}
