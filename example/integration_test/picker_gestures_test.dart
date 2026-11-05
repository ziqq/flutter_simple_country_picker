/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 4 November 2026
 */

import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final adaptive in <bool>[false, true]) {
    testWidgets('scroll before dismiss and scroll to top; adaptive=$adaptive', (
      tester,
    ) async {
      var dismissals = 0;
      await tester.pumpWidget(
        _Host(
          adaptive: adaptive,
          canDismiss: true,
          onDismiss: () => dismissals++,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final list = find.byType(CustomScrollView).last;
      final scrollable = find
          .descendant(of: list, matching: find.byType(Scrollable))
          .first;
      final position = tester.state<ScrollableState>(scrollable).position
        ..jumpTo(600);

      // Tap empty app-bar space, not only the title text.
      await tester.pumpAndSettle();
      final bar = tester.getRect(find.byType(CupertinoNavigationBar).last);
      await tester.tapAt(Offset(bar.right - 30, bar.bottom - 12));
      await tester.pumpAndSettle();
      expect(position.pixels, closeTo(position.minScrollExtent, .5));

      // Exercise the same SDK channel used by a native iOS status-bar tap.
      position.jumpTo(600);
      await tester.pumpAndSettle();
      ui.channelBuffers.push(
        SystemChannels.statusBar.name,
        SystemChannels.statusBar.codec.encodeMethodCall(
          const MethodCall('handleScrollToTop'),
        ),
        (_) {},
      );
      await tester.pumpAndSettle();
      expect(position.pixels, closeTo(position.minScrollExtent, .5));

      // A fast gesture crosses the top and continues ballistically.
      // Its remaining distance and velocity must never dismiss the sheet.
      position.jumpTo(300);
      await tester.pumpAndSettle();
      await tester.fling(list, const Offset(0, 500), 4000);
      await tester.pumpAndSettle();
      expect(dismissals, 0);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(position.pixels, closeTo(position.minScrollExtent, .5));

      // Only the next deliberate downward gesture may dismiss it.
      await tester.timedDrag(
        list,
        const Offset(0, 60),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(dismissals, 0);
      expect(
        tester.getRect(find.byType(CupertinoNavigationBar).last).top,
        closeTo(bar.top, .5),
      );
      await tester.fling(list, const Offset(0, 250), 2000);
      await tester.pumpAndSettle();
      expect(dismissals, 1);
      expect(find.byType(CupertinoNavigationBar), findsNothing);
    });

    testWidgets('disabled dismissal keeps scrolling; adaptive=$adaptive', (
      tester,
    ) async {
      var dismissals = 0;
      await tester.pumpWidget(
        _Host(
          adaptive: adaptive,
          canDismiss: false,
          onDismiss: () => dismissals++,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final list = find.byType(CustomScrollView).last;
      await tester.fling(list, const Offset(0, 250), 2000);
      await tester.pumpAndSettle();
      expect(dismissals, 0);
      await tester.drag(list, const Offset(0, -250));
      await tester.pumpAndSettle();
      final scrollable = find
          .descendant(of: list, matching: find.byType(Scrollable))
          .first;
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        greaterThan(0),
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final dark in <bool>[false, true]) {
    for (final expanded in <bool>[false, true]) {
      testWidgets(
        'backdrops preserve sheet corners; dark=$dark expanded=$expanded',
        (tester) async {
          final captureKey = GlobalKey();
          await tester.pumpWidget(
            _Host(
              adaptive: false,
              canDismiss: true,
              expand: expanded,
              dark: dark,
              captureKey: captureKey,
              onDismiss: () {},
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final button = tester.getRect(
            find.byKey(
              const ValueKey<String>('country_picker_header_close_button'),
            ),
          );
          final sheetTop = button.top - 16;
          expect(sheetTop, greaterThan(8));
          final boundary = switch (captureKey.currentContext
              ?.findRenderObject()) {
            RenderRepaintBoundary boundary => boundary,
            _ => throw StateError('Capture boundary is missing.'),
          };
          final image = await boundary.toImage(pixelRatio: 1);
          try {
            final pixels = await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            );
            if (pixels == null)
              throw StateError('Could not read corner pixels.');
            List<int> pixel(int x, int y) => List<int>.generate(
              4,
              (channel) => pixels.getUint8((y * image.width + x) * 4 + channel),
            );
            // These points are well outside the rounded outline, so they must
            // retain the same route backdrop as the pixels directly above it.
            for (final x in <int>[1, image.width - 2]) {
              expect(
                pixel(x, sheetTop.ceil() + 1),
                pixel(x, sheetTop.floor() - 8),
              );
            }
          } finally {
            image.dispose();
          }
        },
      );
    }
  }

  testWidgets('search expands the partial sheet', (tester) async {
    await tester.pumpWidget(
      _Host(adaptive: false, canDismiss: true, expand: false, onDismiss: () {}),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(find.byType(CupertinoNavigationBar)).dy;
    await tester.tap(find.byType(CupertinoSearchTextField));
    // A focused native field keeps scheduling caret frames. Wait for the
    // keyboard transition without requiring the application to become idle.
    await tester.pump(const Duration(milliseconds: 500));
    await Future<void>.delayed(const Duration(milliseconds: 700));
    await tester.pump();
    final after = tester.getTopLeft(find.byType(CupertinoNavigationBar)).dy;
    expect(after, lessThan(before - 50));
    expect(tester.takeException(), isNull);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });

  testWidgets('keyboard insets preserve alphabet size and position', (
    tester,
  ) async {
    await tester.pumpWidget(
      _Host(adaptive: false, canDismiss: true, onDismiss: () {}),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final rail = find.byKey(const ValueKey<String>('country_picker_alphabet'));
    final before = tester.getRect(rail);
    addTearDown(tester.view.resetViewInsets);
    tester.view.viewInsets = FakeViewPadding(
      bottom: 300 * tester.view.devicePixelRatio,
    );
    await tester.pumpAndSettle();
    final after = tester.getRect(rail);
    expect(after.height, closeTo(before.height, .5));
    expect(after.top, closeTo(before.top, .5));
    expect(tester.takeException(), isNull);
  });
}

/// Runs the public picker API against both supported route presentations.
class _Host extends StatelessWidget {
  const _Host({
    required this.adaptive,
    required this.canDismiss,
    required this.onDismiss,
    this.expand = true,
    this.dark = false,
    this.captureKey,
  });

  final bool adaptive;
  final bool canDismiss;
  final VoidCallback onDismiss;
  final bool expand;
  final bool dark;
  final GlobalKey? captureKey;

  @override
  Widget build(BuildContext context) => MaterialApp(
    supportedLocales: CountryLocalizations.supportedLocales,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      CountryLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: const Color(0xFF54738A),
      extensions: <ThemeExtension<dynamic>>[CountryPickerTheme()],
    ),
    builder: (context, child) => RepaintBoundary(
      key: captureKey,
      child: child ?? const SizedBox.shrink(),
    ),
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => showCountryPicker(
              context: context,
              adaptive: adaptive,
              expand: expand,
              showGroup: true,
              showSearch: true,
              shouldCloseOnSwipeDown: canDismiss,
              useHapticFeedback: false,
              whenComplete: onDismiss,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}
