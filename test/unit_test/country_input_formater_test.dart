import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/src/util/country_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('CountryInputFormatter -', () {
  test('initializes with default values', () {
    final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');
    expect(formatter.getMask(), '+# (###) ###-##-##');
    expect(formatter.getMaskedText(), '');
    expect(formatter.getUnmaskedText(), '');
    expect(formatter.isFill, false);
  });

  test('switches to flat mode when input longer than mask', () {
    final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '123456789012345'),
    );

    expect(result.text, '123456789012345'); // flat digits-only
    expect(formatter.getMask(), isNull); // маска “сброшена”
    expect(formatter.getUnmaskedText(), '123456789012345');
  });

  test('formats input correctly with adjusted mask', () {
    final formatter = CountryInputFormatter(mask: '+# (###) ###-####');
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '01234567890'),
    );

    expect(result.text, '+0 (123) 456-7890');
    expect(formatter.getMaskedText(), '+0 (123) 456-7890');
    expect(formatter.getUnmaskedText(), '01234567890');
    expect(formatter.isFill, true);
  });

  test('handles incomplete input', () {
    final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '12345'),
    );

    expect(result.text, '+1 (234) 5');
    expect(formatter.getMaskedText(), '+1 (234) 5');
    expect(formatter.getUnmaskedText(), '12345');
    expect(formatter.isFill, false);
    expect(formatter.isIncomplete, true);
  });

  test('respects the filter for non-digit characters', () {
    final formatter = CountryInputFormatter(
      mask: 'AA-###',
      filter: {'A': RegExp('[A-Za-z]'), '#': RegExp(r'\d')},
    );

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: 'AB123'),
    );

    expect(result.text, 'AB-123');
    expect(formatter.getMaskedText(), 'AB-123');
    expect(formatter.getUnmaskedText(), 'AB123');
    expect(formatter.isFill, true);
  });

  test('removes invalid characters', () {
    final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '0sff1a2b3c4d5e6f7g8h9i0'),
    );

    expect(result.text, '+0 (123) 456-78-90');
    expect(formatter.getUnmaskedText(), '01234567890');
  });

  test('handles eager completion type', () {
    final formatter = CountryInputFormatter.eager(
      mask: '#/#/#',
      filter: {'#': RegExp(r'\d')},
    );

    var result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '11'),
    );

    // Ожидаем, что '/' добавится автоматически после первой цифры
    expect(result.text, '1/1/');
    expect(formatter.getMaskedText(), '1/1/');
    expect(formatter.getUnmaskedText(), '11');

    result = formatter.formatEditUpdate(
      const TextEditingValue(text: '1/1'),
      const TextEditingValue(text: '1/2'),
    );

    // Ожидаем, что следующая '/' добавится после второй цифры
    expect(result.text, '1/2');
    expect(formatter.getMaskedText(), '1/2');
    expect(formatter.getUnmaskedText(), '12');
  });

  test('updates mask and re-formats text', () {
    final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '12345678900'),
    );

    expect(result.text, '+1 (234) 567-89-00');

    formatter.updateMask(
      mask: '###-###-####',
      newValue: const TextEditingValue(
        text: '1234567890',
        selection: TextSelection.collapsed(offset: 10),
      ),
    );

    expect(formatter.getMaskedText(), '123-456-7890');
  });

  test('clear method resets formatter', () {
    final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##')
      ..formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1234567890'),
      );

    expect(formatter.getMaskedText(), '+1 (234) 567-89-0');

    formatter.clear();

    expect(formatter.getMaskedText(), '');
    expect(formatter.getUnmaskedText(), '');
  });

  group('type -', () {
    test('should return <CountryInputCompletionType> as lazy', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##')
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(text: '1234567890'),
        );

      expect(formatter.getMaskedText(), '+1 (234) 567-89-0');

      formatter.clear();

      expect(formatter.type, CountryInputCompletionType.lazy);
      expect(formatter.getUnmaskedText(), '');
    });

    test('should return <CountryInputCompletionType> as eager', () {
      final formatter = CountryInputFormatter.eager(mask: '+# (###) ###-##-##')
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(text: '1234567890'),
        );

      expect(formatter.getMaskedText(), '+1 (234) 567-89-0');

      formatter.clear();

      expect(formatter.type, CountryInputCompletionType.eager);
      expect(formatter.getUnmaskedText(), '');
    });
  });

  group('flat mode -', () {
    // mask '+# (###) ###-##-##' has 11 digit slots (_maskLength = 11)
    // overflow requires 12+ digits.

    test('enters flat mode when input exceeds mask capacity', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '123456789012'),
      );

      // flat mode: digits-only, mask dropped
      expect(result.text, '123456789012');
      expect(formatter.getMask(), isNull);
      expect(formatter.getUnmaskedText(), '123456789012');
    });

    test('stays in flat mode when more digits are added', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##')
        // step 1: enter flat mode
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(
            text: '123456789012',
            selection: TextSelection.collapsed(offset: 12),
          ),
        );

      // step 2: add one more digit while still flat
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '123456789012',
          selection: TextSelection.collapsed(offset: 12),
        ),
        const TextEditingValue(
          text: '1234567890123',
          selection: TextSelection.collapsed(offset: 13),
        ),
      );

      expect(result.text, '1234567890123');
      expect(formatter.getMask(), isNull);
    });

    test('restores mask when digits deleted back to mask capacity', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##')
        // step 1: enter flat mode with 12 digits
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(
            text: '123456789012',
            selection: TextSelection.collapsed(offset: 12),
          ),
        );

      // step 2: delete one digit → 11 digits = mask capacity
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '123456789012',
          selection: TextSelection.collapsed(offset: 12),
        ),
        const TextEditingValue(
          text: '12345678901',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );

      // mask is restored
      expect(result.text, '+1 (234) 567-89-01');
      expect(formatter.getMask(), '+# (###) ###-##-##');
    });

    test('restores mask and places cursor at start (digit index = 0)', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##')
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(
            text: '123456789012',
            selection: TextSelection.collapsed(offset: 12),
          ),
        );

      // delete while cursor is at offset 0 → flatCaretDigits = 0
      // exercises _offsetInMaskedForDigitIndex digitIndex <= 0 branch
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '123456789012',
          selection: TextSelection.collapsed(offset: 0),
        ),
        const TextEditingValue(
          text: '12345678901',
          selection: TextSelection.collapsed(offset: 0),
        ),
      );

      expect(result.text, '+1 (234) 567-89-01');
      expect(result.selection.baseOffset, 0);
    });

    test('restores mask and maps cursor by digit index (mid-string)', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##')
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(
            text: '123456789012',
            selection: TextSelection.collapsed(offset: 12),
          ),
        );

      // cursor after 5th digit (offset 5) → flatCaretDigits = 5
      // exercises _offsetInMaskedForDigitIndex with seen reaching digitIndex
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '123456789012',
          selection: TextSelection.collapsed(offset: 5),
        ),
        const TextEditingValue(
          text: '12345678901',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );

      expect(result.text, '+1 (234) 567-89-01');
      // cursor should be placed after the 5th digit in masked text
      expect(result.selection.baseOffset, greaterThan(0));
    });

    test('flat mode with invalid selection uses flat.length as caret', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

      // Enter flat mode with invalid selection
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '123456789012',
          selection: TextSelection(baseOffset: -1, extentOffset: -1),
        ),
      );

      expect(result.text, '123456789012');
      // caret should be at text end (flat.length)
      expect(result.selection.baseOffset, 12);
    });

    test('stays flat with invalid selection: caret uses flat.length', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##')
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(
            text: '123456789012',
            selection: TextSelection.collapsed(offset: 12),
          ),
        );

      // now add another digit with invalid selection while in flat mode
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '123456789012',
          selection: TextSelection(baseOffset: -1, extentOffset: -1),
        ),
        const TextEditingValue(
          text: '1234567890120',
          selection: TextSelection(baseOffset: -1, extentOffset: -1),
        ),
      );

      expect(result.text, '1234567890120');
      // caret at flat.length when selection invalid
      expect(result.selection.baseOffset, 13);
    });

    test(
      'tryRestoreMask: does NOT restore when digits still exceed capacity',
      () {
        final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##')
          // Enter flat mode with 13 digits
          ..formatEditUpdate(
            TextEditingValue.empty,
            const TextEditingValue(
              text: '1234567890123',
              selection: TextSelection.collapsed(offset: 13),
            ),
          );

        // Delete one → 12 digits, still above mask capacity (11)
        final result = formatter.formatEditUpdate(
          const TextEditingValue(
            text: '1234567890123',
            selection: TextSelection.collapsed(offset: 13),
          ),
          const TextEditingValue(
            text: '123456789012',
            selection: TextSelection.collapsed(offset: 12),
          ),
        );

        // still flat (12 > 11)
        expect(result.text, '123456789012');
        expect(formatter.getMask(), isNull);
      },
    );
  });

  group('overflow callbacks -', () {
    test('onOverflowChanged is called with true on overflow', () {
      var received = <bool>[];
      CountryInputFormatter(
        mask: '+# (###) ###-##-##',
        onOverflowChanged: received.add,
      ).formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '123456789012'),
      );

      expect(received, [true]);
    });

    test('onOverflowChanged is called with false when mask restored', () {
      final received = <bool>[];
      CountryInputFormatter(
          mask: '+# (###) ###-##-##',
          onOverflowChanged: received.add,
        )
        // enter overflow
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(
            text: '123456789012',
            selection: TextSelection.collapsed(offset: 12),
          ),
        )
        // restore (delete back to mask capacity)
        ..formatEditUpdate(
          const TextEditingValue(
            text: '123456789012',
            selection: TextSelection.collapsed(offset: 12),
          ),
          const TextEditingValue(
            text: '12345678901',
            selection: TextSelection.collapsed(offset: 11),
          ),
        );

      expect(received, [true, false]);
    });

    test('overflowNotifier value is updated on overflow', () {
      final notifier = ValueNotifier<bool>(false);
      CountryInputFormatter(
        mask: '+# (###) ###-##-##',
        overflowNotifier: notifier,
      ).formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '123456789012'),
      );

      expect(notifier.value, isTrue);
      notifier.dispose();
    });

    test('overflowNotifier reverts to false when mask is restored', () {
      final notifier = ValueNotifier<bool>(false);
      final formatter =
          CountryInputFormatter(
            mask: '+# (###) ###-##-##',
            overflowNotifier: notifier,
          )..formatEditUpdate(
            TextEditingValue.empty,
            const TextEditingValue(
              text: '123456789012',
              selection: TextSelection.collapsed(offset: 12),
            ),
          );
      expect(notifier.value, isTrue);

      formatter.formatEditUpdate(
        const TextEditingValue(
          text: '123456789012',
          selection: TextSelection.collapsed(offset: 12),
        ),
        const TextEditingValue(
          text: '12345678901',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );
      expect(notifier.value, isFalse);
      notifier.dispose();
    });
  });

  group('incomplete callbacks -', () {
    test('onIncompleteChanged tracks partial and complete input', () {
      final received = <bool>[];
      CountryInputFormatter(
          mask: '+# (###) ###-##-##',
          onIncompleteChanged: received.add,
        )
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(
            text: '12345',
            selection: TextSelection.collapsed(offset: 5),
          ),
        )
        ..formatEditUpdate(
          const TextEditingValue(
            text: '+1 (234) 5',
            selection: TextSelection.collapsed(offset: 10),
          ),
          const TextEditingValue(
            text: '+1 (234) 567-89-00',
            selection: TextSelection.collapsed(offset: 18),
          ),
        );

      expect(received, [true, false]);
    });

    test('incompleteNotifier is true only for partial non-empty input', () {
      final notifier = ValueNotifier<bool>(false);
      final formatter = CountryInputFormatter(
        mask: '+# (###) ###-##-##',
        incompleteNotifier: notifier,
      );

      expect(notifier.value, isFalse);

      formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '12345',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(notifier.value, isTrue);

      formatter.clear();
      expect(notifier.value, isFalse);

      notifier.dispose();
    });

    test('incompleteNotifier becomes false when input overflows', () {
      final notifier = ValueNotifier<bool>(false);
      final formatter =
          CountryInputFormatter(
            mask: '+# (###) ###-##-##',
            incompleteNotifier: notifier,
          )..formatEditUpdate(
            TextEditingValue.empty,
            const TextEditingValue(
              text: '12345',
              selection: TextSelection.collapsed(offset: 5),
            ),
          );
      expect(notifier.value, isTrue);

      formatter.formatEditUpdate(
        const TextEditingValue(
          text: '+1 (234) 5',
          selection: TextSelection.collapsed(offset: 10),
        ),
        const TextEditingValue(
          text: '123456789012',
          selection: TextSelection.collapsed(offset: 12),
        ),
      );

      expect(notifier.value, isFalse);
      notifier.dispose();
    });
  });

  group('updateMask with type -', () {
    test('can change completion type via updateMask', () {
      final formatter = CountryInputFormatter(mask: '#-#-#');
      expect(formatter.type, CountryInputCompletionType.lazy);

      formatter.updateMask(
        mask: '#-#-#',
        type: CountryInputCompletionType.eager,
      );

      expect(formatter.type, CountryInputCompletionType.eager);
    });

    test('updateMask resets flat mode', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##')
        // Enter flat mode with 12 digits (exceeds mask capacity of 11)
        ..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(text: '123456789012'),
        );
      expect(formatter.getMask(), isNull);

      // updateMask with a short newValue to avoid re-triggering overflow
      formatter.updateMask(
        mask: '+# (###) ###-##-##',
        newValue: const TextEditingValue(
          text: '71234567890',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );
      expect(formatter.getMask(), '+# (###) ###-##-##');
    });
  });

  group('maskText / unmaskText -', () {
    test('maskText applies mask to plain digits', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');
      expect(formatter.maskText('71234567890'), '+7 (123) 456-78-90');
    });

    test('maskText can normalize a full phone before masking', () {
      final formatter = CountryInputFormatter(
        mask: '0000 000000',
        phoneCode: '44',
        example: '7400123456',
        shouldTryStripPhoneCode: true,
        shouldTryStripLeadingPrefix: true,
      );

      expect(
        formatter.maskText(
          '447400123456',
          normalize: true,
          allowImplicitPhoneCodeStrip: true,
          allowLeadingPrefixStrip: true,
        ),
        '7400 123456',
      );
    });

    test('unmaskText extracts digits from masked text', () {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');
      expect(formatter.unmaskText('+7 (123) 456-78-90'), '71234567890');
    });
  });

  group('phone normalization -', () {
    test('normalizePhoneText strips 00 prefix before stripping phone code', () {
      final formatter = CountryInputFormatter(
        mask: '0000 000000',
        phoneCode: '44',
        example: '7400123456',
        shouldTryStripPhoneCode: true,
      );

      expect(
        formatter.normalizePhoneText(
          '00447400123456',
          allowImplicitPhoneCodeStrip: true,
        ),
        '7400123456',
      );
    });

    test(
      'normalizePhoneText keeps implicit phone code when stripping is disabled',
      () {
        final formatter = CountryInputFormatter(
          mask: '0000 000000',
          phoneCode: '44',
          example: '7400123456',
          shouldTryStripPhoneCode: true,
        );

        expect(
          formatter.normalizePhoneText(
            '447400123456',
            allowImplicitPhoneCodeStrip: false,
          ),
          '447400123456',
        );
      },
    );

    test('normalizePhoneText strips configured leading prefix', () {
      final formatter = CountryInputFormatter(
        mask: '000 000 0000',
        example: '9123456789',
        shouldTryStripLeadingPrefix: true,
        leadingPrefixes: const {'8'},
      );

      expect(
        formatter.normalizePhoneText(
          '89123456789',
          allowLeadingPrefixStrip: true,
        ),
        '9123456789',
      );
    });

    test('updateMask resets empty leadingPrefixes back to defaults', () {
      final formatter = CountryInputFormatter(
        mask: '000 000 0000',
        example: '9123456789',
        shouldTryStripLeadingPrefix: true,
        leadingPrefixes: const {'9'},
      )..updateMask(leadingPrefixes: const <String>{});

      expect(
        formatter.normalizePhoneText(
          '89123456789',
          allowLeadingPrefixStrip: true,
        ),
        '9123456789',
      );
    });

    test('formatEditUpdate normalizes pasted phone text when configured', () {
      final formatter = CountryInputFormatter(
        mask: '000 000 0000',
        phoneCode: '7',
        example: '9123456789',
        shouldTryStripPhoneCode: true,
        shouldTryStripLeadingPrefix: true,
      );

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '+7 999 123 45 67',
          selection: TextSelection.collapsed(offset: 16),
        ),
      );

      expect(result.text, '999 123 4567');
    });

    test('formatEditUpdate does not strip another country phone code', () {
      final formatter = CountryInputFormatter(
        mask: '00 000 0000',
        phoneCode: '994',
        example: '401234567',
        shouldTryStripPhoneCode: true,
        shouldTryStripLeadingPrefix: true,
      );

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '+79378032888',
          selection: TextSelection.collapsed(offset: 12),
        ),
      );

      expect(result.text, '79378032888');
    });
  });
});
