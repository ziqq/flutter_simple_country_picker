/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 10 November 2026
 */

import 'package:flutter_simple_country_picker/src/model/country.dart';
import 'package:flutter_simple_country_picker/src/util/country_phone_format_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryPhoneFormatResolver', () {
    late CountryPhoneFormatResolver indonesia;

    setUp(() {
      indonesia = CountryPhoneFormatResolver(Country.fromCountryCode('ID'));
    });

    group('supportedLengths', () {
      test('uses the lengths supported by the mobile prefix', () {
        expect(indonesia.supportedLengths('812345678'), [9, 10, 11, 12]);
        expect(indonesia.supportedLengths('212345678'), contains(8));
      });

      test('includes lengths without a corresponding display template', () {
        final resolver = CountryPhoneFormatResolver(
          Country.fromCountryCode('LU'),
        );
        expect(resolver.supportedLengths('2712'), contains(4));
      });
    });

    group('normalize', () {
      for (final prefix in ['+62 ', '0062 ', '62 ', '0']) {
        test('removes "$prefix" and preserves the significant leading 8', () {
          expect(
            indonesia.normalize(
              '${prefix}812-3456-78901',
              stripCode: true,
              stripTrunk: true,
              allowImplicitCode: true,
            ),
            '812345678901',
          );
        });
      }

      test('keeps a bare country code when implicit stripping is disabled', () {
        expect(
          indonesia.normalize(
            '62 812-3456-78901',
            stripCode: true,
            stripTrunk: true,
            allowImplicitCode: false,
          ),
          '62812345678901',
        );
      });
    });

    group('format', () {
      test('selects distinct landline and mobile layouts by prefix', () {
        expect(indonesia.format('212345678'), '21 2345678');
        expect(indonesia.format('812345678'), '812-345-678');
      });

      test('preserves the tail beyond the longest matching template', () {
        final resolver = CountryPhoneFormatResolver(
          Country.fromCountryCode('EE'),
        );
        expect(resolver.format('512345678'), '5123 45678');
      });

      test('prefers the more specific prefix when capacities are equal', () {
        final resolver = CountryPhoneFormatResolver(
          Country.fromCountryCode('AL'),
        );
        expect(resolver.format('220123456'), '22 012 3456');
      });
    });
  });
}
