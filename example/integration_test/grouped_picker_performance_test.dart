import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui' show FramePhase, FrameTiming;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    ..framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.benchmarkLive;
  binding.reportData = <String, dynamic>{
    'source_revision': const String.fromEnvironment('BENCHMARK_REVISION'),
    'mode': 'profile',
    'frame_policy': binding.framePolicy.name,
    'protocol_version': 2,
    'first_open_measured': true,
    'semantics_enabled': const bool.fromEnvironment(
      'BENCHMARK_SEMANTICS',
      defaultValue: true,
    ),
    'platform': defaultTargetPlatform.name,
    'dart_version': Platform.version,
    'repetitions': 3,
    'favorites': ['RU', 'US', 'FR'],
    'show_world_wide': true,
    'show_phone_code': true,
  };

  for (final style in CountryPickerStyle.values) {
    for (final language in ['en', 'tr', 'ru']) {
      const requestedStyle = String.fromEnvironment('BENCHMARK_STYLE');
      if (requestedStyle.isNotEmpty && style.name != requestedStyle) continue;
      final scenario = '${style.name}_$language';
      testWidgets(
        'grouped picker performance: $scenario',
        (tester) async {
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

          final headersFinder = find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.header == true,
          );
          final phases = <({String name, int start, int end})>[];
          final frameTimings = <FrameTiming>[];
          Future<void> measure(
            String name,
            Future<void> Function() action,
          ) async {
            final start = developer.Timeline.now;
            await action();
            phases.add((name: name, start: start, end: developer.Timeline.now));
          }

          Future<void> open() => measure('open', () async {
            await tester.tap(find.text('Open picker'));
            await tester.pumpAndSettle();
            expect(headersFinder, findsWidgets);
          });

          Future<void> close() => measure('close', () async {
            Navigator.of(tester.element(find.byType(CustomScrollView))).pop();
            await tester.pumpAndSettle();
          });

          // Retain the first opening separately from the repeated cycles.
          final firstOpenTimings = <FrameTiming>[];
          void onFirstOpen(List<FrameTiming> frames) =>
              firstOpenTimings.addAll(frames);
          binding.addTimingsCallback(onFirstOpen);
          try {
            await binding.watchPerformance(
              open,
              reportKey: '${scenario}_first_open',
            );
          } finally {
            binding.removeTimingsCallback(onFirstOpen);
          }
          final firstOpen = phases.last;
          binding.reportData!['${scenario}_first_open_action_us'] =
              firstOpen.end - firstOpen.start;
          binding.reportData!['${scenario}_first_open_window'] = {
            'start_us': firstOpen.start,
            'end_us': firstOpen.end,
          };
          binding.reportData!['${scenario}_first_open_samples'] = [
            for (final frame in firstOpenTimings) _frameData(frame),
          ];
          binding.reportData!['${scenario}_first_open_frames'] = [
            for (final frame in firstOpenTimings)
              if (frame.timestampInMicroseconds(FramePhase.buildStart) >=
                      firstOpen.start &&
                  frame.timestampInMicroseconds(FramePhase.buildStart) <
                      firstOpen.end)
                _frameData(frame),
          ];
          final headers = headersFinder.evaluate().length;
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
            'mounted_country_buttons_after_open': find
                .byWidgetPredicate(
                  (widget) =>
                      widget is Semantics &&
                      widget.properties.button == true &&
                      (widget.properties.label?.contains(', +') ?? false),
                  skipOffstage: false,
                )
                .evaluate()
                .length,
            'visible_country_buttons_after_open': buttons,
          };
          await close();

          phases.clear();
          void onTimings(List<FrameTiming> frames) =>
              frameTimings.addAll(frames);
          binding.addTimingsCallback(onTimings);
          try {
            await binding.watchPerformance(() async {
              for (var iteration = 0; iteration < 3; iteration++) {
                await open();
                final scrollView = find.byType(CustomScrollView);
                await measure('scroll_down', () async {
                  await tester.fling(scrollView, const Offset(0, -1500), 3000);
                  await tester.pumpAndSettle();
                });
                await measure('scroll_up', () async {
                  await tester.fling(scrollView, const Offset(0, 1500), 3000);
                  await tester.pumpAndSettle();
                });
                expect(scrollView, findsOneWidget);

                final search = find.byType(CupertinoSearchTextField);
                // Exercise the package search without native keyboard timing.
                final controller = tester
                    .widget<CupertinoSearchTextField>(search)
                    .controller!;
                await measure('search', () async {
                  controller.text = language == 'ru' ? 'р' : 'a';
                  await tester.pumpAndSettle();
                });
                expect(countryButtons, findsWidgets);
                await measure('empty_search', () async {
                  controller.text = 'zzzzzz';
                  await tester.pumpAndSettle();
                });
                expect(headersFinder, findsNothing);
                expect(countryButtons, findsNothing);
                await measure('clear_search', () async {
                  controller.clear();
                  await tester.pumpAndSettle();
                });
                expect(headersFinder.evaluate().length, headers);
                await close();
              }
              // Wait for the final batch of frame timings.
              await Future<void>.delayed(const Duration(milliseconds: 1100));
            }, reportKey: scenario);
          } finally {
            binding.removeTimingsCallback(onTimings);
          }
          binding.reportData!['${scenario}_image_cache'] = {
            'count': imageCache.currentSize,
            'bytes': imageCache.currentSizeBytes,
            'live': imageCache.liveImageCount,
            'pending': imageCache.pendingImageCount,
          };
          binding.reportData!['${scenario}_timing_samples'] = [
            for (final frame in frameTimings) _frameData(frame),
          ];
          binding.reportData!['${scenario}_phases'] = [
            for (final phase in phases)
              {
                'name': phase.name,
                'start_us': phase.start,
                'end_us': phase.end,
                'action_us': phase.end - phase.start,
                'frames': [
                  for (final frame in frameTimings)
                    if (frame.timestampInMicroseconds(FramePhase.buildStart) >=
                            phase.start &&
                        frame.timestampInMicroseconds(FramePhase.buildStart) <
                            phase.end)
                      _frameData(frame),
                ],
              },
          ];
        },
        semanticsEnabled: const bool.fromEnvironment(
          'BENCHMARK_SEMANTICS',
          defaultValue: true,
        ),
      );
    }
  }
}

Map<String, int> _frameData(FrameTiming frame) => {
  'frame_number': frame.frameNumber,
  'build_start_us': frame.timestampInMicroseconds(FramePhase.buildStart),
  'raster_start_us': frame.timestampInMicroseconds(FramePhase.rasterStart),
  'raster_finish_us': frame.timestampInMicroseconds(FramePhase.rasterFinish),
  'ui_us': frame.buildDuration.inMicroseconds,
  'raster_us': frame.rasterDuration.inMicroseconds,
  'raster_queue_us':
      frame.timestampInMicroseconds(FramePhase.rasterStart) -
      frame.timestampInMicroseconds(FramePhase.buildFinish),
  'total_us': frame.totalSpan.inMicroseconds,
};
