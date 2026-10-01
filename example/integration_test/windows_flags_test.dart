import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    expect(Platform.isWindows, isTrue);
    expect(kIsWeb, isFalse);
    expect(defaultTargetPlatform, TargetPlatform.windows);
    await (FontLoader('packages/theme_fonts/Body')..addFont(
          rootBundle.load('assets/fonts/SF-Pro/SF-Pro-Rounded-Regular.otf'),
        ))
        .load();
  });

  for (final extended in <bool>[false, true]) {
    testWidgets(
      'renders colored flags: ${extended ? 'extended' : 'default'} input',
      (tester) async {
        final boundaryKey = GlobalKey();
        final fontLoaded = Completer<void>();
        void onFontLoaded() {
          if (!fontLoaded.isCompleted) fontLoaded.complete();
        }

        if (!extended) {
          PaintingBinding.instance.systemFonts.addListener(onFontLoaded);
          addTearDown(
            () => PaintingBinding.instance.systemFonts.removeListener(
              onFontLoaded,
            ),
          );
        }
        await tester.pumpWidget(
          _app(
            boundaryKey,
            Center(
              child: SizedBox(
                width: 400,
                child: extended
                    ? CountryPhoneInput.extended(initialCountry: Country.ru())
                    : CountryPhoneInput(initialCountry: Country.ru()),
              ),
            ),
          ),
        );
        if (!extended) {
          await fontLoaded.future.timeout(const Duration(seconds: 30));
        }
        await tester.pumpAndSettle();
        await _checkFlag(
          tester,
          boundaryKey,
          extended ? 'extended' : 'default',
        );
      },
    );
  }

  for (final style in CountryPickerStyle.values) {
    testWidgets('renders a colored flag in the ${style.name} picker', (
      tester,
    ) async {
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        _app(
          boundaryKey,
          Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showCountryPicker(
                  context: context,
                  filter: const <String>['RU'],
                  showSearch: false,
                  showGroup: false,
                  onSelect: (_) {},
                ),
                child: const Text('Show picker'),
              ),
            ),
          ),
          style: style,
        ),
      );
      await tester.tap(find.text('Show picker'));
      await tester.pumpAndSettle();
      await _checkFlag(tester, boundaryKey, style.name);
    });
  }
}

Widget _app(
  GlobalKey boundaryKey,
  Widget child, {
  CountryPickerStyle style = CountryPickerStyle.classic,
}) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: CountryLocalizations.supportedLocales,
  localizationsDelegates: const <LocalizationsDelegate<Object?>>[
    CountryLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  theme: ThemeData(
    fontFamily: 'Body',
    package: 'theme_fonts',
    fontFamilyFallback: const <String>['Fallback'],
  ),
  builder: (context, child) => RepaintBoundary(
    key: boundaryKey,
    child: InheritedCountryPickerTheme(
      data: CountryPickerTheme(style: style),
      child: child!,
    ),
  ),
  home: Scaffold(backgroundColor: Colors.white, body: child),
);

Future<void> _checkFlag(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String name,
) async {
  expect(tester.takeException(), isNull);
  final flag = Country.ru().flagEmoji;
  final text = tester.widget<RichText>(
    find.byWidgetPredicate(
      (widget) =>
          widget is RichText && widget.text.toPlainText().contains(flag),
    ),
  );
  expect(
    text.text
        .getSpanForPosition(
          TextPosition(offset: text.text.toPlainText().indexOf(flag)),
        )
        ?.style
        ?.fontFamily,
    'TwemojiCountryFlags',
  );
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage();
  try {
    final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    final directory = await Directory(
      'build/windows-flags',
    ).create(recursive: true);
    await File('${directory.path}/$name.png').writeAsBytes(
      png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
    );
    final pixels = (await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    ))!;
    var red = 0;
    var blue = 0;
    for (var i = 0; i < pixels.lengthInBytes; i += 4) {
      final r = pixels.getUint8(i);
      final g = pixels.getUint8(i + 1);
      final b = pixels.getUint8(i + 2);
      if (pixels.getUint8(i + 3) < 200) continue;
      if (r > 120 && r > g * 1.5 && r > b * 1.5) red++;
      if (b > 80 && b > r * 1.5 && b > g * 1.2) blue++;
    }
    expect(
      red,
      greaterThan(10),
      reason: '$name must render the red flag stripe',
    );
    expect(
      blue,
      greaterThan(10),
      reason: '$name must render the blue flag stripe',
    );
  } finally {
    image.dispose();
  }
}
