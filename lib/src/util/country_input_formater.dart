import 'package:flutter/services.dart';

/// Country input completion type.
enum CountryInputCompletionType {
  /// Lazy completion.
  lazy,

  /// Eager completion.
  eager,
}

/// Country input formatter.
///
/// Formats text input according to a specified mask.
/// The [mask] defines the format, and [filter] specifies allowed characters
/// for each mask symbol.
/// By default, `#` matches a digit and `A` matches a non-digit.
///
/// Use [type] to set completion behavior:
/// - [CountryInputCompletionType.lazy] (default): unfiltered characters are
/// auto-completed after the next filtered character is input.
///   Example: with mask "#/#", input "1", then "2" results in "1", then "1/2".
/// - [CountryInputCompletionType.eager]: unfiltered characters
/// are auto-completed
/// immediately after the previous filtered character is input.
/// Example: with mask "#/#", input "1", then "2" results in "1/", then "1/2".
class CountryInputFormater implements TextInputFormatter {
  /// Creates a [CountryInputFormater]
  /// with the given [mask], [filter],and [initialText].
  CountryInputFormater({
    String? mask,
    Map<String, RegExp>? filter,
    String? initialText,
    CountryInputCompletionType type = CountryInputCompletionType.lazy,
  }) : _type = type {
    updateMask(
      mask: mask,
      filter: filter ?? {'#': RegExp(r'\d')},
      newValue: initialText == null
          ? null
          : TextEditingValue(
              text: initialText,
              selection: TextSelection.collapsed(
                offset: initialText.length,
              ),
            ),
    );
  }

  /// Creates an eager [CountryInputFormater].
  CountryInputFormater.eager({
    String? mask,
    Map<String, RegExp>? filter,
    String? initialText,
  }) : this(
            mask: mask,
            filter: filter,
            initialText: initialText,
            type: CountryInputCompletionType.eager);

  CountryInputCompletionType _type;

  /// Completion type.
  CountryInputCompletionType get type => _type;

  String? _mask;
  Set<String> _maskChars = {};
  Map<String, RegExp>? _maskFilter;

  int _maskLength = 0;
  final _TextMatcher _resultTextArray = _TextMatcher();
  String _resultTextMasked = '';

  /// Updates the mask and filter.
  TextEditingValue updateMask({
    String? mask,
    Map<String, RegExp>? filter,
    CountryInputCompletionType? type,
    TextEditingValue? newValue,
  }) {
    if (mask == null || mask.isEmpty) {
      throw ArgumentError('Mask cannot be null or empty');
    }
    if (filter == null) {
      if (_maskFilter == null || _maskFilter!.isEmpty) {
        throw ArgumentError('Filter cannot be null or empty');
      }
    } else if (filter.isEmpty) {
      throw ArgumentError('Filter cannot be empty');
    } else {
      _updateFilter(filter);
    }
    _mask = mask;
    if (type != null) _type = type;
    _calcMaskLength();
    var targetValue = newValue;
    if (targetValue == null) {
      final unmaskedText = getUnmaskedText();
      targetValue = TextEditingValue(
        text: unmaskedText,
        selection: TextSelection.collapsed(offset: unmaskedText.length),
      );
    }
    clear();
    return formatEditUpdate(TextEditingValue.empty, targetValue);
  }

  /// Gets the current mask.
  String? getMask() => _mask;

  /// Gets the masked text, e.g., "+0 (123) 456-78-90".
  String getMaskedText() => _resultTextMasked;

  /// Gets the unmasked text, e.g., "01234567890".
  String getUnmaskedText() => _resultTextArray.toString();

  /// Checks if the mask is fully filled.
  bool get isFill => _resultTextArray.length == _maskLength;

  /// Clears the masked text.
  void clear() {
    _resultTextMasked = '';
    _resultTextArray.clear();
  }

  /// Applies the mask to the given text.
  String maskText(String text) => CountryInputFormater(
        mask: _mask,
        filter: _maskFilter,
        initialText: text,
      ).getMaskedText();

  /// Removes the mask from the given text.
  String unmaskText(String text) => CountryInputFormater(
        mask: _mask,
        filter: _maskFilter,
        initialText: text,
      ).getUnmaskedText();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.isEmpty) {
      _resultTextArray.clear();
    }

    _handleTextReplacement(oldValue, newValue);
    _buildMaskedText();

    var cursorPosition = _calculateCursorPosition();

    return TextEditingValue(
      text: _resultTextMasked,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  /// Handles text replacement during input.
  void _handleTextReplacement(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var replacementText = newValue.text;

    // Collect only valid characters
    final validChars = <String>[];
    for (final char in replacementText.split('')) {
      if (_maskFilter!.values.any((regex) => regex.hasMatch(char))) {
        validChars.add(char);
      }
    }

    // Truncate valid characters to mask length
    if (validChars.length > _maskLength) {
      validChars.removeRange(_maskLength, validChars.length);
    }

    _resultTextArray.set(validChars.join());
  }

  /// Builds the masked text based on the current mask and input.
  void _buildMaskedText() {
    final $mask = _mask;
    if ($mask == null || $mask.isEmpty) return;

    final buffer = StringBuffer();
    var textIndex = 0;
    var maskIndex = 0;

    // Add all leading unfiltered characters from the mask
    while (maskIndex < $mask.length && !_maskChars.contains($mask[maskIndex])) {
      buffer.write($mask[maskIndex]);
      maskIndex++;
    }

    while (maskIndex < $mask.length) {
      final maskChar = $mask[maskIndex];
      final isMaskChar = _maskChars.contains(maskChar);

      if (isMaskChar) {
        if (textIndex < _resultTextArray.length) {
          final textChar = _resultTextArray[textIndex];
          if (_maskFilter![maskChar]!.hasMatch(textChar)) {
            buffer.write(textChar);
            textIndex++;
          } else {
            // Skip invalid character
            textIndex++;
            maskIndex--; // Stay on the same mask character
          }
        } else {
          break;
        }
      } else {
        if (_type == CountryInputCompletionType.eager) {
          // In eager mode, add unfiltered character immediately
          buffer.write(maskChar);
        } else {
          // In lazy mode, add unfiltered character
          // only after inputting next filtered character
          if (textIndex > 0) buffer.write(maskChar);
        }
      }
      maskIndex++;
    }

    _resultTextMasked = buffer.toString();
  }

  /// Calculates the cursor position after formatting.
  int _calculateCursorPosition() => _resultTextMasked.length;

  /// Calculates the length of the mask.
  void _calcMaskLength() {
    // Escape each mask character for RegExp to handle special characters
    final escapedMaskChars = _maskChars.map(RegExp.escape).join();

    // Create a RegExp pattern that matches any of the mask characters
    final regExp = RegExp('[$escapedMaskChars]');

    // Find all matches in the mask
    final matches = regExp.allMatches(_mask!);

    // Set _maskLength to the number of mask characters found
    _maskLength = matches.length;
  }

  /// Updates the mask filter and mask characters.
  void _updateFilter(Map<String, RegExp> filter) {
    _maskFilter = filter;
    _maskChars = _maskFilter!.keys.toSet();
  }
}

/// Text matcher.
class _TextMatcher {
  final List<String> _symbols = <String>[];

  /// Gets the length of the text.
  int get length => _symbols.length;

  /// Removes a range of characters.
  void removeRange(int start, int end) => _symbols.removeRange(start, end);

  /// Inserts characters at a specified position.
  void insert(int start, String substring) {
    final runes = substring.runes.toList();
    for (var i = 0; i < runes.length; i++) {
      _symbols.insert(start + i, String.fromCharCode(runes[i]));
    }
  }

  /// Removes a character at the specified index.
  void removeAt(int index) => _symbols.removeAt(index);

  /// Gets the character at the specified index.
  String operator [](int index) => _symbols[index];

  /// Clears all characters.
  void clear() => _symbols.clear();

  @override
  String toString() => _symbols.join();

  /// Sets the text.
  void set(String text) {
    _symbols.clear();
    final runes = text.runes.toList();
    for (final rune in runes) {
      _symbols.add(String.fromCharCode(rune));
    }
  }
}
