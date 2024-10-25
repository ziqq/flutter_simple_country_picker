import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/widget_test_helper.dart';

const _key = Key('country');

void main() => group('Country -', () {
      group('getTranslatedName', () {
        testWidgets('should return localized country name if available',
            (tester) async {
          final country = Country.fromJson(const {
            'e164_cc': '1',
            'iso2_cc': 'US',
            'e164_sc': 1,
            'geographic': true,
            'level': 1,
            'name': 'United States',
            'example': '2012345678',
            'display_name': 'United States (US) [1]',
            'display_name_no_e164_cc': 'United States',
            'e164_key': 'us',
          });

          await tester.pumpWidget(
            WidgetTestHelper.createWidgetUnderTest(
              locale: const Locale('en'),
              builder: (context) => const Scaffold(
                key: _key,
                body: SizedBox.shrink(),
              ),
            ),
          );

          expect(find.byKey(_key), findsOneWidget);

          final context = tester.firstElement(find.byKey(_key));
          final translatedName = country.getTranslatedName(context);
          expect(translatedName, equals('United States'));
        });
      });
    });
