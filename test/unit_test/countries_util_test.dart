import 'package:flutter_simple_country_picker/src/util/countries_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountriesUtil -', () {
    group('countryCodeToEmoji() -', () {
      test('should convert valid uppercase country codes to emoji flags', () {
        expect(CountriesUtil.countryCodeToEmoji('US'), '🇺🇸');
        expect(CountriesUtil.countryCodeToEmoji('GB'), '🇬🇧');
        expect(CountriesUtil.countryCodeToEmoji('DE'), '🇩🇪');
        expect(CountriesUtil.countryCodeToEmoji('FR'), '🇫🇷');
        expect(CountriesUtil.countryCodeToEmoji('JP'), '🇯🇵');
      });

      test('should convert valid lowercase country codes to emoji flags', () {
        expect(CountriesUtil.countryCodeToEmoji('us'), '🇺🇸');
        expect(CountriesUtil.countryCodeToEmoji('gb'), '🇬🇧');
        expect(CountriesUtil.countryCodeToEmoji('de'), '🇩🇪');
        expect(CountriesUtil.countryCodeToEmoji('fr'), '🇫🇷');
        expect(CountriesUtil.countryCodeToEmoji('jp'), '🇯🇵');
      });

      test('should handle mixed case country codes', () {
        expect(CountriesUtil.countryCodeToEmoji('Us'), '🇺🇸');
        expect(CountriesUtil.countryCodeToEmoji('gB'), '🇬🇧');
      });

      test('should throw ArgumentError for empty string', () {
        expect(
          () => CountriesUtil.countryCodeToEmoji(''),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for single character input', () {
        expect(
          () => CountriesUtil.countryCodeToEmoji('U'),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for input longer than 2 characters', () {
        expect(
          () => CountriesUtil.countryCodeToEmoji('USA'),
          throwsArgumentError,
        );
        expect(
          () => CountriesUtil.countryCodeToEmoji('GBR'),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for non-alphabetic characters', () {
        expect(
          () => CountriesUtil.countryCodeToEmoji('1A'),
          throwsArgumentError,
        );
        expect(
          () => CountriesUtil.countryCodeToEmoji('@#'),
          throwsArgumentError,
        );
        expect(
          () => CountriesUtil.countryCodeToEmoji('A#'),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for non-ASCII characters', () {
        expect(
          () => CountriesUtil.countryCodeToEmoji('ÜÖ'),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for invalid inputs', () {
        expect(
          () => CountriesUtil.countryCodeToEmoji(''),
          throwsArgumentError,
        );
        expect(
          () => CountriesUtil.countryCodeToEmoji('U'),
          throwsArgumentError,
        );
        expect(
          () => CountriesUtil.countryCodeToEmoji('USA'),
          throwsArgumentError,
        );
        expect(
          () => CountriesUtil.countryCodeToEmoji('1A'),
          throwsArgumentError,
        );
        expect(
          () => CountriesUtil.countryCodeToEmoji('@#'),
          throwsArgumentError,
        );
      });
    });
  });
}
