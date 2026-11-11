/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 4 November 2026
 */

import 'package:flutter_simple_country_picker/src/constant/country_phone_rules.g.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';
import 'package:meta/meta.dart';

/// Resolves national formatting independently from input editing and validation.
@internal
class CountryPhoneFormatResolver {
  /// Creates a resolver for one explicitly selected country.
  CountryPhoneFormatResolver(this.country)
    : rules = countryPhoneRules[country.countryCode.toUpperCase()];

  /// Selected country, including any region prefix embedded in its calling code.
  final Country country;

  /// Pinned metadata, or null for a region without compatible numbering data.
  final CountryPhoneRules? rules;

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

  /// Applies the most specific prefix pattern, leaving an unbounded soft tail.
  String format(String digits) {
    final data = rules;
    if (digits.isEmpty) return '';
    if (data == null || data.formats.isEmpty)
      return _applyMask(country.mask, digits);
    final national = '${data.regionPrefix}$digits';
    CountryPhoneFormat? selected;
    var bestPrefixMatchLength = -1;
    var bestLengthFit = -1;
    var bestCapacity = 0;
    for (final candidate in data.formats) {
      final prefixMatchLength = _leadingDigitsMatchLength(candidate, national);
      if (prefixMatchLength < 0) continue;
      final lengthFit = candidate.groupLengths.containsKey(national.length)
          ? 2
          : candidate.groupLengths.keys.any((n) => n >= national.length)
          ? 1
          : 0;
      final candidateCapacity = candidate.groupLengths.keys.fold<int>(
        0,
        (largest, length) => length > largest ? length : largest,
      );
      if (lengthFit > bestLengthFit ||
          (lengthFit == bestLengthFit &&
              (lengthFit == 0
                  ? candidateCapacity > bestCapacity ||
                        (candidateCapacity == bestCapacity &&
                            prefixMatchLength > bestPrefixMatchLength)
                  : prefixMatchLength > bestPrefixMatchLength))) {
        selected = candidate;
        bestPrefixMatchLength = prefixMatchLength;
        bestLengthFit = lengthFit;
        bestCapacity = candidateCapacity;
      }
    }
    if (selected == null) return _applyMask(country.mask, digits);
    final sizes = selected.groupLengths.keys.toList()..sort();
    if (sizes.isEmpty) return _applyMask(country.mask, digits);
    final length = sizes.firstWhere(
      (n) => n >= national.length,
      orElse: () => sizes.last,
    );
    final groups = selected.groupLengths[length] ?? const <int>[];
    final mask = selected.replacement.replaceAllMapped(RegExp(r'\$(\d+)'), (
      match,
    ) {
      final index = int.tryParse(match.group(1) ?? '') ?? 0;
      return index > 0 && index <= groups.length ? '#' * groups[index - 1] : '';
    });
    var result = _applyMask(mask, national);
    if (data.regionPrefix.isEmpty) return result;
    var removed = 0;
    var offset = 0;
    while (offset < result.length && removed < data.regionPrefix.length) {
      if (_digit.hasMatch(result[offset])) removed++;
      offset++;
    }
    while (offset < result.length && !_digit.hasMatch(result[offset])) offset++;
    return result.substring(offset);
  }

  /// Emits literals lazily and appends all digits beyond the template.
  static String _applyMask(String? mask, String digits) {
    if (mask == null || mask.isEmpty) return digits;
    final result = StringBuffer();
    var index = 0;
    for (
      var position = 0;
      position < mask.length && index < digits.length;
      position++
    ) {
      final character = mask[position];
      if (character == '#' || character == '0' || character == 'A') {
        result.write(digits[index++]);
      } else {
        result.write(character);
      }
    }
    result.write(digits.substring(index));
    return result.toString();
  }
}
