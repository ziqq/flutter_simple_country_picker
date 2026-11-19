/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 6 November 2026
 */

import 'dart:ui' show SemanticsAction;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() => group('Country accessibility -', () {
  for (final size in [
    const Size(320, 568),
    const Size(568, 320),
    const Size(1024, 768),
  ]) {
    for (final scale in [1.0, 2.0, 3.2]) {
      for (final brightness in Brightness.values) {
        for (final locale in [const Locale('ru'), const Locale('ar')]) {
          for (final bold in [false, true]) {
            testWidgets(
              'picker $size $scale $brightness $locale bold=$bold',
              (tester) async {
                await _pumpAccessible(
                  tester,
                  size: size,
                  scale: scale,
                  brightness: brightness,
                  bold: bold,
                  locale: locale,
                  child: const CountryListView(
                    showGroup: true,
                    showSearch: true,
                  ),
                );
                expect(tester.takeException(), isNull);
                final close = find.byKey(
                  const ValueKey<String>('country_picker_header_close_button'),
                );
                final header = tester.getRect(close);
                final dock = tester.getRect(
                  find.byType(CupertinoSearchTextField),
                );
                expect(header.top, greaterThanOrEqualTo(0));
                expect(header.bottom, lessThan(dock.top));
                expect(dock.bottom, lessThanOrEqualTo(size.height));
                await tester.enterText(
                  find.byType(CupertinoSearchTextField),
                  'Russia',
                );
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
              },
              variant: const TargetPlatformVariant({
                TargetPlatform.android,
                TargetPlatform.iOS,
              }),
            );
          }
        }
      }
    }
  }

  for (final extended in [false, true]) {
    for (final scale in [1.0, 2.0, 3.2]) {
      testWidgets(
        'phone extended=$extended scale=$scale bold',
        (tester) async {
          await _pumpAccessible(
            tester,
            size: const Size(320, 568),
            scale: scale,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: extended
                    ? CountryPhoneInput.extended(
                        initialCountry: Country.parse('BS'),
                      )
                    : CountryPhoneInput(initialCountry: Country.parse('BS')),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          final editable = tester
              .state<EditableTextState>(find.byType(EditableText))
              .renderEditable;
          expect(
            editable.size.height,
            greaterThanOrEqualTo(editable.preferredLineHeight),
          );
          expect(
            editable.cursorHeight,
            greaterThanOrEqualTo(editable.preferredLineHeight),
          );
          await tester.enterText(find.byType(EditableText), '2425551234');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
        variant: const TargetPlatformVariant({
          TargetPlatform.android,
          TargetPlatform.iOS,
        }),
      );
    }
  }

  for (final brightness in Brightness.values) {
    for (final highContrast in [false, true]) {
      testWidgets(
        'labelled platform targets $brightness highContrast=$highContrast',
        (tester) async {
          final handle = tester.ensureSemantics();
          try {
            await _pumpAccessible(
              tester,
              size: const Size(390, 844),
              brightness: brightness,
              highContrast: highContrast,
              child: const CountryListView(showGroup: true, showSearch: true),
            );
            await expectLater(
              tester,
              meetsGuideline(labeledTapTargetGuideline),
            );
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            await expectLater(
              tester,
              meetsGuideline(
                Theme.of(
                          tester.element(find.byType(CountryListView)),
                        ).platform ==
                        TargetPlatform.android
                    ? androidTapTargetGuideline
                    : iOSTapTargetGuideline,
              ),
            );
          } finally {
            handle.dispose();
          }
        },
        variant: const TargetPlatformVariant({
          TargetPlatform.android,
          TargetPlatform.iOS,
        }),
      );
    }
  }
  testWidgets(
    'screen reader adjusts letters and selects a full country label',
    (tester) async {
      final handle = tester.ensureSemantics();
      Country? selected;
      final notifier = ValueNotifier<Country?>(Country.ru());
      try {
        await _pumpAccessible(
          tester,
          size: const Size(320, 568),
          scale: 3.2,
          child: CountryListView(
            filter: const ['AU', 'RU', 'ZW'],
            showGroup: true,
            selected: notifier,
            onSelect: (country) => selected = country,
          ),
        );
        final rail = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.slider == true,
        );
        var node = tester.getSemantics(rail);
        expect(node.getSemanticsData().value, 'A');
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.increase),
          isTrue,
        );
        node.owner?.performAction(node.id, SemanticsAction.increase);
        await tester.pumpAndSettle();
        node = tester.getSemantics(rail);
        expect(node.getSemanticsData().value, 'R');
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.decrease),
          isTrue,
        );
        final country = tester.getSemantics(
          find.bySemanticsLabel('Russia, +7'),
        );
        expect(
          country,
          matchesSemantics(
            label: 'Russia, +7',
            isButton: true,
            isSelected: true,
            hasSelectedState: true,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true,
          ),
        );
        country.owner?.performAction(country.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(selected?.countryCode, 'RU');
      } finally {
        notifier.dispose();
        handle.dispose();
      }
    },
  );

  testWidgets(
    'large bold text keeps search and alphabet stable above keyboard',
    (tester) async {
      await _pumpAccessible(
        tester,
        size: const Size(320, 568),
        scale: 3.2,
        child: const CountryListView(showGroup: true, showSearch: true),
      );
      final rail = find.byKey(
        const ValueKey<String>('country_picker_alphabet'),
      );
      final rect = tester.getRect(rail);
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetViewInsets);
      await tester.tap(find.byType(CupertinoSearchTextField));
      await tester.pumpAndSettle();
      expect(tester.getRect(rail), rect);
      expect(
        tester.getRect(find.byType(CupertinoSearchTextField)).bottom,
        lessThanOrEqualTo(328),
      );
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.byType(CupertinoSearchTextField),
        'no-such-country',
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.byType(EditableText)).getSemanticsData().label,
        'Search',
      );
    },
  );
  for (final adaptive in [false, true]) {
    testWidgets(
      'modal large text safe area adaptive=$adaptive',
      (tester) async {
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 34);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);
        Country? selected;
        await _pumpAccessible(
          tester,
          size: const Size(320, 568),
          scale: 3.2,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showCountryPicker(
                context: context,
                adaptive: adaptive,
                showSearch: true,
                showGroup: true,
                filter: const ['BS', 'RU', 'ZW'],
                onSelect: (country) => selected = country,
              ),
              child: const Text('Open'),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.enterText(find.byType(CupertinoSearchTextField), 'Russia');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.bySemanticsLabel('Russia, +7'));
        await tester.pumpAndSettle();
        expect(selected?.countryCode, 'RU');
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );
  }

  testWidgets(
    'font preferences update an existing list and support nonlinear scaling',
    (tester) async {
      const list = CountryListView(filter: ['RU'], showGroup: true);
      await _pumpAccessible(
        tester,
        size: const Size(320, 568),
        bold: false,
        child: list,
      );
      final original = tester
          .getSize(find.bySemanticsLabel('Russia, +7'))
          .height;
      await _pumpAccessible(
        tester,
        size: const Size(320, 568),
        scale: 3.2,
        child: list,
      );
      expect(
        tester.getSize(find.bySemanticsLabel('Russia, +7')).height,
        greaterThan(original * 2),
      );
      expect(tester.takeException(), isNull);
      await _pumpAccessible(
        tester,
        size: const Size(320, 568),
        textScaler: const _NonlinearTextScaler(),
        child: list,
      );
      expect(tester.takeException(), isNull);
      for (final extended in [false, true]) {
        await _pumpAccessible(
          tester,
          size: const Size(320, 568),
          textScaler: const _NonlinearTextScaler(),
          child: extended
              ? const CountryPhoneInput.extended()
              : const CountryPhoneInput(),
        );
        expect(tester.takeException(), isNull);
        final editable = tester
            .state<EditableTextState>(find.byType(EditableText))
            .renderEditable;
        expect(
          editable.size.height,
          greaterThanOrEqualTo(editable.preferredLineHeight),
        );
      }
    },
  );

  for (final extended in [false, true]) {
    testWidgets(
      'phone labels survive editing; disabled country extended=$extended',
      (tester) async {
        await _pumpAccessible(
          tester,
          size: const Size(320, 568),
          child: extended
              ? const CountryPhoneInput.extended(enableOpenPicker: false)
              : const CountryPhoneInput(enableOpenPicker: false),
        );
        final country = tester.getSemantics(
          find.byKey(
            ValueKey<String>(
              extended
                  ? 'country_picker_button_extended'
                  : 'country_picker_phone_code',
            ),
          ),
        );
        expect(
          country,
          matchesSemantics(
            label: 'Russia, +7',
            isButton: true,
            hasEnabledState: true,
            hasTapAction: true,
          ),
        );
        // Cupertino retains its tap semantics action even when disabled.
        // Activation must still leave the picker closed.
        country.owner?.performAction(country.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(find.byType(CountryListView), findsNothing);
        await tester.enterText(find.byType(EditableText), '12345');
        await tester.pumpAndSettle();
        final field = tester.getSemantics(find.byType(EditableText));
        expect(
          field.getSemanticsData().label,
          CountryLocalizations.of(
            tester.element(find.byType(EditableText)),
          ).phonePlaceholder,
        );
        expect(field.getSemanticsData().value, isNotEmpty);
      },
    );
  }
  for (final extended in [false, true]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'phone contrast and touch targets extended=$extended $brightness',
        (tester) async {
          final handle = tester.ensureSemantics();
          try {
            await _pumpAccessible(
              tester,
              size: const Size(390, 844),
              brightness: brightness,
              child: SingleChildScrollView(
                child: extended
                    ? const CountryPhoneInput.extended()
                    : const CountryPhoneInput(),
              ),
            );
            await expectLater(
              tester,
              meetsGuideline(labeledTapTargetGuideline),
            );
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            await expectLater(
              tester,
              meetsGuideline(
                Theme.of(tester.element(find.byType(EditableText))).platform ==
                        TargetPlatform.android
                    ? androidTapTargetGuideline
                    : iOSTapTargetGuideline,
              ),
            );
          } finally {
            handle.dispose();
          }
        },
        variant: const TargetPlatformVariant({
          TargetPlatform.android,
          TargetPlatform.iOS,
        }),
      );
    }
  }
});

/// Applies platform accessibility preferences above every tested widget.
Future<void> _pumpAccessible(
  WidgetTester tester, {
  required Widget child,
  required Size size,
  double scale = 1,
  bool bold = true,
  TextScaler? textScaler,
  bool highContrast = false,
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    createWidgetUnderTest(
      locale: locale,
      theme: ThemeData(brightness: brightness),
      appBuilder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: textScaler ?? TextScaler.linear(scale),
          boldText: bold,
          highContrast: highContrast,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      builder: (context) =>
          child is CountryListView ? child : Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

/// Models Android-style nonlinear font scaling instead of one global multiplier.
class _NonlinearTextScaler extends TextScaler {
  const _NonlinearTextScaler();

  @override
  double scale(double fontSize) => fontSize * (fontSize <= 14 ? 2 : 1.6);

  @override
  double get textScaleFactor => 2;
}
