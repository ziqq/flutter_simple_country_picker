import 'package:flutter/widgets.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeCountryLocalizations extends CountryLocalizations {
  const _FakeCountryLocalizations();

  @override
  String get cancelButton => 'Cancel';

  @override
  String? countryName(String countryCode) => switch (countryCode) {
    'RU' => 'Rossiya',
    'SH' => 'Saint Helena',
    _ => null,
  };

  @override
  String? getCountryNameByCode(String countryCode) => countryName(countryCode);

  @override
  String get phonePlaceholder => 'Phone';

  @override
  String get searchPlaceholder => 'Search';

  @override
  String get selectCountryLabel => 'Select';
}

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

  test('parse should return worldwide country for WW', () {
    final country = Country.parse('WW');
    expect(country, same(Country.worldWide));
  });

  test('tryParse should return worldwide country for WW', () {
    final country = Country.tryParse('WW');
    expect(country, same(Country.worldWide));
  });

  test('fromJson should handle string-backed numeric and boolean values', () {
    final country = Country.fromJson(const {
      'e164_cc': '999',
      'iso2_cc': 'ZZ',
      'e164_sc': '12',
      'geographic': 'true',
      'level': '3',
      'name': 'Zedland',
      'example': '123456',
      'display_name': 'Zedland (ZZ) [+999]',
      'display_name_no_e164_cc': 'Zedland (ZZ)',
      'full_example_with_plus_sign': '+999123456',
      'e164_key': '999-ZZ-0',
    });

    expect(country.e164Sc, 12);
    expect(country.geographic, isTrue);
    expect(country.level, 3);
  });

  test('fromJson should handle double and fallback values', () {
    final country = Country.fromJson(const {
      'e164_cc': '998',
      'iso2_cc': 'ZY',
      'e164_sc': 8.0,
      'geographic': Object(),
      'level': Object(),
      'name': 'Fallbackia',
      'mask': null,
      'example': '654321',
      'display_name': 'Fallbackia (ZY) [+998]',
      'display_name_no_e164_cc': 'Fallbackia (ZY)',
      'full_example_with_plus_sign': null,
      'e164_key': '998-ZY-0',
    });

    expect(country.e164Sc, 8);
    expect(country.geographic, isFalse);
    expect(country.level, 0);
    expect(country.mask, isNull);
    expect(country.fullExampleWithPlusSign, isNull);
  });

  test('fromJson should fallback e164Sc to zero for unsupported values', () {
    final country = Country.fromJson(const {
      'e164_cc': '997',
      'iso2_cc': 'ZX',
      'e164_sc': Object(),
      'geographic': true,
      'level': 1,
      'name': 'Fallback E164',
      'example': '777777',
      'display_name': 'Fallback E164 (ZX) [+997]',
      'display_name_no_e164_cc': 'Fallback E164 (ZX)',
      'e164_key': '997-ZX-0',
    });

    expect(country.e164Sc, 0);
  });

  test(
    'startsWith should match phone code, name, country code and localization',
    () {
      final country = Country.ru();
      const localization = _FakeCountryLocalizations();

      expect(country.startsWith('+7', localization), isTrue);
      expect(country.startsWith('rus', localization), isTrue);
      expect(country.startsWith('ru', localization), isTrue);
      expect(country.startsWith('rossiya', localization), isTrue);
      expect(country.startsWith('nomatch', localization), isFalse);
      expect(country.startsWith('rossiya', null), isFalse);
    },
  );

  test('copyWith should override all supported fields', () {
    final updated = original.copyWith(
      phoneCode: '44',
      countryCode: 'GB',
      e164Sc: 9,
      e164Key: '44-GB-0',
      geographic: false,
      level: 7,
      displayName: 'United Kingdom (GB) [+44]',
      displayNameNoCountryCode: 'United Kingdom (GB)',
      example: '7911123456',
      fullExampleWithPlusSign: '+447911123456',
      mask: '0000 000000',
      name: 'United Kingdom',
      nameLocalized: 'Britain',
    );

    expect(updated.phoneCode, '44');
    expect(updated.countryCode, 'GB');
    expect(updated.e164Sc, 9);
    expect(updated.e164Key, '44-GB-0');
    expect(updated.geographic, isFalse);
    expect(updated.level, 7);
    expect(updated.displayName, 'United Kingdom (GB) [+44]');
    expect(updated.displayNameNoCountryCode, 'United Kingdom (GB)');
    expect(updated.example, '7911123456');
    expect(updated.fullExampleWithPlusSign, '+447911123456');
    expect(updated.mask, '0000 000000');
    expect(updated.name, 'United Kingdom');
    expect(updated.nameLocalized, 'Britain');
  });

  test('fromLocaleOrNull should return null without region code', () {
    expect(Country.fromLocaleOrNull(const Locale('en')), isNull);
  });

  test('fromLocaleOrNull should resolve aliases from locale region codes', () {
    final country = Country.fromLocaleOrNull(const Locale('en', 'AC'));
    expect(country?.countryCode, 'SH');
  });

  test('fromLocale should resolve locale region codes', () {
    final country = Country.fromLocale(const Locale('en', 'US'));
    expect(country.countryCode, 'US');
  });

  test('fromLocale should throw without region code', () {
    expect(() => Country.fromLocale(const Locale('en')), throwsArgumentError);
  });

  test(
    'fromCountryCodeOrNull should support empty, worldwide, alias and direct codes',
    () {
      expect(Country.fromCountryCodeOrNull('   '), isNull);
      expect(Country.fromCountryCodeOrNull('WW'), same(Country.worldWide));
      expect(Country.fromCountryCodeOrNull('IC')?.countryCode, 'ES');
      expect(Country.fromCountryCodeOrNull('US')?.countryCode, 'US');
      expect(Country.fromCountryCodeOrNull('ZZ'), isNull);
    },
  );

  test('fromCountryCode should support aliases and throw on invalid input', () {
    expect(Country.fromCountryCode('TA').countryCode, 'SH');
    expect(Country.fromCountryCode('WW'), same(Country.worldWide));
    expect(() => Country.fromCountryCode('   '), throwsArgumentError);
    expect(() => Country.fromCountryCode('ZZ'), throwsArgumentError);
  });

  test('normalizeRegionCode should trim, uppercase and map aliases', () {
    expect(Country.normalizeRegionCode(' ac '), 'SH');
    expect(Country.normalizeRegionCode('ru'), 'RU');
    expect(Country.normalizeRegionCode('   '), '');
  });

  test('operator == should compare country and phone codes', () {
    final sameValue = Country.fromJson(countryJson);
    final different = Country.ru();

    expect(original == original, isTrue);
    expect(original == sameValue, isTrue);
    expect(original == different, isFalse);
    expect(original == Object(), isFalse);
  });
});
