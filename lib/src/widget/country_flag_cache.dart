/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 16 October 2026
 */

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Reuses a GPU image of the actual emoji subtree through Flutter's cache.
@internal
class CountryFlagCache extends SingleChildRenderObjectWidget {
  /// Creates the internal flag cache.
  const CountryFlagCache({required super.child, super.key});

  @override
  RenderProxyBox createRenderObject(BuildContext context) =>
      _RenderCountryFlagCache(MediaQuery.devicePixelRatioOf(context));

  @override
  void updateRenderObject(BuildContext context, RenderProxyBox renderObject) {
    if (renderObject case _RenderCountryFlagCache cache) {
      cache.devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    }
  }
}

/// Paints flags through the bounded image cache when the subtree is cacheable.
class _RenderCountryFlagCache extends RenderProxyBox {
  _RenderCountryFlagCache(this._devicePixelRatio);

  /// The device pixel ratio used for rendering the cached flag image.
  double get devicePixelRatio => _devicePixelRatio;

  /// Sets the device pixel ratio used for rendering the cached flag image.
  set devicePixelRatio(double value) {
    if (_devicePixelRatio == value) return;
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  double _devicePixelRatio;

  static int _fontRevision = 0;
  static void _onFontsChanged() => _fontRevision++;
  static final Listenable _fonts = PaintingBinding.instance.systemFonts
    ..addListener(_onFontsChanged);

  static int _rasterizedThisFrame = 0;
  static Duration? _rasterFrame;
  Object? _paintedKey;

  void _paintTextAndRetry(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) markNeedsPaint();
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final effectiveChild = child;
    if (effectiveChild == null) return;

    // A selectable paragraph can own composited selection layers.
    final cache = PaintingBinding.instance.imageCache;
    final maximumSizeBytes =
        (size.width * devicePixelRatio).ceil() *
        (size.height * devicePixelRatio).ceil() *
        4;
    if (effectiveChild.needsCompositing ||
        cache.maximumSize == 0 ||
        cache.maximumSizeBytes < maximumSizeBytes) {
      super.paint(context, offset);
      return;
    }

    // Custom wrappers may not contain text; retain their normal renderer.
    RenderParagraph? findParagraph(RenderObject object) {
      if (object case RenderParagraph paragraph) return paragraph;
      RenderParagraph? paragraph;
      object.visitChildren((child) => paragraph ??= findParagraph(child));
      return paragraph;
    }

    final text = findParagraph(effectiveChild);
    if (text == null) {
      super.paint(context, offset);
      return;
    }
    final key = (
      CountryFlagCache,
      _fonts,
      _fontRevision,
      text.text,
      text.textAlign,
      text.textDirection,
      text.textScaler,
      text.locale,
      text.maxLines,
      text.softWrap,
      text.overflow,
      text.strutStyle,
      text.textWidthBasis,
      text.textHeightBehavior,
      text.size,
      size,
      devicePixelRatio,
    );
    if (!cache.containsKey(key)) {
      // Let the first frame draw its glyphs before making GPU snapshots.
      // Bound snapshot work so a cold viewport does not allocate every image
      // in the same frame. These retries remain part of normal frame timing.
      final firstPaint = _paintedKey != key;
      _paintedKey = key;
      final frame = WidgetsBinding.instance.currentFrameTimeStamp;
      if (_rasterFrame != frame) {
        _rasterizedThisFrame = 0;
        _rasterFrame = frame;
      }
      if (firstPaint || _rasterizedThisFrame >= 2) {
        _paintTextAndRetry(context, offset);
        return;
      }
      _rasterizedThisFrame++;
    }
    final recorder = ui.PictureRecorder();
    final recordingLayer = OffsetLayer();
    final layer = LayerHandle<OffsetLayer>(recordingLayer);
    final canvas = Canvas(recorder)..scale(devicePixelRatio);
    try {
      // Paint on cache hits too: this clears the child's dirty-paint flags so
      // later font/style changes can propagate to the parent normally.
      _FlagCanvasContext(
        recordingLayer,
        Offset.zero & size,
        canvas,
      ).paintChild(effectiveChild, Offset.zero);
    } finally {
      layer.layer = null;
    }
    final picture = recorder.endRecording();
    ImageStreamCompleterHandle? handle;
    ImageInfo? image;
    try {
      final completer = cache.putIfAbsent(key, () {
        final result = OneFrameImageStreamCompleter(
          SynchronousFuture(
            ImageInfo(
              image: picture.toImageSync(
                (size.width * devicePixelRatio).ceil(),
                (size.height * devicePixelRatio).ceil(),
              ),
              scale: devicePixelRatio,
            ),
          ),
        );
        handle = result.keepAlive();
        return result;
      });
      // addListener synchronously supplies the current ImageInfo when ready.
      // Our SynchronousFuture loader is ready during this paint; the short
      // subscription obtains a clone, then releases the stream listener.
      // A pending custom completer leaves image null and uses normal painting.
      final listener = ImageStreamListener(
        (value, synchronousCall) => image = value,
      );
      completer?.addListener(listener);
      completer?.removeListener(listener);
      if (image case ImageInfo info) {
        context.canvas.drawImageRect(
          info.image,
          Rect.fromLTWH(
            0,
            0,
            size.width * devicePixelRatio,
            size.height * devicePixelRatio,
          ),
          offset & size,
          Paint()..filterQuality = .low,
        );
      } else {
        // The default cache resolves this private synchronous loader at once.
        // Preserve the text if a custom ImageCache declines or defers it.
        super.paint(context, offset); // coverage:ignore-line
      }
    } finally {
      image?.dispose();
      handle?.dispose();
      picture.dispose();
    }
  }
}

/// Records a non-composited subtree without adding it to the on-screen scene.
class _FlagCanvasContext extends PaintingContext {
  _FlagCanvasContext(super.containerLayer, super.estimatedBounds, this.canvas);

  @override
  final Canvas canvas;
}
