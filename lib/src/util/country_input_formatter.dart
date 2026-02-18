/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

import 'dart:math';

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/services.dart';

/// Default filter for country input formatter.
final _kDefaultFilter = <String, RegExp>{
  '#': RegExp('[0-9]'),
  '0': RegExp('[0-9]'),
  'A': RegExp('[0-9]'),
};

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
/// Example: with mask `#/#`, input `1`, then `2` results in `1`, then `1/2`.
///
/// - [CountryInputCompletionType.eager]: unfiltered characters
/// are auto-completed immediately after the previous filtered character
/// is input.
/// Example: with mask `#/#`, input `1`, then `2` results in `1/`, then `1/2`.
class CountryInputFormatter implements TextInputFormatter {
  /// Constructor to initialize the formatter with [mask], [filter],
  /// and optional [initialText].
  ///
  /// You can choose [type] between [CountryInputCompletionType.lazy] or
  /// [CountryInputCompletionType.eager] to control the behavior of
  /// character completion.
  CountryInputFormatter({
    String? mask,
    String? initialText,
    Map<String, RegExp>? filter,
    CountryInputCompletionType type = CountryInputCompletionType.lazy,

    /// Notify UI about overflow (flat mode) state changes.
    ValueChanged<bool>? onOverflowChanged,

    /// Notifier to bind into UI without callback.
    ValueNotifier<bool>? overflowNotifier,
  }) : _type = type,
       _overflowNotifier = overflowNotifier,
       _onOverflowChanged = onOverflowChanged {
    updateMask(
      mask: mask,
      filter: filter ?? _kDefaultFilter,
      newValue: initialText == null
          ? null
          : TextEditingValue(
              text: initialText,
              selection: TextSelection.collapsed(offset: initialText.length),
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
         type: CountryInputCompletionType.eager,
       );

  /// Regexp to filter input characters for each mask symbol.
  static final RegExp _kDigit = RegExp(r'\d');

  /// Notify UI about overflow (flat mode) state changes.
  final ValueChanged<bool>? _onOverflowChanged;

  /// Notifier to bind into UI without callback.
  final ValueNotifier<bool>? _overflowNotifier;

  /// Indicates whether the formatter is in flat mode (mask overflow).
  ///
  /// Flat mode is enabled when input exceeds mask capacity.
  /// While in flat mode, formatter outputs digits-only text (no mask characters).
  bool _isFlatMode = false;

  /// Original mask that we can restore after user deletes characters back
  /// to mask capacity.
  ///
  /// Note: when mask overflow happens we set `_mask = null` to indicate that
  /// currently mask is not applied, but we keep the original here.
  String? _savedMask;

  /// Removes all non-digit characters from the input string.
  static String _digitsOnly(String s) {
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      if (_kDigit.hasMatch(ch)) b.write(ch);
    }
    return b.toString();
  }

  /// Counts the number of digit characters in the string [s]
  /// before the given [offset].
  static int _digitsCountBefore(String s, int offset) {
    final end = offset.clamp(0, s.length);
    var c = 0;
    for (var i = 0; i < end; i++) {
      if (_kDigit.hasMatch(s[i])) c++;
    }
    return c;
  }

  /// Finds cursor offset in masked text by "digits count before cursor".
  ///
  /// Example:
  /// - digitIndex=0 -> 0
  /// - digitIndex=3 -> position right after 3rd digit in masked string
  static int _offsetInMaskedForDigitIndex(String masked, int digitIndex) {
    if (digitIndex <= 0) return 0;

    var seen = 0;
    for (var i = 0; i < masked.length; i++) {
      if (_kDigit.hasMatch(masked[i])) {
        seen++;
        if (seen == digitIndex) {
          // caret goes after this digit
          return i + 1;
        }
      }
    }
    return masked.length;
  }

  /// Reformat from scratch in masked mode and then correct cursor position
  /// based on "digits before caret" in flat input.
  ///
  /// This is used when we restore mask after overflow. Without this step
  /// cursor may "jump" due to mask literals (spaces, brackets, dashes, etc.).
  TextEditingValue _reformatFromScratchWithCaret({
    required String flatDigits,
    required int flatCaretDigits,
    required TextEditingValue selectionMeta,
  }) {
    // Reset internal buffers to avoid mixing states
    clear();

    // Run formatter as if user typed from empty (stable for restore).
    final base = formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: flatDigits,
        selection: TextSelection.collapsed(
          offset: flatCaretDigits.clamp(0, flatDigits.length),
        ),
      ),
    );

    final correctedOffset = _offsetInMaskedForDigitIndex(
      base.text,
      flatCaretDigits,
    ).clamp(0, base.text.length);

    return base.copyWith(
      selection: TextSelection.collapsed(
        offset: correctedOffset,
        affinity: selectionMeta.selection.affinity,
      ),
      composing: TextRange.empty,
    );
  }

  /// Update the mask and optionally update the [filter] and [type].
  /// Pass a [newValue] to reformat an existing text value.
  TextEditingValue updateMask({
    String? mask,
    Map<String, RegExp>? filter,
    CountryInputCompletionType? type,
    TextEditingValue? newValue,
  }) {
    // Reset flat mode when mask updates.
    _setFlatMode(false);

    // Save mask for potential restore after overflow.
    _savedMask = mask;
    _mask = mask;

    if (type != null) _type = type;
    if (filter != null) _updateFilter(filter);
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

  /// Get the current completion type.
  CountryInputCompletionType get type => _type;
  CountryInputCompletionType _type;

  String? _mask;
  int _maskLength = 0;

  /// Mask symbols, e.g. ['#','0','A'] (kept for compatibility / debug)
  List<String> _maskChars = <String>[];

  /// O(1) membership checks for mask symbols.
  Set<String> _maskCharSet = const {};

  Map<String, RegExp>? _maskFilter;

  final _TextMatcher _resultTextArray = _TextMatcher();
  String _resultTextMasked = '';

  /// Get the current mask.
  String? getMask() => _mask;

  /// Get the current masked text.
  String getMaskedText() => _resultTextMasked;

  /// Get the current unmasked text.
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

  /// Restore mask if we are in flat mode and user has deleted enough digits
  /// to fit into the mask again.
  ///
  /// This keeps the UX intuitive:
  /// - overflow -> flat digits-only
  /// - delete back to <= mask length -> mask is applied again
  ///
  /// NOTE:
  /// Cursor is fixed separately by remapping it using "digit index" when mask
  /// is restored (see [_reformatFromScratchWithCaret]).
  void _tryRestoreMaskIfPossible({
    required TextEditingValue oldValue,
    required TextEditingValue newValue,
    required String flatDigits,
  }) {
    if (!_isFlatMode) return;

    final savedMask = _savedMask;
    if (savedMask == null || savedMask.isEmpty) return;

    if (flatDigits.length > _maskLength) return;

    // Restore only when deleting (prevents surprising jumps on paste).
    final isDeleting = newValue.text.length < oldValue.text.length;
    if (!isDeleting) return;

    _setFlatMode(false);
    _mask = savedMask;
  }

  /// Format the text input according to the mask and filter.
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Flat mode handling:
    // - We still watch deletions. When digits count becomes <= mask length,
    //   we restore the mask and re-run formatting for masked output with proper caret.
    if (_isFlatMode) {
      final flat = _digitsOnly(newValue.text);

      // Caret in flat-mode: "how many digits are before cursor"
      final flatCaretDigits = newValue.selection.isValid
          ? _digitsCountBefore(newValue.text, newValue.selection.extentOffset)
          : flat.length;

      _tryRestoreMaskIfPossible(
        oldValue: oldValue,
        newValue: newValue,
        flatDigits: flat,
      );

      // If still flat -> just return flat digits-only
      if (_isFlatMode) {
        _resultTextMasked = flat;
        _resultTextArray.set(flat);

        return TextEditingValue(
          text: flat,
          selection: TextSelection.collapsed(
            offset: flatCaretDigits.clamp(0, flat.length),
            affinity: newValue.selection.affinity,
          ),
          composing: TextRange.empty,
        );
      }

      // Mask was restored: reformat from scratch and map caret by digit index
      return _reformatFromScratchWithCaret(
        flatDigits: flat,
        flatCaretDigits: flatCaretDigits,
        selectionMeta: newValue,
      );
    }

    final mask = _mask;
    if (mask == null || mask.isEmpty) {
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

    for (
      var i = 0;
      i < beforeSelectionStart && i < beforeText.length && i < afterText.length;
      i++
    ) {
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

    for (
      var i = 0;
      i < min(beforeReplaceStart + beforeReplaceLength, mask.length);
      i++
    ) {
      if (_maskCharSet.contains(mask[i]) && currentResultTextLength > 0) {
        currentResultTextLength -= 1;
        if (i < beforeReplaceStart) {
          currentResultSelectionStart += 1;
        }
        if (i >= beforeReplaceStart) {
          currentResultSelectionLength += 1;
        }
      }
    }

    final replacementText = afterText.substring(
      afterChangeStart,
      afterChangeEnd,
    );

    var targetCursorPosition = currentResultSelectionStart;
    if (replacementText.isEmpty) {
      _resultTextArray.removeRange(
        currentResultSelectionStart,
        currentResultSelectionStart + currentResultSelectionLength,
      );
    } else {
      if (currentResultSelectionLength > 0) {
        _resultTextArray.removeRange(
          currentResultSelectionStart,
          currentResultSelectionStart + currentResultSelectionLength,
        );
        currentResultSelectionLength = 0;
      }
      _resultTextArray.insert(currentResultSelectionStart, replacementText);
      targetCursorPosition += replacementText.length;
    }

    if (beforeResultTextLength == 0 && _resultTextArray.length > 1) {
      var prefixLength = 0;
      for (var i = 0; i < mask.length; i++) {
        if (_maskCharSet.contains(mask[i])) {
          prefixLength = i;
          break;
        }
      }
      if (prefixLength > 0) {
        final resultPrefix = _resultTextArray.symbols
            .take(prefixLength)
            .toList();
        final effectivePrefixLength = min(
          _resultTextArray.length,
          resultPrefix.length,
        );
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

    var cursorPos = -1;
    var curTextPos = 0;
    var maskPos = 0;
    var maskInside = 0;
    var nonMaskedCount = 0;

    _resultTextMasked = '';

    // local refs (micro-opt)
    final maskFilter = _maskFilter;
    final isLazy = _type == CountryInputCompletionType.lazy;
    final isEager = _type == CountryInputCompletionType.eager;

    while (maskPos < mask.length) {
      final curMaskChar = mask[maskPos];
      final isMaskChar = _maskCharSet.contains(curMaskChar);

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
          if (maskFilter?[curMaskChar]?.hasMatch(potentialTextChar) ?? false) {
            curTextChar = potentialTextChar;
          } else {
            _resultTextArray.removeAt(curTextPos);
            curTextInRange = curTextPos < _resultTextArray.length;
            if (curTextPos <= targetCursorPosition) {
              targetCursorPosition -= 1;
            }
          }
        }
      } else if (!isMaskChar && !curTextInRange && isEager) {
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
          _resultTextMasked += curMaskChar;

          if (!isMaskChar &&
              curTextPos < _resultTextArray.length &&
              curMaskChar == _resultTextArray[curTextPos]) {
            if (isLazy && lengthAdded <= 1) {
              // keep original behavior
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

        if (isLazy ||
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
        0,
        _resultTextMasked.length - nonMaskedCount,
      );
      cursorPos -= nonMaskedCount;
    }

    // overflow => switch to flat (instead of trimming)
    if (_resultTextArray.length > _maskLength) {
      // Enter flat mode and drop the visible mask.
      _setFlatMode(true);

      // Keep original mask so we can restore it when user deletes extra digits.
      _savedMask ??= _mask;

      // IMPORTANT:
      // We DO NOT zero `_maskLength`.
      // `_maskLength` remains the capacity of the saved mask.
      _mask = null;

      final flat = _digitsOnly(newValue.text);
      _resultTextMasked = flat;
      _resultTextArray.set(flat);

      final caret = newValue.selection.isValid
          ? _digitsCountBefore(newValue.text, newValue.selection.extentOffset)
          : flat.length;

      return TextEditingValue(
        text: flat,
        selection: TextSelection.collapsed(offset: caret.clamp(0, flat.length)),
        composing: TextRange.empty,
      );
    }

    final finalCursorPosition = cursorPos < 0
        ? _resultTextMasked.length
        : cursorPos;

    return TextEditingValue(
      text: _resultTextMasked,
      selection: TextSelection(
        baseOffset: finalCursorPosition,
        extentOffset: finalCursorPosition,
        affinity: newValue.selection.affinity,
        isDirectional: newValue.selection.isDirectional,
      ),
    );
  }

  /// Calculate the length of the mask (number of mask characters).
  void _calcMaskLength() {
    _maskLength = 0;
    final mask = _mask;
    if (mask != null && mask.isNotEmpty) {
      for (var i = 0; i < mask.length; i++) {
        if (_maskCharSet.contains(mask[i])) {
          _maskLength++;
        }
      }
    }
  }

  /// Update the filter and related mask character lists.
  void _updateFilter(Map<String, RegExp> filter) {
    _maskFilter = filter;

    // keep original list for compatibility/debug
    _maskChars = _maskFilter?.keys.toList(growable: false) ?? const [];

    // set for fast lookup
    _maskCharSet = _maskChars.isEmpty ? const {} : _maskChars.toSet();
  }

  /// Set flat mode state and notify UI if needed.
  void _setFlatMode(bool value) {
    if (_isFlatMode == value) return;
    _isFlatMode = value;

    // Notify UI.
    _onOverflowChanged?.call(value);
    _overflowNotifier?.value = value;
  }
}

/// Internal helper class to manage text as a list of symbols.
///
/// OPT: caches total length to avoid fold() on each length call.
class _TextMatcher {
  _TextMatcher() : _symbols = <String>[];

  List<String> get symbols => _symbols;
  final List<String> _symbols;

  int _length = 0;

  /// Total character length (O(1)).
  int get length => _length;

  void removeRange(int start, int end) {
    // Bounds safety is responsibility of caller (same as original).
    for (var i = start; i < end; i++) {
      _length -= _symbols[i].length; // usually 1
    }
    _symbols.removeRange(start, end);
  }

  void insert(int start, String substring) {
    for (var i = 0; i < substring.length; i++) {
      _symbols.insert(start + i, substring[i]);
      _length += 1;
    }
  }

  void removeAt(int index) {
    _length -= _symbols[index].length; // usually 1
    _symbols.removeAt(index);
  }

  void set(String text) {
    _symbols.clear();
    _length = 0;
    for (var i = 0; i < text.length; i++) {
      _symbols.add(text[i]);
      _length += 1;
    }
  }

  void clear() {
    _symbols.clear();
    _length = 0;
  }

  @override
  String toString() => _symbols.join();

  String operator [](int index) => _symbols[index];
}
