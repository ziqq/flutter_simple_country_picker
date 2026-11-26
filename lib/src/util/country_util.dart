/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

import 'package:meta/meta.dart';

/// {@template country_util}
/// Shared rules for country names, flag emoji, and telephone prefixes.
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

  /// Letters with diacritics, matched by position with [_foldedLetters].
  static const String _accentedLetters =
      'ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéê'
      'ëìíîïñòóôõöùúûüýÿĀāĂăĄąĆćĈĉĊċČčĎďĒēĔ'
      'ĕĖėĘęĚěĜĝĞğĠġĢģĤĥĨĩĪīĬĭĮįİĴĵĶķĹĺĻļĽľ'
      'ŃńŅņŇňŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŨũŪūŬŭ'
      'ŮůŰűŲųŴŵŶŷŸŹźŻżŽžƠơƯưǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛ'
      'ǜǞǟǠǡǢǣǦǧǨǩǪǫǬǭǮǯǰǴǵǸǹǺǻǼǽǾǿȀȁȂȃȄȅȆȇ'
      'ȈȉȊȋȌȍȎȏȐȑȒȓȔȕȖȗȘșȚțȞȟȦȧȨȩȪȫȬȭȮȯȰȱȲȳ'
      'ʹΆΈΉΊΌΎΏΐΪΫάέήίΰϊϋόύώϓϔЁёØøŁłĐđıς';

  /// Base letters for [_accentedLetters].
  static const String _foldedLetters =
      'AAAAAACEEEEIIIINOOOOOUUUUYaaaaaaceee'
      'eiiiinooooouuuuyyAaAaAaCcCcCcCcDdEeE'
      'eEeEeEeGgGgGgGgHhIiIiIiIiIJjKkLlLlLl'
      'NnNnNnOoOoOoRrRrRrSsSsSsSsTtTtUuUuUu'
      'UuUuUuWwYyYZzZzZzOoUuAaIiOoUuUuUuUuU'
      'uAaAaÆæGgKkOoOoƷʒjGgNnAaÆæØøAaAaEeEe'
      'IiIiOoOoRrRrUuUuSsTtHhAaEeOoOoOoOoYy'
      'ʹΑΕΗΙΟΥΩιΙΥαεηιυιυουωϒϒЕеOoLlDdiσ';

  /// Letters that fold into more than one letter.
  static const Map<String, String> _foldedLigatures = <String, String>{
    'ß': 'ss',
    'ẞ': 'SS',
    'Æ': 'AE',
    'æ': 'ae',
    'Œ': 'OE',
    'œ': 'oe',
  };

  /// Rune lookup table for the supported diacritics and ligatures.
  static final Map<int, String> _foldTable = () {
    final accented = _accentedLetters.runes.toList(growable: false);
    final folded = _foldedLetters.runes.toList(growable: false);
    final table = <int, String>{};
    for (var i = 0; i < accented.length; i++) {
      table[accented[i]] = String.fromCharCode(folded[i]);
    }
    for (final MapEntry(:key, :value) in _foldedLigatures.entries) {
      table[key.runes.single] = value;
    }
    return table;
  }();

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

  /// Whether [text] contains only an explicit [callingCode].
  static bool hasOnlyCallingCode(String text, String callingCode) {
    if (callingCode.isEmpty) return false;
    final input = trimPhoneInput(text);
    final digits = input.replaceAll(_nonDigits, '');
    return input.startsWith('+')
        ? digits == callingCode
        : input.startsWith('00') && digits == '00$callingCode';
  }

  /// Converts a two-letter [countryCode] to an emoji flag.
  ///
  /// Throws an [ArgumentError] if the code is not two ASCII letters.
  static String countryCodeToEmoji(String countryCode) {
    if (countryCode.length != 2 || !_codeRegExp.hasMatch(countryCode)) {
      throw ArgumentError(
        'Country code must be exactly two alphabetic characters',
      );
    }

    final code = countryCode.toUpperCase();

    // Map ASCII A–Z to the matching Unicode regional indicator symbols.
    final firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  /// Removes diacritics from Latin, Greek and Cyrillic letters,
  /// e.g. `Österreich` → `Osterreich`, `Égypte` → `Egypte`, `Ёлка` → `Елка`.
  ///
  /// Letters that are distinct in their alphabet and not accented
  /// variants, such as the Cyrillic `Й`, are kept.
  static String foldDiacritics(String value) {
    StringBuffer? buffer;
    var index = 0;
    for (final rune in value.runes) {
      final folded = _foldTable[rune];
      if (folded != null && buffer == null) {
        // Delay allocation until the first replacement.
        buffer = StringBuffer(value.substring(0, index));
      }
      buffer?.write(folded ?? String.fromCharCode(rune));
      // A substring offset counts UTF-16 code units, not runes.
      index += rune > 0xFFFF ? 2 : 1;
    }
    return buffer?.toString() ?? value;
  }

  /// Compares country names for display order.
  ///
  /// Diacritics and case are ignored first, so `Österreich` is sorted
  /// among the `O` names; the original strings break ties.
  static int compareNames(String a, String b) {
    final result = foldDiacritics(
      a,
    ).toLowerCase().compareTo(foldDiacritics(b).toLowerCase());
    return result != 0 ? result : a.compareTo(b);
  }
}
