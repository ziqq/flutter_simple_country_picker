import 'dart:convert';
import 'dart:io';

import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('country_codes_test -', () {
  group('dart -', () {
    for (final country in countries) {
      final e164KEY = country['e164_key']; // e.g: 7-RU-0
      final e164cc = country['e164_cc']; // e.g: 7
      final iso2 = country['iso2_cc']; // e.g: RU
      final name = country['name']; // e.g: Russia
      // final phoneMask = country['mask']; // e.g: 000 000 0000
      // final phoneExample = country['example']; // e.g: 79111234567
      final geographic = country['geographic']; // e.g: true or false

      test('check country name', () {
        expect(name, isNotEmpty, reason: 'Country name should not be empty');
      });

      test('check country code (e164_cc) for $name ($e164cc)', () {
        expect(e164cc, isNotEmpty, reason: 'E164 CC should not be empty');
      });

      test('check country e164 key for $name ($e164KEY)', () {
        expect(e164KEY, isNotEmpty, reason: 'e164 key should not be empty');
      });

      // TODO(ziqq): Add phone example to each country in country_codes.dart, https://github.com/ziqq/flutter_simple_country_picker/issues/11
      // Anton Ustinoff <a.a.ustinoff@gmail.com>, 22 January 2026
      /* test('check phone example for $name ($phoneExample)', () {
        expect(
          phoneExample,
          isNotEmpty,
          reason: 'Example phone should not be empty',
        );
      }); */

      // TODO(ziqq): Add phone mask to each country in country_codes.dart, https://github.com/ziqq/flutter_simple_country_picker/issues/11
      // Anton Ustinoff <a.a.ustinoff@gmail.com>, 22 January 2026
      /* test('check phone mask format for $name ($phoneMask)', () {
        expect(phoneMask, isNotEmpty, reason: 'Phone mask should not be empty');
        expect(
          phoneMask,
          matches(RegExp(r'^[0-9 ]+$')),
          reason: 'Phone mask should only contain digits and spaces',
        );
      }); */

      test('check ISO2 code for $name ($iso2)', () {
        expect(
          iso2,
          matches(RegExp(r'^[A-Z]{2}$')),
          reason: 'ISO2 code should be a 2-letter code',
        );
      });

      test('check geographic for $name ($geographic)', () {
        expect(
          geographic,
          isA<bool>(),
          reason: 'Geographic should be a boolean value',
        );
        expect(geographic, isNotNull, reason: 'Geographic should not be null');
      });
    }
  });

  test('json matches dart (all keys/values)', () {
    final jsonFile = File('lib/src/constant/country_codes.json');
    expect(
      jsonFile.existsSync(),
      isTrue,
      reason: 'Expected ${jsonFile.path} to exist. Run the generator script.',
    );

    final decoded = jsonDecode(jsonFile.readAsStringSync());
    expect(decoded, isA<List<Object?>>());

    final jsonList = (decoded as List<Object?>)
        .whereType<Map<Object?, Object?>>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList(growable: false);

    expect(
      jsonList.length,
      countries.length,
      reason: 'JSON list length must match Dart list length.',
    );

    final dartByKey = <String, Map<String, Object?>>{};
    for (final country in countries) {
      final key = country['e164_key'];
      expect(key, isA<String>(), reason: 'Each Dart entry must have e164_key');
      final k = key as String;
      expect(
        dartByKey.containsKey(k),
        isFalse,
        reason: 'Duplicate e164_key in Dart list: $k',
      );
      dartByKey[k] = country;
    }

    final jsonByKey = <String, Map<String, Object?>>{};
    for (final country in jsonList) {
      final key = country['e164_key'];
      expect(key, isA<String>(), reason: 'Each JSON entry must have e164_key');
      final k = key as String;
      expect(
        jsonByKey.containsKey(k),
        isFalse,
        reason: 'Duplicate e164_key in JSON file: $k',
      );
      jsonByKey[k] = country;
    }

    expect(
      jsonByKey.keys.toSet(),
      equals(dartByKey.keys.toSet()),
      reason: 'JSON and Dart must contain the same e164_key set.',
    );

    for (final entry in dartByKey.entries) {
      final e164Key = entry.key;
      final dartCountry = entry.value;
      final jsonCountry = jsonByKey[e164Key];

      expect(
        jsonCountry,
        isNotNull,
        reason: 'Missing JSON entry for e164_key=$e164Key',
      );
      if (jsonCountry == null) continue;

      final dartKeys = dartCountry.keys.toSet();
      final jsonKeys = jsonCountry.keys.toSet();
      expect(
        jsonKeys,
        equals(dartKeys),
        reason: 'Key-set mismatch for e164_key=$e164Key',
      );

      for (final key in dartKeys) {
        expect(
          jsonCountry.containsKey(key),
          isTrue,
          reason: 'Missing key `$key` in JSON for e164_key=$e164Key',
        );
        expect(
          jsonCountry[key],
          equals(dartCountry[key]),
          reason: 'Value mismatch for e164_key=$e164Key key=$key',
        );
      }
    }
  });
});
