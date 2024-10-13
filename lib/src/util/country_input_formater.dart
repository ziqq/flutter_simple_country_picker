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
class CountryInputFormatter implements TextInputFormatter {
  /// Creates a [CountryInputFormatter]
  /// with the given [mask], [filter],and [initialText].
  CountryInputFormatter({
    String? mask,
    Map<String, RegExp>? filter,
    String? initialText,
    CountryInputCompletionType type = CountryInputCompletionType.lazy,
  }) : _type = type {
    updateMask(
      mask: mask,
      filter: filter ?? {'#': RegExp(r'\d'), 'A': RegExp(r'\D')},
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

  /// Creates an eager [CountryInputFormatter].
  CountryInputFormatter.eager({
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
    if (filter == null || filter.isEmpty) {
      throw ArgumentError('Filter cannot be null or empty');
    }
    _mask = mask;
    _updateFilter(filter);
    if (type != null) {
      _type = type;
    }
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
  bool isFill() => _resultTextArray.length == _maskLength;

  /// Clears the masked text.
  void clear() {
    _resultTextMasked = '';
    _resultTextArray.clear();
  }

  /// Applies the mask to the given text.
  String maskText(String text) => CountryInputFormatter(
        mask: _mask,
        filter: _maskFilter,
        initialText: text,
      ).getMaskedText();

  /// Removes the mask from the given text.
  String unmaskText(String text) => CountryInputFormatter(
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

    var beforeSelectionStart = oldValue.selection.start;
    var beforeSelectionEnd = oldValue.selection.end;

    _handleTextReplacement(
      oldValue,
      newValue,
      beforeSelectionStart,
      beforeSelectionEnd,
    );

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
    int beforeSelectionStart,
    int beforeSelectionEnd,
  ) {
    var replacementText = newValue.text;
    if (replacementText.length > _maskLength) {
      replacementText = replacementText.substring(0, _maskLength);
    }
    _resultTextArray.set(replacementText);
  }

  /// Builds the masked text based on the current mask and input.
  void _buildMaskedText() {
    _resultTextMasked = '';
    var textIndex = 0;
    var maskIndex = 0;

    while (maskIndex < _mask!.length) {
      final maskChar = _mask![maskIndex];
      final isMaskChar = _maskChars.contains(maskChar);

      if (isMaskChar) {
        if (textIndex < _resultTextArray.length) {
          final textChar = _resultTextArray[textIndex];
          if (_maskFilter![maskChar]!.hasMatch(textChar)) {
            _resultTextMasked += textChar;
            textIndex++;
          } else {
            // Remove invalid character.
            // Удаляем недопустимый символ.
            _resultTextArray.removeAt(textIndex);
          }
        } else {
          break;
        }
      } else {
        _resultTextMasked += maskChar;
      }
      maskIndex++;
    }
  }

  /// Calculates the cursor position after formatting.
  int _calculateCursorPosition() => _resultTextMasked.length;

  /// Calculates the length of the mask.
  void _calcMaskLength() {
    _maskLength = 0;
    for (var i = 0; i < _mask!.length; i++) {
      if (_maskChars.contains(_mask![i])) {
        _maskLength++;
      }
    }
  }

  /// Updates the mask filter and mask characters.
  void _updateFilter(Map<String, RegExp> filter) {
    _maskFilter = filter;
    _maskChars = _maskFilter!.keys.toSet();
  }
}

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
