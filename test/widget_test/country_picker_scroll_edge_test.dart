/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 11 November 2026
 */

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_scroll_edge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Run the shader variant from example to bundle shaders as package assets.
  const shaderFilters = bool.fromEnvironment('PICKER_TEST_SCROLL_EDGE');
  testWidgets(
    'renders the header fade through opacity, transforms and isolated clips',
    (tester) async {
      expect(ui.ImageFilter.isShaderFilterSupported, shaderFilters);
      tester.view
        ..devicePixelRatio = 3
        ..physicalSize = const Size(360, 540);
      addTearDown(tester.view.reset);
      final boundaryKey = GlobalKey();
      final shade = find.descendant(
        of: find.byType(CountryPickerScrollEdgeEffect),
        matching: find.byWidgetPredicate((widget) => widget is DecoratedBox),
      );

      for (final (opacity, isolated, extent, scale) in [
        (1.0, false, 20.0, 1.0),
        (.85, false, 16.0, 1.0),
        (1.0, false, 20.0, .95),
        (1.0, true, 20.0, 1.0),
      ]) {
        await tester.pumpWidget(
          _scene(
            boundaryKey,
            opacity: opacity,
            isolated: isolated,
            extent: extent,
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();
        expect(shade, shaderFilters ? findsNothing : findsOneWidget);

        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(boundaryKey),
        );
        // The first scene may initialize the shader for translucent layers.
        await tester.runAsync(
          () => _sampleFrame(boundary, tester.view.devicePixelRatio),
        );
        await tester.pumpAndSettle();
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
    },
  );
}

Widget _scene(
  Key boundaryKey, {
  required double opacity,
  required bool isolated,
  required double extent,
  required double scale,
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
