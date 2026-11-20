import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() => group('showCountryPicker -', () {
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
      radius: 15,
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

    final modalSheet = tester.widget<ClipRRect>(find.byType(ClipRRect));
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

  final initialTheme = CountryPickerTheme(flagSize: 22, radius: 11);
  for (final (scope, localTheme, useMaterialTheme) in [
    ('global', null, false),
    ('local Material styling with inherited extensions', null, true),
    ('local', CountryPickerTheme(flagSize: 34, radius: 17), false),
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
          (widget) => widget is ClipRRect && widget.child is DecoratedBox,
        ),
      );
      void expectSheetTheme(double expectedFlagSize) {
        final radius = Radius.circular(expectedFlagSize / 2);
        expect(tester.widget<Text>(flag).style?.fontSize, expectedFlagSize);
        expect(
          tester.widget<ClipRRect>(sheet).borderRadius,
          BorderRadius.only(topLeft: radius, topRight: radius),
        );
      }

      expectSheetTheme(localTheme?.flagSize ?? 22);
      appTheme.value = CountryPickerTheme(flagSize: 42, radius: 21);
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
    final header = find.byKey(const ValueKey('header_child_R'));
    Color? headerColor() =>
        (tester.widget<DecoratedBox>(header).decoration as BoxDecoration).color;

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

      final cancelButton = CountryLocalizations.of(
        tester.element(find.byType(CountryListView)),
      ).cancelButton;
      await tester.tap(find.text(cancelButton));
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
});
