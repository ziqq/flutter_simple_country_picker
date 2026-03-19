/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 27 January 2026
 */

import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart'
    show countries;
import 'package:flutter_test/flutter_test.dart';

void main() => group('CountryPhoneController -', () {
  final countryCodesByPhone = <String, Set<String>>{};
  for (final entry in countries) {
    final phoneFull = entry['full_example_with_plus_sign']?.toString();
    final countryCode = entry['iso2_cc']?.toString();
    if (phoneFull == null || phoneFull.isEmpty) continue;
    if (countryCode == null || countryCode.isEmpty) continue;
    countryCodesByPhone
        .putIfAbsent(phoneFull, () => <String>{})
        .add(countryCode);
  }

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

  group('resolution behavior -', () {
    test('resolves shared +7 calling code exactly when examples diverge', () {
      final russia = CountryPhoneController.apply('+79123456789');
      final kazakhstan = CountryPhoneController.apply('+77710009998');

      expect(russia.resolution.status, CountryPhoneResolutionStatus.exact);
      expect(russia.resolution.primaryCountryCode, 'RU');
      expect(russia.resolution.countryCodes, <String>['RU']);

      expect(kazakhstan.resolution.status, CountryPhoneResolutionStatus.exact);
      expect(kazakhstan.resolution.primaryCountryCode, 'KZ');
      expect(kazakhstan.resolution.countryCodes, <String>['KZ']);
    });

    test('resolves +61 to Australia exactly', () {
      final controller = CountryPhoneController.apply('+61123456789');

      expect(controller.resolution.status, CountryPhoneResolutionStatus.exact);
      expect(controller.resolution.primaryCountryCode, 'AU');
      expect(controller.resolution.countryCodes, <String>['AU']);
      expect(controller.resolution.isAmbiguous, isFalse);
    });

    test('resolves +212 to Morocco exactly', () {
      final controller = CountryPhoneController.apply('+212650123456');

      expect(controller.resolution.status, CountryPhoneResolutionStatus.exact);
      expect(controller.resolution.primaryCountryCode, 'MA');
      expect(controller.resolution.countryCodes, <String>['MA']);
      expect(controller.resolution.isAmbiguous, isFalse);
    });

    test('resolves +590 to Guadeloupe exactly', () {
      final controller = CountryPhoneController.apply('+590690301234');

      expect(controller.resolution.status, CountryPhoneResolutionStatus.exact);
      expect(controller.resolution.primaryCountryCode, 'GP');
      expect(controller.resolution.countryCodes, <String>['GP']);
      expect(controller.resolution.isAmbiguous, isFalse);
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
        'for phone number $phoneFull should include country ISO2 ($countryCode)',
        () {
          final controller = CountryPhoneController.apply(phoneFull);
          expect(controller.resolution.countryCodes, contains(countryCode));

          final duplicates = countryCodesByPhone[phoneFull] ?? const <String>{};
          if (duplicates.length == 1) {
            expect(controller.resolution.primaryCountryCode, countryCode);
            expect(controller.resolution.isResolved, isTrue);
            expect(controller.resolution.isAmbiguous, isFalse);
          } else {
            expect(controller.resolution.isAmbiguous, isTrue);
          }
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
