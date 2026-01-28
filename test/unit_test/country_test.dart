import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('Country -', () {
  final original = Country.us();
  final countryJson = original.toJson();

  test('should create Country from JSON', () {
    final country = Country.fromJson(countryJson);
    expect(country.countryCode, original.countryCode);
    expect(country.phoneCode, original.phoneCode);
    expect(country.e164Key, original.e164Key);
    expect(country.e164Sc, original.e164Sc);
    expect(country.geographic, original.geographic);
    expect(country.level, original.level);
    expect(country.name, original.name);
    expect(country.mask, original.mask);
    expect(country.example, original.example);
    expect(country.displayName, original.displayName);
    expect(country.fullExampleWithPlusSign, original.fullExampleWithPlusSign);
    expect(country.displayNameNoCountryCode, original.displayNameNoCountryCode);
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
    expect(country.toString(), original.toString());
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
    expect(json.keys.length, 12);
    expect(json['iso2_cc'], original.countryCode);
    expect(json['e164_cc'], original.phoneCode);
    expect(json['e164_key'], original.e164Key);
    expect(json['e164_sc'], original.e164Sc);
    expect(json['geographic'], original.geographic);
    expect(json['level'], original.level);
    expect(json['name'], original.name);
    expect(json['mask'], original.mask);
    expect(json['example'], original.example);
    expect(json['display_name'], original.displayName);
    expect(json['display_name_no_e164_cc'], original.displayNameNoCountryCode);
    expect(
      json['full_example_with_plus_sign'],
      original.fullExampleWithPlusSign,
    );
  });

  test('parse should return correct Country object', () {
    final country = Country.parse(original.countryCode);
    expect(country.countryCode, original.countryCode);
    expect(country.name, original.name);
  });

  test('tryParse should return null for invalid country code', () {
    final country = Country.tryParse('ZZZZZ');
    expect(country, isNull);
  });
});
