import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_code/country_codes.dart';
import 'package:flutter_simple_country_picker/src/controller/countries_parser.dart';
import 'package:flutter_simple_country_picker/src/util/countries_util.dart';
import 'package:meta/meta.dart';

/// {@template country}
/// The country Model that has all the country
/// information needed from the [flutter_simple_country_picker]
/// {@endtemplate}
@immutable
class Country {
  /// {@macro country}
  const Country({
    required this.phoneCode,
    required this.countryCode,
    required this.e164Sc,
    required this.geographic,
    required this.level,
    required this.name,
    required this.example,
    required this.displayName,
    required this.displayNameNoCountryCode,
    required this.e164Key,
    this.nameLocalized = '',
    this.fullExampleWithPlusSign,
    this.mask,
  });

  /// Create a `RU` country.
  factory Country.ru() =>
      Country.fromJson(countries.firstWhere((c) => c['e164_key'] == '7-RU-0'));

  /// Create a `United States` country.
  factory Country.us() =>
      Country.fromJson(countries.firstWhere((c) => c['e164_key'] == '1-US-0'));

  /// Create a country from a JSON object
  Country.fromJson(Map<String, Object?> json)
      : phoneCode = json['e164_cc'] as String,
        countryCode = json['iso2_cc'] as String,
        e164Sc = json['e164_sc'] as int,
        geographic = json['geographic'] as bool,
        level = json['level'] as int,
        name = json['name'] as String,
        nameLocalized = '',
        example = json['example'] as String,
        displayName = json['display_name'] as String,
        fullExampleWithPlusSign =
            json['full_example_with_plus_sign'] as String?,
        mask = json['mask'] as String?,
        displayNameNoCountryCode = json['display_name_no_e164_cc'] as String,
        e164Key = json['e164_key'] as String;

  /// The world wide country
  static const Country worldWide = Country(
    phoneCode: '',
    countryCode: 'WW',
    e164Sc: -1,
    geographic: false,
    level: -1,
    name: 'World Wide',
    example: '',
    displayName: 'World Wide (WW)',
    displayNameNoCountryCode: 'World Wide',
    e164Key: '',
  );

  /// The country phone code
  final String phoneCode;

  /// The country code, ISO (alpha-2)
  final String countryCode;

  /// The country e164Sc
  final int e164Sc;

  /// Is geographic?
  final bool geographic;

  /// The country level
  final int level;

  /// The country phone mask, whitout [countryCode]
  final String? mask;

  /// The country name in English
  final String name;

  /// The country name localized
  final String? nameLocalized;

  /// An example of a telephone number without the phone code
  final String example;

  /// Country name (country code) [phone code]
  final String displayName;

  /// An example of a telephone number with the phone code and plus sign
  final String? fullExampleWithPlusSign;

  /// Country name (country code)
  final String displayNameNoCountryCode;

  /// The country e164 key
  final String e164Key;

  /// Get the country name localized
  String? getTranslatedName(BuildContext context) =>
      CountriesLocalization.of(context).getCountryNameByCode(countryCode);

  /// Check if the country starts with a query
  bool startsWith(String query, CountriesLocalization? localization) {
    var $query = query.toLowerCase();
    if (query.startsWith('+')) $query = query.replaceAll('+', '').trim();
    return phoneCode.startsWith($query) ||
        name.toLowerCase().startsWith($query) ||
        countryCode.toLowerCase().startsWith($query) ||
        (localization
                ?.getCountryNameByCode(countryCode)
                ?.toLowerCase()
                .startsWith($query) ??
            false);
  }

  /// Copy the country with new values
  @useResult
  Country copyWith({
    String? phoneCode,
    String? countryCode,
    int? e164Sc,
    String? e164Key,
    bool? geographic,
    int? level,
    String? displayName,
    String? displayNameNoCountryCode,
    String? example,
    String? fullExampleWithPlusSign,
    String? mask,
    String? name,
    String? nameLocalized,
  }) =>
      Country(
        phoneCode: phoneCode ?? this.phoneCode,
        countryCode: countryCode ?? this.countryCode,
        e164Sc: e164Sc ?? this.e164Sc,
        e164Key: e164Key ?? this.e164Key,
        geographic: geographic ?? this.geographic,
        level: level ?? this.level,
        displayName: displayName ?? this.displayName,
        displayNameNoCountryCode:
            displayNameNoCountryCode ?? this.displayNameNoCountryCode,
        example: example ?? this.example,
        fullExampleWithPlusSign:
            fullExampleWithPlusSign ?? this.fullExampleWithPlusSign,
        mask: mask ?? this.mask,
        name: name ?? this.name,
        nameLocalized: nameLocalized ?? this.nameLocalized,
      );

  /// Parse a country from a string
  @useResult
  static Country parse(String country) {
    if (country == worldWide.countryCode) {
      return worldWide;
    } else {
      return CountriesParser.parse(country);
    }
  }

  /// Try to parse a country from a string
  @useResult
  static Country? tryParse(String country) {
    if (country == worldWide.countryCode) {
      return worldWide;
    } else {
      return CountriesParser.tryParse(country);
    }
  }

  /// Convert the country to a JSON object
  Map<String, Object?> toJson() {
    final data = <String, Object?>{};
    data['e164_cc'] = phoneCode;
    data['iso2_cc'] = countryCode;
    data['e164_sc'] = e164Sc;
    data['geographic'] = geographic;
    data['level'] = level;
    data['name'] = name;
    data['example'] = example;
    data['display_name'] = displayName;
    data['full_example_with_plus_sign'] = fullExampleWithPlusSign;
    data['display_name_no_e164_cc'] = displayNameNoCountryCode;
    data['e164_key'] = e164Key;
    return data;
  }

  /// Check to world wide
  bool get iswWorldWide => countryCode == Country.worldWide.countryCode;

  @override
  String toString() {
    final buffer = StringBuffer('Country{')
      ..write('countryCode: $countryCode, ')
      ..write('phoneCode: $phoneCode, ')
      ..write('name: $name, ')
      ..write('nameLocalized: $nameLocalized, ')
      ..write('mask: $mask, ')
      ..write('fullExampleWithPlusSign: $fullExampleWithPlusSign')
      ..write('}');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country &&
        other.countryCode == countryCode &&
        other.phoneCode == phoneCode;
  }

  @override
  int get hashCode => countryCode.hashCode ^ phoneCode.hashCode;

  /// provides country flag as emoji.
  /// Can be displayed using
  ///
  ///```dart
  /// Text(country.flagEmoji)
  /// ```
  String get flagEmoji => CountriesUtil.countryCodeToEmoji(countryCode);
}
