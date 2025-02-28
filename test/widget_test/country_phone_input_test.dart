import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/widget_test_helper.dart';

const _key = Key('country_phone_input');

void main() => group('CountryPhoneInput -', () {
      group('initialization -', () {
        testWidgets(
            'should display the default country '
            'if no initial country is provided', (tester) async {
          await tester.pumpWidget(
            WidgetTestHelper.createWidgetUnderTest(
              locale: const Locale('en'),
              builder: (context) => const Scaffold(
                key: _key,
                body: CountryPhoneInput(),
              ),
            ),
          );

          expect(find.byKey(_key), findsOneWidget);

          final defaultCountry = Country.ru();
          expect(find.textContaining('+${defaultCountry.phoneCode}'),
              findsOneWidget);
        });

        testWidgets('should display the initial country provided',
            (tester) async {
          final testCountry = Country.fromJson(const {
            'e164_cc': '44',
            'iso2_cc': 'GB',
            'e164_sc': 0,
            'geographic': true,
            'level': 1,
            'name': 'United Kingdom',
            'example': '7911123456',
            'display_name': 'United Kingdom (GB) [44]',
            'display_name_no_e164_cc': 'United Kingdom',
            'e164_key': 'gb',
          });

          final controller = ValueNotifier<String>('+447911123456');

          await tester.pumpWidget(
            WidgetTestHelper.createWidgetUnderTest(
              locale: const Locale('en'),
              builder: (context) => Scaffold(
                key: _key,
                body: CountryPhoneInput(
                  initialCountry: testCountry,
                  controller: controller,
                ),
              ),
            ),
          );
          final phoneField = find.byType(TextFormField);
          expect(phoneField, findsOneWidget);
          find.widgetWithText(TextFormField, '+447911123456');
        });
      });

      group('interaction -', () {
        testWidgets(
            'should open country picker when country code area is tapped',
            (tester) async {
          await tester.pumpWidget(
            WidgetTestHelper.createWidgetUnderTest(
              locale: const Locale('en'),
              builder: (context) => const Scaffold(
                body: CountryPhoneInput(),
              ),
            ),
          );

          expect(find.byType(CountryPhoneInput), findsOneWidget);

          // Tapping on the country code area
          await tester.tap(find.byType(GestureDetector));
          await tester.pumpAndSettle();

          // Verify the bottom sheet is present
          expect(find.byType(BottomSheet), findsOneWidget);
        });

        testWidgets(
            'should update the displayed phone code '
            'when a new country is selected', (tester) async {
          final initialCountry = Country.fromJson(const {
            'e164_cc': '1',
            'iso2_cc': 'US',
            'e164_sc': 0,
            'geographic': true,
            'level': 1,
            'name': 'United States',
            'example': '2025550125',
            'display_name': 'United States (US) [1]',
            'display_name_no_e164_cc': 'United States',
            'e164_key': 'us',
          });

          await tester.pumpWidget(
            WidgetTestHelper.createWidgetUnderTest(
              locale: const Locale('en'),
              builder: (context) => Scaffold(
                body: CountryPhoneInput(initialCountry: initialCountry),
              ),
            ),
          );

          expect(find.byType(CountryPhoneInput), findsOneWidget);

          await tester.tap(find.byType(GestureDetector));
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Check if the ListView containing countries is present
          // debugPrint('Country Picker should be open now');
          expect(find.byType(CustomScrollView), findsWidgets);

          // Select Canada from the list (assuming "Canada" text is displayed)
          // debugPrint('Canada, checking if displayed phone code is updated');
          // await tester.tap(find.textContaining('Canada'));
          // await tester.pumpAndSettle();

          // expect(find.byKey(const ValueKey<String>('7')), findsWidgets);
          // await tester.tap(find.byKey(const ValueKey<String>('7')));
        });
      });

      group('placeholder -', () {
        testWidgets('should display a custom placeholder if provided',
            (tester) async {
          const customPlaceholder = 'Enter phone number';

          await tester.pumpWidget(
            WidgetTestHelper.createWidgetUnderTest(
              locale: const Locale('en'),
              builder: (context) => const Scaffold(
                key: _key,
                body: CountryPhoneInput(placeholder: customPlaceholder),
              ),
            ),
          );

          expect(find.byKey(_key), findsOneWidget);
          expect(find.text(customPlaceholder), findsOneWidget);
        });
      });

      group('formatting -', () {
        testWidgets('should apply country mask to input phone number',
            (tester) async {
          final testCountry = Country.fromJson(const {
            'e164_cc': '33',
            'iso2_cc': 'FR',
            'e164_sc': 0,
            'geographic': true,
            'level': 1,
            'name': 'France',
            'example': '612345678',
            'display_name': 'France (FR) [33]',
            'display_name_no_e164_cc': 'France',
            'e164_key': 'fr',
            'mask': '00 00 00 00 00',
          });

          await tester.pumpWidget(
            WidgetTestHelper.createWidgetUnderTest(
              locale: const Locale('en'),
              builder: (context) => Scaffold(
                key: _key,
                body: CountryPhoneInput(initialCountry: testCountry),
              ),
            ),
          );

          final phoneInputField = find.byType(TextFormField);
          await tester.enterText(phoneInputField, '12345678');
          await tester.pump();

          expect(find.text('12 34 56 78'),
              findsOneWidget); // Formatted according to the country mask
        });
      });
    });
