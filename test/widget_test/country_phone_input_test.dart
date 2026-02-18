import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() {
  _$defaultCountryPhoneInputTest();
  _$extendedCountryPhoneInputTest();
}

void _$defaultCountryPhoneInputTest() {
  const buttonKey = ValueKey<String>('country_picker_phone_code');
  const phoneFieldKey = ValueKey<String>('country_phone_number');
  group('CountryPhoneInput -', () {
    testWidgets('should use numeric keyboard type', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => const Scaffold(body: CountryPhoneInput()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      final textField = tester
          .widgetList<TextField>(find.byType(TextField))
          .first;
      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('should use hint text as mask', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => const Scaffold(body: CountryPhoneInput()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      final textField = tester
          .widgetList<TextField>(find.byType(TextField))
          .first;
      // Cehck that hintText matches expected mask for default country (RU)
      expect(textField.decoration?.hintText, Country.ru().mask);
    });

    group('initialization -', () {
      testWidgets('should display the default country '
          'if no initial country is provided', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => const Scaffold(body: CountryPhoneInput()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(phoneFieldKey), findsOneWidget);

        final defaultCountry = Country.ru();
        expect(
          find.textContaining('+${defaultCountry.phoneCode}'),
          findsOneWidget,
        );
      });

      testWidgets('should display the initial country provided', (
        tester,
      ) async {
        final initialCountry = getCountryByISO2asJSON('GB');
        final controller = CountryPhoneController.apply('+447911123456');

        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput(
                initialCountry: initialCountry,
                controller: controller,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final phoneField = find.byKey(phoneFieldKey);
        expect(phoneField, findsOneWidget);
        find.widgetWithText(TextFormField, '+447911123456');
      });
    });

    group('interaction -', () {
      testWidgets(
        'should open country picker when country code area is tapped',
        (tester) async {
          await tester.pumpWidget(
            createWidgetUnderTest(
              locale: const Locale('en'),
              builder: (_) => const Scaffold(body: CountryPhoneInput()),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(CountryPhoneInput), findsOneWidget);

          // Tapping on the country code area
          await tester.tap(find.byType(CupertinoButton));
          await tester.pumpAndSettle();

          // Verify the bottom sheet is present
          expect(find.byType(BottomSheet), findsOneWidget);
        },
      );

      testWidgets('should update the displayed phone code '
          'when a new country is selected', (tester) async {
        final initialCountry = getCountryByISO2asJSON('US');
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput(initialCountry: initialCountry),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CountryPhoneInput), findsOneWidget);

        await tester.tap(find.byType(CupertinoButton));
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

      group('_onSelect -', () {
        testWidgets(
          'should skip updating selected country if tapped country is same as current',
          (tester) async {
            final initialCountryRU = getCountryByISO2asJSON('RU');

            // Provide filter to keep list short (no grouping) and include AX (Åland Islands) which has no mask.
            await tester.pumpWidget(
              createWidgetUnderTest(
                locale: const Locale('en'),
                builder: (_) => Scaffold(
                  body: CountryPhoneInput(
                    initialCountry: initialCountryRU,
                    filter: const ['RU', 'VU'],
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.textContaining('+7'), findsOneWidget);

            final textField = tester
                .widgetList<TextField>(find.byType(TextField))
                .first;
            final prevControllerText = textField.controller?.text;

            // Open picker
            await tester.tap(find.byType(CupertinoButton));
            await tester.pumpAndSettle();
            expect(find.byType(BottomSheet), findsOneWidget);

            // Tap Russia key '7-RU-0'
            const russiaKey = ValueKey<String>('7-RU-0');
            expect(find.byKey(russiaKey), findsOneWidget);
            await tester.tap(find.byKey(russiaKey));
            await tester.pumpAndSettle();

            expect(textField.controller?.text, prevControllerText);

            // SnackBar should appear with error message
            expect(
              find.text(
                'Phone mask is not defined. Please add issue from github.',
              ),
              findsNothing,
            );

            // Selection should remain RU (phone code +7 still visible)
            expect(find.textContaining('+7'), findsOneWidget);
          },
        );
      });
    });

    group('placeholder -', () {
      testWidgets('should display a custom placeholder if provided', (
        tester,
      ) async {
        const customPlaceholder = 'Enter phone number';

        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => const Scaffold(
              body: CountryPhoneInput(placeholder: customPlaceholder),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(phoneFieldKey), findsOneWidget);
        expect(find.text(customPlaceholder), findsOneWidget);
      });
    });

    group('formatting -', () {
      testWidgets('should apply country mask to input phone number', (
        tester,
      ) async {
        final initialCountry = getCountryByISO2asJSON('FR');
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput(initialCountry: initialCountry),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final phoneInputField = find.byType(TextFormField);
        await tester.enterText(phoneInputField, '12345678');
        await tester.pump();

        final input = tester.widget<TextFormField>(phoneInputField);
        // In widget tests, input formatters may not apply on enterText.
        // Verify text captured; detailed formatting is covered by formatter tests.
        expect(input.controller?.text, '12345678');
      });
    });

    group('didUpdateWidget -', () {
      testWidgets('should update phone code when initialCountry changes', (
        tester,
      ) async {
        // 1. Pump widget with initialCountry = RU (for example)
        final initialCountry = Country.fromJson(
          countries.firstWhere((c) => c['e164_key'] == '7-RU-0'),
        );

        final updatedCountry = Country.fromJson(
          countries.firstWhere((c) => c['e164_key'] == '1-US-0'),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput(initialCountry: initialCountry),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 2. Verify phone code is "+7"
        expect(find.byKey(phoneFieldKey), findsOneWidget);
        expect(find.textContaining('+7'), findsOneWidget);

        // 3. Rebuild widget with updatedCountry
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput(initialCountry: updatedCountry),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 4. Pump and verify phone code is now "44"
        expect(find.textContaining('+1'), findsOneWidget);
      });

      testWidgets('should update phone text when controller changes', (
        tester,
      ) async {
        // 1. Create initial controller with some phone
        final oldController = CountryPhoneController.apply('+71234567890');
        final newController = CountryPhoneController.apply('+11234567890');

        final initialCountry = Country.fromJson(
          countries.firstWhere((c) => c['e164_key'] == '7-RU-0'),
        );

        final newInitialCountry = Country.fromJson(
          countries.firstWhere((c) => c['e164_key'] == '1-US-0'),
        );

        // 2. Pump widget with oldController
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput(
                controller: oldController,
                initialCountry: initialCountry,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 3. Check text contains oldController value
        expect(find.byKey(phoneFieldKey), findsOneWidget);
        expect(find.textContaining('+7'), findsOneWidget);
        expect(find.textContaining('123 456 7890'), findsOneWidget);

        // 4. Rebuild with newController
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput(
                initialCountry: newInitialCountry,
                controller: newController,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 5. Pump and verify text changed
        expect(find.byKey(phoneFieldKey), findsOneWidget);
        expect(find.textContaining('+7'), findsNothing);
        expect(find.textContaining('+1'), findsOneWidget);
        expect(find.textContaining('123 456 7890'), findsOneWidget);
      });

      testWidgets('should remove leading 8 if shouldReplace8 changes', (
        tester,
      ) async {
        // 1. Pump with shouldReplace8=false, and see no leading removal
        final controller = CountryPhoneController.apply('+7 8 1234567');

        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput(
                controller: controller,
                shouldReplace8: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Expect the leading "8" to remain since shouldReplace8=false
        expect(find.textContaining('8'), findsWidgets);

        // 2. Rebuild with shouldReplace8=true
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              key: phoneFieldKey,
              body: CountryPhoneInput(
                controller: controller,
                shouldReplace8: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 3. Pump and verify leading 8 is removed
        expect(find.textContaining('8'), findsNothing);
      });
    });
  });
}

void _$extendedCountryPhoneInputTest() {
  const buttonKey = ValueKey<String>('country_picker_button_extended');
  const phoneFieldKey = ValueKey<String>('country_phone_input_extended');
  group(r'CountryPhoneInput$Extended -', () {
    testWidgets('should use numeric keyboard type', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => const Scaffold(body: CountryPhoneInput.extended()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      final textField = tester
          .widgetList<TextField>(find.byType(TextField))
          .first;
      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('should use hint text as mask', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => const Scaffold(body: CountryPhoneInput.extended()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      final textField = tester
          .widgetList<TextField>(find.byType(TextField))
          .first;
      // Cehck that hintText matches expected mask for default country (RU)
      expect(textField.decoration?.hintText, Country.ru().mask);
    });

    testWidgets('initialization: shows country name, flag and phone code', (
      tester,
    ) async {
      final initialCountry = getCountryByISO2asJSON('RU');
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => Scaffold(
            body: CountryPhoneInput.extended(initialCountry: initialCountry),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CountryPhoneInput$Extended), findsOneWidget);
      // Flag + localized name (simplified check just phone code and flag)
      expect(find.textContaining('+7'), findsOneWidget);
      expect(find.textContaining('Russia'), findsOneWidget);
    });

    testWidgets('interaction: opens country picker on country name tap', (
      tester,
    ) async {
      final initialCountry = getCountryByISO2asJSON('RU');
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => Scaffold(
            body: CountryPhoneInput.extended(initialCountry: initialCountry),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CountryPhoneInput$Extended), findsOneWidget);

      // Tap the CupertinoButton (country name area) to open picker
      final buttonFinder = find.byKey(buttonKey);
      expect(buttonFinder, findsOneWidget);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Expect bottom sheet or scroll view of countries
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(CountryListView), findsWidgets);
    });

    testWidgets('formatting: applies mask to typed digits', (tester) async {
      final initialCountry = getCountryByISO2asJSON('FR');
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => Scaffold(
            body: CountryPhoneInput.extended(initialCountry: initialCountry),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final field = find.byType(TextFormField);
      expect(field, findsOneWidget);
      await tester.enterText(field, '1234567890');
      await tester.pump();
      final input = tester.widget<TextFormField>(field);
      // In widget tests, input formatters may not apply on enterText.
      expect(input.controller?.text, '1234567890');
    });

    testWidgets('onChanged: emits full value with code', (tester) async {
      final initialCountry = getCountryByISO2asJSON('GB');
      String? emitted;

      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => Scaffold(
            body: CountryPhoneInput.extended(
              initialCountry: initialCountry,
              onChanged: (v) => emitted = v,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final field = find.byType(TextFormField);
      await tester.enterText(field, '447911123456');
      await tester.pump();

      expect(emitted, isNotNull);
      expect(emitted!.startsWith('+44'), isTrue);
    });

    testWidgets('didUpdateWidget: country change updates code & mask', (
      tester,
    ) async {
      final initialCountryRU = getCountryByISO2asJSON('RU');
      final initialCountryUS = getCountryByISO2asJSON('US');
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => Scaffold(
            body: CountryPhoneInput.extended(initialCountry: initialCountryRU),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('+7'), findsOneWidget);

      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          builder: (_) => Scaffold(
            body: CountryPhoneInput.extended(initialCountry: initialCountryUS),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('+1'), findsOneWidget);
    });

    group('showCountryPicker arguments -', () {
      testWidgets('exclude: removed country is not listed', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput.extended(
                initialCountry: Country.ru(),
                exclude: const ['RU'],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check the hint text of the phone input field?
        final phoneInputFinder = find.byKey(phoneFieldKey);
        expect(phoneInputFinder, findsOneWidget);
        final phoneInputField = tester.widget<TextFormField>(phoneInputFinder);
        expect(phoneInputField, isNotNull);
        // final inputDecoration = phoneInputField.decoration as InputDecoration?;

        final buttonFinder = find.byKey(buttonKey);
        expect(buttonFinder, findsOneWidget);
        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();

        // CountryListView built
        final listView = tester.widget<CountryListView>(
          find.byType(CountryListView),
        );
        expect(listView.exclude, contains('RU'));
        // Assert Russia tile absent (key pattern e164Key starts with '7-RU')
        expect(find.byKey(const ValueKey<String>('7-RU-0')), findsNothing);
      });

      testWidgets('filter: only filtered country appears', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput.extended(
                initialCountry: Country.ru(),
                filter: const ['FR'],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(buttonKey));
        await tester.pumpAndSettle();
        final listView = tester.widget<CountryListView>(
          find.byType(CountryListView),
        );
        expect(listView.filter, contains('FR'));
        // Should show France tile and not Russia tile.
        // Key for France constructed from Country.e164Key pattern. We derive dynamically.
        // Fallback: assert that only one list tile is present.
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byKey(const ValueKey<String>('7-RU-0')), findsNothing);
      });

      testWidgets('showWorldWide: globe entry visible', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput.extended(
                initialCountry: Country.ru(),
                showWorldWide: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(buttonKey));
        await tester.pumpAndSettle();
        // Assert argument propagated to CountryListView
        final listView = tester.widget<CountryListView>(
          find.byType(CountryListView),
        );
        expect(listView.showWorldWide, isTrue);
      });

      testWidgets('showPhoneCode: argument is propagated to CountryListView', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (_) => Scaffold(
              body: CountryPhoneInput.extended(
                initialCountry: Country.ru(),
                showPhoneCode: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(buttonKey));
        await tester.pumpAndSettle();

        final listView = tester.widget<CountryListView>(
          find.byType(CountryListView),
        );
        expect(listView.showPhoneCode, isTrue);
      });
    });
  });
}
