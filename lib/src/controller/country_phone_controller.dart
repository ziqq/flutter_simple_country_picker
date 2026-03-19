/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 27 January 2026
 */

import 'package:flutter/foundation.dart' show ValueNotifier, listEquals;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryPhoneResolution &&
          other.phone == phone &&
          other.phoneCode == phoneCode &&
          other.nationalNumber == nationalNumber &&
          other.status == status &&
          listEquals(other.countryCodes, countryCodes);

  @override
  int get hashCode => Object.hash(
    phone,
    phoneCode,
    nationalNumber,
    status,
    Object.hashAll(countryCodes),
  );
}

/// Status of the current phone input value.
///
/// This status describes the local phone-number input relative to the expected
/// length for the currently selected country in [CountryPhoneInput].
@immutable
final class CountryPhoneValueStatus {
  /// Creates a phone-value status.
  const CountryPhoneValueStatus({
    required this.currentLength,
    required this.expectedLength,
    required this.isOverflow,
  }) : assert(currentLength >= 0, 'currentLength cannot be negative'),
       assert(expectedLength >= 0, 'expectedLength cannot be negative');

  /// Creates an empty phone-value status.
  const CountryPhoneValueStatus.empty()
    : currentLength = 0,
      expectedLength = 0,
      isOverflow = false;

  /// Current count of national digits in the phone input.
  final int currentLength;

  /// Expected count of national digits for the selected country.
  final int expectedLength;

  /// Whether the current input exceeds the expected length.
  final bool isOverflow;

  /// Whether the current input has no national digits yet.
  bool get isEmpty => currentLength == 0;

  /// Whether the current input is non-empty and shorter than expected.
  bool get isIncomplete =>
      !isOverflow &&
      currentLength > 0 &&
      expectedLength > 0 &&
      currentLength < expectedLength;

  /// Whether the current input matches the expected length exactly.
  bool get isComplete =>
      !isOverflow && expectedLength > 0 && currentLength == expectedLength;

  /// Creates a new status with updated fields.
  CountryPhoneValueStatus copyWith({
    int? currentLength,
    int? expectedLength,
    bool? isOverflow,
  }) => CountryPhoneValueStatus(
    currentLength: currentLength ?? this.currentLength,
    expectedLength: expectedLength ?? this.expectedLength,
    isOverflow: isOverflow ?? this.isOverflow,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryPhoneValueStatus &&
          other.currentLength == currentLength &&
          other.expectedLength == expectedLength &&
          other.isOverflow == isOverflow;

  @override
  int get hashCode => Object.hash(currentLength, expectedLength, isOverflow);
}

/// Immutable controller value, similar in role to Flutter's editing values.
///
/// The [text] field stores the controller text exactly as it was assigned,
/// while [phone], [resolution], and [valueStatus] expose normalized derived
/// state that can be observed from a single listenable object.
@immutable
final class CountryPhoneEditingValue {
  /// Creates a controller value from raw [text] and optional [valueStatus].
  ///
  /// Use this when you want to seed a controller with a fully specified value:
  ///
  /// ```dart
  /// final value = CountryPhoneEditingValue(
  ///   text: '+44 7911 123456',
  ///   valueStatus: const CountryPhoneValueStatus(
  ///     currentLength: 10,
  ///     expectedLength: 10,
  ///     isOverflow: false,
  ///   ),
  /// );
  /// ```
  factory CountryPhoneEditingValue({
    String text = '',
    CountryPhoneValueStatus? valueStatus,
  }) => CountryPhoneEditingValue._(
    text: text,
    resolution: CountryPhoneController._resolve(text),
    valueStatus:
        valueStatus ?? CountryPhoneController._defaultValueStatus(text),
  );

  /// Creates an empty editing value.
  const CountryPhoneEditingValue.empty()
    : text = '',
      resolution = const CountryPhoneResolution(
        phone: '',
        phoneCode: '',
        nationalNumber: '',
        status: CountryPhoneResolutionStatus.unresolved,
        countryCodes: <String>[],
      ),
      valueStatus = const CountryPhoneValueStatus.empty();

  const CountryPhoneEditingValue._({
    required this.text,
    required this.resolution,
    required this.valueStatus,
  });

  /// Raw controller text, preserving spacing and formatting.
  final String text;

  /// Full country-resolution result for the current phone number.
  final CountryPhoneResolution resolution;

  /// Current value status for the phone input.
  final CountryPhoneValueStatus valueStatus;

  /// Normalized phone value without formatting spaces.
  String get phone => text.replaceAll(CountryPhoneController._regExp, '');

  /// Detected calling code without a leading `+`.
  String get phoneCode {
    final e164 = CountryPhoneController._toE164Digits(phone);
    if (e164.isEmpty) return '';
    return CountryPhoneController._extractCallingCode(e164);
  }

  /// National number without the detected calling code.
  String get number {
    final e164 = CountryPhoneController._toE164Digits(phone);
    if (e164.isEmpty) return '';

    final code = phoneCode;
    if (code.isEmpty) return e164;

    return e164.startsWith(code) ? e164.substring(code.length) : e164;
  }

  /// Creates a new value while keeping derived fields consistent.
  ///
  /// This is the preferred way to update controller state from the outside:
  ///
  /// ```dart
  /// controller.value = controller.value.copyWith(
  ///   text: '+44 7911 12345',
  /// );
  /// ```
  CountryPhoneEditingValue copyWith({
    String? text,
    CountryPhoneValueStatus? valueStatus,
  }) {
    final nextText = text ?? this.text;
    final nextStatus =
        valueStatus ??
        (text != null
            ? CountryPhoneController._updatedValueStatus(
                text: nextText,
                previous: this.valueStatus,
              )
            : this.valueStatus);

    return CountryPhoneEditingValue(text: nextText, valueStatus: nextStatus);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryPhoneEditingValue &&
          other.text == text &&
          other.resolution == resolution &&
          other.valueStatus == valueStatus;

  @override
  int get hashCode => Object.hash(text, resolution, valueStatus);
}

/// Country phone controller.
///
/// This controller manages a single [CountryPhoneEditingValue], which keeps the
/// raw text, resolved phone metadata, and current input-length status together.
///
/// Example:
/// ```dart
/// final controller = CountryPhoneController.apply('+7 123 456 78 90');
/// print(controller.phone); // +71234567890
/// print(controller.number); // 1234567890
/// ```
final class CountryPhoneController
    extends ValueNotifier<CountryPhoneEditingValue> {
  /// Creates an empty [CountryPhoneController].
  CountryPhoneController.empty()
    : super(const CountryPhoneEditingValue.empty());

  /// Creates a [CountryPhoneController] with the given [phone].
  CountryPhoneController.apply(String phone)
    : super(CountryPhoneEditingValue(text: phone));

  /// Creates a [CountryPhoneController] from a complete editing [value].
  ///
  /// This mirrors the Flutter SDK `TextEditingController.fromValue(...)`
  /// pattern and is useful when callers already know both text and status.
  CountryPhoneController.fromValue(CountryPhoneEditingValue value)
    : super(_normalizeValue(value));

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

  /// Returns the raw controller text.
  ///
  /// For example, if the phone number is `+7 123 456 78 90`,
  /// this will return `+7 123 456 78 90`.
  String get text => value.text;

  /// Updates the raw controller text while preserving derived status when possible.
  set text(String newText) {
    if (value.text == newText) return;
    value = value.copyWith(text: newText);
  }

  /// Return the current phone number with country code.
  /// For example, if the phone number is `+7 123 456 78 90`,
  /// this will return `+71234567890`.
  String get phone => value.phone;

  /// Current value status for the phone input.
  CountryPhoneValueStatus get valueStatus => value.valueStatus;

  /// Full country-resolution result for the current phone number.
  CountryPhoneResolution get resolution => value.resolution;

  /// Return the current country code from the phone number (without `+`).
  /// For example, if the phone number is `+7 123 456 78 90`,
  /// this will return `7`.
  String get phoneCode => value.phoneCode;

  /// Return the current phone number without country code.
  /// For example, `+7 123 456 78 90` -> `1234567890`.
  String get number => value.number;

  /// Replaces the controller value with a normalized editing value.
  @override
  set value(CountryPhoneEditingValue newValue) {
    final normalizedValue = _normalizeValue(newValue);
    if (super.value == normalizedValue) return;
    super.value = normalizedValue;
  }

  /// Clears the raw controller text.
  void clear() {
    if (text.isEmpty) return;
    value = value.copyWith(text: '');
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

  static CountryPhoneValueStatus _defaultValueStatus(String value) =>
      CountryPhoneValueStatus(
        currentLength: _nationalDigitsLength(value),
        expectedLength: 0,
        isOverflow: false,
      );

  static CountryPhoneEditingValue _normalizeValue(
    CountryPhoneEditingValue value,
  ) => CountryPhoneEditingValue(
    text: value.text,
    valueStatus: value.valueStatus,
  );

  static CountryPhoneValueStatus _updatedValueStatus({
    required String text,
    required CountryPhoneValueStatus previous,
  }) {
    final nextLength = _nationalDigitsLength(text);
    final expectedLength = previous.expectedLength;

    return previous.copyWith(
      currentLength: nextLength,
      isOverflow: expectedLength > 0 && nextLength > expectedLength,
    );
  }

  static int _nationalDigitsLength(String value) {
    final e164 = _toE164Digits(value);
    if (e164.isEmpty) return 0;

    final code = _extractCallingCode(e164);
    if (code.isEmpty) return e164.length;

    return e164.startsWith(code)
        ? e164.substring(code.length).length
        : e164.length;
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
