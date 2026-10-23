import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() => group('CountryListView -', () {
  Future<void> pumpList(
    WidgetTester tester, {
    CountryPickerStyle style = .classic,
    Locale locale = const Locale('en'),
    bool autofocus = false,
    bool showGroup = false,
    bool adaptive = false,
    bool dark = false,
    bool emptyTextTheme = false,
    bool showWorldWide = false,
    bool rtl = false,
    InteractiveInkFeatureFactory? splashFactory,
    ScrollController? scrollController,
    ValueNotifier<Country?>? selected,
    void Function(Country)? onSelect,
    EdgeInsets viewPadding = EdgeInsets.zero,
    EdgeInsets gestureInsets = EdgeInsets.zero,
    List<String>? filter = const ['RU', 'US'],
  }) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        locale: locale,
        builder: (context) => Theme(
          data: (dark ? ThemeData.dark() : ThemeData.light()).copyWith(
            splashFactory: splashFactory,
            textTheme: emptyTextTheme ? const TextTheme() : null,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              viewPadding: viewPadding,
              systemGestureInsets: gestureInsets,
            ),
            child: Directionality(
              textDirection: rtl ? .rtl : .ltr,
              child: InheritedCountryPickerTheme(
                data: CountryPickerTheme(
                  searchTextStyle: emptyTextTheme
                      ? null
                      : const TextStyle(color: Colors.green),
                ).copyWith(style: style),
                child: CountryListView(
                  autofocus: autofocus,
                  adaptive: adaptive,
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
      ),
    );
    await tester.pumpAndSettle();
  }

  group('country row splash -', () {
    Finder countryInkWell() => find.descendant(
      of: find.byKey(ValueKey<String>(Country.fromCountryCode('RU').e164Key)),
      matching: find.byType(InkWell),
    );

    for (final dark in [false, true]) {
      testWidgets('ios26 replaces InkSparkle and retains highlight: $dark', (
        tester,
      ) async {
        Country? chosen;
        await pumpList(
          tester,
          style: .ios26,
          dark: dark,
          splashFactory: InkSparkle.splashFactory,
          onSelect: (country) => chosen = country,
        );
        final ink = countryInkWell();
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
      });
    }

    testWidgets('classic retains the inherited InkSparkle factory', (
      tester,
    ) async {
      await pumpList(tester, splashFactory: InkSparkle.splashFactory);
      final ink = countryInkWell();
      expect(tester.widget<InkWell>(ink).splashFactory, isNull);
      expect(
        Theme.of(tester.element(ink)).splashFactory,
        InkSparkle.splashFactory,
      );
    });

    for (final factory in [
      InkRipple.splashFactory,
      InkSparkle.constantTurbulenceSeedSplashFactory,
    ]) {
      testWidgets('ios26 retains custom splash factory: $factory', (
        tester,
      ) async {
        await pumpList(tester, style: .ios26, splashFactory: factory);
        final ink = countryInkWell();
        expect(tester.widget<InkWell>(ink).splashFactory, isNull);
        expect(Theme.of(tester.element(ink)).splashFactory, factory);
      });
    }
  });

  testWidgets('status bar tap scrolls the list back to the first country', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpList(tester, scrollController: controller, filter: null);
    controller.jumpTo(400);
    await tester.pump();
    expect(controller.offset, 400);

    (tester.state(find.byType(CountryListView)) as WidgetsBindingObserver)
        .handleStatusBarTap();
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });

  testWidgets('tapping the list dismisses the search keyboard', (tester) async {
    await pumpList(tester, autofocus: true);
    expect(tester.testTextInput.isVisible, isTrue);
    final blank =
        tester.getRect(find.byType(CustomScrollView)).bottomCenter -
        const Offset(0, 15);
    await tester.tapAt(blank);
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('list taps are safe without focus and after disposal', (
    tester,
  ) async {
    await pumpList(tester);
    final gesture = tester.widget<GestureDetector>(
      find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector && widget.child is CustomScrollView,
      ),
    );
    gesture.onTap!();
    await tester.pumpWidget(const SizedBox.shrink());
    gesture.onTap!();
    expect(tester.takeException(), isNull);
  });

  for (final style in CountryPickerStyle.values) {
    testWidgets('clearing the search restores countries in $style', (
      tester,
    ) async {
      await pumpList(tester, style: style);
      await tester.enterText(find.byType(CupertinoSearchTextField), 'Russia');
      await tester.pumpAndSettle();
      expect(find.text('United States'), findsNothing);
      await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
      await tester.pumpAndSettle();
      expect(find.text('United States'), findsOneWidget);
      final search = tester.widget<CupertinoSearchTextField>(
        find.byType(CupertinoSearchTextField),
      );
      expect(search.controller!.text, isEmpty);
      expect(
        search.placeholderStyle!.color,
        Colors.green.withValues(alpha: .5),
      );
    });
  }

  for (final adaptive in [false, true]) {
    testWidgets('dark search background respects adaptive opacity: $adaptive', (
      tester,
    ) async {
      await pumpList(tester, dark: true, adaptive: adaptive);
      final search = tester.widget<CupertinoSearchTextField>(
        find.byType(CupertinoSearchTextField),
      );
      final context = tester.element(find.byType(CountryListView));
      expect(
        search.backgroundColor,
        CountryPickerTheme.resolve(
          context,
        ).backgroundColor!.withValues(alpha: adaptive ? 1 : .5),
      );
    });
  }

  testWidgets('RTL iOS 26 phone code puts the plus after the number', (
    tester,
  ) async {
    await pumpList(tester, style: .ios26, rtl: true, filter: const ['RU']);
    expect(find.text('7+'), findsOneWidget);
    expect(find.text('Russia'), findsOneWidget);
  });

  testWidgets('grouped selection invokes callback before updating notifier', (
    tester,
  ) async {
    final selected = ValueNotifier<Country?>(null);
    addTearDown(selected.dispose);
    Country? previous;
    Country? chosen;
    await pumpList(
      tester,
      showGroup: true,
      selected: selected,
      onSelect: (country) {
        previous = selected.value;
        chosen = country;
      },
    );
    await tester.tap(find.text('Russia').first);
    await tester.pumpAndSettle();
    expect(previous, isNull);
    expect(chosen!.countryCode, 'RU');
    expect(selected.value, chosen);
  });

  testWidgets('World Wide has a country button label without a calling code', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpList(tester, style: .ios26, showWorldWide: true);
    expect(find.bySemanticsLabel('Worldwide'), findsOneWidget);
    expect(find.bySemanticsLabel('Worldwide, +'), findsNothing);
    semantics.dispose();
  });

  testWidgets(
    'search uses the Cupertino placeholder color without a text theme',
    (tester) async {
      await pumpList(tester, style: .ios26, emptyTextTheme: true);
      final search = tester.widget<CupertinoSearchTextField>(
        find.byType(CupertinoSearchTextField),
      );
      final context = tester.element(find.byType(CupertinoSearchTextField));
      expect(
        search.placeholderStyle!.color,
        CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
      );
    },
  );

  for (final style in CountryPickerStyle.values) {
    testWidgets(
      'missing Turkish translation preserves the original name: $style',
      (tester) async {
        await pumpList(
          tester,
          style: style,
          locale: const Locale('tr'),
          filter: const ['HR'],
        );
        expect(find.text('Croatia'), findsOneWidget);
      },
    );
  }

  for (final style in CountryPickerStyle.values) {
    testWidgets(
      'missing Turkish translation keeps the country in its group: $style',
      (tester) async {
        await pumpList(
          tester,
          style: style,
          locale: const Locale('tr'),
          filter: const ['HR'],
          showGroup: true,
        );
        expect(find.text('Croatia'), findsWidgets);
        expect(find.text('C'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'group headers keep their labels and style heights after rebuild',
    (tester) async {
      await pumpList(tester, showGroup: true);
      final r = find.byKey(const ValueKey<String>('header_R'));
      final u = find.byKey(const ValueKey<String>('header_U'));
      expect(tester.getSize(r).height, 26);
      expect(tester.getSize(u).height, 26);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
      await pumpList(tester, showGroup: true, style: .ios26);
      expect(tester.getSize(r).height, 36);
      expect(tester.getSize(u).height, 36);
    },
  );

  for (final style in CountryPickerStyle.values) {
    testWidgets(
      'grouped $style builds viewport rows instead of every section',
      (tester) async {
        await pumpList(
          tester,
          style: style,
          showGroup: true,
          filter: null,
          showWorldWide: true,
        );
        final rows = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              (widget.properties.label?.contains(', +') ?? false),
          skipOffstage: false,
        );
        // At this viewport the old section-per-sliver tree mounts over 35 rows.
        expect(rows.evaluate().length, lessThan(25));
        await tester.enterText(find.byType(CupertinoSearchTextField), 'zzzzzz');
        await tester.pumpAndSettle();
        expect(rows, findsNothing);
        await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
        await tester.pumpAndSettle();
        expect(rows.evaluate().length, lessThan(25));
        expect(find.bySemanticsLabel('Worldwide'), findsOneWidget);
      },
    );

    testWidgets(
      '$style sticky headers pin, hand off, and return on reverse scroll',
      (tester) async {
        tester.view.physicalSize = const Size(400, 360);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = ScrollController();
        addTearDown(controller.dispose);
        var selections = 0;
        await pumpList(
          tester,
          style: style,
          showGroup: true,
          scrollController: controller,
          onSelect: (_) => selections++,
          filter: const [
            'AL',
            'AT',
            'AU',
            'BE',
            'BG',
            'BR',
            'CA',
            'CH',
            'CN',
            'DE',
            'DK',
            'DO',
          ],
        );
        final viewport = tester.getRect(find.byType(CustomScrollView));
        final first = find.byKey(
          const ValueKey<String>('header_A'),
          skipOffstage: false,
        );
        final next = find.byKey(
          const ValueKey<String>('header_B'),
          skipOffstage: false,
        );
        final pinnedA = find.byKey(const ValueKey<String>('pinned_header_A'));
        final pinnedB = find.byKey(const ValueKey<String>('pinned_header_B'));
        final initialTop = tester.getTopLeft(first).dy;
        final height = style == CountryPickerStyle.ios26 ? 36.0 : 26.0;
        controller.jumpTo(20);
        await tester.pump();
        expect(tester.getTopLeft(pinnedA).dy, closeTo(viewport.top, .001));

        controller.jumpTo(
          controller.offset +
              tester.getTopLeft(next).dy -
              viewport.top -
              height / 2,
        );
        await tester.pump();
        expect(
          tester.getTopLeft(next).dy,
          closeTo(viewport.top + height / 2, .001),
        );
        expect(
          tester.getBottomLeft(pinnedA).dy,
          closeTo(tester.getTopLeft(next).dy, .001),
        );
        controller.jumpTo(controller.offset + height);
        await tester.pump();
        expect(pinnedA, findsNothing);
        expect(tester.getTopLeft(pinnedB).dy, closeTo(viewport.top, .001));

        // The pinned copy must be the only exposed header for this section.
        final labels = <String>[];
        void collect(SemanticsNode node) {
          labels.add(node.getSemanticsData().label);
          node.visitChildren((child) {
            collect(child);
            return true;
          });
        }

        collect(
          tester
              .binding
              .renderViews
              .single
              .owner!
              .semanticsOwner!
              .rootSemanticsNode!,
        );
        expect(labels.where((label) => label == 'B'), hasLength(1));
        await tester.tap(pinnedB);
        await tester.pump();
        expect(selections, 0);

        controller.jumpTo(controller.offset - height);
        await tester.pump();
        expect(
          tester.getBottomLeft(pinnedA).dy,
          closeTo(tester.getTopLeft(next).dy, .001),
        );
        controller.jumpTo(0);
        await tester.pump();
        expect(pinnedA, findsNothing);
        expect(pinnedB, findsNothing);
        expect(tester.getTopLeft(first).dy, initialTop);
      },
    );

    testWidgets(
      '$style grouped list reaches the final country and selects it',
      (tester) async {
        Country? selection;
        await pumpList(
          tester,
          style: style,
          showGroup: true,
          filter: null,
          onSelect: (value) => selection = value,
        );
        await tester.scrollUntilVisible(
          find.bySemanticsLabel('Zimbabwe, +263'),
          500,
          scrollable: find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Zimbabwe, +263'));
        await tester.pumpAndSettle();
        expect(selection?.countryCode, 'ZW');
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final insets in [
    (const EdgeInsets.only(bottom: 20), EdgeInsets.zero, 20.0),
    (EdgeInsets.zero, const EdgeInsets.only(bottom: 24), 24.0),
  ]) {
    testWidgets('bottom spacer honors safe and gesture insets: ${insets.$3}', (
      tester,
    ) async {
      await pumpList(tester, viewPadding: insets.$1, gestureInsets: insets.$2);
      final spacer =
          tester
                  .widget<SliverToBoxAdapter>(
                    find.byType(SliverToBoxAdapter).last,
                  )
                  .child!
              as SizedBox;
      expect(spacer.height, insets.$3);
    });
  }
  testWidgets(
    'custom localization without World Wide keeps its original label',
    (tester) async {
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
    },
  );
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
