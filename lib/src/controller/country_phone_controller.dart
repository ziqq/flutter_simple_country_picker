/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 27 January 2026
 */

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart'
    show countries;

/// Country phone controller.
/// This controller is used to manage the phone number with country code.
/// Provides methods to get the full phone number
/// and the phone number without country code.
///
/// Example:
/// ```dart
/// final controller = CountryPhoneController.apply('+7 123 456 78 90');
/// print(controller.phone); // +71234567890
/// print(controller.number); // 1234567890
/// ```
extension type CountryPhoneController._(ValueNotifier<String> _source)
    implements ValueNotifier<String> {
  /// Creates an empty [CountryPhoneController].
  /// This constructor is used to create an empty controller.
  CountryPhoneController.empty() : _source = ValueNotifier<String>('');

  /// Creates a [CountryPhoneController] with the given [phone].
  /// This constructor is used to create a controller
  /// with the provided phone number.
  CountryPhoneController.apply(String phone)
    : _source = ValueNotifier<String>(phone);

  /// Regular expression to remove non-digit characters from phone number.
  static final _nonDigitsRegExp = RegExp('[^0-9]');

  /// Regular expression to remove spaces from phone number.
  static final _regExp = RegExp(r'\s+');

  /// List of unique phone codes from the country codes.
  static final List<String> _phoneCodes = _buildPhoneCodes();

  /// Build a list of unique phone codes from the country codes.
  static List<String> _buildPhoneCodes() {
    final codes = <String>{};
    for (final country in countries) {
      final code = country['e164_cc'];
      if (code case String _ when code.isNotEmpty) codes.add(code);
    }
    final list = codes.toList(growable: false);
    return list..sort((a, b) => b.length.compareTo(a.length));
  }

  /// Return the current phone number with country code.
  /// For example, if the phone number is `+7 123 456 78 90`,
  /// this will return `+71234567890`.
  String get phone => _source.value.replaceAll(_regExp, '');

  /// Return the current country ISO2 code from the phone number.
  /// For example, if the phone number is `+7 123 456 78 90`,
  /// this will return `RU`.
  String get countryCode {
    final e164 = _toE164Digits(phone);
    if (e164.isEmpty) return '';

    final callingCode = _extractCallingCode(e164);
    if (callingCode.isEmpty) return '';

    final national = e164.substring(callingCode.length);

    String? bestIso2;
    var bestPrefix = -1;

    // Higher `level` in this dataset is a more specific region/territory.
    var bestLevel = -1;

    for (final country in countries) {
      final cc = country['e164_cc']?.toString();
      if (cc != callingCode) continue;

      final iso2 = country['iso2_cc']?.toString();
      if (iso2 == null || iso2.isEmpty) continue;

      final example = country['example']?.toString() ?? '';
      final exampleDigits = example.replaceAll(_nonDigitsRegExp, '');

      final prefix = exampleDigits.isEmpty
          ? 0
          : _commonPrefixLength(national, exampleDigits);

      final level = switch (country['level']) {
        int v => v,
        String s => int.tryParse(s) ?? -1,
        _ => -1,
      };

      final isBetter =
          prefix > bestPrefix ||
          (prefix == bestPrefix && level > bestLevel) ||
          (prefix == bestPrefix &&
              level == bestLevel &&
              iso2.compareTo(bestIso2 ?? '\uffff') < 0);

      if (isBetter) {
        bestPrefix = prefix;
        bestLevel = level;
        bestIso2 = iso2;
      }
    }

    return bestIso2?.toUpperCase() ?? '';
  }

  /// Return the current country code from the phone number (without `+`).
  /// For example, if the phone number is `+7 123 456 78 90`,
  /// this will return `7`.
  String get phoneCode {
    final e164 = _toE164Digits(phone);
    if (e164.isEmpty) return '';

    for (final code in _phoneCodes) {
      if (e164.startsWith(code) && e164.length > code.length) return code;
    }

    return '';
  }

  /// Return the current phone number without country code.
  /// For example, `+7 123 456 78 90` -> `1234567890`.
  String get number {
    final e164 = _toE164Digits(phone);
    if (e164.isEmpty) return '';

    final code = phoneCode;
    if (code.isEmpty) return e164;

    return e164.startsWith(code) ? e164.substring(code.length) : e164;
  }

  static int _commonPrefixLength(String a, String b) {
    final max = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < max; i++) {
      if (a.codeUnitAt(i) != b.codeUnitAt(i)) return i;
    }
    return max;
  }

  static String _extractCallingCode(String e164) {
    if (e164.isEmpty) return '';
    for (final code in _phoneCodes) {
      if (e164.startsWith(code) && e164.length > code.length) return code;
    }
    return '';
  }

  static String _toE164Digits(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    final noSpaces = trimmed.replaceAll(_regExp, '');
    final withoutPlus = noSpaces.startsWith('+')
        ? noSpaces.substring(1)
        : noSpaces;

    return withoutPlus.replaceAll(_nonDigitsRegExp, '');
  }
}
