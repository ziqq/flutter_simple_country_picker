/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 11 November 2026
 */

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_scroll_edge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Run the shader variant from example to bundle shaders as package assets.
  const shaderFilters = bool.fromEnvironment('PICKER_TEST_SCROLL_EDGE');
  const shaderAssets = String.fromEnvironment(
    'PICKER_TEST_SCROLL_EDGE_ASSETS',
    defaultValue: 'bundled',
  );
  if (shaderAssets != 'bundled') {
    testWidgets('retains the fade with $shaderAssets shader assets', (
      tester,
    ) async {
      expect(ui.ImageFilter.isShaderFilterSupported, isTrue);
      _configureView(tester);
      _replaceShaderAssets(shaderAssets);

      final boundaryKey = GlobalKey();
      final effectKey = GlobalKey();
      const contributionsFail = shaderAssets == 'incompatible-contributions';
      for (final scale in [1.0, if (contributionsFail) .95]) {
        await tester.pumpWidget(_scene(boundaryKey, effectKey, scale: scale));
        await tester.pumpAndSettle();

        final filters = _backdropFilters(tester);
        expect(filters, hasLength(6));
        expect(
          filters.every((filter) => filter.enabled == contributionsFail),
          isTrue,
        );
        expect(_shade, contributionsFail ? findsNothing : findsOneWidget);
        if (!contributionsFail) {
          final filter = filters.first;
          final context = ImageFilterContext(bounds: Offset.zero & filter.size);
          expect(() => filter.filterConfig.resolve(context), throwsStateError);
        }
        await _expectFade(tester, tester.renderObject(find.byKey(boundaryKey)));
      }
    });
    return;
  }

  testWidgets(
    'renders the header fade through opacity, transforms and isolated clips',
    (tester) async {
      expect(ui.ImageFilter.isShaderFilterSupported, shaderFilters);
      _configureView(tester);
      final boundaryKey = GlobalKey();
      final effectKey = GlobalKey();

      for (final (opacity, isolated, extent, scale) in [
        (1.0, false, 20.0, 1.0),
        (.85, false, 16.0, 1.0),
        (1.0, false, 20.0, .95),
        (1.0, true, 20.0, 1.0),
        (1.0, false, 0.0, 1.0),
      ]) {
        await tester.pumpWidget(
          _scene(
            boundaryKey,
            effectKey,
            opacity: opacity,
            isolated: isolated,
            extent: extent,
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();
        expect(_shade, shaderFilters ? findsNothing : findsOneWidget);

        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(boundaryKey),
        );
        // The first scene may initialize the shader for translucent layers.
        await tester.runAsync(
          () => _sampleFrame(boundary, tester.view.devicePixelRatio),
        );
        await tester.pumpAndSettle();
        await _expectFade(tester, boundary);

        if (shaderFilters && !isolated && extent == 20 && scale == 1) {
          final filters = _backdropFilters(tester);
          expect(filters, hasLength(6));
          expect(filters.every((filter) => filter.enabled), isTrue);
          final outer = filters.first;
          final configuration = outer.filterConfig;
          expect(configuration.filter, isNull);
          expect(configuration.debugShortDescription, 'scroll edge');
          final context = ImageFilterContext(bounds: Offset.zero & outer.size);
          expect(configuration.resolve(context), isA<ui.ImageFilter>());

          // An SDK filter in the contribution list invalidates the crop.
          final contribution = filters.elementAt(3);
          final filter = ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1);
          contribution.filterConfig = ImageFilterConfig(filter);
          await tester.pump();
          expect(contribution.layer?.filter, filter);
          await _expectFade(tester, boundary);

          final child = contribution.child;
          contribution.child = null;
          try {
            await tester.pump();
            expect(contribution.layer, isNull);
            await _expectFade(tester, boundary);
          } finally {
            contribution.child = child;
          }
        }
      }
    },
  );
}

final _shade = find.descendant(
  of: find.byType(CountryPickerScrollEdgeEffect),
  matching: find.byWidgetPredicate((widget) => widget is DecoratedBox),
);

void _configureView(WidgetTester tester) {
  tester.view
    ..devicePixelRatio = 3
    ..physicalSize = const Size(360, 540);
  addTearDown(tester.view.reset);
}

Iterable<RenderBackdropFilter> _backdropFilters(WidgetTester tester) =>
    tester.renderObjectList<RenderBackdropFilter>(
      find.byElementPredicate(
        (element) =>
            element is RenderObjectElement &&
            element.renderObject is RenderBackdropFilter,
      ),
    );

void _replaceShaderAssets(String fixture) {
  const bundle = 'build/unit_test_assets';
  const packageShaders =
      '$bundle/packages/flutter_simple_country_picker/assets/shaders';
  final assets = switch (fixture) {
    'missing' || 'incompatible-separation' => ['scroll_edge_separated.frag'],
    'incompatible-contributions' => [
      'scroll_edge.frag',
      'scroll_edge_contribution.frag',
    ],
    _ => throw ArgumentError.value(fixture, 'fixture'),
  };
  // Flutter's InkSparkle is a valid compiled shader with no image samplers.
  final incompatible = File('$bundle/shaders/ink_sparkle.frag');
  for (final name in assets) {
    final asset = File('$packageShaders/$name');
    final original = asset.readAsBytesSync();
    addTearDown(() => asset.writeAsBytesSync(original));
    if (fixture == 'missing') {
      asset.deleteSync();
    } else {
      incompatible.copySync(asset.path);
    }
  }
}

Widget _scene(
  Key boundaryKey,
  Key effectKey, {
  double opacity = 1,
  bool isolated = false,
  double extent = 20,
  double scale = 1,
}) {
  final content = Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: Colors.blue),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 40,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: CountryPickerScrollEdgeEffect(
              key: effectKey,
              color: Colors.white,
              extent: extent,
            ),
          ),
        ),
      ),
    ],
  );
  return Theme(
    data: ThemeData.light(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: boundaryKey,
        child: isolated
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRSuperellipse(
                  borderRadius: BorderRadius.circular(5),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: content,
                ),
              )
            : content,
      ),
    ),
  );
}

Future<void> _expectFade(
  WidgetTester tester,
  RenderRepaintBoundary boundary,
) async {
  final pixels = await tester.runAsync(
    () => _sampleFrame(boundary, tester.view.devicePixelRatio),
  );
  expect(tester.takeException(), isNull);
  if (pixels case (int header, int content)) {
    expect(header, greaterThan(content + 40));
    expect(content, closeTo((Colors.blue.r * 255).round(), 2));
  } else {
    fail('Could not read the rendered scroll edge.');
  }
}

Future<(int, int)> _sampleFrame(
  RenderRepaintBoundary boundary,
  double pixelRatio,
) async {
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final bytes = await image.toByteData();
    if (bytes == null) fail('The captured frame has no pixels.');

    int redAtRow(int y) =>
        bytes.getUint8(4 * (image.width * y + image.width ~/ 2));

    // Sample just below the isolated sheet's top and far below the header.
    return (redAtRow(27), redAtRow(image.height - 4));
  } finally {
    image.dispose();
  }
}
