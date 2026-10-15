import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final captures = <String, String>{};
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    ..reportData = <String, dynamic>{
      'revision': const String.fromEnvironment('CAPTURE_REVISION'),
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'captures': captures,
    };

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    await settle(tester);
    expect(tester.takeException(), isNull);
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      final pixels = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      var red = 0;
      var blue = 0;
      for (var i = 0; i < pixels.lengthInBytes; i += 4) {
        final r = pixels.getUint8(i);
        final g = pixels.getUint8(i + 1);
        final b = pixels.getUint8(i + 2);
        if (r > 120 && r > g * 1.5 && r > b * 1.5) red++;
        if (b > 80 && b > r * 1.5 && b > g * 1.2) blue++;
      }
      expect(red, greaterThan(30), reason: '$name has colored flag pixels');
      expect(blue, greaterThan(30), reason: '$name has colored flag pixels');
      captures[name] = base64Encode(
        png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
      );
      binding.reportData!['${name}_size'] = [image.width, image.height];
    } finally {
      image.dispose();
    }
  }

  for (final brightness in Brightness.values) {
    final mode = brightness.name;
    testWidgets('phone inputs / $mode', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        _app(
          key,
          brightness,
          .classic,
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${kIsWeb ? 'web' : defaultTargetPlatform.name} · $mode',
                style: const TextStyle(fontSize: 22, fontWeight: .w600),
              ),
              const SizedBox(height: 20),
              const Text('CountryPhoneInput'),
              const SizedBox(height: 8),
              CountryPhoneInput(initialCountry: Country.ru()),
              const SizedBox(height: 12),
              CountryPhoneInput(initialCountry: Country.fromCountryCode('US')),
              const SizedBox(height: 20),
              const Text('CountryPhoneInput.extended'),
              const SizedBox(height: 8),
              CountryPhoneInput.extended(
                initialCountry: Country.fromCountryCode('JP'),
              ),
              const SizedBox(height: 16),
              CountryPhoneInput.extended(
                initialCountry: Country.fromCountryCode('AE'),
              ),
            ],
          ),
        ),
      );
      await capture(tester, key, '$mode-inputs');
    });

    for (final style in CountryPickerStyle.values) {
      for (final grouped in [false, true]) {
        testWidgets('${style.name} / grouped=$grouped / $mode', (tester) async {
          final key = GlobalKey();
          final selected = SelectedCountry(Country.fromCountryCode('US'));
          addTearDown(selected.dispose);
          await tester.pumpWidget(
            _app(
              key,
              brightness,
              style,
              Builder(
                builder: (context) => Center(
                  child: TextButton(
                    onPressed: () => showCountryPicker(
                      context: context,
                      expand: true,
                      showGroup: grouped,
                      showPhoneCode: grouped,
                      showSearch: true,
                      showWorldWide: true,
                      favorites: const ['US', 'RU', 'JP'],
                      filter: const [
                        'US',
                        'RU',
                        'JP',
                        'AE',
                        'GB',
                        'DE',
                        'FR',
                        'CN',
                        'IN',
                      ],
                      selected: selected,
                      useHapticFeedback: false,
                    ),
                    child: const Text('Open picker'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open picker'));
          await settle(tester);
          expect(find.byType(CupertinoSearchTextField), findsOneWidget);
          final name = '$mode-${style.name}-${grouped ? 'grouped' : 'plain'}';
          await capture(tester, key, name);
          if (!grouped) {
            final controller =
                tester
                      .widget<CupertinoSearchTextField>(
                        find.byType(CupertinoSearchTextField),
                      )
                      .controller!
                  ..text = 'u';
            await settle(tester);
            expect(
              find.byIcon(CupertinoIcons.xmark_circle_fill),
              findsOneWidget,
            );
            await capture(tester, key, '$mode-${style.name}-search');
            controller.clear();
            await settle(tester);
            expect(find.byIcon(CupertinoIcons.xmark_circle_fill), findsNothing);
          }
          Navigator.of(tester.element(find.byType(CustomScrollView))).pop();
          await settle(tester);
        });
      }
    }
  }
}

Widget _app(
  GlobalKey boundaryKey,
  Brightness brightness,
  CountryPickerStyle style,
  Widget child,
) => MaterialApp(
  key: UniqueKey(),
  debugShowCheckedModeBanner: false,
  locale: const Locale('en'),
  supportedLocales: CountryLocalizations.supportedLocales,
  localizationsDelegates: const [
    CountryLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  theme: ThemeData(
    brightness: brightness,
    extensions: [CountryPickerTheme(style: style)],
  ),
  builder: (_, child) => RepaintBoundary(key: boundaryKey, child: child!),
  home: Scaffold(body: SafeArea(child: child)),
);
