/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 4 November 2026
 */

import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() {
  for (final (iso, input, expected) in <(String, String, String)>[
    ('GB', '07911123456', '+447911123456'),
    ('AU', '0412345678', '+61412345678'),
  ]) {
    testWidgets('manual $iso keeps literal trunk normalization', (
      tester,
    ) async {
      final controller = CountryPhoneController.apply(input);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: CountryPhoneInput(
              initialCountry: Country.fromCountryCode(iso),
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controller.phone.replaceAll(RegExp('[^+0-9]'), ''), expected);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  for (final extended in <bool>[false, true]) {
    for (final (prefix, stripPrefix, expected) in <(String, bool, String)>[
      ('8', true, '+79123456789'),
      ('0', true, '+79123456789'),
      ('8', false, '+789123456789'),
    ]) {
      testWidgets(
        'manual custom country handles $prefix with stripping=$stripPrefix; '
        'extended=$extended',
        (tester) async {
          final country = Country.ru().copyWith(countryCode: 'ZZ');
          final controller = CountryPhoneController.apply(
            '${prefix}9123456789',
          );
          addTearDown(controller.dispose);
          await tester.pumpWidget(
            createWidgetUnderTest(
              builder: (_) => Scaffold(
                body: extended
                    ? CountryPhoneInput.extended(
                        initialCountry: country,
                        controller: controller,
                        shouldReplace8: stripPrefix,
                      )
                    : CountryPhoneInput(
                        initialCountry: country,
                        controller: controller,
                        shouldReplace8: stripPrefix,
                      ),
              ),
            ),
          );
          await tester.pump();
          expect(controller.text.replaceAll(RegExp('[^+0-9]'), ''), expected);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }

    testWidgets(
      'switching formatting preserves text and selection; extended=$extended',
      (tester) async {
        final controller = CountryPhoneController.empty();
        addTearDown(controller.dispose);
        Future<void> showInput({required bool useCountryFormatting}) =>
            tester.pumpWidget(
              createWidgetUnderTest(
                builder: (_) => Scaffold(
                  body: extended
                      ? CountryPhoneInput.extended(
                          initialCountry: Country.fromCountryCode('ID'),
                          controller: controller,
                          useCountryFormatting: useCountryFormatting,
                        )
                      : CountryPhoneInput(
                          initialCountry: Country.fromCountryCode('ID'),
                          controller: controller,
                          useCountryFormatting: useCountryFormatting,
                        ),
                ),
              ),
            );
        final field = find.byKey(
          ValueKey<String>(
            extended ? 'country_phone_input_extended' : 'country_phone_number',
          ),
        );
        await showInput(useCountryFormatting: false);
        await tester.enterText(field, '81234567');
        await tester.pump();
        final editable = tester.widget<EditableText>(find.byType(EditableText));
        final editingController = editable.controller;
        const manualSelection = TextSelection(
          baseOffset: 8,
          extentOffset: 2,
          affinity: TextAffinity.upstream,
          isDirectional: true,
        );
        editingController.selection = manualSelection;
        await tester.pump();

        await showInput(useCountryFormatting: true);
        await tester.pump();
        expect(editingController.text, '812-345-67');
        expect(
          editingController.selection,
          manualSelection.copyWith(baseOffset: 9),
        );
        expect(
          controller.phone.replaceAll(RegExp('[^+0-9]'), ''),
          '+6281234567',
        );

        await showInput(useCountryFormatting: false);
        await tester.pump();
        expect(editingController.text, '812 34567');
        expect(editingController.selection, manualSelection);

        const caret = TextSelection.collapsed(offset: 2);
        editingController.selection = caret;
        await tester.pump();
        await showInput(useCountryFormatting: true);
        await tester.pump();
        expect(editingController.selection, caret);

        await tester.enterText(field, '812345678901');
        await tester.pump();
        expect(
          controller.phone.replaceAll(RegExp('[^+0-9]'), ''),
          '+62812345678901',
        );
        expect(controller.valueStatus.isComplete, isTrue);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'automatic ID input preserves all lengths; extended=$extended',
      (tester) async {
        final controller = CountryPhoneController.empty();
        addTearDown(controller.dispose);
        final country = Country.fromCountryCode('ID');
        await tester.pumpWidget(
          createWidgetUnderTest(
            builder: (_) => Scaffold(
              body: extended
                  ? CountryPhoneInput.extended(
                      initialCountry: country,
                      controller: controller,
                      useCountryFormatting: true,
                    )
                  : CountryPhoneInput(
                      initialCountry: country,
                      controller: controller,
                      useCountryFormatting: true,
                    ),
            ),
          ),
        );
        for (var length = 9; length <= 12; length++) {
          final digits = '812345678901'.substring(0, length);
          await tester.enterText(
            find.byKey(
              ValueKey<String>(
                extended
                    ? 'country_phone_input_extended'
                    : 'country_phone_number',
              ),
            ),
            digits,
          );
          await tester.pump();
          expect(
            controller.phone.replaceAll(RegExp('[^+0-9]'), ''),
            '+62$digits',
          );
          expect(controller.valueStatus.isComplete, isTrue);
        }
        await tester.enterText(
          find.byKey(
            ValueKey<String>(
              extended
                  ? 'country_phone_input_extended'
                  : 'country_phone_number',
            ),
          ),
          '0812345678901',
        );
        await tester.pump();
        expect(
          controller.phone.replaceAll(RegExp('[^+0-9]'), ''),
          '+62812345678901',
        );
        expect(controller.valueStatus.isComplete, isTrue);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'legacy widget paste keeps the significant ID 8; extended=$extended',
      (tester) async {
        final controller = CountryPhoneController.empty();
        addTearDown(controller.dispose);
        final country = Country.fromCountryCode('ID');
        await tester.pumpWidget(
          createWidgetUnderTest(
            builder: (_) => Scaffold(
              body: extended
                  ? CountryPhoneInput.extended(
                      initialCountry: country,
                      controller: controller,
                    )
                  : CountryPhoneInput(
                      initialCountry: country,
                      controller: controller,
                    ),
            ),
          ),
        );
        await tester.enterText(
          find.byKey(
            ValueKey<String>(
              extended
                  ? 'country_phone_input_extended'
                  : 'country_phone_number',
            ),
          ),
          '8123456789',
        );
        await tester.pump();
        expect(
          controller.phone.replaceAll(RegExp('[^+0-9]'), ''),
          '+628123456789',
        );
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
