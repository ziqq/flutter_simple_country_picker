/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 4 November 2026
 */

import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds an editing value with an explicit caret, as supplied by the IME.
TextEditingValue _edit(String text, {int? caret}) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: caret ?? text.length),
);

void main() {
  group('automatic country formatting', () {
    test(
      'initial automatic text and legacy completion getter retain all digits',
      () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode('ID'),
          initialText: '812345678',
        );
        expect(formatter.getUnmaskedText(), '812345678');
        expect(formatter.isFill, isTrue);
        formatter.formatEditUpdate(
          _edit(formatter.getMaskedText()),
          _edit('8123'),
        );
        expect(formatter.isFill, isFalse);
      },
    );

    test(
      'changing country without a new editing value preserves current digits',
      () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode('ID'),
          initialText: '8123456789',
        );
        final result = formatter.updateCountry(Country.ru());
        expect(result.text.replaceAll(RegExp(r'\D'), ''), '8123456789');
        expect(formatter.getUnmaskedText(), '8123456789');
        expect(formatter.isFill, isTrue);
      },
    );

    for (var length = 9; length <= 12; length++) {
      test('ID accepts $length digits without losing initial 8', () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode('ID'),
          shouldTryStripLeadingPrefix: true,
        );
        final digits = '812345678901'.substring(0, length);
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          _edit(digits),
        );
        expect(result.text.replaceAll(RegExp(r'\D'), ''), digits);
        expect(result.text, contains('-'));
        expect(formatter.valueStatus.isComplete, isTrue);
        expect(formatter.valueStatus.isOverflow, isFalse);
        expect(formatter.valueStatus.expectedLength, length);
      });
    }

    test('ID preserves overflow and its separators', () {
      final formatter = CountryInputFormatter.forCountry(
        country: Country.fromCountryCode('ID'),
      );
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _edit('81234567890123'),
      );
      expect(result.text.replaceAll(RegExp(r'\D'), ''), '81234567890123');
      expect(result.text, contains('-'));
      expect(formatter.valueStatus.isOverflow, isTrue);
      expect(formatter.valueStatus.isComplete, isFalse);
    });

    test(
      'disabled normalization retains international-looking leading zeros',
      () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode('ID'),
          shouldTryStripPhoneCode: false,
          shouldTryStripLeadingPrefix: false,
        );
        expect(
          formatter.maskText('001234').replaceAll(RegExp(r'\D'), ''),
          '001234',
        );
      },
    );

    for (final prefix in <String>['', '0', '+62 ', '0062 ', '62 ']) {
      test(
        'ID normalizes paste prefix "$prefix" independently of mask capacity',
        () {
          final formatter = CountryInputFormatter.forCountry(
            country: Country.fromCountryCode('ID'),
            shouldTryStripLeadingPrefix: true,
          );
          final result = formatter.formatEditUpdate(
            TextEditingValue.empty,
            _edit('${prefix}812345678901'),
          );
          expect(result.text.replaceAll(RegExp(r'\D'), ''), '812345678901');
          expect(formatter.valueStatus.isComplete, isTrue);
        },
      );
    }

    test(
      'prefix chooses ID fixed-line grouping rather than mobile grouping',
      () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode('ID'),
        );
        expect(formatter.maskText('212345678'), '21 2345678');
        expect(formatter.maskText('812345678'), '812-345-678');
      },
    );

    for (final (iso, digits, expected) in <(String, String, String)>[
      ('EE', '51234567', '5123 4567'),
      ('CN', '1012345678', '10 1234 5678'),
      ('IR', '2123456789', '21 2345 6789'),
    ]) {
      test('$iso uses a full-length format before extending a shorter one', () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode(iso),
        );
        expect(formatter.maskText(digits), expected);
      });
    }

    test('overflow extends the longest applicable EE template', () {
      final formatter = CountryInputFormatter.forCountry(
        country: Country.fromCountryCode('EE'),
      );
      final full = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _edit('51234567'),
      );
      final overflow = formatter.formatEditUpdate(full, _edit('${full.text}8'));
      expect(full.text, '5123 4567');
      expect(overflow.text, '5123 45678');
      expect(formatter.valueStatus.isOverflow, isTrue);
    });

    test('AL overflow keeps the more specific of equal-capacity templates', () {
      final formatter = CountryInputFormatter.forCountry(
        country: Country.fromCountryCode('AL'),
      );

      expect(formatter.maskText('220123456'), '22 012 3456');
    });

    test('LU supports a national length without a display template', () {
      final formatter = CountryInputFormatter.forCountry(
        country: Country.fromCountryCode('LU'),
      )..formatEditUpdate(TextEditingValue.empty, _edit('2712'));
      expect(formatter.valueStatus.isComplete, isTrue);
      expect(formatter.valueStatus.expectedLength, 4);
    });

    test('ID mobile does not inherit shorter fixed-line lengths', () {
      final formatter = CountryInputFormatter.forCountry(
        country: Country.fromCountryCode('ID'),
      )..formatEditUpdate(TextEditingValue.empty, _edit('8123456'));
      expect(formatter.valueStatus.isComplete, isFalse);
      expect(formatter.valueStatus.expectedLength, 9);
    });

    test('both reversed selection endpoints survive reformatting', () {
      final formatter = CountryInputFormatter.forCountry(
        country: Country.fromCountryCode('ID'),
      );
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '8123456789',
          selection: TextSelection(
            baseOffset: 8,
            extentOffset: 3,
            isDirectional: true,
          ),
        ),
      );
      expect(
        result.text
            .substring(0, result.selection.baseOffset)
            .replaceAll(RegExp(r'\D'), '')
            .length,
        8,
      );
      expect(
        result.text
            .substring(0, result.selection.extentOffset)
            .replaceAll(RegExp(r'\D'), '')
            .length,
        3,
      );
      expect(result.selection.isDirectional, isTrue);
    });

    test(
      'paste normalization retains a middle caret instead of jumping to the end',
      () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode('ID'),
        );
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          _edit('+62 8123456789', caret: 8),
        );
        expect(
          result.text
              .substring(0, result.selection.extentOffset)
              .replaceAll(RegExp(r'\D'), ''),
          '8123',
        );
      },
    );

    test('active composing is untouched until commit', () {
      final formatter = CountryInputFormatter.forCountry(
        country: Country.fromCountryCode('ID'),
      );
      const composing = TextEditingValue(
        text: '8123456789',
        selection: TextSelection.collapsed(offset: 6),
        composing: TextRange(start: 0, end: 10),
      );
      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, composing),
        composing,
      );
      final committed = formatter.formatEditUpdate(
        composing,
        composing.copyWith(composing: TextRange.empty),
      );
      expect(committed.text, '812-3456-789');
      expect(committed.composing, TextRange.empty);
    });

    test('backspace over a separator removes the preceding digit', () {
      final formatter = CountryInputFormatter.forCountry(
        country: Country.fromCountryCode('ID'),
      );
      final previous = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _edit('812345678'),
      );
      final result = formatter.formatEditUpdate(
        previous.copyWith(selection: const TextSelection.collapsed(offset: 4)),
        _edit('812345-678', caret: 3),
      );
      expect(result.text.replaceAll(RegExp(r'\D'), ''), '81345678');
      expect(result.selection.extentOffset, 2);
    });

    test(
      'embedded NANP region prefix is not repeated in the national input',
      () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode('BS'),
        );
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          _edit('+12425551234'),
        );
        expect(result.text.replaceAll(RegExp(r'\D'), ''), '5551234');
        expect(formatter.valueStatus.expectedLength, 7);
        expect(formatter.valueStatus.isComplete, isTrue);
      },
    );

    test(
      'manual constructors, null masks and custom filters retain their contract',
      () {
        final manual = CountryInputFormatter(mask: '##-##');
        expect(manual.maskText('12345'), '12345');
        expect(CountryInputFormatter().maskText('abc 123'), 'abc 123');
        expect(
          CountryInputFormatter(
            mask: 'X/X',
            filter: {'X': RegExp('[a-z]')},
          ).maskText('ab'),
          'a/b',
        );
      },
    );

    test(
      'updateMask explicitly returns an automatic formatter to manual mode',
      () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode('ID'),
        );
        expect(
          formatter.updateMask(mask: '#/#', newValue: _edit('12')).text,
          '1/2',
        );
        expect(formatter.maskText('123'), '123');
      },
    );

    test('all bundled country examples retain their digits', () {
      for (final data in countries) {
        final country = Country.fromJson(data);
        final digits = country.example.replaceAll(RegExp(r'\D'), '');
        final formatter = CountryInputFormatter.forCountry(
          country: country,
          shouldTryStripPhoneCode: false,
        );
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          _edit(digits),
        );
        expect(
          result.text.replaceAll(RegExp(r'\D'), ''),
          digits,
          reason: country.countryCode,
        );
      }
    });

    for (final iso in <String>['VA', 'HM', 'GS']) {
      test('$iso fallback keeps a soft tail and reports overflow', () {
        final formatter = CountryInputFormatter.forCountry(
          country: Country.fromCountryCode(iso),
        );
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          _edit('1234567890123'),
        );
        expect(result.text.replaceAll(RegExp(r'\D'), ''), '1234567890123');
        expect(formatter.valueStatus.isOverflow, isTrue);
      });
    }
  });
}
