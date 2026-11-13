/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 4 November 2026
 */

import 'package:flutter_simple_country_picker/src/constant/country_phone_display_patterns.g.dart';
import 'package:flutter_simple_country_picker/src/constant/country_phone_rules.g.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';
import 'package:meta/meta.dart';

/// Resolves national formatting independently from input editing and validation.
@internal
class CountryPhoneFormatResolver {
  /// Creates a resolver for one explicitly selected country.
  CountryPhoneFormatResolver(this.country)
    : rules = countryPhoneRules[country.countryCode.toUpperCase()],
      _displayPatterns = countryPhoneDisplayPatterns[country.e164Key]
          ?.map(
            (pattern) =>
                (prefix: pattern.replaceAll(_nonDigits, ''), pattern: pattern),
          )
          .toList(growable: false);

  /// Selected country, including any region prefix embedded in its calling code.
  final Country country;

  /// Pinned metadata, or null for a region without compatible numbering data.
  final CountryPhoneRules? rules;

  final List<({String prefix, String pattern})>? _displayPatterns;
  final Map<String, RegExp> _prefixes = <String, RegExp>{};
  static final RegExp _nonDigits = RegExp(r'\D');
  static final RegExp _digit = RegExp(r'\d');

  /// Matches prefix rules without compiling expressions on every keystroke.
  int _leadingDigitsMatchLength(CountryPhoneFormat format, String digits) {
    if (format.leadingDigits.isEmpty) return 0;
    final expression = _prefixes.putIfAbsent(
      format.leadingDigits,
      () => RegExp('^(?:${format.leadingDigits})'),
    );
    return expression.matchAsPrefix(digits)?.end ?? -1;
  }

  /// Supported local lengths; presentation capacity does not limit the input.
  List<int> supportedLengths(String digits) {
    final data = rules;
    if (data == null) return const <int>[];
    final national = '${data.regionPrefix}$digits';
    final matched = <int>{};
    final covered = <int>{};
    for (final format in data.formats) {
      covered.addAll(format.groupLengths.keys);
      if (_leadingDigitsMatchLength(format, national) >= 0)
        matched.addAll(format.groupLengths.keys);
    }
    final result = <int>[
      for (final length in data.possibleLengths)
        // A supported number can be shorter than every display template.
        if ((matched.isEmpty ||
                matched.contains(length) ||
                !covered.contains(length)) &&
            length > data.regionPrefix.length)
          length - data.regionPrefix.length,
    ]..sort();
    return result;
  }

  /// Whether a full local input has a supported length and recognized prefix.
  bool _hasSupportedPrefixAndLength(String digits) {
    final data = rules;
    if (data == null) return false;
    final national = '${data.regionPrefix}$digits';
    return supportedLengths(digits).contains(digits.length) &&
        (data.formats.isEmpty ||
            data.formats.any(
              (f) => _leadingDigitsMatchLength(f, national) >= 0,
            ));
  }

  /// Removes calling/trunk prefixes only when their interpretation is supported.
  String normalize(
    String text, {
    required bool stripCode,
    required bool stripTrunk,
    required bool allowImplicitCode,
  }) {
    var digits = text.replaceAll(_nonDigits, '');
    final international =
        text.trimLeft().startsWith('+') || text.trimLeft().startsWith('00');
    final code = country.phoneCode;
    if (stripCode &&
        text.trimLeft().startsWith('00') &&
        digits.startsWith('00$code') &&
        digits.length > code.length + 2) {
      digits = digits.substring(2);
    }
    if (stripCode && digits.startsWith(code) && digits.length > code.length) {
      final candidate = digits.substring(code.length);
      if (international ||
          (allowImplicitCode &&
              !_hasSupportedPrefixAndLength(digits) &&
              _hasSupportedPrefixAndLength(candidate))) {
        digits = candidate;
      }
    }
    final prefix = rules?.nationalPrefixPattern;
    if (stripTrunk && prefix != null && prefix.isNotEmpty) {
      final match = _prefixes
          .putIfAbsent(prefix, () => RegExp('^(?:$prefix)'))
          .matchAsPrefix(digits);
      if (match != null && match.end > 0) {
        final candidate = digits.substring(match.end);
        if (!_hasSupportedPrefixAndLength(digits) &&
            _hasSupportedPrefixAndLength(candidate))
          digits = candidate;
      }
    }
    return digits;
  }

  String? _selectDisplayPattern(String digits) {
    final patterns = _displayPatterns;
    if (patterns == null) return country.mask;
    if (patterns.isEmpty) return null;
    var selected = patterns.first.pattern;
    var bestPrefixMatchLength = -1;
    for (final candidate in patterns) {
      if (candidate.prefix.length >= bestPrefixMatchLength &&
          digits.startsWith(candidate.prefix)) {
        // The last template for a duplicate prefix takes precedence.
        selected = candidate.pattern;
        bestPrefixMatchLength = candidate.prefix.length;
      }
    }
    return selected;
  }

  /// Applies the selected pattern and appends all digits beyond the template.
  String format(String digits) => formatWithHint(digits).text;

  /// Returns the text and the unused part of its template.
  ///
  /// A null hint indicates that no template is available. An empty hint means
  /// the template is full.
  ({String text, String? hint}) formatWithHint(String digits) {
    final pattern = _selectDisplayPattern(digits);
    if (pattern == null || pattern.isEmpty) return (text: digits, hint: null);

    final useLegacySlots = _displayPatterns == null;
    final result = StringBuffer();
    var digitIndex = 0;
    var position = 0;
    while (position < pattern.length && digitIndex < digits.length) {
      final character = pattern[position++];
      final isSlot = useLegacySlots
          ? '0#A'.contains(character)
          : character == 'X' || _digit.hasMatch(character);
      if (isSlot) {
        result.write(digits[digitIndex++]);
      } else {
        result.write(character);
      }
    }
    result.write(digits.substring(digitIndex));

    final remaining = pattern.substring(position);
    final hint = useLegacySlots
        ? remaining.replaceAll('#', '0').replaceAll('A', '0')
        : remaining.replaceAll('X', '0');
    return (text: result.toString(), hint: hint);
  }
}
