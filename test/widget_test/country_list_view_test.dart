/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 2 October 2026
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() => group('CountryListView -', () {
  Future<void> pumpList(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool autofocus = false,
    bool showGroup = false,
    bool dark = false,
    bool showWorldWide = false,
    bool rtl = false,
    InteractiveInkFeatureFactory? splashFactory,
    ScrollController? scrollController,
    ValueNotifier<Country?>? selected,
    ValueChanged<Country>? onSelect,
    EdgeInsets viewInsets = EdgeInsets.zero,
    List<String>? filter = const ['RU', 'US'],
  }) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        locale: locale,
        theme: (dark ? ThemeData.dark() : ThemeData.light()).copyWith(
          splashFactory: splashFactory,
        ),
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
          child: Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: InheritedCountryPickerTheme(
              data: CountryPickerTheme(
                searchTextStyle: const TextStyle(color: Colors.green),
              ),
              child: CountryListView(
                autofocus: autofocus,
                showSearch: true,
                showGroup: showGroup,
                showWorldWide: showWorldWide,
                filter: filter,
                scrollController: scrollController,
                selected: selected,
                onSelect: onSelect,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder country(String code) =>
      find.byKey(ValueKey<String>(Country.fromCountryCode(code).e164Key));

  for (final dark in <bool>[false, true]) {
    testWidgets(
      'default sparkle is replaced and selection is retained: dark=$dark',
      (tester) async {
        Country? chosen;
        await pumpList(
          tester,
          dark: dark,
          splashFactory: InkSparkle.splashFactory,
          onSelect: (value) => chosen = value,
        );
        final ink = find.descendant(
          of: country('RU'),
          matching: find.byType(InkWell),
        );
        expect(
          tester.widget<InkWell>(ink).splashFactory,
          NoSplash.splashFactory,
        );
        final context = tester.element(ink);
        expect(
          Theme.of(context).highlightColor,
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context),
        );
        await tester.tap(ink);
        await tester.pumpAndSettle();
        expect(chosen?.countryCode, 'RU');
      },
    );

    testWidgets('search and clear restore the original countries: dark=$dark', (
      tester,
    ) async {
      await pumpList(tester, dark: dark);
      await tester.enterText(find.byType(CupertinoSearchTextField), 'Russia');
      await tester.pumpAndSettle();
      expect(country('US'), findsNothing);
      await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
      await tester.pumpAndSettle();
      expect(country('US'), findsOneWidget);
      final search = tester.widget<CupertinoSearchTextField>(
        find.byType(CupertinoSearchTextField),
      );
      expect(search.controller?.text, isEmpty);
      expect(
        search.placeholderStyle?.color,
        Colors.green.withValues(alpha: .5),
      );
    });

    testWidgets(
      'group surfaces follow brightness and keep symmetric margins: dark=$dark',
      (tester) async {
        await pumpList(tester, dark: dark, showGroup: true);
        final surface = find.ancestor(
          of: country('RU'),
          matching: find.byType(ClipRSuperellipse),
        );
        expect(surface, dark ? findsNothing : findsOneWidget);
        if (!dark) {
          final body = tester.getRect(find.byType(CustomScrollView));
          final card = tester.getRect(surface);
          expect(card.left - body.left, 16);
          expect(body.right - card.right, 16);
        }
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
        expect(scaffold.extendBodyBehindAppBar, isTrue);
      },
    );

    testWidgets('content and divider padding matches iOS: dark=$dark', (
      tester,
    ) async {
      await pumpList(
        tester,
        dark: dark,
        showGroup: true,
        filter: const ['RU', 'RW', 'US'],
      );
      final viewport = tester.getRect(find.byType(CustomScrollView));
      final flag = find.text(Country.ru().flagEmoji);
      expect(tester.getTopLeft(flag).dx - viewport.left, 32);
      expect(viewport.right - tester.getTopRight(find.text('+7')).dx, 32);
      expect(
        tester.getTopLeft(find.byType(Divider).first).dx,
        viewport.left + (dark ? 0 : 16),
      );
    }, variant: TargetPlatformVariant.only(.android));

    testWidgets(
      'headers scroll with the list and return without pinned copies: dark=$dark',
      (tester) async {
        final scroll = ScrollController();
        addTearDown(scroll.dispose);
        await pumpList(
          tester,
          dark: dark,
          showGroup: true,
          filter: null,
          scrollController: scroll,
        );
        final first = find.byKey(const ValueKey<String>('header_A'));
        final initial = tester.getTopLeft(first).dy;
        scroll.jumpTo(20);
        await tester.pump();
        expect(tester.getTopLeft(first).dy, closeTo(initial - 20, .001));
        expect(
          find.byKey(const ValueKey<String>('pinned_header_A')),
          findsNothing,
        );
        scroll.jumpTo(0);
        await tester.pump();
        expect(tester.getTopLeft(first).dy, initial);
      },
    );
  }

  for (final factory in [
    InkRipple.splashFactory,
    InkSparkle.constantTurbulenceSeedSplashFactory,
  ]) {
    testWidgets('custom splash factory is preserved: $factory', (tester) async {
      await pumpList(tester, splashFactory: factory);
      final ink = find.descendant(
        of: country('RU'),
        matching: find.byType(InkWell),
      );
      expect(tester.widget<InkWell>(ink).splashFactory, isNull);
      expect(Theme.of(tester.element(ink)).splashFactory, factory);
    });
  }

  testWidgets('status bar tap scrolls back to the first country', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await pumpList(tester, scrollController: scroll, filter: null);
    scroll.jumpTo(400);
    await tester.pump();
    if (tester.state(find.byType(CountryListView))
        case WidgetsBindingObserver observer) {
      observer.handleStatusBarTap();
    } else {
      fail('The list must observe native status-bar taps.');
    }
    await tester.pumpAndSettle();
    expect(scroll.offset, 0);
  });

  testWidgets('keyboard does not shrink or move the alphabet', (tester) async {
    const key = ValueKey<String>('country_picker_alphabet');
    await pumpList(tester, showGroup: true, filter: null);
    final before = tester.getRect(find.byKey(key));
    await pumpList(
      tester,
      showGroup: true,
      filter: null,
      viewInsets: const EdgeInsets.only(bottom: 250),
    );
    expect(tester.getRect(find.byKey(key)), before);
  });

  testWidgets('alphabet glyphs are centered in the outer 16-pixel margin', (
    tester,
  ) async {
    await pumpList(tester, showGroup: true);
    final glyph = find.descendant(
      of: find.byKey(const ValueKey<String>('country_picker_alphabet')),
      matching: find.text('R'),
    );
    final viewport = tester.getRect(find.byType(CustomScrollView));
    expect(viewport.right - tester.getCenter(glyph).dx, 8);
  });

  testWidgets(
    'first letter header is compact; later groups keep their spacing',
    (tester) async {
      await pumpList(tester, showGroup: true);
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('header_R'))).height,
        26,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('header_U'))).height,
        56,
      );
      expect(find.text('R'), findsNWidgets(2));
    },
  );

  testWidgets('grouped countries remain virtualized through search and clear', (
    tester,
  ) async {
    await pumpList(tester, showGroup: true, filter: null, showWorldWide: true);
    final rows = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.button == true &&
          (widget.properties.label?.contains(', +') ?? false),
      skipOffstage: false,
    );
    expect(rows.evaluate().length, lessThan(25));
    await tester.enterText(find.byType(CupertinoSearchTextField), 'zzzzzz');
    await tester.pumpAndSettle();
    expect(rows, findsNothing);
    await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
    await tester.pumpAndSettle();
    expect(rows.evaluate().length, lessThan(25));
    expect(find.bySemanticsLabel('Worldwide'), findsOneWidget);
  });

  testWidgets('alphabet tap and drag navigate through lazy groups', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await pumpList(
      tester,
      showGroup: true,
      filter: null,
      scrollController: scroll,
    );
    final rail = find.byKey(const ValueKey<String>('country_picker_alphabet'));
    final z = find.descendant(of: rail, matching: find.text('Z'));
    await tester.tap(z);
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(0));
    expect(find.bySemanticsLabel('Zimbabwe, +263'), findsOneWidget);
    final bounds = tester.getRect(rail);
    await tester.dragFrom(
      bounds.bottomCenter - const Offset(0, 2),
      Offset(0, -bounds.height + 4),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('header_A')), findsOneWidget);
  });

  testWidgets('the final country remains reachable and selectable', (
    tester,
  ) async {
    Country? chosen;
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await pumpList(
      tester,
      showGroup: true,
      filter: null,
      scrollController: scroll,
      onSelect: (value) => chosen = value,
    );
    await tester.scrollUntilVisible(
      find.bySemanticsLabel('Zimbabwe, +263'),
      500,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Zimbabwe, +263'));
    await tester.pumpAndSettle();
    expect(chosen?.countryCode, 'ZW');
  });

  testWidgets(
    'grouped selection invokes callback before updating the notifier',
    (tester) async {
      final selected = ValueNotifier<Country?>(null);
      addTearDown(selected.dispose);
      Country? before;
      Country? chosen;
      await pumpList(
        tester,
        showGroup: true,
        selected: selected,
        onSelect: (value) {
          before = selected.value;
          chosen = value;
        },
      );
      await tester.tap(country('RU'));
      await tester.pumpAndSettle();
      expect(before, isNull);
      expect(chosen?.countryCode, 'RU');
      expect(selected.value, chosen);
    },
  );

  testWidgets('missing Turkish translation keeps Croatia visible and grouped', (
    tester,
  ) async {
    await pumpList(
      tester,
      locale: const Locale('tr'),
      filter: const ['HR'],
      showGroup: true,
    );
    expect(find.text('Croatia'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('header_C')), findsOneWidget);
  });

  testWidgets('RTL calling code places the plus after the number', (
    tester,
  ) async {
    await pumpList(tester, rtl: true, filter: const ['RU']);
    expect(find.text('7+'), findsOneWidget);
  });

  testWidgets('a list tap dismisses the keyboard', (tester) async {
    await pumpList(tester, autofocus: true);
    expect(tester.testTextInput.isVisible, isTrue);
    await tester.tapAt(tester.getRect(find.byType(CustomScrollView)).center);
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('a custom localization retains the original worldwide label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      createWidgetUnderTest(
        locale: const Locale('en'),
        builder: (context) => Localizations.override(
          context: context,
          delegates: const [_MissingCountryNamesDelegate()],
          child: const CountryListView(filter: ['RU'], showWorldWide: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('World Wide'), findsOneWidget);
    semantics.dispose();
  });
});

final class _MissingCountryNames extends CountryLocalizations {
  const _MissingCountryNames();

  @override
  String get cancelButton => 'Cancel';

  @override
  String get phonePlaceholder => 'Phone';

  @override
  String get searchPlaceholder => 'Search';

  @override
  String get selectCountryLabel => 'Select country';

  @override
  String? countryName(String code) => null;
}

final class _MissingCountryNamesDelegate
    extends LocalizationsDelegate<CountryLocalizations> {
  const _MissingCountryNamesDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CountryLocalizations> load(Locale locale) =>
      SynchronousFuture(const _MissingCountryNames());

  @override
  bool shouldReload(_MissingCountryNamesDelegate old) => false;
}
