/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

import 'package:flutter/widgets.dart' show BuildContext, Locale;
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart'
    show countries;
import 'package:flutter_simple_country_picker/src/constant/country_region_aliases.dart'
    show countryRegionAliases;
import 'package:flutter_simple_country_picker/src/data/country_parser.dart';
import 'package:flutter_simple_country_picker/src/util/country_util.dart'
    show CountryUtil;
import 'package:meta/meta.dart';

/// {@template country}
/// The country entity that has all the country
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
    : e164Key = json['e164_key'].toString(),
      phoneCode = json['e164_cc'].toString(),
      countryCode = json['iso2_cc'].toString(),
      e164Sc = switch (json['e164_sc']) {
        String vstring => int.tryParse(vstring) ?? 0,
        double vdouble => vdouble.toInt(),
        int vint => vint,
        _ => 0,
      },
      geographic = switch (json['geographic']) {
        String vstring => vstring.toLowerCase() == 'true',
        int vint => vint != 0,
        bool vbool => vbool,
        _ => false,
      },
      level = switch (json['level']) {
        String vstring => int.tryParse(vstring) ?? 0,
        double vdouble => vdouble.toInt(),
        int vint => vint,
        _ => 0,
      },
      nameLocalized = '',
      name = json['name'].toString(),
      mask = json['mask']?.toString(),
      example = json['example'].toString(),
      displayName = json['display_name'].toString(),
      fullExampleWithPlusSign = json['full_example_with_plus_sign']?.toString(),
      displayNameNoCountryCode = json['display_name_no_e164_cc'].toString();

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

  /// The country code, ISO (iso2_cc / alpha-2)
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

  /// Country name (country code)
  final String displayName;

  /// An example of a telephone number with the phone code and plus sign
  final String? fullExampleWithPlusSign;

  /// Country name (country code)
  final String displayNameNoCountryCode;

  /// The country e164 key
  final String e164Key;

  /// Зrovides country flag as emoji.
  /// Can be displayed using:
  ///```dart
  /// Text(country.flagEmoji)
  /// ```
  String get flagEmoji => CountryUtil.countryCodeToEmoji(countryCode);

  /// Check to world wide
  bool get iswWorldWide => countryCode == Country.worldWide.countryCode;

  /// Get the localized country name
  String? getTranslatedName(BuildContext context) =>
      CountryLocalizations.of(context).getCountryNameByCode(countryCode);

  /// Check if the country starts with a query
  bool startsWith(String query, CountryLocalizations? localization) {
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
  }) => Country(
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
      return CountryParser.parse(country);
    }
  }

  /// Try to parse a country from a string
  @useResult
  static Country? tryParse(String country) {
    if (country == worldWide.countryCode) {
      return worldWide;
    } else {
      return CountryParser.tryParse(country);
    }
  }

  /// Resolves a country from [locale], or returns `null` when it has no region
  /// code or the normalized region is not present in the bundled dataset.
  @useResult
  static Country? tryFromLocale(Locale locale) {
    final countryCode = locale.countryCode;
    if (countryCode == null || countryCode.trim().isEmpty) {
      return null;
    }
    return tryFromCountryCode(countryCode);
  }

  /// Resolves a country from [locale].
  ///
  /// Throws an [ArgumentError] when [locale] has no region code or when the
  /// normalized region is not present in the bundled dataset.
  @useResult
  static Country fromLocale(Locale locale) {
    final countryCode = locale.countryCode;
    if (countryCode == null || countryCode.trim().isEmpty) {
      throw ArgumentError.value(
        locale,
        'locale',
        'Locale.countryCode cannot be null or empty.',
      );
    }
    return fromCountryCode(countryCode);
  }

  /// Resolves a country from [countryCode], applying bundled region aliases.
  @useResult
  static Country? tryFromCountryCode(String countryCode) {
    final normalized = normalizeRegionCode(countryCode);
    if (normalized.isEmpty) return null;
    if (normalized == worldWide.countryCode) return worldWide;
    return CountryParser.tryParseCountryCode(normalized);
  }

  /// Resolves a country from [countryCode], applying bundled region aliases.
  ///
  /// Throws an [ArgumentError] when the normalized code is not present in the
  /// bundled dataset.
  @useResult
  static Country fromCountryCode(String countryCode) {
    final normalized = normalizeRegionCode(countryCode);
    if (normalized.isEmpty) {
      throw ArgumentError.value(
        countryCode,
        'countryCode',
        'countryCode cannot be empty.',
      );
    }
    if (normalized == worldWide.countryCode) return worldWide;

    final country = CountryParser.tryParseCountryCode(normalized);
    if (country != null) return country;

    throw ArgumentError.value(
      countryCode,
      'countryCode',
      'No bundled country found for the normalized region code $normalized.',
    );
  }

  /// Normalizes [countryCode] to the ISO2 region code used by the bundled
  /// dataset.
  @useResult
  static String normalizeRegionCode(String countryCode) {
    final normalized = countryCode.trim().toUpperCase();
    if (normalized.isEmpty) return normalized;
    return countryRegionAliases[normalized] ?? normalized;
  }

  /// Convert the country to a JSON object
  Map<String, Object?> toJson() {
    final data = <String, Object?>{};
    data['iso2_cc'] = countryCode;
    data['e164_cc'] = phoneCode;
    data['e164_key'] = e164Key;
    data['e164_sc'] = e164Sc;
    data['geographic'] = geographic;
    data['level'] = level;
    data['name'] = name;
    data['mask'] = mask;
    data['example'] = example;
    data['display_name'] = displayName;
    data['full_example_with_plus_sign'] = fullExampleWithPlusSign;
    data['display_name_no_e164_cc'] = displayNameNoCountryCode;
    return data;
  }

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
}
