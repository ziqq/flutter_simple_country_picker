import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/widget_test_helper.dart';

const _key = Key('country_picker_theme');

void main() => group('CountryPickerTheme -', () {
      testWidgets('provides theme data to children widgets', (tester) async {
        final themeData = CountryPickerTheme(
          accentColor: CupertinoColors.systemBlue,
          backgroundColor: Colors.white,
          barrierColor: Colors.black,
          dividerColor: Colors.grey,
          secondaryBackgroundColor: Colors.blue,
          textStyle: const TextStyle(fontSize: 16),
          searchTextStyle: const TextStyle(fontSize: 14),
          flagSize: 25,
          padding: 10,
          indent: 10,
          radius: 10,
          inputDecoration: const InputDecoration(),
        );

        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (context) => Scaffold(
              body: CountryPickerInheritedTheme(
                data: themeData,
                child: const SizedBox.shrink(key: _key),
              ),
            ),
          ),
        );

        expect(find.byKey(_key), findsOneWidget);

        final context = tester.firstElement(find.byKey(_key));
        final providedTheme = CountryPickerInheritedTheme.maybeOf(context);
        expect(providedTheme, equals(themeData));
      });

      testWidgets('resolves correct values', (tester) async {
        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            builder: (context) => Scaffold(
              body: CountryPickerInheritedTheme(
                data: CountryPickerTheme.resolve(context),
                child: const SizedBox.shrink(key: _key),
              ),
            ),
          ),
        );

        expect(find.byKey(_key), findsOneWidget);

        final context = tester.firstElement(find.byKey(_key));
        final defaultTheme = CountryPickerTheme.defaults(context);
        final resolvedTheme = CountryPickerInheritedTheme.maybeOf(context);
        expect(resolvedTheme, isNotNull);
        expect(resolvedTheme!.backgroundColor, defaultTheme.backgroundColor);
      });

      testWidgets('provides inherited properties to widget tree',
          (tester) async {
        final themeData = CountryPickerTheme(
          accentColor: CupertinoColors.systemRed,
          backgroundColor: Colors.red,
          barrierColor: Colors.yellow,
          dividerColor: Colors.green,
          secondaryBackgroundColor: Colors.orange,
          textStyle: const TextStyle(fontSize: 18),
          searchTextStyle: const TextStyle(fontSize: 15),
          flagSize: 24,
          padding: 8,
          indent: 12,
          radius: 15,
          inputDecoration: const InputDecoration(
            hintText: 'Search...',
          ),
        );

        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            builder: (context) => CountryPickerInheritedTheme(
              data: themeData,
              child: const Scaffold(
                body: SizedBox.shrink(key: _key),
              ),
            ),
          ),
        );

        expect(find.byKey(_key), findsOneWidget);

        final context = tester.firstElement(find.byKey(_key));
        final inheritedTheme = CountryPickerInheritedTheme.maybeOf(context);

        expect(inheritedTheme, isNotNull);
        expect(inheritedTheme!.accentColor, CupertinoColors.systemRed);
        expect(inheritedTheme.backgroundColor, Colors.red);
        expect(inheritedTheme.barrierColor, Colors.yellow);
        expect(inheritedTheme.dividerColor, Colors.green);
        expect(inheritedTheme.secondaryBackgroundColor, Colors.orange);
        expect(inheritedTheme.textStyle?.fontSize, 18);
        expect(inheritedTheme.searchTextStyle?.fontSize, 15);
        expect(inheritedTheme.flagSize, 24.0);
        expect(inheritedTheme.padding, 8.0);
        expect(inheritedTheme.indent, 12.0);
        expect(inheritedTheme.radius, 15.0);
        expect(inheritedTheme.inputDecoration?.hintText, 'Search...');
      });

      testWidgets('with fallback to defaults', (tester) async {
        await tester.pumpWidget(
          WidgetTestHelper.createWidgetUnderTest(
            builder: (context) => const Scaffold(
              body: SizedBox.shrink(key: _key),
            ),
          ),
        );

        expect(find.byKey(_key), findsOneWidget);

        final context = tester.firstElement(find.byKey(_key));
        final defaultTheme = CountryPickerTheme.defaults(context);

        expect(defaultTheme.accentColor, CupertinoColors.systemBlue);
        expect(defaultTheme.backgroundColor, CupertinoColors.systemBackground);
        expect(defaultTheme.barrierColor, kCupertinoModalBarrierColor);
        expect(defaultTheme.textStyle?.fontSize, null);
        expect(defaultTheme.flagSize, 25.0);
      });
    });
