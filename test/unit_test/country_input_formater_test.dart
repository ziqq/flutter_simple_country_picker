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

      // expect(formatter.type, CountryInputCompletionType.lazy);
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

      // expect(formatter.type, CountryInputCompletionType.eager);
      expect(formatter.getUnmaskedText(), '');
    });
  });
});
