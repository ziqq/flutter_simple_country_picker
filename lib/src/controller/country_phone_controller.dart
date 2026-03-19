/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 27 January 2026
 */

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart'
    show countries;
import 'package:meta/meta.dart';

/// Resolution status for a parsed phone number.
enum CountryPhoneResolutionStatus {
  /// A single candidate was resolved for the current phone number.
  exact,

  /// Multiple candidates remain valid for the current phone number.
  ambiguous,

  /// No valid candidate could be resolved.
  unresolved,
}

/// Result of resolving a phone number to one or more country candidates.
@immutable
final class CountryPhoneResolution {
  /// Creates a phone resolution result.
  const CountryPhoneResolution({
    required this.phone,
    required this.phoneCode,
    required this.nationalNumber,
    required this.status,
    required this.countryCodes,
  });

  /// Normalized E.164-like phone value with a leading `+` when available.
  final String phone;

  /// Detected country calling code without a leading `+`.
  final String phoneCode;

  /// National significant number without the calling code.
  final String nationalNumber;

  /// Resolution status for the current phone number.
  final CountryPhoneResolutionStatus status;

  /// Ordered ISO2 candidates for the current phone number.
  final List<String> countryCodes;

  /// Primary resolved ISO2 code or `null` if unresolved.
  String? get primaryCountryCode =>
      countryCodes.isEmpty ? null : countryCodes.first;

  /// Whether the phone number was resolved to a single candidate.
  bool get isExact => status == CountryPhoneResolutionStatus.exact;

  /// Whether the phone number still has multiple valid candidates.
  bool get isAmbiguous => status == CountryPhoneResolutionStatus.ambiguous;

  /// Whether the phone number resolved to any candidate at all.
  bool get isResolved => status != CountryPhoneResolutionStatus.unresolved;
}

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

  /// Full country-resolution result for the current phone number.
  CountryPhoneResolution get resolution => _resolve(phone);

  /// Return the current country code from the phone number (without `+`).
  /// For example, if the phone number is `+7 123 456 78 90`,
  /// this will return `7`.
  String get phoneCode {
    final e164 = _toE164Digits(phone);
    if (e164.isEmpty) return '';
    return _extractCallingCode(e164);
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

  /// Resolves a phone number into exact, ambiguous, or unresolved state.
  ///
  /// Resolution uses the bundled dataset by comparing the national number with
  /// country example numbers and then using dataset priority for ties.
  static CountryPhoneResolution _resolve(String value) {
    final e164 = _toE164Digits(value);
    if (e164.isEmpty) return _unresolvedResolution();

    final callingCode = _extractCallingCode(e164);
    if (callingCode.isEmpty) {
      return _unresolvedResolution(phone: '+$e164');
    }

    final national = e164.substring(callingCode.length);
    final normalizedPhone = '+$e164';

    final heuristicMatches = _resolveCountryMatches(
      callingCode: callingCode,
      national: national,
    );

    if (heuristicMatches.isEmpty) {
      return _unresolvedResolution(
        phone: normalizedPhone,
        phoneCode: callingCode,
        nationalNumber: national,
      );
    }

    final status = heuristicMatches.length == 1
        ? CountryPhoneResolutionStatus.exact
        : CountryPhoneResolutionStatus.ambiguous;

    return CountryPhoneResolution(
      phone: normalizedPhone,
      phoneCode: callingCode,
      nationalNumber: national,
      status: status,
      countryCodes: heuristicMatches
          .map((match) => match.iso2)
          .toList(growable: false),
    );
  }

  static CountryPhoneResolution _unresolvedResolution({
    String phone = '',
    String phoneCode = '',
    String nationalNumber = '',
  }) => CountryPhoneResolution(
    phone: phone,
    phoneCode: phoneCode,
    nationalNumber: nationalNumber,
    status: CountryPhoneResolutionStatus.unresolved,
    countryCodes: const <String>[],
  );

  /// Returns heuristic candidates from the bundled dataset.
  static List<_CountryCodeMatch> _resolveCountryMatches({
    required String callingCode,
    required String national,
  }) {
    final bestMatches = <_CountryCodeMatch>[];
    var bestPrefix = -1;

    for (final country in countries) {
      final cc = country['e164_cc']?.toString();
      if (cc != callingCode) continue;

      final iso2 = country['iso2_cc']?.toString().toUpperCase();
      if (iso2 == null || iso2.isEmpty) continue;

      final example = country['example']?.toString() ?? '';
      final exampleDigits = example.replaceAll(_nonDigitsRegExp, '');
      final prefix = exampleDigits.isEmpty
          ? 0
          : _commonPrefixLength(national, exampleDigits);
      final level = switch (country['level']) {
        int v => v,
        String s => int.tryParse(s) ?? 0,
        _ => 0,
      };

      if (prefix > bestPrefix) {
        bestPrefix = prefix;
        bestMatches
          ..clear()
          ..add(
            _CountryCodeMatch(iso2: iso2, level: level, prefixLength: prefix),
          );
        continue;
      }

      if (prefix == bestPrefix) {
        bestMatches.add(
          _CountryCodeMatch(iso2: iso2, level: level, prefixLength: prefix),
        );
      }
    }

    bestMatches.sort((a, b) {
      // Lower levels win because they represent the main region in this dataset.
      final levelComparison = a.level.compareTo(b.level);
      if (levelComparison != 0) return levelComparison;

      final prefixComparison = b.prefixLength.compareTo(a.prefixLength);
      if (prefixComparison != 0) return prefixComparison;

      return a.iso2.compareTo(b.iso2);
    });

    final orderedMatches = <_CountryCodeMatch>[];
    final seenIso2 = <String>{};
    for (final match in bestMatches) {
      if (seenIso2.add(match.iso2)) orderedMatches.add(match);
    }

    return orderedMatches;
  }
}

final class _CountryCodeMatch {
  const _CountryCodeMatch({
    required this.iso2,
    required this.level,
    required this.prefixLength,
  });

  final String iso2;
  final int level;
  final int prefixLength;
}
