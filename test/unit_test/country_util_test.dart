import 'package:flutter_simple_country_picker/src/util/country_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryUtil -', () {
    group('countryCodeToEmoji() -', () {
      test('should convert valid uppercase country codes to emoji flags', () {
        expect(CountryUtil.countryCodeToEmoji('US'), '🇺🇸');
        expect(CountryUtil.countryCodeToEmoji('GB'), '🇬🇧');
        expect(CountryUtil.countryCodeToEmoji('DE'), '🇩🇪');
        expect(CountryUtil.countryCodeToEmoji('FR'), '🇫🇷');
        expect(CountryUtil.countryCodeToEmoji('JP'), '🇯🇵');
      });

      test('should convert valid lowercase country codes to emoji flags', () {
        expect(CountryUtil.countryCodeToEmoji('us'), '🇺🇸');
        expect(CountryUtil.countryCodeToEmoji('gb'), '🇬🇧');
        expect(CountryUtil.countryCodeToEmoji('de'), '🇩🇪');
        expect(CountryUtil.countryCodeToEmoji('fr'), '🇫🇷');
        expect(CountryUtil.countryCodeToEmoji('jp'), '🇯🇵');
      });

      test('should handle mixed case country codes', () {
        expect(CountryUtil.countryCodeToEmoji('Us'), '🇺🇸');
        expect(CountryUtil.countryCodeToEmoji('gB'), '🇬🇧');
      });

      test('should throw ArgumentError for empty string', () {
        expect(() => CountryUtil.countryCodeToEmoji(''), throwsArgumentError);
      });

      test('should throw ArgumentError for single character input', () {
        expect(() => CountryUtil.countryCodeToEmoji('U'), throwsArgumentError);
      });

      test('should throw ArgumentError for input longer than 2 characters', () {
        expect(
          () => CountryUtil.countryCodeToEmoji('USA'),
          throwsArgumentError,
        );
        expect(
          () => CountryUtil.countryCodeToEmoji('GBR'),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for non-alphabetic characters', () {
        expect(() => CountryUtil.countryCodeToEmoji('1A'), throwsArgumentError);
        expect(() => CountryUtil.countryCodeToEmoji('@#'), throwsArgumentError);
        expect(() => CountryUtil.countryCodeToEmoji('A#'), throwsArgumentError);
      });

      test('should throw ArgumentError for non-ASCII characters', () {
        expect(() => CountryUtil.countryCodeToEmoji('ÜÖ'), throwsArgumentError);
      });

      test('should throw ArgumentError for invalid inputs', () {
        expect(() => CountryUtil.countryCodeToEmoji(''), throwsArgumentError);
        expect(() => CountryUtil.countryCodeToEmoji('U'), throwsArgumentError);
        expect(
          () => CountryUtil.countryCodeToEmoji('USA'),
          throwsArgumentError,
        );
        expect(() => CountryUtil.countryCodeToEmoji('1A'), throwsArgumentError);
        expect(() => CountryUtil.countryCodeToEmoji('@#'), throwsArgumentError);
      });
    });
  });
}
