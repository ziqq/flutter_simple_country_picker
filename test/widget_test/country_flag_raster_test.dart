import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/widget/country_list_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/test_util.dart';

void main() => group('Country flag raster -', () {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cache = PaintingBinding.instance.imageCache;

  setUp(() {
    cache
      ..clear()
      ..clearLiveImages();
  });
  tearDown(() {
    cache
      ..clear()
      ..clearLiveImages();
  });

  Future<void> pumpFlags(
    WidgetTester tester, {
    ValueNotifier<Country?>? selected,
    double scale = 1,
    double dpr = 1,
    bool rtl = false,
    bool selectable = false,
    bool settle = true,
    Color color = Colors.black,
  }) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        locale: const Locale('en'),
        builder: (context) {
          final list = InheritedCountryPickerTheme(
            data: CountryPickerTheme(style: CountryPickerStyle.ios26),
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.apply(bodyColor: color),
              ),
              child: CountryListView(
                showSearch: false,
                showGroup: false,
                showWorldWide: true,
                selected: selected,
                filter: const ['RU', 'US'],
                useHapticFeedback: false,
              ),
            ),
          );
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              devicePixelRatio: dpr,
            ),
            child: Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: selectable ? SelectionArea(child: list) : list,
            ),
          );
        },
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  Future<void> systemMessage(WidgetTester tester, String type) async {
    await tester.runAsync(() async {
      final done = Completer<void>();
      tester.binding.channelBuffers.push(
        SystemChannels.system.name,
        const JSONMessageCodec().encodeMessage({'type': type}),
        (_) => done.complete(),
      );
      await done.future;
    });
    await tester.pumpAndSettle();
  }

  testWidgets('reuses flags after selection changes and remounting', (
    tester,
  ) async {
    final selected = ValueNotifier<Country?>(Country.fromCountryCode('US'));
    addTearDown(selected.dispose);
    await pumpFlags(tester, selected: selected);
    expect(cache.currentSize, 3);
    final bytes = cache.currentSizeBytes;
    selected.value = Country.fromCountryCode('RU');
    await tester.pumpAndSettle();
    expect(cache.currentSize, 3);
    expect(cache.currentSizeBytes, bytes);
    expect(
      find.byKey(const ValueKey<String>('country_picker_selected_badge')),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpFlags(tester, selected: selected);
    expect(cache.currentSize, 3);
    expect(cache.liveImageCount, 0);
    expect(cache.pendingImageCount, 0);
  });

  testWidgets('shows text first and prepares at most two images per frame', (
    tester,
  ) async {
    await pumpFlags(tester, settle: false);
    for (
      var frame = 0;
      frame < 10 && find.byType(ClipOval).evaluate().isEmpty;
      frame++
    ) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.byType(ClipOval), findsNWidgets(3));
    expect(cache.currentSize, 0);
    final glyphs = find.descendant(
      of: find.byType(ClipOval),
      matching: find.byType(RichText),
    );
    expect(glyphs, findsNWidgets(3));
    for (final element in glyphs.evaluate()) {
      expect(
        (element.renderObject! as RenderParagraph).debugNeedsPaint,
        isFalse,
      );
    }
    await tester.pump(const Duration(milliseconds: 16));
    expect(cache.currentSize, 2);
    await tester.pumpAndSettle();
    expect(cache.currentSize, 3);
  });

  testWidgets('text scaling, direction and density keep distinct images', (
    tester,
  ) async {
    await pumpFlags(tester);
    final bytes = cache.currentSizeBytes;
    await pumpFlags(tester, scale: 1.8);
    expect(cache.currentSize, 6);
    await pumpFlags(tester, scale: 1.8, rtl: true);
    expect(cache.currentSize, 9);
    await pumpFlags(tester, scale: 1.8, rtl: true, dpr: 2);
    expect(cache.currentSize, 12);
    expect(cache.currentSizeBytes, bytes * 7);
    for (final element in find.byType(ClipOval).evaluate()) {
      expect((element.renderObject! as RenderBox).size, const Size(40, 40));
    }
  });

  testWidgets('invalidates cached glyphs after fontsChange while unmounted', (
    tester,
  ) async {
    await pumpFlags(tester);
    expect(cache.currentSize, 3);
    await tester.pumpWidget(const SizedBox.shrink());
    await systemMessage(tester, 'fontsChange');
    await pumpFlags(tester);
    expect(cache.currentSize, 6);
  });

  testWidgets('repaints after fontsChange and inherited style updates', (
    tester,
  ) async {
    await pumpFlags(tester);
    await systemMessage(tester, 'fontsChange');
    expect(cache.currentSize, 6);
    await pumpFlags(tester, color: Colors.red);
    expect(cache.currentSize, greaterThan(6));
    final redCount = cache.currentSize;
    await pumpFlags(tester, color: Colors.blue);
    expect(cache.currentSize, greaterThan(redCount));
  });

  for (final disableBytes in [false, true]) {
    testWidgets('draws with the image cache disabled: bytes=$disableBytes', (
      tester,
    ) async {
      final oldCount = cache.maximumSize;
      final oldBytes = cache.maximumSizeBytes;
      addTearDown(() {
        cache
          ..maximumSize = oldCount
          ..maximumSizeBytes = oldBytes;
      });
      if (disableBytes) {
        cache.maximumSizeBytes = 0;
      } else {
        cache.maximumSize = 0;
      }
      await pumpFlags(tester);
      await pumpFlags(tester, scale: 1.8);
      expect(cache.currentSize, 0);
      expect(cache.liveImageCount, 0);
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Worldwide'), findsOneWidget);
    });
  }

  testWidgets('respects eviction and repaints after memory pressure', (
    tester,
  ) async {
    final oldLimit = cache.maximumSize;
    addTearDown(() => cache.maximumSize = oldLimit);
    cache.maximumSize = 1;
    await pumpFlags(tester);
    expect(cache.currentSize, 1);
    await systemMessage(tester, 'memoryPressure');
    expect(cache.currentSize, 0);
    await pumpFlags(tester, scale: 1.8);
    expect(cache.currentSize, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retains selectable text without caching selection layers', (
    tester,
  ) async {
    await pumpFlags(tester, selectable: true);
    expect(cache.currentSize, 0);
    expect(find.bySemanticsLabel('Worldwide'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
});
