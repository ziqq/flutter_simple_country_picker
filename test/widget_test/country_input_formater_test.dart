import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/widget_test_helper.dart';

const ValueKey<String> _key = ValueKey<String>('country_input_text_field');

void main() {
  group('CountryInputFormatter -', () {
    late TextEditingController controller;
    late CountryInputFormatter formatter;
    late Widget testWidget;

    setUp(() {
      controller = TextEditingController();
      formatter = CountryInputFormatter(
        mask: '+# (###) ###-##-##',
      );
      testWidget = TextField(
        key: _key,
        controller: controller,
        inputFormatters: [formatter],
      );
    });

    tearDown(() {
      controller.dispose();
      formatter.clear();
    });

    testWidgets('should format input correctly', (tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createWidgetUnderTest(
          builder: (_) => Scaffold(body: testWidget),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);

      // Вводим текст в TextField
      await tester.enterText(find.byKey(_key), '1234567890');
      await tester.pump();

      // Проверяем отформатированный текст
      expect(controller.text, '+1 (234) 567-89-0');
    });

    testWidgets('should correctly report isFill property', (tester) async {
      final controller = TextEditingController();
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

      await tester.pumpWidget(
        WidgetTestHelper.createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: TextField(
              key: _key,
              controller: controller,
              inputFormatters: [formatter],
            ),
          ),
        ),
      );

      // Enter a partial number
      await tester.enterText(find.byKey(_key), formatter.unmaskText('12345'));
      await tester.pump();

      expect(controller.text, '+1 (234) 5');
      expect(formatter.isFill, isFalse);

      /// Enter a complete number
      await tester.enterText(
        find.byKey(_key),
        formatter.unmaskText('12345678901'),
      );
      await tester.pump();

      // +1 (234) 5 and 123456
      expect(controller.text, '+1 (234) 567-89-01');
      expect(formatter.isFill, isTrue);
    });

    testWidgets('should format initial text correctly', (tester) async {
      final controller = TextEditingController();
      final formatter = CountryInputFormatter(
        mask: '+# (###) ###-##-##',
        initialText: '1234567890',
      );

      controller.text = formatter.getMaskedText();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              key: _key,
              controller: controller,
              inputFormatters: [formatter],
            ),
          ),
        ),
      );

      expect(controller.text, '+1 (234) 567-89-0');
      expect(formatter.getUnmaskedText(), '1234567890');
    });

    testWidgets('should update filter and reformat text', (tester) async {
      final filter = {'A': RegExp('[A-Za-z]'), '#': RegExp(r'\d')};
      final formatter = CountryInputFormatter(mask: 'AA-###', filter: filter);
      final controller = TextEditingController();

      await tester.pumpWidget(
        WidgetTestHelper.createWidgetUnderTest(
          builder: (_) => Scaffold(
            body: TextField(
              key: _key,
              controller: controller,
              inputFormatters: [formatter],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Проверяем первоначальное форматирование
      await tester.enterText(find.byKey(_key), 'AB123');
      await tester.pump();

      expect(controller.text, 'AB-123');
      expect(formatter.getMaskedText(), 'AB-123');
      expect(formatter.getUnmaskedText(), 'AB123');

      // Обновляем маску и фильтр
      formatter.updateMask(
        mask: '#A#-##',
        filter: filter,
        newValue: const TextEditingValue(
          text: '1A223',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );

      // Принудительно обновляем контроллер текста
      final text = formatter.getMaskedText();
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      await tester.pump();

      // Проверяем переформатированный текст
      expect(controller.text, '1A2-23');
    });

    testWidgets('should maintain correct cursor position after formatting',
        (tester) async {
      final controller = TextEditingController();
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              key: _key,
              controller: controller,
              inputFormatters: [formatter],
            ),
          ),
        ),
      );

      // Вводим часть номера
      await tester.enterText(find.byKey(_key), '12345');
      await tester.pump();
      var text = formatter.getMaskedText();

      // Проверим, что позиция курсора соответствует длине
      // неформатированного текста
      expect(controller.selection.baseOffset, text.length);

      // Вводим полный номер
      await tester.enterText(find.byKey(_key), '12345678901');
      await tester.pump();
      text = formatter.getMaskedText();

      // Проверим позицию курсора после ввода полного номера
      expect(controller.selection.baseOffset, text.length);
    });

    testWidgets('should handle deletion of characters correctly',
        (tester) async {
      final controller = TextEditingController();
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              key: _key,
              controller: controller,
              inputFormatters: [formatter],
            ),
          ),
        ),
      );

      // Вводим полный номер
      await tester.enterText(find.byKey(_key), '12345678901');
      await tester.pump();

      expect(controller.text, '+1 (234) 567-89-01');

      // Удаляем последние 3 символа
      controller.text =
          controller.text.substring(0, controller.text.length - 3);
      await tester.pump();

      // Проверяем отформатированный текст после удаления
      expect(controller.text, '+1 (234) 567-89');
    });

    testWidgets('should ignore input with only invalid characters',
        (tester) async {
      final controller = TextEditingController();
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              key: _key,
              controller: controller,
              inputFormatters: [formatter],
            ),
          ),
        ),
      );

      // Вводим только недопустимые символы
      await tester.enterText(find.byKey(_key), 'abcdefg');
      await tester.pump();

      // Проверяем, что текст остался без изменений
      expect(controller.text, '');
      expect(formatter.getUnmaskedText(), '');
    });

    testWidgets('should handle empty input correctly', (tester) async {
      final formatter = CountryInputFormatter(mask: '+# (###) ###-##-##');
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              key: _key,
              controller: controller,
              inputFormatters: [formatter],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Вводим пустую строку
      await tester.enterText(find.byKey(_key), '');
      await tester.pump();

      // Проверяем, что текст остался без изменений
      expect(controller.text, '');
      expect(formatter.getUnmaskedText(), '');
    });
  });
}
