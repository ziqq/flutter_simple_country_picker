import 'package:flutter_simple_country_picker/src/constant/country_code/country_codes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('Country data -', () {
      group(r'countries$Favorite', () {
        for (final country in countries$Favorite) {
          final iso2Cc = country['iso2_cc']; // e.g: RU
          final name = country['name']; // e.g: Russia
          final phoneExample = country['example']; // e.g: 79111234567
          final phoneMask = country['mask']; // e.g: 000 000 0000

          test('check phone example for $name ($iso2Cc)', () {
            expect(
              phoneExample,
              isNotEmpty,
              reason: 'Example phone should not be empty',
            );
          });

          test('check mask format for $name ($iso2Cc)', () {
            expect(
              phoneMask,
              isNotEmpty,
              reason: 'Phone mask should not be empty',
            );
            expect(
              phoneMask,
              matches(RegExp(r'^[0-9 ]+$')),
              reason: 'Phone mask should only contain digits and spaces',
            );
          });

          test('check ISO2 code for $name ($iso2Cc)', () {
            expect(
              iso2Cc,
              matches(RegExp(r'^[A-Z]{2}$')),
              reason: 'ISO2 code should be a 2-letter code',
            );
          });

          test('check country name for $iso2Cc', () {
            expect(
              name,
              isNotEmpty,
              reason: 'Country name should not be empty',
            );
          });
        }
      });
    });
