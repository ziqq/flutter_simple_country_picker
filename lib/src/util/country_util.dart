/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

import 'package:meta/meta.dart';

/// {@template country_util}
/// CountryUtil class.
///
/// A utility class that provides helper methods for countries.
///
/// Methods:
/// [countryCodeToEmoji] - Convert country code to emoji flag.
/// {@endtemplate}
@internal
abstract final class CountryUtil {
  /// {@macro country_util}
  const CountryUtil._();

  static final _codeRegExp = RegExp(r'^[A-Za-z]{2}$');
  static final _nonDigits = RegExp('[^0-9]');
  static final _leadingPhonePadding = RegExp(
    r'^[\s\u061C\u200E\u200F\u202A-\u202E\u2066-\u2069]+',
  );

  /// Skips leading whitespace, bidirectional controls, and an opening
  /// parenthesis before an explicit plus sign.
  static String trimPhoneInput(String text) {
    final input = text.trimLeft().replaceFirst(_leadingPhonePadding, '');
    if (!input.startsWith('(')) return input;

    final afterParenthesis = input
        .substring(1)
        .trimLeft()
        .replaceFirst(_leadingPhonePadding, '');
    return afterParenthesis.startsWith('+') ? afterParenthesis : input;
  }

  /// Whether [text] specifies an international number outside [callingCode].
  static bool hasForeignCallingCode(String text, String callingCode) {
    if (callingCode.isEmpty) return false;
    final input = trimPhoneInput(text);
    if (!input.startsWith('+') && !input.startsWith('00')) return false;
    final digits = input.replaceAll(_nonDigits, '');
    if (input.startsWith('+')) {
      return digits.isNotEmpty && !digits.startsWith(callingCode);
    }
    return input.startsWith('00') &&
        digits.length > 2 &&
        digits[2] != '0' &&
        !digits.startsWith('00$callingCode');
  }

  /// Convert country code to emoji flag
  static String countryCodeToEmoji(String countryCode) {
    // 0x41 is Letter A
    // 0x1F1E6 is Regional Indicator Symbol Letter A
    // Example :
    // firstLetter U => 20 + 0x1F1E6
    // secondLetter S => 18 + 0x1F1E6
    // See: https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
    if (countryCode.length != 2 || !_codeRegExp.hasMatch(countryCode)) {
      throw ArgumentError(
        'Country code must be exactly two alphabetic characters',
      );
    }

    var code = countryCode.toUpperCase();

    final firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}
