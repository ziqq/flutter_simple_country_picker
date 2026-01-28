/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 27 January 2026
 */

import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart'
    show countries;
import 'package:flutter_test/flutter_test.dart';

void main() => group('CountryPhoneController -', () {
  group('simple tests -', () {
    const phone = '+71234567890';
    const phoneSpaced = '+7 123 456 78 90';
    const phoneWithoutCode = '1234567890';

    test('should return phone number without country code', () {
      final controller = CountryPhoneController.apply(phone);
      expect(controller.phone, phone);
      expect(controller.number, phoneWithoutCode);
    });

    test('should return phone number without country code & space', () {
      final controller = CountryPhoneController.apply(phoneSpaced);
      expect(controller.phone, phone);
      expect(controller.number, phoneWithoutCode);
    });
  });
  for (final entry in countries) {
    final countryCode = entry['iso2_cc']?.toString();
    final phoneCode = entry['e164_cc']?.toString();
    final phoneFull = entry['full_example_with_plus_sign']?.toString();
    final phone = phoneFull?.replaceFirst('+', '');
    final number = phoneFull
        ?.replaceFirst('+', '')
        .replaceFirst(phoneCode ?? '', '');

    /* e164_cc, iso2_cc, e164_sc, geographic, level, name, example, display_name, mask, full_example_with_plus_sign, display_name_no_e164_cc, e164_key */
    group('object of ($countryCode) -', () {
      test('should contain e164_cc key', () {
        expect(entry.containsKey('e164_cc'), isTrue);
      });
      test('should contain iso2_cc key', () {
        expect(entry.containsKey('iso2_cc'), isTrue);
      });
      test('should contain geographic key', () {
        expect(entry.containsKey('geographic'), isTrue);
      });
      test('should contain level key', () {
        expect(entry.containsKey('level'), isTrue);
      });
      test('should contain name key', () {
        expect(entry.containsKey('name'), isTrue);
      });
      test('should contain example key', () {
        expect(entry.containsKey('example'), isTrue);
      });
      test('should contain display_name key', () {
        expect(entry.containsKey('display_name'), isTrue);
      });
      test('should contain mask key', () {
        expect(entry.containsKey('mask'), isTrue);
      });
      test('should contain full_example_with_plus_sign key', () {
        expect(entry.containsKey('full_example_with_plus_sign'), isTrue);
      });
      test('should contain display_name_no_e164_cc key', () {
        expect(entry.containsKey('display_name_no_e164_cc'), isTrue);
      });
      test('should contain e164_key key', () {
        expect(entry.containsKey('e164_key'), isTrue);
      });
    });

    if (countryCode == null ||
        countryCode.isEmpty ||
        phoneFull == null ||
        phoneFull.isEmpty ||
        phoneCode == null ||
        phone == null ||
        phone.isEmpty) {
      continue;
    }

    group('phone -', () {
      test('for phone number $phoneFull should return full phone number', () {
        final controller = CountryPhoneController.apply(phoneFull);
        expect(controller.phone, phoneFull);
      });
    });

    group('number -', () {
      test(
        'for phone number $phoneFull should return phone number without coutnry code and without + sign',
        () {
          final controller = CountryPhoneController.apply(phoneFull);
          expect(controller.number, number);
        },
      );
    });

    group('countryCode -', () {
      test(
        'for phone number $phoneFull should return country ISO2 ($countryCode)',
        () {
          final controller = CountryPhoneController.apply(phoneFull);
          expect(controller.countryCode, countryCode);
        },
      );
    });

    group('phoneCode -', () {
      test(
        'for phone number $phoneFull should return country phone code $phoneCode without + sign',
        () {
          final controller = CountryPhoneController.apply(phoneFull);
          expect(controller.phoneCode, phoneCode.replaceFirst('+', ''));
        },
      );
    });
  }
});
