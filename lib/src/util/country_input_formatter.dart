import 'dart:math';

import 'package:flutter/services.dart';

/// Country input completion type.
enum CountryInputCompletionType {
  /// Lazy completion type where unfiltered characters are completed
  /// after a filtered character is entered.
  lazy,

  /// Eager completion type where unfiltered characters are completed
  /// as soon as the previous filtered character is entered.
  eager,
}

/// Country input formatter.
///
/// Formats text input according to a specified mask.
/// The [mask] defines the format,
/// and [filter] specifies allowed characters for each mask symbol.
/// By default, `#` matches a digit and `A` matches a non-digit.
///
/// Use [type] to set completion behavior:
///
/// - [CountryInputCompletionType.lazy] (default): unfiltered characters are
/// auto-completed after the next filtered character is input.
///   Example: with mask "#/#", input "1", then "2" results in "1", then "1/2".
///
/// - [CountryInputCompletionType.eager]: unfiltered characters
/// are auto-completed immediately after the previous filtered character
/// is input.
///
/// Example: with mask "#/#", input "1", then "2" results in "1/", then "1/2".
class CountryInputFormatter implements TextInputFormatter {
  /// Constructor to initialize the formatter with [mask], [filter],
  /// and optional [initialText].
  /// You can choose between [CountryInputCompletionType.lazy] or
  /// [CountryInputCompletionType.eager] to control the behavior of
  /// character completion.
  CountryInputFormatter({
    String? mask,
    Map<String, RegExp>? filter,
    String? initialText,
    CountryInputCompletionType type = CountryInputCompletionType.lazy,
  }) : _type = type {
    updateMask(
      mask: mask,
      filter: filter ??
          {
            '#': RegExp('[0-9]'),
            '0': RegExp('[^0-9]'),
            'A': RegExp('[^0-9]'),
          },
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

  /// Constructor for eager [mask] formatter.
  CountryInputFormatter.eager({
    String? mask,
    Map<String, RegExp>? filter,
    String? initialText,
  }) : this(
            mask: mask,
            filter: filter,
            initialText: initialText,
            type: CountryInputCompletionType.eager);

  /// Update the mask and optionally update the [filter] and [type].
  /// Pass a [newValue] to reformat an existing text value.
  TextEditingValue updateMask({
    String? mask,
    Map<String, RegExp>? filter,
    CountryInputCompletionType? type,
    TextEditingValue? newValue,
  }) {
    _mask = mask;
    if (filter != null) {
      _updateFilter(filter);
    }
    if (type != null) {
      _type = type;
    }
    _calcMaskLength();
    var targetValue = newValue;
    if (targetValue == null) {
      final unmaskedText = getUnmaskedText();
      targetValue = TextEditingValue(
        text: unmaskedText,
        selection: TextSelection.collapsed(
          offset: unmaskedText.length,
        ),
      );
    }
    clear();
    return formatEditUpdate(TextEditingValue.empty, targetValue);
  }

  CountryInputCompletionType _type;

  /// Get the current completion type.
  CountryInputCompletionType get type => _type;

  String? _mask;
  List<String> _maskChars = [];
  Map<String, RegExp>? _maskFilter;

  int _maskLength = 0;
  final _TextMatcher _resultTextArray = _TextMatcher();
  String _resultTextMasked = '';

  /// Get the current mask.
  String? getMask() => _mask;

  /// Get the masked text.
  String getMaskedText() => _resultTextMasked;

  /// Get the unmasked text.
  String getUnmaskedText() => _resultTextArray.toString();

  /// Check if the mask is fully filled.
  bool get isFill => _resultTextArray.length == _maskLength;

  /// Clear the masked text.
  /// Note: Manually call this if you clear the TextField text, as it won't
  /// trigger the formatter on an empty value.
  void clear() {
    _resultTextMasked = '';
    _resultTextArray.clear();
  }

  /// Mask the provided [text] with the current mask.
  String maskText(String text) => CountryInputFormatter(
        mask: _mask,
        filter: _maskFilter,
        initialText: text,
      ).getMaskedText();

  /// Unmask the provided [text].
  String unmaskText(String text) => CountryInputFormatter(
        mask: _mask,
        filter: _maskFilter,
        initialText: text,
      ).getUnmaskedText();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final mask = _mask;

    if (mask == null || mask.isEmpty == true) {
      _resultTextMasked = newValue.text;
      _resultTextArray.set(newValue.text);
      return newValue;
    }

    if (oldValue.text.isEmpty) {
      _resultTextArray.clear();
    }

    final beforeText = oldValue.text;
    final afterText = newValue.text;

    final beforeSelection = oldValue.selection;
    final afterSelection = newValue.selection;

    var beforeSelectionStart = afterSelection.isValid
        ? beforeSelection.isValid
            ? beforeSelection.start
            : 0
        : 0;

    for (var i = 0;
        i < beforeSelectionStart &&
            i < beforeText.length &&
            i < afterText.length;
        i++) {
      if (beforeText[i] != afterText[i]) {
        beforeSelectionStart = i;
        break;
      }
    }

    final beforeSelectionLength = afterSelection.isValid
        ? beforeSelection.isValid
            ? beforeSelection.end - beforeSelectionStart
            : 0
        : oldValue.text.length;

    final lengthDifference =
        afterText.length - (beforeText.length - beforeSelectionLength);
    final lengthRemoved = lengthDifference < 0 ? lengthDifference.abs() : 0;
    final lengthAdded = lengthDifference > 0 ? lengthDifference : 0;

    final afterChangeStart = max(0, beforeSelectionStart - lengthRemoved);
    final afterChangeEnd = max(0, afterChangeStart + lengthAdded);

    final beforeReplaceStart = max(0, beforeSelectionStart - lengthRemoved);
    final beforeReplaceLength = beforeSelectionLength + lengthRemoved;

    final beforeResultTextLength = _resultTextArray.length;

    var currentResultTextLength = _resultTextArray.length;
    var currentResultSelectionStart = 0;
    var currentResultSelectionLength = 0;

    for (var i = 0;
        i < min(beforeReplaceStart + beforeReplaceLength, mask.length);
        i++) {
      if (_maskChars.contains(mask[i]) && currentResultTextLength > 0) {
        currentResultTextLength -= 1;
        if (i < beforeReplaceStart) {
          currentResultSelectionStart += 1;
        }
        if (i >= beforeReplaceStart) {
          currentResultSelectionLength += 1;
        }
      }
    }

    final replacementText =
        afterText.substring(afterChangeStart, afterChangeEnd);
    var targetCursorPosition = currentResultSelectionStart;
    if (replacementText.isEmpty) {
      _resultTextArray.removeRange(currentResultSelectionStart,
          currentResultSelectionStart + currentResultSelectionLength);
    } else {
      if (currentResultSelectionLength > 0) {
        _resultTextArray.removeRange(currentResultSelectionStart,
            currentResultSelectionStart + currentResultSelectionLength);
        currentResultSelectionLength = 0;
      }
      _resultTextArray.insert(currentResultSelectionStart, replacementText);
      targetCursorPosition += replacementText.length;
    }

    if (beforeResultTextLength == 0 && _resultTextArray.length > 1) {
      var prefixLength = 0;
      for (var i = 0; i < mask.length; i++) {
        if (_maskChars.contains(mask[i])) {
          prefixLength = i;
          break;
        }
      }
      if (prefixLength > 0) {
        final resultPrefix =
            _resultTextArray._symbolArray.take(prefixLength).toList();
        final effectivePrefixLength =
            min(_resultTextArray.length, resultPrefix.length);
        for (var j = 0; j < effectivePrefixLength; j++) {
          if (mask[j] != resultPrefix[j]) {
            _resultTextArray.removeRange(0, j);
            break;
          }
          if (j == effectivePrefixLength - 1) {
            _resultTextArray.removeRange(0, effectivePrefixLength);
            break;
          }
        }
      }
    }

    var curTextPos = 0;
    var maskPos = 0;
    _resultTextMasked = '';
    var cursorPos = -1;
    var nonMaskedCount = 0;
    var maskInside = 0;

    while (maskPos < mask.length) {
      final curMaskChar = mask[maskPos];
      final isMaskChar = _maskChars.contains(curMaskChar);

      var curTextInRange = curTextPos < _resultTextArray.length;

      String? curTextChar;
      if (isMaskChar && curTextInRange) {
        if (maskInside > 0) {
          _resultTextArray.removeRange(curTextPos - maskInside, curTextPos);
          curTextPos -= maskInside;
        }
        maskInside = 0;
        while (curTextChar == null && curTextInRange) {
          final potentialTextChar = _resultTextArray[curTextPos];
          if (_maskFilter?[curMaskChar]?.hasMatch(potentialTextChar) ?? false) {
            curTextChar = potentialTextChar;
          } else {
            _resultTextArray.removeAt(curTextPos);
            curTextInRange = curTextPos < _resultTextArray.length;
            if (curTextPos <= targetCursorPosition) {
              targetCursorPosition -= 1;
            }
          }
        }
      } else if (!isMaskChar &&
          !curTextInRange &&
          type == CountryInputCompletionType.eager) {
        curTextInRange = true;
      }

      if (isMaskChar && curTextInRange && curTextChar != null) {
        _resultTextMasked += curTextChar;
        if (curTextPos == targetCursorPosition && cursorPos == -1) {
          cursorPos = maskPos - nonMaskedCount;
        }
        nonMaskedCount = 0;
        curTextPos += 1;
      } else {
        if (!curTextInRange) {
          if (maskInside > 0) {
            curTextPos -= maskInside;
            maskInside = 0;
            nonMaskedCount = 0;
            continue;
          } else {
            break;
          }
        } else {
          _resultTextMasked += mask[maskPos];
          if (!isMaskChar &&
              curTextPos < _resultTextArray.length &&
              curMaskChar == _resultTextArray[curTextPos]) {
            if (type == CountryInputCompletionType.lazy && lengthAdded <= 1) {
            } else {
              maskInside++;
              curTextPos++;
            }
          } else if (maskInside > 0) {
            curTextPos -= maskInside;
            maskInside = 0;
          }
        }

        if (curTextPos == targetCursorPosition &&
            cursorPos == -1 &&
            !curTextInRange) {
          cursorPos = maskPos;
        }

        if (type == CountryInputCompletionType.lazy ||
            lengthRemoved > 0 ||
            currentResultSelectionLength > 0 ||
            beforeReplaceLength > 0) {
          nonMaskedCount++;
        }
      }

      maskPos++;
    }

    if (nonMaskedCount > 0) {
      _resultTextMasked = _resultTextMasked.substring(
          0, _resultTextMasked.length - nonMaskedCount);
      cursorPos -= nonMaskedCount;
    }

    if (_resultTextArray.length > _maskLength) {
      _resultTextArray.removeRange(_maskLength, _resultTextArray.length);
    }

    final finalCursorPosition =
        cursorPos < 0 ? _resultTextMasked.length : cursorPos;

    return TextEditingValue(
        text: _resultTextMasked,
        selection: TextSelection(
            baseOffset: finalCursorPosition,
            extentOffset: finalCursorPosition,
            affinity: newValue.selection.affinity,
            isDirectional: newValue.selection.isDirectional));
  }

  void _calcMaskLength() {
    _maskLength = 0;
    final mask = _mask;
    if (mask != null) {
      for (var i = 0; i < mask.length; i++) {
        if (_maskChars.contains(mask[i])) {
          _maskLength++;
        }
      }
    }
  }

  void _updateFilter(Map<String, RegExp> filter) {
    _maskFilter = filter;
    _maskChars = _maskFilter?.keys.toList(growable: false) ?? [];
  }
}

class _TextMatcher {
  final List<String> _symbolArray = <String>[];

  int get length => _symbolArray.fold(0, (prev, match) => prev + match.length);

  void removeRange(int start, int end) => _symbolArray.removeRange(start, end);

  void insert(int start, String substring) {
    for (var i = 0; i < substring.length; i++) {
      _symbolArray.insert(start + i, substring[i]);
    }
  }

  void removeAt(int index) => _symbolArray.removeAt(index);

  String operator [](int index) => _symbolArray[index];

  void clear() => _symbolArray.clear();

  @override
  String toString() => _symbolArray.join();

  void set(String text) {
    _symbolArray.clear();
    for (var i = 0; i < text.length; i++) {
      _symbolArray.add(text[i]);
    }
  }
}
