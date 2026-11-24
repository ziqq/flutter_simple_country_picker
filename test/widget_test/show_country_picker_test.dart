/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 25 October 2024
 */

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_sheet_gesture.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() => group('showCountryPicker -', () {
  for (final (closeOnSwipe, expand, initialSize, minSize) in [
    (false, false, null, null),
    (true, false, null, null),
    (true, true, null, null),
    (true, false, .45, null),
    (true, false, .45, .44),
    (false, false, .45, .45),
    (true, false, .45, .45),
    (true, true, 1.0, 1.0),
    (false, true, 1.0, 1.0),
  ]) {
    testWidgets(
      'dismisses by the header and honors list swipe dismissal '
      '(closeOnSwipe: $closeOnSwipe, expand: $expand, '
      'initialSize: $initialSize, minSize: $minSize)',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showCountryPicker(
                  context: context,
                  filter: const ['GB', 'US'],
                  showSearch: false,
                  isDismissible: false,
                  shouldCloseOnSwipeDown: closeOnSwipe,
                  expand: expand,
                  initialChildSize: initialSize,
                  minChildSize: minSize,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final sheet = find.byType(CountryPickerSheetGesture);
        final bounds = tester.getRect(find.byType(ClipRSuperellipse).first);
        final draggableSheet = tester.widget<CountryPickerSheetGesture>(
          find.byType(CountryPickerSheetGesture),
        );
        expect(draggableSheet.initialSize, initialSize ?? (expand ? 1 : .65));
        await tester.dragFrom(
          Offset(bounds.center.dx, bounds.top + 10),
          Offset(0, bounds.height * .85),
        );
        await tester.pumpAndSettle();
        expect(sheet, findsNothing);

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final list = find.byType(CustomScrollView);
        await tester.drag(list, const Offset(0, 320));
        await tester.pumpAndSettle();

        expect(sheet, closeOnSwipe ? findsNothing : findsOneWidget);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );
  }

  testWidgets(
    'scrolls the list during a drag in a full-height Material sheet',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showCountryPicker(
                context: context,
                expand: true,
                showSearch: false,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final list = find.byType(CustomScrollView);
      final scrollable = find.descendant(
        of: list,
        matching: find.byType(Scrollable),
      );
      final position = tester.state<ScrollableState>(scrollable).position;
      expect(position.maxScrollExtent, greaterThan(0));

      final drag = await tester.startGesture(tester.getCenter(list));
      await drag.moveBy(const Offset(0, -30));
      await tester.pump(const Duration(milliseconds: 100));
      await drag.moveBy(const Offset(0, -80));
      await tester.pump(const Duration(milliseconds: 100));
      expect(position.pixels, greaterThan(0));
      await drag.up();
      await tester.pumpAndSettle();
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('closes the picker before an onSelect navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showCountryPicker(
              context: context,
              filter: ['RU'],
              onSelect: (_) {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Next page')),
                  ),
                );
              },
            ),
            child: const Text('Show Picker'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey(Country.ru().e164Key)));
    await tester.pumpAndSettle();

    expect(find.text('Next page'), findsOneWidget);
    expect(find.byType(CountryListView, skipOffstage: false), findsNothing);
  });

  testWidgets('dragging the country list enlarges a Material sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showCountryPicker(
              context: context,
              filter: ['RU'],
              initialChildSize: .45,
              minChildSize: .30,
            ),
            child: const Text('Show Picker'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    final list = find.byType(CountryListView);
    final initialHeight = tester.getSize(list).height;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.getSize(list).height, greaterThan(initialHeight + 20));
  });

  testWidgets('grouped countries update when the app locale changes', (
    tester,
  ) async {
    final locale = ValueNotifier(const Locale('en'));
    addTearDown(locale.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        child: const Scaffold(
          body: CountryListView(showGroup: true, filter: ['RU']),
        ),
        builder: (context, locale, child) => MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ru')],
          localizationsDelegates: const [
            CountryLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final search = find.byType(CupertinoSearchTextField);
    expect(find.byKey(const ValueKey<String>('header_R')), findsOneWidget);
    await tester.enterText(search, 'RU');
    await tester.pumpAndSettle();

    locale.value = const Locale('ru');
    await tester.pumpAndSettle();
    expect(find.text('Россия'), findsOneWidget);
    expect(
      tester.widget<CupertinoSearchTextField>(search).controller?.text,
      'RU',
    );
    await tester.enterText(search, '');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('header_Р')), findsOneWidget);
  });

  testWidgets('grouped countries use the original name without a translation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [_MissingCountryTranslationDelegate()],
        home: Scaffold(body: CountryListView(showGroup: true, filter: ['RU'])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('header_R')), findsOneWidget);
    expect(find.bySemanticsLabel('Russia'), findsOneWidget);
  });

  testWidgets('adaptive iOS sheet selects a country and calls whenComplete', (
    tester,
  ) async {
    Country? selected;
    var completed = 0;
    await tester.pumpWidget(
      createWidgetUnderTest(
        locale: const Locale('en'),
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showCountryPicker(
              context: context,
              adaptive: true,
              showPhoneCode: true,
              filter: const ['RU'],
              onSelect: (country) => selected = country,
              whenComplete: () => completed++,
            ),
            child: const Text('Open adaptive picker'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open adaptive picker'));
    await tester.pumpAndSettle();
    expect(find.byType(CountryListView), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Russia, +7'));
    await tester.pumpAndSettle();
    expect(selected!.countryCode, 'RU');
    expect(completed, 1);
    expect(find.byType(CountryListView), findsNothing);
  }, variant: TargetPlatformVariant.only(.iOS));

  testWidgets('displays bottom sheet with country list view', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(context: context, onSelect: (_) {});
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Проверяем, что виджет BottomSheet с country list отображен
    expect(find.byType(CountryListView), findsOneWidget);
  });

  testWidgets('calls onSelect callback when country is selected', (
    tester,
  ) async {
    Country? selectedCountry;

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (country) => selectedCountry = country,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Симулируем выбор страны
    final listView = tester.widget<CountryListView>(
      find.byType(CountryListView),
    );
    listView.onSelect!(Country.ru());

    await tester.pumpAndSettle();
    expect(selectedCountry, isNotNull);
  });

  testWidgets('applies theme correctly', (tester) async {
    final themeData = CountryPickerTheme(
      accentColor: CupertinoColors.systemBlue,
      backgroundColor: Colors.white,
      secondaryBackgroundColor: Colors.blueAccent,
      barrierColor: Colors.black54,
      dividerColor: Colors.grey,
      textStyle: const TextStyle(fontSize: 16),
      searchTextStyle: const TextStyle(fontSize: 14),
      inputHeight: 70,
      flagSize: 25,
      padding: 10,
      indent: 10,
      sheetCornerRadius: 15,
      inputDecoration: const InputDecoration(),
    );

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => InheritedCountryPickerTheme(
          data: themeData,
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showCountryPicker(context: context, onSelect: (_) {});
                },
                child: const Text('Show Picker'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    final modalSheet = tester.widget<ClipRSuperellipse>(
      find.byType(ClipRSuperellipse).first,
    );
    expect(
      modalSheet.borderRadius,
      const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    );
  });

  testWidgets('shows search bar when showSearch is true', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (_) {},
                  showSearch: true,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Expect search bar to be displayed
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
  });

  testWidgets('the adaptive iOS sheet inherits the local picker theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => InheritedCountryPickerTheme(
          data: CountryPickerTheme(flagSize: 42),
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showCountryPicker(
                context: context,
                adaptive: true,
                filter: const ['RU'],
                useHapticFeedback: false,
              ),
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    final list = tester.element(find.byType(CountryListView));
    expect(CountryPickerTheme.of(list).flagSize, 42);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  final initialTheme = CountryPickerTheme(flagSize: 22, sheetCornerRadius: 11);
  for (final (scope, localTheme, useMaterialTheme) in [
    ('global', null, false),
    ('local Material styling with inherited extensions', null, true),
    ('local', CountryPickerTheme(flagSize: 34, sheetCornerRadius: 17), false),
    ('shared instance in local picker theme', initialTheme, false),
    ('shared instance in local Material theme', initialTheme, true),
  ]) {
    testWidgets('open iOS sheet handles app theme changes ($scope)', (
      tester,
    ) async {
      final appTheme = ValueNotifier(initialTheme);
      addTearDown(appTheme.dispose);
      final launcher = Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showCountryPicker(
              context: context,
              adaptive: true,
              filter: const ['RU'],
              useHapticFeedback: false,
            ),
            child: const Text('Show Picker'),
          ),
        ),
      );
      final home = switch ((localTheme, useMaterialTheme)) {
        (null, false) => launcher,
        (null, true) => Builder(
          builder: (context) => Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.transparent),
            child: launcher,
          ),
        ),
        (final CountryPickerTheme theme, true) => Theme(
          data: ThemeData(extensions: [theme]),
          child: launcher,
        ),
        (final CountryPickerTheme theme, false) => InheritedCountryPickerTheme(
          data: theme,
          child: launcher,
        ),
      };
      await tester.pumpWidget(
        ValueListenableBuilder(
          valueListenable: appTheme,
          child: home,
          builder: (_, theme, home) => MaterialApp(
            theme: ThemeData(extensions: [theme]),
            home: home,
          ),
        ),
      );
      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      final list = find.byType(CountryListView);
      final flag = find.descendant(of: list, matching: find.text('🇷🇺'));
      final sheet = find.ancestor(
        of: list,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is ClipRSuperellipse && widget.child is DecoratedBox,
        ),
      );
      void expectSheetTheme(double expectedFlagSize) {
        final radius = Radius.circular(expectedFlagSize / 2);
        expect(tester.widget<Text>(flag).style?.fontSize, expectedFlagSize);
        expect(
          tester.widget<ClipRSuperellipse>(sheet).borderRadius,
          BorderRadius.only(topLeft: radius, topRight: radius),
        );
      }

      expectSheetTheme(localTheme?.flagSize ?? 22);
      appTheme.value = CountryPickerTheme(flagSize: 42, sheetCornerRadius: 21);
      await tester.pumpAndSettle();
      expectSheetTheme(localTheme?.flagSize ?? 42);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  }

  testWidgets('group headers update their background with the theme', (
    tester,
  ) async {
    final color = ValueNotifier<Color>(Colors.red);
    addTearDown(color.dispose);
    await tester.pumpWidget(
      createWidgetUnderTest(
        locale: const Locale('en'),
        builder: (_) => ValueListenableBuilder(
          valueListenable: color,
          child: const CountryListView(showGroup: true, filter: ['RU']),
          builder: (_, value, child) => InheritedCountryPickerTheme(
            data: CountryPickerTheme(secondaryBackgroundColor: value),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final list = find.byType(CountryListView);
    final sheet = find.descendant(of: list, matching: find.byType(Scaffold));
    Color? headerColor() => tester.widget<Scaffold>(sheet).backgroundColor;

    expect(headerColor(), Colors.red);
    color.value = Colors.blue;
    await tester.pumpAndSettle();
    expect(headerColor(), Colors.blue);
  });

  testWidgets('applies searchTextStyle to entered text', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => InheritedCountryPickerTheme(
          data: CountryPickerTheme(
            textStyle: const TextStyle(fontSize: 16, color: Colors.blue),
            searchTextStyle: const TextStyle(fontSize: 28, color: Colors.red),
          ),
          child: const CountryListView(showSearch: true, filter: ['RU']),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final search = find.byType(CupertinoSearchTextField);
    await tester.enterText(search, 'RU');
    await tester.pumpAndSettle();
    final field = tester.widget<EditableText>(
      find.descendant(of: search, matching: find.byType(EditableText)),
    );
    expect(field.style.fontSize, 28);
    expect(field.style.color, Colors.red);
  });

  testWidgets('grouped search clears rows with no matches', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (_) => const CountryListView(showGroup: true, filter: ['RU']),
      ),
    );
    await tester.pumpAndSettle();
    final row = find.byKey(ValueKey(Country.ru().e164Key));
    final search = find.byType(CupertinoSearchTextField);
    expect(row, findsOneWidget);

    await tester.enterText(search, 'zzzzzzz');
    await tester.pumpAndSettle();
    expect(row, findsNothing);

    await tester.enterText(search, '');
    await tester.pumpAndSettle();
    expect(row, findsOneWidget);
  });

  for (final grouped in [false, true]) {
    testWidgets(
      'showWorldWide adds a selectable first entry (grouped: $grouped)',
      (tester) async {
        final selection = ValueNotifier(Country.us());
        addTearDown(selection.dispose);
        Country? selected;
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showCountryPicker(
                  context: context,
                  filter: const ['US'],
                  showGroup: grouped,
                  showSearch: false,
                  showWorldWide: true,
                  selected: selection,
                  onSelect: (country) => selected = country,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final worldWide = find.text('Worldwide').hitTestable();
        expect(worldWide, findsOneWidget);
        expect(
          tester.getTopLeft(worldWide).dy,
          lessThan(tester.getTopLeft(find.text('United States').first).dy),
        );
        await tester.tap(worldWide);
        await tester.pumpAndSettle();
        expect(selected, Country.worldWide);
        expect(selection.value, Country.worldWide);
        expect(worldWide, findsNothing);
      },
    );

    testWidgets('shows dialing codes only when enabled (grouped: $grouped)', (
      tester,
    ) async {
      for (final showPhoneCode in [false, true]) {
        await tester.pumpWidget(
          createWidgetUnderTest(
            builder: (_) => CountryListView(
              filter: const ['RU'],
              showGroup: grouped,
              showPhoneCode: showPhoneCode,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(ValueKey(Country.ru().e164Key)), findsOneWidget);
        expect(
          find.textContaining('+7'),
          showPhoneCode ? findsOneWidget : findsNothing,
        );
      }
    });
  }

  testWidgets('calls onDone callback when picker is dismissed', (tester) async {
    var onDoneCalled = false;

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (_) {},
                  whenComplete: () => onDoneCalled = true,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Dismiss the picker
    Navigator.of(tester.element(find.text('Show Picker'))).pop();
    await tester.pumpAndSettle();

    expect(onDoneCalled, isTrue);
  });

  testWidgets('applies haptic feedback on show', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    var hapticFeedbackTriggered = false;

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (methodCall) async {
        if (methodCall.method == 'HapticFeedback.vibrate') {
          hapticFeedbackTriggered = true;
        }
        return null;
      },
    );

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (_) {},
                  useHapticFeedback: true,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    // Check if haptic feedback was triggered
    expect(hapticFeedbackTriggered, isTrue);

    // Reset mock handler
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  testWidgets(
    'applies haptic feedback when picker is dismissed from search bar',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      var hapticFeedbackTriggered = false;

      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          if (methodCall.method == 'HapticFeedback.vibrate') {
            hapticFeedbackTriggered = true;
          }
          return null;
        },
      );
      addTearDown(
        () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showCountryPicker(
                    context: context,
                    onSelect: (_) {},
                    showSearch: true,
                    useHapticFeedback: true,
                  );
                },
                child: const Text('Show Picker'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();
      hapticFeedbackTriggered = false;

      await tester.tap(
        find.byKey(const ValueKey<String>('country_picker_close_button')),
      );
      await tester.pumpAndSettle();

      expect(hapticFeedbackTriggered, isTrue);
    },
  );

  testWidgets('does not apply haptic feedback when disabled', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    var hapticFeedbackTriggered = false;

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (methodCall) async {
        if (methodCall.method == 'HapticFeedback.vibrate') {
          hapticFeedbackTriggered = true;
        }
        return null;
      },
    );

    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  filter: const ['RU'],
                  onSelect: (_) {},
                  useHapticFeedback: false,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('7-RU-0')));
    await tester.pumpAndSettle();

    expect(hapticFeedbackTriggered, isFalse);

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  testWidgets('deprecated parameter remains supported', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (_) {},
                  // ignore: deprecated_member_use
                  useHaptickFeedback: false,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    final listView = tester.widget<CountryListView>(
      find.byType(CountryListView),
    );
    expect(listView.useHapticFeedback, isFalse);
  });

  testWidgets('new parameter takes precedence over deprecated parameter', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        builder: (context) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  onSelect: (_) {},
                  // ignore: deprecated_member_use
                  useHaptickFeedback: true,
                  useHapticFeedback: false,
                );
              },
              child: const Text('Show Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Picker'));
    await tester.pumpAndSettle();

    final listView = tester.widget<CountryListView>(
      find.byType(CountryListView),
    );
    expect(listView.useHapticFeedback, isFalse);
  });

  // ignore: deprecated_member_use
  testWidgets(
    'onDone (deprecated) callback is called when picker is dismissed',
    (tester) async {
      var onDoneCalled = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showCountryPicker(
                    context: context,
                    onSelect: (_) {},
                    // ignore: deprecated_member_use
                    onDone: () => onDoneCalled = true,
                    // whenComplete is intentionally null so onDone is used.
                  );
                },
                child: const Text('Show Picker'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.text('Show Picker'))).pop();
      await tester.pumpAndSettle();

      expect(onDoneCalled, isTrue);
    },
  );

  group('unified picker -', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      CountryPickerTheme? theme,
      bool dark = false,
      bool adaptive = false,
      bool expand = true,
      double? initialSize,
      bool showGroup = true,
      bool showSearch = true,
      List<String>? filter = const ['RU', 'US', 'GB'],
      List<String>? favorites,
      bool showWorldWide = false,
      bool showPhoneCode = true,
      SelectedCountry? selected,
      SelectCountryCallback? onSelect,
    }) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('en'),
          theme: dark ? ThemeData.dark() : ThemeData.light(),
          builder: (context) => InheritedCountryPickerTheme(
            data: theme ?? CountryPickerTheme(),
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showCountryPicker(
                      context: context,
                      adaptive: adaptive,
                      expand: expand,
                      initialChildSize: initialSize,
                      showGroup: showGroup,
                      showSearch: showSearch,
                      filter: filter,
                      favorites: favorites,
                      showWorldWide: showWorldWide,
                      showPhoneCode: showPhoneCode,
                      selected: selected,
                      onSelect: onSelect,
                    ),
                    child: const Text('Open picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();
    }

    Finder sheet() => find
        .ancestor(
          of: find.byType(CountryListView),
          matching: find.byType(ClipRSuperellipse),
        )
        .first;
    const headerClose = ValueKey<String>('country_picker_header_close_button');
    const dockClose = ValueKey<String>('country_picker_close_button');
    const badge = ValueKey<String>('country_picker_selected_badge');

    for (final adaptive in <bool>[false, true]) {
      for (final radius in <double>[0, 24, 38]) {
        testWidgets(
          'theme overrides sheet corners in both presentations: adaptive=$adaptive radius=$radius',
          (tester) async {
            await pumpPicker(
              tester,
              adaptive: adaptive,
              theme: CountryPickerTheme(
                sheetCornerRadius: radius,
                baseCornerRadius: 9,
              ),
            );
            final clip = tester.widget<ClipRSuperellipse>(sheet());
            expect(
              clip.borderRadius.resolve(TextDirection.ltr).topLeft.x,
              radius,
            );
            expect(clip.clipBehavior, Clip.antiAliasWithSaveLayer);
            final context = tester.element(find.byType(CountryListView));
            expect(CountryPickerTheme.resolve(context).baseCornerRadius, 9);
            expect(tester.takeException(), isNull);
          },
          variant: TargetPlatformVariant.only(.iOS),
        );
      }
    }

    for (final dark in <bool>[false, true]) {
      testWidgets(
        'header title and glass controls coexist with search: dark=$dark',
        (tester) async {
          await pumpPicker(tester, dark: dark);
          expect(find.text('Select country'), findsOneWidget);
          expect(find.byKey(headerClose), findsOneWidget);
          expect(find.byKey(dockClose), findsOneWidget);
          expect(find.byType(CupertinoSearchTextField), findsOneWidget);
          expect(find.text('Cancel'), findsNothing);
          final close = tester.getRect(find.byKey(headerClose));
          final bounds = tester.getRect(sheet());
          expect(close.left - bounds.left, 16);
          expect(close.top - bounds.top, 16);
          expect(close.size, const Size(44, 44));
        },
        variant: TargetPlatformVariant.only(.iOS),
      );

      testWidgets(
        'Android AppBar keeps its height, dock and scroll-to-top: dark=$dark',
        (tester) async {
          await pumpPicker(tester, dark: dark, filter: null);
          final appBar = find.byType(AppBar);
          final dock = find.byType(CupertinoSearchTextField);
          expect(appBar, findsOneWidget);
          expect(tester.widget<AppBar>(appBar).toolbarHeight, 72);
          final closeButton = find.byKey(headerClose);
          final closeRect = tester.getRect(closeButton);
          final sheetRect = tester.getRect(sheet());
          expect(closeRect.left - sheetRect.left, 16);
          expect(closeRect.top - sheetRect.top, 16);
          expect(closeRect.size, const Size(48, 48));
          expect(
            find.descendant(
              of: closeButton,
              matching: find.byIcon(CupertinoIcons.xmark),
            ),
            findsOneWidget,
          );
          final title = find.text('Select country');
          final titleRect = tester.getRect(title);
          final titleStyle = tester.widget<Text>(title).style;
          expect(titleStyle?.inherit, isFalse);
          expect(titleStyle?.fontSize, 17);
          expect(titleStyle?.fontWeight, FontWeight.w500);
          expect(titleStyle?.letterSpacing, -.41);
          expect(titleRect.center.dx, tester.getCenter(appBar).dx);
          expect(titleRect.center.dy, closeRect.center.dy);
          expect(dock, findsOneWidget);
          final dockRect = tester.getRect(dock);

          final list = find.byType(CustomScrollView);
          final scrollable = tester.state<ScrollableState>(
            find.descendant(of: list, matching: find.byType(Scrollable)).first,
          );
          await tester.drag(list, const Offset(0, -400));
          await tester.pumpAndSettle();
          expect(scrollable.position.pixels, greaterThan(0));

          final barRect = tester.getRect(appBar);
          await tester.tapAt(Offset(barRect.right - 16, barRect.center.dy));
          await tester.pumpAndSettle();
          expect(scrollable.position.pixels, 0);
          expect(tester.getRect(dock), dockRect);

          await tester.tap(find.byKey(headerClose));
          await tester.pumpAndSettle();
          expect(find.byType(CountryListView), findsNothing);
        },
        variant: TargetPlatformVariant.only(.android),
      );

      testWidgets(
        'Android header paints the rim on hover and press: dark=$dark',
        (tester) async {
          await pumpPicker(tester, dark: dark);
          final button = find.byKey(headerClose);
          final rim = find.descendant(
            of: button,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is DecoratedBox &&
                  widget.position == DecorationPosition.foreground,
            ),
          );
          BorderSide side() => switch (tester
              .widget<DecoratedBox>(rim)
              .decoration) {
            ShapeDecoration(shape: CircleBorder(side: BorderSide side)) => side,
            _ => throw StateError('Expected the close button rim'),
          };

          final resting = side();
          final center = tester.getCenter(button);
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(center);
          await tester.pumpAndSettle();
          expect(side().width, greaterThan(resting.width));
          await mouse.removePointer();
          await tester.pumpAndSettle();
          expect(side(), resting);

          final tap = await tester.startGesture(center);
          await tester.pump(const Duration(milliseconds: 150));
          await tester.pumpAndSettle();
          expect(side().width, 2);
          expect(find.byType(CountryListView), findsOneWidget);
          await tap.up();
          await tester.pumpAndSettle();
          expect(find.byType(CountryListView), findsNothing);
        },
        variant: TargetPlatformVariant.only(.android),
      );

      testWidgets('full list opens at full available height: dark=$dark', (
        tester,
      ) async {
        await pumpPicker(tester, dark: dark);
        expect(
          tester.getRect(sheet()).height,
          tester.view.physicalSize.height / tester.view.devicePixelRatio,
        );
      });

      testWidgets(
        'selection is labelled, reported and dismisses the route: dark=$dark',
        (tester) async {
          final handle = tester.ensureSemantics();
          final selected = ValueNotifier<Country?>(Country.ru());
          addTearDown(selected.dispose);
          Country? chosen;
          await pumpPicker(
            tester,
            dark: dark,
            selected: selected,
            onSelect: (value) => chosen = value,
          );
          expect(find.byKey(badge), findsOneWidget);
          expect(
            tester.getSemantics(find.bySemanticsLabel('Russia, +7')),
            isSemantics(isSelected: true, isButton: true),
          );
          await tester.tap(find.bySemanticsLabel('United States, +1'));
          await tester.pumpAndSettle();
          expect(chosen?.countryCode, 'US');
          expect(selected.value?.countryCode, 'US');
          expect(find.byType(CountryListView), findsNothing);
          handle.dispose();
        },
      );
    }

    for (final closeKey in <ValueKey<String>>[headerClose, dockClose]) {
      testWidgets('each close button dismisses the route: $closeKey', (
        tester,
      ) async {
        await pumpPicker(tester);
        await tester.tap(find.byKey(closeKey));
        await tester.pumpAndSettle();
        expect(find.byType(CountryListView), findsNothing);
      });
    }

    testWidgets('hiding search retains header close and title', (tester) async {
      await pumpPicker(tester, showSearch: false);
      expect(find.byType(CupertinoSearchTextField), findsNothing);
      expect(find.byKey(headerClose), findsOneWidget);
      expect(find.byKey(dockClose), findsNothing);
      expect(find.text('Select country'), findsOneWidget);
    });

    testWidgets(
      'explicit partial opening retains a scrollable list and expands',
      (tester) async {
        await pumpPicker(tester, expand: false, initialSize: .6, filter: null);
        final before = tester.getRect(sheet()).height;
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
        await tester.pumpAndSettle();
        expect(tester.getRect(sheet()).height, greaterThan(before));
        expect(find.byType(CustomScrollView), findsOneWidget);
      },
    );

    testWidgets(
      'search focus expands a partial sheet without hiding the title',
      (tester) async {
        await pumpPicker(tester, expand: false, initialSize: .6);
        final before = tester.getRect(sheet()).height;
        await tester.tap(find.byType(CupertinoSearchTextField));
        await tester.pumpAndSettle();
        expect(tester.getRect(sheet()).height, greaterThan(before));
        expect(find.text('Select country'), findsOneWidget);
      },
    );

    testWidgets('content scrolls under the compact transparent app bar', (
      tester,
    ) async {
      await pumpPicker(tester);
      final scaffold = tester.widget<Scaffold>(
        find
            .ancestor(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scaffold),
            )
            .first,
      );
      expect(scaffold.extendBodyBehindAppBar, isTrue);
      expect(
        tester.getTopLeft(find.byType(CustomScrollView)).dy,
        tester.getTopLeft(sheet()).dy,
      );
    });

    testWidgets('favorites precede non-repeated scrolling letter headers', (
      tester,
    ) async {
      await pumpPicker(
        tester,
        filter: const ['RU', 'RO', 'AU'],
        favorites: const ['RU'],
      );
      final favorite = find.byKey(ValueKey<String>(Country.ru().e164Key)).first;
      final a = find.byKey(const ValueKey<String>('header_A'));
      final r = find.byKey(const ValueKey<String>('header_R'));
      expect(a, findsOneWidget);
      expect(r, findsOneWidget);
      expect(tester.getTopLeft(favorite).dy, lessThan(tester.getTopLeft(a).dy));
      expect(find.byKey(const ValueKey<String>('header_')), findsNothing);
    });

    testWidgets('focusing search in an already full sheet is safe', (
      tester,
    ) async {
      await pumpPicker(tester);
      await tester.tap(find.byType(CupertinoSearchTextField));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.testTextInput.isVisible, isTrue);
    });

    testWidgets('empty search hides groups and clearing restores them', (
      tester,
    ) async {
      await pumpPicker(tester);
      await tester.enterText(find.byType(CupertinoSearchTextField), 'zzzzzz');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('header_R')), findsNothing);
      expect(find.text('Russia'), findsNothing);
      await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('header_R')), findsOneWidget);
    });

    for (final grouped in <bool>[false, true]) {
      testWidgets(
        'worldwide is first and has no calling code: grouped=$grouped',
        (tester) async {
          await pumpPicker(
            tester,
            filter: const ['RU'],
            showGroup: grouped,
            showWorldWide: true,
          );
          expect(find.bySemanticsLabel('Worldwide'), findsOneWidget);
          expect(
            tester.getTopLeft(find.text('Worldwide')).dy,
            lessThan(tester.getTopLeft(find.text('Russia').first).dy),
          );
          expect(find.text('+'), findsNothing);
        },
      );
    }

    testWidgets(
      'search-to-close gap follows padding rather than deprecated indent',
      (tester) async {
        await pumpPicker(
          tester,
          theme: CountryPickerTheme(
            padding: 24,
            // ignore: deprecated_member_use_from_same_package
            indent: 40,
          ),
        );
        expect(
          tester.getTopLeft(find.byKey(dockClose)).dx -
              tester.getTopRight(find.byType(CupertinoSearchTextField)).dx,
          24 / 1.6,
        );
      },
    );

    testWidgets('flags retain native glyphs without a circular crop', (
      tester,
    ) async {
      await pumpPicker(tester, filter: const ['RU']);
      final flag = find.text(Country.ru().flagEmoji);
      expect(flag, findsOneWidget);
      expect(
        find.ancestor(of: flag, matching: find.byType(ClipOval)),
        findsNothing,
      );
      expect(tester.widget<Text>(flag).style?.fontSize, 22);
    }, variant: TargetPlatformVariant.all());
  });

  group('diacritics -', () {
    testWidgets('accented names are sorted and grouped with the base letter', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('de'),
          builder: (context) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showCountryPicker(
                  context: context,
                  filter: const ['AT', 'OM', 'CY', 'EG', 'AL'],
                  showGroup: true,
                ),
                child: const Text('Show Picker'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      double top(String text) => tester.getTopLeft(find.text(text).first).dy;
      expect(top('Ägypten'), lessThan(top('Albanien')));
      expect(top('Oman'), lessThan(top('Österreich')));
      expect(top('Österreich'), lessThan(top('Zypern')));
      expect(
        find.byKey(const ValueKey<String>('header_Ö'), skipOffstage: false),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('header_Ä'), skipOffstage: false),
        findsNothing,
      );
    });
  });

  group('surfaceBuilder -', () {
    Future<void> pumpPicker(
      WidgetTester tester,
      CountryPickerSurfaceBuilder builder,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: InheritedCountryPickerTheme(
              data: CountryPickerTheme(),
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showCountryPicker(
                    context: context,
                    filter: const ['RU'],
                    showSearch: true,
                    surfaceBuilder: builder,
                  ),
                  child: const Text('Show Picker'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();
    }

    const closeButton = ValueKey<String>('country_picker_close_button');

    testWidgets('builds search field and close button surfaces', (
      tester,
    ) async {
      final surfaces = <CountryPickerSurface>[];
      await pumpPicker(tester, (context, surface, child) {
        surfaces.add(surface);
        return KeyedSubtree(
          key: ValueKey<String>('custom_${surface.type.name}'),
          child: child,
        );
      });

      final search = surfaces.lastWhere(
        (s) => s.type == CountryPickerSurfaceType.searchField,
      );
      final close = surfaces.lastWhere(
        (s) => s.type == CountryPickerSurfaceType.closeButton,
      );
      expect(search.shape, isA<StadiumBorder>());
      expect(search.isInteractive, isFalse);
      expect(close.shape, isA<CircleBorder>());
      expect(close.isInteractive, isTrue);
      expect(close.decoration.shape, isA<CircleBorder>());

      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('custom_searchField')),
          matching: find.byType(CupertinoSearchTextField),
        ),
        findsOneWidget,
      );
      // The custom builder replaces the default background.
      expect(
        find.descendant(
          of: find.byKey(closeButton),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
    });

    testWidgets('exposes pressed state and still closes the picker', (
      tester,
    ) async {
      final pressedValues = <bool>[];
      await pumpPicker(tester, (context, surface, child) {
        if (surface.type == CountryPickerSurfaceType.closeButton) {
          return ValueListenableBuilder<bool>(
            valueListenable: surface.pressed,
            builder: (_, pressed, child) {
              pressedValues.add(pressed);
              return child ?? const SizedBox.shrink();
            },
            child: child,
          );
        }
        return child;
      });

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(closeButton)),
      );
      // Tap down is reported after the press timeout
      // while the sheet's drag recognizer is still in the arena.
      await tester.pump(kPressTimeout);
      expect(pressedValues.last, isTrue);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byType(CountryListView), findsNothing);
    });

    testWidgets(
      'cancelled close gesture resets pressed state and keeps picker',
      (tester) async {
        ValueListenable<bool>? pressed;
        await pumpPicker(tester, (context, surface, child) {
          if (surface.type == CountryPickerSurfaceType.closeButton) {
            pressed = surface.pressed;
          }
          return child;
        });
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(closeButton)),
        );
        await tester.pump(kPressTimeout);
        expect(pressed?.value, isTrue);
        await gesture.cancel();
        await tester.pumpAndSettle();
        expect(pressed?.value, isFalse);
        expect(find.byType(CountryListView), findsOneWidget);
      },
    );

    testWidgets('builder with its own tap handler can call onPressed', (
      tester,
    ) async {
      await pumpPicker(
        tester,
        (context, surface, child) =>
            GestureDetector(onTap: surface.onPressed, child: child),
      );

      await tester.tap(find.byKey(closeButton));
      await tester.pumpAndSettle();
      expect(find.byType(CountryListView), findsNothing);
    });
  });

  group('flag rendering with a package font -', () {
    for (final brightness in Brightness.values) {
      testWidgets('preserves inherited package fonts in ${brightness.name}', (
        tester,
      ) async {
        const textStyle = TextStyle(
          fontFamily: 'Body',
          package: 'theme_fonts',
          fontFamilyFallback: <String>['Fallback'],
        );
        await tester.pumpWidget(
          createWidgetUnderTest(
            locale: const Locale('en'),
            builder: (context) => Theme(
              data: ThemeData(
                brightness: brightness,
                fontFamily: 'Body',
                package: 'theme_fonts',
                fontFamilyFallback: const <String>['Fallback'],
              ),
              child: Scaffold(
                body: InheritedCountryPickerTheme(
                  data: CountryPickerTheme(),
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () => showCountryPicker(
                        context: context,
                        filter: const ['RU'],
                        showSearch: false,
                      ),
                      child: const Text('Show Picker'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        final flag = tester.widget<RichText>(
          find.descendant(
            of: find.text(Country.ru().flagEmoji),
            matching: find.byType(RichText),
          ),
        );
        final flagSpan = flag.text.getSpanForPosition(
          const TextPosition(offset: 0),
        );
        expect(
          flagSpan?.style?.fontFamily,
          defaultTargetPlatform == TargetPlatform.windows
              ? 'TwemojiCountryFlags'
              : isNot('TwemojiCountryFlags'),
        );
        final name = tester.widget<RichText>(
          find.descendant(
            of: find.text('Russia').first,
            matching: find.byType(RichText),
          ),
        );
        expect(name.text.style?.fontFamily, textStyle.fontFamily);
        expect(
          name.text.style?.fontFamilyFallback,
          textStyle.fontFamilyFallback,
        );
      }, variant: TargetPlatformVariant.all());
    }
  });
});

class _MissingCountryTranslationDelegate
    extends LocalizationsDelegate<CountryLocalizations> {
  const _MissingCountryTranslationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<CountryLocalizations> load(Locale locale) =>
      SynchronousFuture(const _MissingCountryTranslation());

  @override
  bool shouldReload(_MissingCountryTranslationDelegate old) => false;
}

class _MissingCountryTranslation extends CountryLocalizations {
  const _MissingCountryTranslation();

  @override
  String get cancelButton => 'Cancel';

  @override
  String get phonePlaceholder => 'Phone';

  @override
  String get searchPlaceholder => 'Search';

  @override
  String get selectCountryLabel => 'Select country';

  @override
  String? countryName(String countryCode) => null;
}
