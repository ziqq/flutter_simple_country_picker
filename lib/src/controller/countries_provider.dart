import 'package:collection/collection.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/country_codes.dart';

/// {@template countries_provider}
/// CountriesProvider
///
/// This class provides a list of countries.
/// {@endtemplate}
class CountriesProvider {
  /// {@macro countries_provider}
  CountriesProvider()
      : _countries = countryCodes.map(Country.fromJson).toList();

  final List<Country> _countries;

  /// Return list with all countries
  List<Country> getAll() => _countries;

  /// Returns the first country that mach the given code.
  Country? findByCode(String? code) {
    final uppercaseCode = code?.toUpperCase();
    return _countries.firstWhereOrNull((c) => c.countryCode == uppercaseCode);
  }

  /// Returns the first country that mach the given name.
  Country? findByName(String? name) =>
      _countries.firstWhereOrNull((c) => c.name == name);

  /// Returns a list with all the countries that mach the given codes list.
  List<Country> findCountriesByCode(List<String> codes) {
    final $codes = codes.map((c) => c.toUpperCase()).toList();
    final countries = <Country>[];

    for (final code in $codes) {
      final country = findByCode(code);
      if (country != null) {
        countries.add(country);
      }
    }

    return countries;
  }
}

/// List of countries
/// Россия
/// Абхазия
/// Армения
/// Бералусь
/// Кыргызстан
/// ПМР Молдова
/// Таджикистан
/// Узбекистан
/// Другой код старны
final contries = [
  {
    'e164_cc': '7',
    'iso2_cc': 'RU',
    'e164_sc': 0,
    'geographic': true,
    'level': 1,
    'name': 'Russia',
    'example': '9123456789',
    'display_name': 'Russia (RU) [+7]',
    'full_example_with_plus_sign': '+79123456789',
    'display_name_no_e164_cc': 'Russia (RU)',
    'e164_key': '7-RU-0'
  },
  {
    'e164_cc': '7',
    'iso2_cc': 'KZ',
    'e164_sc': 0,
    'geographic': true,
    'level': 2,
    'name': 'Kazakhstan',
    'example': '7710009998',
    'display_name': 'Kazakhstan (KZ) [+7]',
    'mask': null,
    'full_example_with_plus_sign': '+77710009998',
    'display_name_no_e164_cc': 'Kazakhstan (KZ)',
    'e164_key': '7-KZ-0'
  },
  {
    'e164_cc': '374',
    'iso2_cc': 'AM',
    'e164_sc': 0,
    'geographic': true,
    'level': 1,
    'name': 'Armenia',
    'example': '77123456',
    'display_name': 'Armenia (AM) [+374]',
    'mask': '00 000 000',
    'full_example_with_plus_sign': '+37477123456',
    'display_name_no_e164_cc': 'Armenia (AM)',
    'e164_key': '374-AM-0'
  },
  {
    'e164_cc': '375',
    'iso2_cc': 'BY',
    'e164_sc': 0,
    'geographic': true,
    'level': 1,
    'name': 'Belarus',
    'example': '294911911',
    'display_name': 'Belarus (BY) [+375]',
    'mask': '00 000 0000',
    'full_example_with_plus_sign': '+375294911911',
    'display_name_no_e164_cc': 'Belarus (BY)',
    'e164_key': '375-BY-0'
  },
  {
    'e164_cc': '996',
    'iso2_cc': 'KG',
    'e164_sc': 0,
    'geographic': true,
    'level': 1,
    'name': 'Kyrgyzstan',
    'example': '700123456',
    'display_name': 'Kyrgyzstan (KG) [+996]',
    'mask': null,
    'full_example_with_plus_sign': '+996700123456',
    'display_name_no_e164_cc': 'Kyrgyzstan (KG)',
    'e164_key': '996-KG-0'
  },
  {
    'e164_cc': '373',
    'iso2_cc': 'MD',
    'e164_sc': 0,
    'geographic': true,
    'level': 1,
    'name': 'Moldova',
    'example': '65012345',
    'display_name': 'Moldova (MD) [+373]',
    'mask': null,
    'full_example_with_plus_sign': '+37365012345',
    'display_name_no_e164_cc': 'Moldova (MD)',
    'e164_key': '373-MD-0'
  },
  {
    'e164_cc': '992',
    'iso2_cc': 'TJ',
    'e164_sc': 0,
    'geographic': true,
    'level': 1,
    'name': 'Tajikistan',
    'example': '917123456',
    'display_name': 'Tajikistan (TJ) [+992]',
    'mask': '000 000 00',
    'full_example_with_plus_sign': '+992917123456',
    'display_name_no_e164_cc': 'Tajikistan (TJ)',
    'e164_key': '992-TJ-0'
  },
  {
    'e164_cc': '998',
    'iso2_cc': 'UZ',
    'e164_sc': 0,
    'geographic': true,
    'level': 1,
    'name': 'Uzbekistan',
    'example': '912345678',
    'display_name': 'Uzbekistan (UZ) [+998]',
    'mask': '000 000 000',
    'full_example_with_plus_sign': '+998912345678',
    'display_name_no_e164_cc': 'Uzbekistan (UZ)',
    'e164_key': '998-UZ-0'
  }
];
