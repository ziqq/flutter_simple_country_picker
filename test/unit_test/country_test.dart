import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('Country -', () {
      final countryJson = {
        'e164_cc': '1',
        'iso2_cc': 'US',
        'e164_sc': 1,
        'geographic': true,
        'level': 1,
        'name': 'United States',
        'example': '2012345678',
        'display_name': 'United States (US) [1]',
        'display_name_no_e164_cc': 'United States',
        'e164_key': 'us',
      };

      test('should create Country from JSON', () {
        final country = Country.fromJson(countryJson);

        expect(country.phoneCode, '1');
        expect(country.countryCode, 'US');
        expect(country.e164Sc, 1);
        expect(country.geographic, true);
        expect(country.level, 1);
        expect(country.name, 'United States');
        expect(country.example, '2012345678');
        expect(country.displayName, 'United States (US) [1]');
        expect(country.displayNameNoCountryCode, 'United States');
        expect(country.e164Key, 'us');
      });

      test('should return flag emoji for country', () {
        final country = Country.ru();
        expect(country.flagEmoji, isNotNull);
      });

      test('should copy with same values', () {
        final country = Country.ru();
        final copiedCountry = country.copyWith();

        expect(copiedCountry.name, copiedCountry.name);
        expect(copiedCountry.countryCode, copiedCountry.countryCode);
      });

      test('toString should return formatted country details', () {
        final country = Country.fromJson(countryJson);
        expect(
          country.toString(),
          'Country{'
          'countryCode: US, '
          'phoneCode: 1, '
          'name: United States, '
          'nameLocalized: , '
          'mask: null, '
          'fullExampleWithPlusSign: null}',
        );
      });

      test('hashCode should be consistent for identical country codes', () {
        final country1 = Country.fromJson(countryJson);
        final country2 = Country.fromJson(countryJson);
        expect(country1.hashCode, equals(country2.hashCode));
      });

      test('iswWorldWide should be true for worldwide country code', () {
        expect(Country.worldWide.iswWorldWide, isTrue);
      });

      test('toJson should serialize to JSON object', () {
        final country = Country.fromJson(countryJson);
        final json = country.toJson();
        expect(json['e164_cc'], '1');
        expect(json['iso2_cc'], 'US');
        expect(json['e164_sc'], 1);
        expect(json['geographic'], true);
        expect(json['level'], 1);
        expect(json['name'], 'United States');
        expect(json['display_name'], 'United States (US) [1]');
        expect(json['display_name_no_e164_cc'], 'United States');
        expect(json['e164_key'], 'us');
      });

      test('parse should return correct Country object', () {
        final country = Country.parse('US');
        expect(country.countryCode, 'US');
        expect(country.name, 'United States');
      });

      test('tryParse should return null for invalid country code', () {
        final country = Country.tryParse('ZZ');
        expect(country, isNull);
      });
    });
