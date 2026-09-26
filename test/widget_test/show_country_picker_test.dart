import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_simple_country_picker/src/widget/show_country_picker.dart'
    show CountryPickerOptions;
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

  test('CountryPickerOptions constructs with default values', () {
    const options = CountryPickerOptions(onSelect: null);

    expect(options.expand, isFalse);
    expect(options.adaptive, isFalse);
    expect(options.autofocus, isFalse);
    expect(options.isDismissible, isTrue);
    expect(options.isScrollControlled, isTrue);
    expect(options.showPhoneCode, isFalse);
    expect(options.showWorldWide, isFalse);
    expect(options.useHapticFeedback, isTrue);
    expect(options.useRootNavigator, isFalse);
    expect(options.useSafeArea, isTrue);
    expect(options.exclude, isNull);
    expect(options.filter, isNull);
    expect(options.favorites, isNull);
    expect(options.whenComplete, isNull);
  });

  group('useIOS26 -', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      bool useIOS26 = true,
      bool? showGroup,
      bool? showSearch,
      SelectedCountry? selected,
      SelectCountryCallback? onSelect,
    }) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: InheritedCountryPickerTheme(
              data: CountryPickerTheme(useIOS26: useIOS26),
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showCountryPicker(
                    context: context,
                    filter: const ['RU', 'US', 'GB'],
                    showGroup: showGroup,
                    showSearch: showSearch,
                    selected: selected,
                    onSelect: onSelect,
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
    const selectedBadge = ValueKey<String>('country_picker_selected_badge');

    testWidgets('shows round close button instead of cancel text', (
      tester,
    ) async {
      await pumpPicker(tester, showSearch: true);

      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
      expect(find.byKey(closeButton), findsOneWidget);
      expect(find.text('Отмена'), findsNothing);
    });

    testWidgets('close button dismisses the picker', (tester) async {
      await pumpPicker(tester, showSearch: true);

      await tester.tap(find.byKey(closeButton));
      await tester.pumpAndSettle();

      expect(find.byType(CountryListView), findsNothing);
    });

    testWidgets('hides title when search is shown', (tester) async {
      await pumpPicker(tester, showSearch: true);
      expect(find.text('Выберите страну'), findsNothing);
    });

    testWidgets('keeps title and drag handle when search is hidden', (
      tester,
    ) async {
      await pumpPicker(tester, showSearch: false);
      expect(find.text('Выберите страну'), findsOneWidget);
      expect(find.byKey(closeButton), findsNothing);
    });

    testWidgets('shows phone code and localized name in plain list', (
      tester,
    ) async {
      await pumpPicker(tester, showSearch: true);

      expect(find.text('+7'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('+44'), findsOneWidget);
      expect(find.text('Россия'), findsOneWidget);
    });

    testWidgets('marks selected country with a badge', (tester) async {
      final selected = ValueNotifier<Country?>(Country.ru());
      addTearDown(selected.dispose);

      await pumpPicker(tester, showSearch: true, selected: selected);

      expect(find.byKey(selectedBadge), findsOneWidget);
    });

    testWidgets('shows no badge without selection', (tester) async {
      await pumpPicker(tester, showSearch: true);
      expect(find.byKey(selectedBadge), findsNothing);
    });

    testWidgets('selecting a country calls onSelect and closes picker', (
      tester,
    ) async {
      Country? result;
      final selected = ValueNotifier<Country?>(null);
      addTearDown(selected.dispose);

      await pumpPicker(
        tester,
        showSearch: true,
        selected: selected,
        onSelect: (country) => result = country,
      );

      await tester.tap(find.text('Россия'));
      await tester.pumpAndSettle();

      expect(result?.countryCode, 'RU');
      expect(selected.value?.countryCode, 'RU');
      expect(find.byType(CountryListView), findsNothing);
    });

    testWidgets('renders grouped list with section headers', (tester) async {
      final selected = ValueNotifier<Country?>(Country.ru());
      addTearDown(selected.dispose);

      await pumpPicker(tester, showGroup: true, selected: selected);

      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
      expect(find.text('Р'), findsOneWidget);
      expect(find.text('Россия'), findsOneWidget);
      expect(find.byKey(selectedBadge), findsOneWidget);
    });

    testWidgets('default style keeps cancel text button', (tester) async {
      await pumpPicker(tester, useIOS26: false, showSearch: true);

      expect(find.byKey(closeButton), findsNothing);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.byKey(selectedBadge), findsNothing);
    });
  });

  group('grouping -', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      required List<String> filter,
      List<String>? favorites,
      bool useIOS26 = false,
      bool showPhoneCode = false,
      bool showWorldWide = false,
      bool? showGroup = true,
      List<String>? exclude,
    }) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: InheritedCountryPickerTheme(
              data: CountryPickerTheme(useIOS26: useIOS26),
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showCountryPicker(
                    context: context,
                    filter: exclude == null ? filter : null,
                    exclude: exclude,
                    favorites: favorites,
                    showGroup: showGroup,
                    showPhoneCode: showPhoneCode,
                    showWorldWide: showWorldWide,
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

    Finder header(String letter) =>
        find.byKey(ValueKey<String>('header_$letter'), skipOffstage: false);

    for (final useIOS26 in <bool>[false, true]) {
      for (final showPhoneCode in <bool>[false, true]) {
        testWidgets('favorites get their own section without a header and '
            'letters are not repeated (useIOS26: $useIOS26, '
            'showPhoneCode: $showPhoneCode)', (tester) async {
          await pumpPicker(
            tester,
            filter: const ['RU', 'RO', 'AU'],
            favorites: const ['RU'],
            useIOS26: useIOS26,
            showPhoneCode: showPhoneCode,
          );

          expect(header('Р'), findsOneWidget);
          expect(header('А'), findsOneWidget);
          expect(header(''), findsNothing);

          // The favorite is listed above every letter header.
          final favoriteTop = tester.getTopLeft(find.text('Россия').first).dy;
          expect(favoriteTop, lessThan(tester.getTopLeft(find.text('А')).dy));
          expect(
            find.text('Россия'),
            showPhoneCode ? findsNWidgets(2) : findsOneWidget,
          );
        });
      }
    }

    testWidgets('search without results clears the groups', (tester) async {
      await pumpPicker(tester, filter: const ['RU', 'AU']);
      expect(header('Р'), findsOneWidget);

      await tester.enterText(find.byType(CupertinoSearchTextField), 'zzz');
      await tester.pumpAndSettle();

      expect(header('Р'), findsNothing);
      expect(find.text('Россия'), findsNothing);
    });

    for (final useIOS26 in <bool>[false, true]) {
      for (final showGroup in <bool>[false, true]) {
        testWidgets('showWorldWide adds the option on top without a phone '
            'code (useIOS26: $useIOS26, showGroup: $showGroup)', (
          tester,
        ) async {
          await pumpPicker(
            tester,
            filter: const ['RU'],
            showWorldWide: true,
            useIOS26: useIOS26,
            showGroup: showGroup,
          );

          expect(find.text('Мировой'), findsOneWidget);
          expect(
            tester.getTopLeft(find.text('Мировой')).dy,
            lessThan(tester.getTopLeft(find.text('Россия')).dy),
          );
          expect(find.text('+'), findsNothing);
          expect(find.textContaining('(+)'), findsNothing);
        });
      }
    }

    testWidgets('showWorldWide respects exclude', (tester) async {
      await pumpPicker(
        tester,
        filter: const [],
        exclude: const ['WW'],
        showWorldWide: true,
      );
      expect(find.text('Мировой'), findsNothing);
    });
  });

  group('iOS 26 sheet behavior -', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      required bool useIOS26,
    }) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: InheritedCountryPickerTheme(
              data: CountryPickerTheme(useIOS26: useIOS26),
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () =>
                      showCountryPicker(context: context, showSearch: true),
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

    for (final useIOS26 in <bool>[false, true]) {
      testWidgets('scrolling the list ${useIOS26 ? 'expands' : 'keeps'} '
          'the sheet (useIOS26: $useIOS26)', (tester) async {
        await pumpPicker(tester, useIOS26: useIOS26);
        final search = find.byType(CupertinoSearchTextField);
        final before = tester.getTopLeft(search).dy;

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
        await tester.pumpAndSettle();

        final after = tester.getTopLeft(search).dy;
        if (useIOS26) {
          expect(after, lessThan(before));
        } else {
          expect(after, before);
        }
      });
    }

    testWidgets('list is clipped below a solid header', (tester) async {
      await pumpPicker(tester, useIOS26: true);

      final scaffold = tester.widget<Scaffold>(
        find
            .ancestor(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scaffold),
            )
            .first,
      );
      expect(scaffold.extendBodyBehindAppBar, isFalse);
      expect(
        tester.getTopLeft(find.byType(CustomScrollView)).dy,
        greaterThan(
          tester.getBottomLeft(find.byType(CupertinoSearchTextField)).dy,
        ),
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
              data: CountryPickerTheme(useIOS26: true, surfaceBuilder: builder),
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showCountryPicker(
                    context: context,
                    filter: const ['RU'],
                    showSearch: true,
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
              return child!;
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

  group('semantics -', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      bool useIOS26 = false,
      bool? showGroup,
      bool? showSearch,
      bool showPhoneCode = false,
      SelectedCountry? selected,
    }) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: InheritedCountryPickerTheme(
              data: CountryPickerTheme(useIOS26: useIOS26),
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showCountryPicker(
                    context: context,
                    filter: const ['RU', 'US'],
                    showGroup: showGroup,
                    showSearch: showSearch,
                    showPhoneCode: showPhoneCode,
                    selected: selected,
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

    for (final useIOS26 in <bool>[false, true]) {
      testWidgets('tile is one button labelled with name and phone code '
          '(useIOS26: $useIOS26)', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpPicker(tester, useIOS26: useIOS26, showGroup: true);

        expect(
          tester.getSemantics(find.bySemanticsLabel('Россия, +7')),
          isSemantics(label: 'Россия, +7', isButton: true, hasTapAction: true),
        );
        // The emoji flag and the separate texts are not announced.
        expect(find.bySemanticsLabel('🇷🇺'), findsNothing);
        expect(find.bySemanticsLabel('Russia'), findsNothing);
        handle.dispose();
      });

      testWidgets('group letters are headers (useIOS26: $useIOS26)', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpPicker(tester, useIOS26: useIOS26, showGroup: true);

        expect(
          tester.getSemantics(find.bySemanticsLabel('Р')),
          isSemantics(label: 'Р', isHeader: true),
        );
        handle.dispose();
      });
    }

    testWidgets('simple tile exposes selected state', (tester) async {
      final handle = tester.ensureSemantics();
      final selected = ValueNotifier<Country?>(Country.ru());
      addTearDown(selected.dispose);
      await pumpPicker(tester, selected: selected);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Россия, +7')),
        isSemantics(isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Соединенные Штаты, +1')),
        isSemantics(isSelected: false),
      );
      handle.dispose();
    });

    testWidgets('iOS 26 tile exposes selected state', (tester) async {
      final handle = tester.ensureSemantics();
      final selected = ValueNotifier<Country?>(Country.ru());
      addTearDown(selected.dispose);
      await pumpPicker(
        tester,
        useIOS26: true,
        showSearch: true,
        selected: selected,
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Россия, +7')),
        isSemantics(isSelected: true, isButton: true),
      );
      handle.dispose();
    });

    testWidgets('iOS 26 close button is labelled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPicker(tester, useIOS26: true, showSearch: true);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Отмена')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      handle.dispose();
    });

    testWidgets('drag handle is excluded from semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPicker(tester, showSearch: false);

      // Title and tiles are still reachable, nothing else is added.
      expect(find.bySemanticsLabel('Выберите страну'), findsOneWidget);
      handle.dispose();
    });
  });

  group('iOS 26 flag rendering -', () {
    const regionalRU = '\u{1F1F7}\u{1F1FA}';

    Future<void> pumpPicker(WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          builder: (context) => Scaffold(
            body: InheritedCountryPickerTheme(
              data: CountryPickerTheme(useIOS26: true),
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showCountryPicker(
                    context: context,
                    filter: const ['RU'],
                    showSearch: true,
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

    double fontSizeOf(WidgetTester tester, String text) =>
        tester.widget<Text>(find.text(text)).style!.fontSize!;

    testWidgets(
      'renders emoji flag clipped to a circle with a platform scale',
      (tester) async {
        await pumpPicker(tester);

        final expectedScale = switch (defaultTargetPlatform) {
          TargetPlatform.iOS || TargetPlatform.macOS => 2.0,
          _ => 1.6,
        };

        if (defaultTargetPlatform == TargetPlatform.windows) {
          // Segoe UI Emoji has no flags: ISO code fallback in a circle.
          expect(find.text(regionalRU), findsNothing);
          expect(
            find.ancestor(of: find.text('RU'), matching: find.byType(ClipOval)),
            findsOneWidget,
          );
        } else {
          expect(
            find.ancestor(
              of: find.text(regionalRU),
              matching: find.byType(ClipOval),
            ),
            findsOneWidget,
          );
          expect(fontSizeOf(tester, regionalRU), 40 * expectedScale);
        }
      },
      variant: TargetPlatformVariant.all(),
    );
  });

  test('CountryPickerOptions accepts all optional fields', () {
    final options = CountryPickerOptions(
      exclude: const ['RU'],
      favorites: const ['US'],
      filter: const ['GB'],
      onSelect: (_) {},
      whenComplete: () {},
      expand: true,
      showPhoneCode: true,
      showWorldWide: true,
      showGroup: true,
      showSearch: false,
      isDismissible: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
    );

    expect(options.exclude, contains('RU'));
    expect(options.favorites, contains('US'));
    expect(options.filter, contains('GB'));
    expect(options.expand, isTrue);
    expect(options.showPhoneCode, isTrue);
    expect(options.showWorldWide, isTrue);
    expect(options.showGroup, isTrue);
    expect(options.showSearch, isFalse);
    expect(options.isDismissible, isFalse);
    expect(options.initialChildSize, 0.8);
    expect(options.minChildSize, 0.4);
  });

  test('CountryPickerOptions prefers the correctly spelled parameter', () {
    const options = CountryPickerOptions(
      // ignore: deprecated_member_use
      useHaptickFeedback: true,
      useHapticFeedback: false,
    );

    expect(options.useHapticFeedback, isFalse);
  });
});
