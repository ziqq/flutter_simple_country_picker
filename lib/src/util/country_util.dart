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
/// [foldDiacritics] - Remove diacritics from letters.
/// [compareNames] - Compare country names for display order.
/// {@endtemplate}
@internal
abstract final class CountryUtil {
  /// {@macro country_util}
  const CountryUtil._();

  static final _codeRegExp = RegExp(r'^[A-Za-z]{2}$');

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
        buffer = StringBuffer(value.substring(0, index));
      }
      buffer?.write(folded ?? String.fromCharCode(rune));
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
