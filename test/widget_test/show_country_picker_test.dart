/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 25 October 2024
 */

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

  test('CountryPickerOptions constructs with default values', () {
    const options = CountryPickerOptions(onSelect: null);

    expect(options.expand, isTrue);
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
          expect(
            close.size,
            defaultTargetPlatform == TargetPlatform.android
                ? const Size(48, 48)
                : const Size(44, 44),
          );
        },
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
