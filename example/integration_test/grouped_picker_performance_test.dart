import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    ..reportData = <String, dynamic>{
      'source_revision': const String.fromEnvironment('BENCHMARK_REVISION'),
      'mode': 'profile',
      'platform': defaultTargetPlatform.name,
      'dart_version': Platform.version,
      'repetitions': 3,
      'favorites': ['RU', 'US', 'FR'],
      'show_world_wide': true,
      'show_phone_code': true,
    };

  for (final style in CountryPickerStyle.values) {
    for (final language in ['en', 'tr', 'ru']) {
      final scenario = '${style.name}_$language';
      testWidgets('grouped picker performance: $scenario', (tester) async {
        if (!kProfileMode) fail('Run this benchmark with --profile.');
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(scenario),
            locale: Locale(language),
            supportedLocales: CountryLocalizations.supportedLocales,
            localizationsDelegates: const [
              CountryLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            theme: ThemeData(extensions: [CountryPickerTheme(style: style)]),
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: TextButton(
                    onPressed: () => showCountryPicker(
                      context: context,
                      showGroup: true,
                      showSearch: true,
                      showPhoneCode: true,
                      showWorldWide: true,
                      expand: true,
                      shouldCloseOnSwipeDown: false,
                      favorites: const ['RU', 'US', 'FR'],
                      useHapticFeedback: false,
                    ),
                    child: const Text('Open picker'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        Future<void> open() async {
          await tester.tap(find.text('Open picker'));
          await tester.pumpAndSettle();
          expect(find.byType(SliverPersistentHeader), findsWidgets);
        }

        Future<void> close() async {
          Navigator.of(tester.element(find.byType(CustomScrollView))).pop();
          await tester.pumpAndSettle();
        }

        // Warm the locale, font glyphs and rendering pipeline before timing.
        await open();
        final headers = find.byType(SliverPersistentHeader).evaluate().length;
        final countryButtons = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              (widget.properties.label?.contains(', +') ?? false),
        );
        final buttons = countryButtons.evaluate().length;
        expect(buttons, greaterThan(0));
        expect(buttons, lessThan(241));
        binding.reportData!['${scenario}_structure'] = {
          'visible_group_headers_after_open': headers,
          'visible_country_buttons_after_open': buttons,
        };
        await close();

        await binding.watchPerformance(() async {
          for (var iteration = 0; iteration < 3; iteration++) {
            await open();
            final scrollView = find.byType(CustomScrollView);
            await tester.fling(scrollView, const Offset(0, -1500), 3000);
            await tester.pumpAndSettle();
            await tester.fling(scrollView, const Offset(0, 1500), 3000);
            await tester.pumpAndSettle();
            expect(scrollView, findsOneWidget);

            final search = find.byType(CupertinoSearchTextField);
            // Exercise the package search without native keyboard timing.
            final controller =
                tester.widget<CupertinoSearchTextField>(search).controller!
                  ..text = language == 'ru' ? 'р' : 'a';
            await tester.pumpAndSettle();
            expect(countryButtons, findsWidgets);
            controller.text = 'zzzzzz';
            await tester.pumpAndSettle();
            expect(find.byType(SliverPersistentHeader), findsNothing);
            expect(countryButtons, findsNothing);
            controller.clear();
            await tester.pumpAndSettle();
            expect(
              find.byType(SliverPersistentHeader).evaluate().length,
              headers,
            );
            await close();
          }
        }, reportKey: scenario);
      });
    }
  }
}
