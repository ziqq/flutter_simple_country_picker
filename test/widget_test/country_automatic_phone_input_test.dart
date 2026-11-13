/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 4 November 2026
 */

import 'dart:ui' as ui;

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
        expect(editingController.text, '812 34567');
        expect(editingController.selection, manualSelection);
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
      'automatic ID rejects a national number of zeros; extended=$extended',
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
        final field = find.byType(TextFormField);
        await tester.enterText(field, '000 000000');
        await tester.pump();

        expect(controller.valueStatus.currentLength, 9);
        expect(controller.valueStatus.expectedLength, 9);
        expect(controller.valueStatus.isAllZeros, isTrue);
        expect(controller.valueStatus.isComplete, isFalse);
        expect(controller.valueStatus.isOverflow, isFalse);

        await tester.enterText(field, '812345678');
        await tester.pump();

        expect(controller.valueStatus.isAllZeros, isFalse);
        expect(controller.valueStatus.isComplete, isTrue);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'automatic ID hint shrinks, disappears, and returns; extended=$extended',
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
        final field = find.byType(TextFormField);
        await tester.showKeyboard(field);
        final emptyHint = await _paintedHintPixels(tester, field);
        expect(emptyHint, greaterThan(0));

        Future<void> edit(String text) async {
          tester.testTextInput.updateEditingValue(
            TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            ),
          );
          await tester.pump();
        }

        final editable = tester.widget<EditableText>(find.byType(EditableText));
        await edit('240');
        await edit('2404');
        expect(editable.controller.text, '240 4');
        expect(controller.number, '2404');
        final partialHint = await _paintedHintPixels(tester, field);
        expect(partialHint, inExclusiveRange(0, emptyHint));

        await edit('240 412345');
        expect(editable.controller.text, '240 412345');
        expect(await _paintedHintPixels(tester, field), 0);

        await edit('240 412345678');
        expect(editable.controller.text, '240 412345678');
        expect(controller.number, '240412345678');
        expect(controller.valueStatus.isOverflow, isTrue);
        expect(await _paintedHintPixels(tester, field), 0);

        await edit('240 4');
        expect(editable.controller.text, '240 4');
        expect(controller.number, '2404');
        expect(controller.valueStatus.isOverflow, isFalse);
        expect(await _paintedHintPixels(tester, field), partialHint);

        await edit('');
        expect(editable.controller.text, isEmpty);
        expect(controller.valueStatus.isEmpty, isTrue);
        expect(await _paintedHintPixels(tester, field), emptyHint);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'automatic hint survives rebuilds in Material 2; extended=$extended',
      (tester) async {
        final controller = CountryPhoneController.empty();
        addTearDown(controller.dispose);
        final country = Country.fromCountryCode('ID');
        final theme = ThemeData.light(useMaterial3: false);
        final inputTheme = theme.copyWith(
          textTheme: theme.textTheme.copyWith(
            bodyLarge: const TextStyle(fontSize: 16),
            titleMedium: const TextStyle(fontSize: 16),
          ),
          inputDecorationTheme: const InputDecorationTheme(isDense: true),
        );
        Future<void> showInput(TextScaler textScaler) => tester.pumpWidget(
          createWidgetUnderTest(
            builder: (context) => Theme(
              data: inputTheme,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(boldText: true, textScaler: textScaler),
                child: Scaffold(
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
            ),
          ),
        );

        await showInput(TextScaler.noScaling);
        final field = find.byType(TextFormField);
        await tester.enterText(field, '2404');
        await tester.pump();
        final hintPixels = await _paintedHintPixels(tester, field);
        expect(hintPixels, greaterThan(0));

        await showInput(TextScaler.noScaling);
        expect(await _paintedHintPixels(tester, field), hintPixels);

        await showInput(const TextScaler.linear(1.4));
        expect(
          await _paintedHintPixels(tester, field),
          greaterThan(hintPixels),
        );
        expect(controller.number, '2404');
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

/// Counts the pixels painted by the field's hint layer in isolation.
Future<int> _paintedHintPixels(WidgetTester tester, Finder field) async {
  final paint = tester
      .widgetList<CustomPaint>(
        find.ancestor(of: field, matching: find.byType(CustomPaint)),
      )
      .singleWhere((widget) => widget.child is TextFormField);
  final size = tester.getSize(find.byWidget(paint));
  final recorder = ui.PictureRecorder();
  paint.foregroundPainter!.paint(Canvas(recorder), size);
  final picture = recorder.endRecording();
  try {
    final pixels = await tester.runAsync(() async {
      final image = await picture.toImage(
        size.width.ceil(),
        size.height.ceil(),
      );
      try {
        final bytes = (await image.toByteData())!;
        var count = 0;
        for (var index = 3; index < bytes.lengthInBytes; index += 4) {
          if (bytes.getUint8(index) != 0) count++;
        }
        return count;
      } finally {
        image.dispose();
      }
    });
    return pixels!;
  } finally {
    picture.dispose();
  }
}
