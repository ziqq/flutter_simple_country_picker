import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
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

        final sheet = find.byType(BottomSheet);
        final bounds = tester.getRect(sheet);
        final draggableSheet = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        expect(
          draggableSheet.initialChildSize,
          initialSize ?? (expand ? 1 : .65),
        );
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
    await tester.enterText(search, 'RU');
    await tester.pumpAndSettle();
    expect(find.text('R'), findsOneWidget);

    locale.value = const Locale('ru');
    await tester.pumpAndSettle();
    expect(find.text('Россия'), findsOneWidget);
    expect(find.text('Р'), findsOneWidget);
    expect(
      tester.widget<CupertinoSearchTextField>(search).controller?.text,
      'RU',
    );
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

    expect(find.text('R'), findsOneWidget);
    expect(find.text('Russia'), findsOneWidget);
  });

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
