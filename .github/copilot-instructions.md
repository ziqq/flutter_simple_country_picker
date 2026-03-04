# AI rules for flutter_simple_country_picker

This is a **Flutter package** (not an app). All code in `lib/` is public API.
Apply general Flutter AI rules plus the overrides below.

**Important**: Before doing anything, always try to clarify everything possible, highlight weak points, corner cases that were not taken into account, and ask a lot of clarifying questions.


## Lint Rules
Include the package in the `analysis_options.yaml` file. Use the following
analysis_options.yaml file as a starting point:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Add additional lint rules here:
    # avoid_print: false
    # prefer_single_quotes: true
```


## Code Generation
* **Build Runner:** If the project uses code generation, ensure that
  `build_runner` is listed as a dev dependency in `pubspec.yaml`.
* **Running Build Runner:** After modifying files that require code generation,
  run the build command:
  ```shell
  dart run build_runner build --delete-conflicting-outputs --release
  ```


## Testing
* **Running Tests:** To run tests, use the `run_tests` tool if it is available,
  otherwise use `flutter test`.
* **Unit Tests:** Use `package:test` for unit tests.
* **Widget Tests:** Use `package:flutter_test` for widget tests.
* **Integration Tests:** Use `package:integration_test` for integration tests.
* **Assertions:** Prefer using `package:checks` for more expressive and readable
  assertions over the default `matchers`.


### Testing Best practices
* **Convention:** Follow the Arrange-Act-Assert (or Given-When-Then) pattern.
* **Unit Tests:** Write unit tests for domain logic, data layer, and state
  management.
* **Widget Tests:** Write widget tests for UI components.
* **Integration Tests:** For broader application validation, use integration
  tests to verify end-to-end user flows.
* **integration_test package:** Use the `integration_test` package from the
  Flutter SDK for integration tests. Add it as a `dev_dependency` in
  `pubspec.yaml` by specifying `sdk: flutter`.
* **Mocks:** Prefer fakes or stubs over mocks. If mocks are absolutely
  necessary, use `mockito` or `mocktail` to create mocks for dependencies. While
  code generation is common for state management (e.g., with `freezed`), try to
  avoid it for mocks.
* **Coverage:** Aim for high test coverage.


## Documentation
* **`dartdoc`:** Write `dartdoc`-style comments for all public APIs.

### Documentation Philosophy
* **Comment wisely:** Use comments to explain why the code is written a certain
  way, not what the code does. The code itself should be self-explanatory.
* **Document for the user:** Write documentation with the reader in mind. If you
  had a question and found the answer, add it to the documentation where you
  first looked. This ensures the documentation answers real-world questions.
* **No useless documentation:** If the documentation only restates the obvious
  from the code's name, it's not helpful. Good documentation provides context
  and explains what isn't immediately apparent.
* **Consistency is key:** Use consistent terminology throughout your
  documentation.

### Commenting Style
* **Use `///` for doc comments:** This allows documentation generation tools to
  pick them up.
* **Start with a single-sentence summary:** The first sentence should be a
  concise, user-centric summary ending with a period.
* **Separate the summary:** Add a blank line after the first sentence to create
  a separate paragraph. This helps tools create better summaries.
* **Avoid redundancy:** Don't repeat information that's obvious from the code's
  context, like the class name or signature.
* **Don't document both getter and setter:** For properties with both, only
  document one. The documentation tool will treat them as a single field.
* **Important**: Don't delete comments, but feel free to add more if you think it would help the reader understand the code better. The goal is to make the code as clear and self-explanatory as possible, so that even someone new to Flutter could understand it.

### Writing Style
* **Be brief:** Write concisely.
* **Avoid jargon and acronyms:** Don't use abbreviations unless they are widely
  understood.
* **Use Markdown sparingly:** Avoid excessive markdown and never use HTML for
  formatting.
* **Use backticks for code:** Enclose code blocks in backtick fences, and
  specify the language.

### What to Document
* **Public APIs are a priority:** Always document public APIs.
* **Consider private APIs:** It's a good idea to document private APIs as well.
* **Library-level comments are helpful:** Consider adding a doc comment at the
  library level to provide a general overview.
* **Include code samples:** Where appropriate, add code samples to illustrate usage.
* **Explain parameters, return values, and exceptions:** Use prose to describe
  what a function expects, what it returns, and what errors it might throw.
* **Place doc comments before annotations:** Documentation should come before
  any metadata annotations.

## Accessibility (A11Y)
Implement accessibility features to empower all users, assuming a wide variety
of users with different physical abilities, mental abilities, age groups,
education levels, and learning styles.

* **Color Contrast:** Ensure text has a contrast ratio of at least **4.5:1**
  against its background.
* **Dynamic Text Scaling:** Test your UI to ensure it remains usable when users
  increase the system font size.
* **Semantic Labels:** Use the `Semantics` widget to provide clear, descriptive
  labels for UI elements.
* **Screen Reader Testing:** Regularly test your app with TalkBack (Android) and
  VoiceOver (iOS).


## High-Performance Canvas Rendering
Apply these rules when writing `CustomPainter`, custom `RenderObject`, or any code that draws directly on `Canvas`.

### Choosing the Rendering Strategy
| Approach                                        | When to Use                                           |
|-------------------------------------------------|-------------------------------------------------------|
| `CustomPaint` + `CustomPainter`                 | Simple-to-moderate complexity, few repaints           |
| `LeafRenderObjectWidget` + custom `RenderBox`   | Complex scenes, precise lifecycle control, game loops |
| `repaint` package (`RePaint` / `RePainterBase`) | Optimised fine-grained repaint logic                  |

* For most calendar / event painting tasks, `CustomPainter` with a `repaint` listenable is sufficient.
* Promote to `LeafRenderObjectWidget` when you need vsync tickers, pointer-event forwarding, or per-frame updates.

### Repaint Strategy
* **Never** wrap `CustomPaint` inside `AnimatedBuilder`, `BlocBuilder`, `ValueListenableBuilder`, or any builder solely to trigger repaints.
* **Never** call `setState()` to repaint a painter — this causes a full widget rebuild.
* **Always** pass a `Listenable` (e.g. `ChangeNotifier`, `ValueNotifier`, `AnimationController`) via the `repaint` parameter of `CustomPainter`:
  ```dart
  CustomPaint(
    painter: MyPainter(repaint: myNotifier),
  );
  ```
* For custom `RenderObject`s, call `markNeedsPaint()` directly after state mutations instead of triggering widget rebuilds.
* Use `RepaintBoundary` (or `isRepaintBoundary => true` in `RenderBox`) to isolate frequently-updated canvases from the surrounding widget tree. Measure before committing — it trades memory for fewer repaints.

### Clipping
* **Always** `canvas.save()` before clipping and `canvas.restore()` after. Never leave unbalanced save/restore pairs.
* Clip the full content area to prevent overflow:
  ```dart
  canvas
    ..save()
    ..clipRRect(rrect); // or clipRect / clipPath
  // … all drawing …
  canvas.restore();
  ```
* Prefer `clipRect` over `clipRRect` / `clipPath` when corners are not rounded — it is cheaper on the GPU.

### Paint Object Management
* **Reuse** `Paint` objects. Create them as fields or `static final` constants instead of allocating inside `paint()` on every frame.
* Configure `isAntiAlias`, `filterQuality`, and `style` once — only mutate `color` / `shader` per draw call.
* For pixel-art or grid-aligned rendering, disable anti-aliasing:
  ```dart
  final gridPaint = Paint()
    ..isAntiAlias = false
    ..filterQuality = FilterQuality.none
    ..style = PaintingStyle.fill;
  ```

### Avoid Drawing Loops
* **Do not** call `drawRect`, `drawCircle`, `drawImageRect`, etc. in a loop for large numbers of primitives.
* **Batch** operations instead:
  | Method                 | Use Case                                |
  |------------------------|-----------------------------------------|
  | `canvas.drawRawAtlas`  | Multiple sprites from one texture atlas |
  | `canvas.drawRawPoints` | Large point / particle sets             |
  | `canvas.drawVertices`  | Mesh-based rendering                    |
* When batching is not applicable (e.g. heterogeneous shapes), minimise loop iterations and keep the body lightweight.

### Picture Caching
* Cache static or infrequently-changing content with `PictureRecorder`:
  ```dart
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, rect);
  // … expensive drawing …
  final picture = recorder.endRecording();
  ```
* Reuse the recorded `Picture` via `canvas.drawPicture(picture)` until the content is invalidated.
* For fully static assets, convert to a raster image with `picture.toImage(w, h)` and draw via `canvas.drawImageRect`.
* **Invalidate** cached pictures/images only on actual data changes (size, zoom, content). Use a dirty flag (`_needsRepicture`) and guard regeneration.

### Composable Painters
For complex scenes, split rendering into focused painter classes:
```dart
abstract class ScenePainter {
  bool get needsPaint;
  void update(ui.Size size, double delta);
  void paint(ui.Size size, Canvas canvas);
}
```
* Each painter owns its own `_needsRelayout` / `_needsPaint` flags.
* The orchestrator checks `painters.any((p) => p.needsPaint)` — only then calls `markNeedsPaint()`.
* Paint in explicit layer order (background → content → overlays → debug).

### Coordinate Snapping
* Snap coordinates to physical pixels to avoid sub-pixel blur:
  ```dart
  double snapPx(double v, double dpr) => (v * dpr).roundToDouble() / dpr;
  ```
* Obtain DPR via `MediaQuery.devicePixelRatioOf(context)` once and pass it to the painter.

### Spatial Queries (QuadTree)
* For scenes with > ~100 interactive objects, use a `QuadTree` for hit-testing, collision detection, and viewport culling.
* Inflate the viewport rect slightly (`camera.bound.inflate(32)`) when querying to prevent pop-in artefacts.
* **Cheap-first** collision: check bounding-box overlap before detailed path intersection.

### Camera / Viewport Pattern
* Use a `Camera` class (`ChangeNotifier`) exposing `globalToLocal` / `localToGlobal` transforms.
* On every paint call: `camera.changeSize(size)`, then transform all global coords to local before drawing.
* Mark `@pragma('vm:prefer-inline')` on hot conversion methods.

### `shouldRepaint` / `shouldRebuildSemantics`
* Implement `shouldRepaint` conservatively: compare **only** fields that affect visual output.
* Use `identical` for reference-equal checks on lists / images; use `==` for primitives.
* If the painter uses `repaint` listenable, `shouldRepaint` can safely return `false` for most cases.

### TextPainter in Canvas
* Create `TextPainter`, call `layout(maxWidth:)`, then `paint(canvas, offset)`.
* **Do not** call `layout()` more than once per frame with the same constraints.
* Guard rendering with a bounds check before painting:
  ```dart
  if (y + tp.height <= contentRect.bottom) {
    tp.paint(canvas, Offset(x, y));
  }
  ```

### Image Rendering on Canvas
* Prefer `canvas.drawImageRect(image, src, dst, paint)` over `canvas.drawImage` — it handles scaling and is more explicit.
* When drawing circular avatars, `clipPath` + `drawImageRect` inside a `save/restore` block.
* Set `filterQuality: FilterQuality.medium` for scaled photos; use `FilterQuality.none` for pixel-art / unscaled textures.

### Debugging Canvas
* Build a toggleable debug overlay (activated via hotkey or flag) showing:
  - FPS / paint count
  - Camera viewport bounds
  - QuadTree node visualisation
  - Grid overlay for alignment
* Use `PaintingContext.addLayer(PerformanceOverlayLayer(...))` for built-in Flutter perf metrics.
* Guard all debug drawing behind `kDebugMode` or a runtime flag so it is stripped from release builds.

### General Rules
* **No `dynamic`** in painter code — all types explicit.
* **No `print()`** — use `dev.log()` behind `kDebugMode` guard.
* **No async work** inside `paint()` — all data must be pre-resolved and passed in.
* Keep `paint()` body under ~80 lines. Extract helpers (`_paintHeader`, `_paintAvatars`, `_paintGrid`, etc.).
* Measure with `flutter run --profile` and DevTools timeline before and after optimisations.

### SVG → Flutter LeafRenderObject Icons
Icons from SVG are implemented uniformly for predictability, simple diffs, and absence of hidden optimizations.

* **Widget Structure:** One public widget: LeafRenderObjectWidget + PreferredSizeWidget (parameters: size, Color? color, double opacity).
* **RenderObject State:** Stores only _targetSize, _scale, _color, _opacity. Update via setters with `markNeedsLayout` / `markNeedsPaint` when needed.
* **Layout:** computeDryLayout -> `constraints.constrain(_targetSize)`; in performLayout compute `_scale = min(size.width/24, size.height/24)`.
* **Painting Sequence:** Center (translate to middle), then scale, then build picture inside `paint` via `ui.PictureRecorder`; immediately obtain `picture` and `canvas.drawPicture(picture)`.
* **Path Definitions:** All paths static: `static final Path path_0`, `path_1`, ... no intermediate local paths.
* **Picture Naming:** Picture builder function by icon name: `UIIcon$Example -> _$examplePicture(Canvas canvas, Color color, double opacity)`.
* **Multiple Layers:** If multiple layers/opacities — draw sequentially inside the build function.
* **Parameters Only:** ONLY size, color, opacity supported. No alignment/fit/contentScale.
* **No Caching:** Do not cache picture / dynamic path calculations; static paths allowed, picture recreated every paint.
* **Prohibited:** imports inside snippet, comments, fixed viewBox, extra state fields, external optimizations.

### LeafRenderObject Icon Template
```dart
import 'dart:math' as math;
import 'dart:ui' as ui hide Size;

import 'package:flutter/material.dart';
import 'package:ui/src/theme/theme.dart';

/// {@template icon_example}
/// Example icon widget.
/// {@endtemplate}
class UIIcon$Example extends LeafRenderObjectWidget implements PreferredSizeWidget {
  /// {@macro icon_example}
  const UIIcon$Example({this.color, this.size = 24, this.opacity = 1.0, super.key});

  /// The size of the icon.
  final double size;

  /// The opacity of the icon.
  final double opacity;

  /// The color of the icon.
  final Color? color;

  @override
  Size get preferredSize => Size.square(size);

  @override
  RenderObject createRenderObject(BuildContext context) => _UIIcon$Example$RenderObject()
    .._isDark = Theme.of(context).brightness == Brightness.dark
    .._targetSize = Size.square(size)
    .._opacity = opacity;

  @override
  void updateRenderObject(BuildContext context, covariant _UIIcon$Example$RenderObject renderObject) {
    final newSize = Size.square(size);
    if (renderObject case _UIIcon$Example$RenderObject object when object._targetSize != newSize) {
      object
        .._targetSize = newSize
        ..markNeedsLayout();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (renderObject case _UIIcon$Example$RenderObject object when object._isDark != isDark) {
      object
        .._isDark = isDark
        ..markNeedsPaint();
    }
    if (renderObject case _UIIcon$Example$RenderObject object when object.color != color) {
      object
        .._color = color
        ..markNeedsPaint();
    }
    if (renderObject case _UIIcon$Example$RenderObject object when object._opacity != opacity) {
      object
        .._opacity = opacity
        ..markNeedsPaint();
    }
  }
}

class _UIIcon$Example$RenderObject extends RenderBox {
  Size _targetSize = Size.zero;
  Color _color = kAccentColor;
  double _opacity = 1.0;
  bool _isDark = false;
  double _scale = .0;

  @override
  bool get alwaysNeedsCompositing => false;

  @override
  bool get isRepaintBoundary => false;

  @override
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(_targetSize);

  @override
  void performLayout() {
    final size = super.size = computeDryLayout(constraints);
    _scale = math.min(size.width / 24.0, size.height / 24.0);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_scale < .01) return;
    final canvas = context.canvas..save();
    final sideScaled = 24.0 * _scale;
    canvas
      ..translate(offset.dx + (size.width - sideScaled) / 2, offset.dy + (size.height - sideScaled) / 2)
      ..scale(_scale, _scale);
    final pic = _$examplePicture(_opacity);
    canvas
      ..drawPicture(pic)
      ..restore();
    pic.dispose();
  }

  static ui.Picture _$examplePicture(Color color, double opacity) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    canvas
      ..drawPath(path_1, paint..color = color.withValues(alpha: 1 * opacity))
      ..drawPath(path_0, paint..color = color.withValues(alpha: 0.5 * opacity));
    return recorder.endRecording();
  }

  static final Path path_1 = Path()
    ..moveTo(20.25, 7.35156)
    ..lineTo(17.5, 7.35156)
    ..cubicTo(17.5, 5.89287, 16.9205, 4.49393, 15.8891, 3.46248)
    ..cubicTo(14.8576, 2.43103, 13.4587, 1.85156, 12, 1.85156)
    ..cubicTo(10.5413, 1.85156, 9.14236, 2.43103, 8.11091, 3.46248)
    ..cubicTo(7.07946, 4.49393, 6.5, 5.89287, 6.5, 7.35156)
    ..lineTo(3.75, 7.35156)
    ..cubicTo(3.02065, 7.35156, 2.32118, 7.64129, 1.80546, 8.15702)
    ..cubicTo(1.28973, 8.67274, 1, 9.37222, 1, 10.1016)
    ..lineTo(1, 19.2682)
    ..cubicTo(1.00146, 20.4834, 1.48481, 21.6483, 2.34403, 22.5075)
    ..cubicTo(3.20326, 23.3668, 4.3682, 23.8501, 5.58333, 23.8516)
    ..lineTo(16.2955, 23.8516)
    ..cubicTo(15.6582, 23.4373, 15.1137, 22.8955, 14.6964, 22.2603)
    ..cubicTo(14.279, 21.6251, 13.9979, 20.9103, 13.8706, 20.1609)
    ..cubicTo(13.7434, 19.4116, 13.7728, 18.644, 13.9571, 17.9066)
    ..cubicTo(14.1414, 17.1693, 14.4765, 16.4781, 14.9413, 15.8767)
    ..cubicTo(15.4061, 15.2753, 15.9905, 14.7768, 16.6576, 14.4126)
    ..cubicTo(17.3247, 14.0485, 18.0601, 13.8265, 18.8173, 13.7608)
    ..cubicTo(19.5745, 13.695, 20.3372, 13.787, 21.0571, 14.0307)
    ..cubicTo(21.777, 14.2745, 22.4385, 14.6649, 23, 15.1771)
    ..lineTo(23, 10.1016)
    ..cubicTo(23, 9.37222, 22.7103, 8.67274, 22.1945, 8.15702)
    ..cubicTo(21.6788, 7.64129, 20.9793, 7.35156, 20.25, 7.35156)
    ..close()
    ..moveTo(8.33333, 7.35156)
    ..cubicTo(8.33333, 6.3791, 8.71964, 5.44647, 9.40728, 4.75884)
    ..cubicTo(10.0949, 4.0712, 11.0275, 3.6849, 12, 3.6849)
    ..cubicTo(12.9725, 3.6849, 13.9051, 4.0712, 14.5927, 4.75884)
    ..cubicTo(15.2804, 5.44647, 15.6667, 6.3791, 15.6667, 7.35156)
    ..lineTo(8.33333, 7.35156)
    ..close();

  static final Path path_0 = Path()
    ..moveTo(22.0827, 18.3516)
    ..lineTo(20.2493, 18.3516)
    ..lineTo(20.2493, 16.5182)
    ..cubicTo(20.2493, 16.2751, 20.1528, 16.042, 19.9809, 15.87)
    ..cubicTo(19.8089, 15.6981, 19.5758, 15.6016, 19.3327, 15.6016)
    ..cubicTo(19.0896, 15.6016, 18.8564, 15.6981, 18.6845, 15.87)
    ..cubicTo(18.5126, 16.042, 18.416, 16.2751, 18.416, 16.5182)
    ..lineTo(18.416, 18.3516)
    ..lineTo(16.5827, 18.3516)
    ..cubicTo(16.3396, 18.3516, 16.1064, 18.4481, 15.9345, 18.62)
    ..cubicTo(15.7626, 18.7919, 15.666, 19.0251, 15.666, 19.2682)
    ..cubicTo(15.666, 19.5113, 15.7626, 19.7445, 15.9345, 19.9164)
    ..cubicTo(16.1064, 20.0883, 16.3396, 20.1849, 16.5827, 20.1849)
    ..lineTo(18.416, 20.1849)
    ..lineTo(18.416, 22.0182)
    ..cubicTo(18.416, 22.2613, 18.5126, 22.4945, 18.6845, 22.6664)
    ..cubicTo(18.8564, 22.8383, 19.0896, 22.9349, 19.3327, 22.9349)
    ..cubicTo(19.5758, 22.9349, 19.8089, 22.8383, 19.9809, 22.6664)
    ..cubicTo(20.1528, 22.4945, 20.2493, 22.2613, 20.2493, 22.0182)
    ..lineTo(20.2493, 20.1849)
    ..lineTo(22.0827, 20.1849)
    ..cubicTo(22.3258, 20.1849, 22.5589, 20.0883, 22.7309, 19.9164)
    ..cubicTo(22.9028, 19.7445, 22.9993, 19.5113, 22.9993, 19.2682)
    ..cubicTo(22.9993, 19.0251, 22.9028, 18.7919, 22.7309, 18.62)
    ..cubicTo(22.5589, 18.4481, 22.3258, 18.3516, 22.0827, 18.3516)
    ..close();
}
```

