/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 4 November 2026
 */

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() {
  const foreignNumber = '+7 999 123 45 67';
  final indonesia = Country.fromCountryCode('ID');

  for (final automatic in [false, true]) {
    testWidgets('pasting a calling code alone keeps the local field empty '
        '(automatic: $automatic)', (tester) async {
      final controller = CountryPhoneController.empty();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: CountryPhoneInput(
              controller: controller,
              initialCountry: indonesia,
              useCountryFormatting: automatic,
            ),
          ),
        ),
      );

      final field = find.byType(EditableText);
      final editor = tester.widget<EditableText>(field).controller;
      const nationalNumber = '8123456';
      for (final prefix in ['+62', '0062']) {
        await tester.enterText(field, prefix);
        expect(editor.text, isEmpty);
        expect(controller.phone, '+62');
        expect(controller.valueStatus.isEmpty, isTrue);

        for (final digit in nationalNumber.split('')) {
          final text = editor.text + digit;
          tester.testTextInput.updateEditingValue(
            TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            ),
          );
          await tester.pump();
        }
        expect(controller.phone, '+62$nationalNumber');
        expect(controller.valueStatus.currentLength, nationalNumber.length);
      }
    });

    testWidgets('keeps a foreign number when the selected country changes '
        '(automatic: $automatic)', (tester) async {
      final controller = CountryPhoneController.apply(foreignNumber);
      final country = ValueNotifier(Country.us());
      addTearDown(controller.dispose);
      addTearDown(country.dispose);
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: CountryPhoneInput(
              controller: controller,
              countryController: country,
              useCountryFormatting: automatic,
            ),
          ),
        ),
      );
      final published = <String>[];
      controller.addListener(() => published.add(controller.phone));

      country.value = indonesia;
      await tester.pump();
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.controller.text, foreignNumber);
      expect(controller.phone, '+79991234567');
      expect(controller.valueStatus.isComplete, isFalse);
      expect(published, everyElement('+79991234567'));

      country.value = Country.ru();
      await tester.pump();
      expect(controller.phone, '+79991234567');
      expect(controller.valueStatus.isComplete, isTrue);
    });
  }

  testWidgets('keeps a foreign number when enabling automatic formatting', (
    tester,
  ) async {
    final controller = CountryPhoneController.apply(foreignNumber);
    addTearDown(controller.dispose);
    Future<void> show({required bool automatic}) => tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => Scaffold(
          body: CountryPhoneInput(
            controller: controller,
            initialCountry: indonesia,
            useCountryFormatting: automatic,
          ),
        ),
      ),
    );

    await show(automatic: false);
    await show(automatic: true);
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.controller.text, foreignNumber);
    expect(controller.phone, '+79991234567');
    expect(controller.valueStatus.isComplete, isFalse);
  });

  for (final automatic in [false, true]) {
    testWidgets('foreign international paste preserves the current value '
        '(automatic: $automatic)', (tester) async {
      final controller = CountryPhoneController.apply('+62 812345678');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: CountryPhoneInput(
              controller: controller,
              initialCountry: Country.fromCountryCode('ID'),
              useCountryFormatting: automatic,
            ),
          ),
        ),
      );

      final field = find.byType(EditableText);
      final initial = controller.value;
      for (final foreign in ['+7 999 123 45 67', '00 7 999 123 45 67']) {
        await tester.enterText(field, foreign);
        expect(controller.value, initial);
      }

      controller.text = '+7 999 123 45 67';
      expect(
        tester.widget<EditableText>(field).controller.text,
        controller.text,
      );
      expect(controller.valueStatus.isComplete, isFalse);

      await tester.enterText(field, '+7 999 123 45 6');
      expect(controller.text, '+7 999 123 45 6');
      expect(controller.valueStatus.isComplete, isFalse);

      await tester.enterText(field, '812345678');
      expect(controller.phone, '+62812345678');
      expect(controller.valueStatus.isComplete, isTrue);
    });
  }

  for (final automatic in [false, true]) {
    testWidgets('checks a calling code in parentheses before formatting '
        '(automatic: $automatic)', (tester) async {
      final controller = CountryPhoneController.apply('+62 812345678');
      final changes = <String>[];
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: CountryPhoneInput(
              controller: controller,
              initialCountry: indonesia,
              onChanged: changes.add,
              useCountryFormatting: automatic,
            ),
          ),
        ),
      );

      final field = find.byType(EditableText);
      final initial = controller.value;
      final editor = tester.widget<EditableText>(field).controller;
      final initialText = editor.text;
      await tester.enterText(field, '(+7) 999 123 45 67');
      expect(editor.text, initialText);
      expect(controller.value, initial);
      expect(changes, isEmpty);

      await tester.enterText(field, '\u200E(\u061C +62) 811 234567');
      expect(controller.phone, '+62811234567');
      expect(controller.valueStatus.isComplete, isTrue);

      await tester.enterText(field, '(812) 345679');
      expect(controller.phone, '+62812345679');
      expect(controller.valueStatus.isComplete, isTrue);
    });

    testWidgets('checks the calling code after a direction mark '
        '(automatic: $automatic)', (tester) async {
      final controller = CountryPhoneController.apply('+62 812345678');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: CountryPhoneInput(
              controller: controller,
              initialCountry: indonesia,
              useCountryFormatting: automatic,
            ),
          ),
        ),
      );

      final field = find.byType(EditableText);
      final initial = controller.value;
      for (final text in [
        '\u200E$foreignNumber',
        '\u061C 00 7 999 123 45 67',
      ]) {
        await tester.enterText(field, text);
        expect(controller.value, initial);
      }
      await tester.enterText(field, '\u2067 +62 811 234567\u2069');
      expect(controller.phone, '+62811234567');
      expect(controller.valueStatus.isComplete, isTrue);
    });

    testWidgets('rejecting a foreign composition does not emit onChanged '
        '(automatic: $automatic)', (tester) async {
      final controller = CountryPhoneController.apply('+62 812345678');
      final changes = <String>[];
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: CountryPhoneInput(
              controller: controller,
              initialCountry: indonesia,
              useCountryFormatting: automatic,
              onChanged: changes.add,
            ),
          ),
        ),
      );

      final field = find.byType(EditableText);
      final initial = controller.value;
      await tester.showKeyboard(field);
      final draft = TextEditingValue(
        text: foreignNumber,
        selection: TextSelection.collapsed(offset: foreignNumber.length),
        composing: TextRange(end: foreignNumber.length, start: 0),
      );
      tester.testTextInput.updateEditingValue(draft);
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        draft.copyWith(composing: TextRange.empty),
      );
      await tester.pump();
      expect(controller.value, initial);
      expect(changes, isEmpty);

      await tester.enterText(field, '811234567');
      expect(controller.phone, '+62811234567');
      expect(changes, [controller.text]);
    });

    testWidgets('keeps the committed number when changing masks during an IME '
        'draft (automatic: $automatic)', (tester) async {
      final panama = Country.fromCountryCode('PA');
      final controller = CountryPhoneController.apply('+507 60012345');
      final changes = <String>[];
      addTearDown(controller.dispose);

      Future<void> show({required bool useCountryFormatting}) =>
          tester.pumpWidget(
            createWidgetUnderTest(
              builder: (_) => Scaffold(
                body: CountryPhoneInput(
                  controller: controller,
                  initialCountry: panama,
                  useCountryFormatting: useCountryFormatting,
                  onChanged: changes.add,
                ),
              ),
            ),
          );

      await show(useCountryFormatting: automatic);
      final field = find.byType(EditableText);
      final editor = tester.widget<EditableText>(field).controller;
      expect(editor.text, automatic ? '6001 2345' : '6001-2345');
      await tester.showKeyboard(field);
      const draft = TextEditingValue(
        text: foreignNumber,
        selection: TextSelection.collapsed(offset: foreignNumber.length),
        composing: TextRange(end: foreignNumber.length, start: 0),
      );
      tester.testTextInput.updateEditingValue(draft);
      await tester.pump();
      await show(useCountryFormatting: !automatic);
      expect(editor.value, draft);
      expect(controller.resolution.phone, '+50760012345');
      expect(changes, isEmpty);

      tester.testTextInput.updateEditingValue(
        draft.copyWith(composing: TextRange.empty),
      );
      await tester.pump();
      expect(editor.text, automatic ? '6001-2345' : '6001 2345');
      expect(controller.resolution.phone, '+50760012345');
      expect(controller.valueStatus.isComplete, isTrue);
      expect(changes, isEmpty);

      const localDraft = TextEditingValue(
        text: '61123456',
        selection: TextSelection.collapsed(offset: 8),
        composing: TextRange(end: 8, start: 0),
      );
      tester.testTextInput.updateEditingValue(
        editor.value.copyWith(composing: const TextRange(start: 0, end: 1)),
      );
      await tester.pump();
      await show(useCountryFormatting: automatic);
      tester.testTextInput.updateEditingValue(draft);
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        draft.copyWith(composing: TextRange.empty),
      );
      await tester.pump();
      expect(controller.resolution.phone, '+50760012345');
      expect(changes, isEmpty);

      tester.testTextInput.updateEditingValue(localDraft);
      await tester.pump();
      await show(useCountryFormatting: !automatic);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(controller.resolution.phone, '+50761123456');
      expect(changes, [controller.text]);
    });

    testWidgets('a listener can clear a number accepted after a country change '
        '(automatic: $automatic)', (tester) async {
      final country = ValueNotifier(Country.us());
      final controller = CountryPhoneController.apply(foreignNumber);
      addTearDown(country.dispose);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: CountryPhoneInput(
              controller: controller,
              countryController: country,
              useCountryFormatting: automatic,
            ),
          ),
        ),
      );
      expect(controller.valueStatus.isComplete, isFalse);

      final published = <String>[];
      controller.addListener(() {
        published.add(controller.phone);
        if (controller.valueStatus.isComplete) controller.clear();
      });
      country.value = Country.ru();
      await tester.pump();

      final field = find.byType(EditableText);
      expect(controller.text, isEmpty);
      expect(controller.valueStatus.isEmpty, isTrue);
      expect(tester.widget<EditableText>(field).controller.text, isEmpty);
      expect(published, ['+79991234567', '']);

      await tester.enterText(field, '9');
      expect(published, ['+79991234567', '', '+79']);
    });
  }

  for (final extended in [false, true]) {
    testWidgets(
      'selecting a new country clears and focuses the phone (extended: $extended)',
      (tester) async {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(402, 874)
          ..viewPadding = const FakeViewPadding(top: 62, bottom: 34);
        addTearDown(tester.view.reset);
        final controller = CountryPhoneController.apply('+79212345678');
        addTearDown(controller.dispose);
        const filter = ['RU', 'ID', 'IN'];
        await tester.pumpWidget(
          createWidgetUnderTest(
            builder: (_) => Scaffold(
              body: extended
                  ? CountryPhoneInput.extended(
                      controller: controller,
                      filter: filter,
                      showSearch: true,
                      useCountryFormatting: true,
                    )
                  : CountryPhoneInput(
                      controller: controller,
                      filter: filter,
                      showSearch: true,
                      useCountryFormatting: true,
                    ),
            ),
          ),
        );
        final phone = find.byType(EditableText);
        expect(tester.widget<EditableText>(phone).focusNode.hasFocus, isFalse);
        expect(controller.phone, '+79212345678');

        await tester.tap(
          find.byKey(
            ValueKey(
              extended
                  ? 'country_picker_button_extended'
                  : 'country_picker_phone_code',
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(of: find.byType(BottomSheet), matching: phone),
          'Инд',
        );
        await tester.pumpAndSettle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 336);
        await tester.pumpAndSettle();
        final indonesia = find.text('Индонезия').hitTestable();
        expect(indonesia, findsOneWidget);
        await tester.tap(indonesia);
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsNothing);
        final field = tester.widget<EditableText>(phone);
        expect(field.controller.text, isEmpty);
        expect(controller.phone, '+62');
        expect(controller.valueStatus.isEmpty, isTrue);
        expect(field.focusNode.hasFocus, isTrue);
        expect(field.keyboardType, TextInputType.number);
        expect(tester.testTextInput.isVisible, isTrue);
      },
    );

    testWidgets(
      'phone input opens a full-height picker (extended: $extended)',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            builder: (_) => Scaffold(
              body: extended
                  ? const CountryPhoneInput.extended(
                      expand: true,
                      filter: ['RU'],
                    )
                  : const CountryPhoneInput(expand: true, filter: ['RU']),
            ),
          ),
        );
        await tester.tap(
          find.byKey(
            ValueKey(
              extended
                  ? 'country_picker_button_extended'
                  : 'country_picker_phone_code',
            ),
          ),
        );
        await tester.pumpAndSettle();
        final sheet = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        expect(sheet.initialChildSize, 1);
      },
    );

    testWidgets('programmatic phone edits update the mounted field '
        '(extended: $extended)', (tester) async {
      final controller = CountryPhoneController.apply('+7 9212345678');
      addTearDown(controller.dispose);
      final changes = <String>[];
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: extended
                ? CountryPhoneInput.extended(
                    controller: controller,
                    onChanged: changes.add,
                    useCountryFormatting: true,
                  )
                : CountryPhoneInput(
                    controller: controller,
                    onChanged: changes.add,
                    useCountryFormatting: true,
                  ),
          ),
        ),
      );

      final editing = tester
          .widget<EditableText>(find.byType(EditableText))
          .controller;
      controller.clear();
      expect(editing.text, isEmpty);
      expect(controller.text, isEmpty);

      controller.text = '+7 911 222 3344';
      expect(editing.text, '911 222 3344');
      expect(controller.valueStatus.isComplete, isTrue);
      expect(changes, isEmpty);
    });
  }

  testWidgets('publishes the committed phone text and matching status', (
    tester,
  ) async {
    final controller = CountryPhoneController.empty();
    addTearDown(controller.dispose);
    final changes = <String>[];
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => Scaffold(
          body: CountryPhoneInput(
            controller: controller,
            onChanged: changes.add,
            useCountryFormatting: true,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(EditableText), '9212345678');
    final committed = controller.value;
    changes.clear();
    const next = TextEditingValue(
      text: '1',
      selection: TextSelection.collapsed(offset: 1),
      composing: TextRange(start: 0, end: 1),
    );

    tester.testTextInput.updateEditingValue(next);
    await tester.pump();
    expect(controller.value, committed);
    expect(changes, isEmpty);

    tester.testTextInput.updateEditingValue(
      next.copyWith(composing: TextRange.empty),
    );
    await tester.pump();
    expect(controller.number, '1');
    expect(controller.valueStatus.currentLength, 1);
    expect(controller.valueStatus.isComplete, isFalse);
    expect(changes, [controller.text]);

    await tester.enterText(find.byType(EditableText), '9212345678');
    changes.clear();
    tester.testTextInput.updateEditingValue(next);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(controller.number, '1');
    expect(controller.valueStatus.currentLength, 1);
    expect(controller.valueStatus.isComplete, isFalse);
    expect(changes, [controller.text]);
  });

  testWidgets('a listener can clear the field when the number is complete', (
    tester,
  ) async {
    final controller = CountryPhoneController.empty();
    addTearDown(controller.dispose);
    controller.addListener(() {
      if (controller.valueStatus.isComplete) controller.clear();
    });
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) =>
            Scaffold(body: CountryPhoneInput(controller: controller)),
      ),
    );

    final field = find.byType(EditableText);
    await tester.enterText(field, '9212345678');
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(tester.widget<EditableText>(field).controller.text, isEmpty);
  });

  testWidgets('extended phone input respects the explicit text style', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => InheritedCountryPickerTheme(
          data: CountryPickerTheme(
            textStyle: const TextStyle(fontSize: 13, color: Colors.red),
          ),
          child: const Scaffold(body: CountryPhoneInput.extended()),
        ),
      ),
    );
    final style = tester.widget<EditableText>(find.byType(EditableText)).style;
    expect(style.fontSize, 13);
    expect(style.color, Colors.red);
  });

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
              body: _capturePhoneField(
                extended
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
        );
        final field = find.byType(TextFormField);
        await tester.showKeyboard(field);
        final emptyHint = await _paintedHintPixels(tester);
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
        final partialHint = await _paintedHintPixels(tester);
        expect(partialHint, inExclusiveRange(0, emptyHint));

        await edit('240 412345');
        expect(editable.controller.text, '240 412345');
        expect(await _paintedHintPixels(tester), 0);

        await edit('240 412345678');
        expect(editable.controller.text, '240 412345678');
        expect(controller.number, '240412345678');
        expect(controller.valueStatus.isOverflow, isTrue);
        expect(await _paintedHintPixels(tester), 0);

        await edit('240 4');
        expect(editable.controller.text, '240 4');
        expect(controller.number, '2404');
        expect(controller.valueStatus.isOverflow, isFalse);
        expect(await _paintedHintPixels(tester), partialHint);

        await edit('');
        expect(editable.controller.text, isEmpty);
        expect(controller.valueStatus.isEmpty, isTrue);
        expect(await _paintedHintPixels(tester), emptyHint);
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
                  body: _capturePhoneField(
                    extended
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
          ),
        );

        await showInput(TextScaler.noScaling);
        final field = find.byType(TextFormField);
        await tester.enterText(field, '2404');
        await tester.pump();
        final hintPixels = await _paintedHintPixels(tester);
        expect(hintPixels, greaterThan(0));

        await showInput(TextScaler.noScaling);
        expect(await _paintedHintPixels(tester), hintPixels);

        await showInput(const TextScaler.linear(1.4));
        expect(await _paintedHintPixels(tester), greaterThan(hintPixels));
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

    testWidgets('manual input strips a matching 00 calling code before '
        'checking length (extended: $extended)', (tester) async {
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
      await tester.enterText(find.byType(TextFormField), '00628123456');
      expect(controller.phone, '+628123456');
      expect(controller.valueStatus.isComplete, isFalse);
    });
  }
}

const _kPhoneMaskCaptureKey = ValueKey<String>('phone_mask_capture');

Widget _capturePhoneField(Widget child) => InheritedCountryPickerTheme(
  data: CountryPickerTheme(onBackgroundColor: Colors.white),
  child: RepaintBoundary(
    key: _kPhoneMaskCaptureKey,
    child: ColoredBox(color: Colors.white, child: child),
  ),
);

/// Counts visible hint pixels to the right of the caret in the painted field.
Future<int> _paintedHintPixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_kPhoneMaskCaptureKey),
  );
  final editable = tester
      .state<EditableTextState>(find.byType(EditableText))
      .renderEditable;
  final origin = editable.localToGlobal(Offset.zero, ancestor: boundary);
  final end = editable
      .getEndpointsForSelection(
        TextSelection.collapsed(offset: editable.plainText.length),
      )
      .single
      .point;
  final pixels = await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      final left = (origin.dx + end.dx + editable.cursorWidth + 1).ceil().clamp(
        0,
        image.width,
      );
      final right = (origin.dx + editable.size.width).floor().clamp(
        0,
        image.width,
      );
      final top = origin.dy.ceil().clamp(0, image.height);
      final bottom = (origin.dy + editable.size.height).floor().clamp(
        0,
        image.height,
      );
      var count = 0;
      for (var y = top; y < bottom; y++) {
        for (var x = left; x < right; x++) {
          final i = (y * image.width + x) * 4;
          if (bytes.getUint8(i) < 250 ||
              bytes.getUint8(i + 1) < 250 ||
              bytes.getUint8(i + 2) < 250) {
            count++;
          }
        }
      }
      return count;
    } finally {
      image.dispose();
    }
  });
  return pixels!;
}
