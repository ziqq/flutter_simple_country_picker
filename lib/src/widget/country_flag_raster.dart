part of 'country_list_view.dart';

/// Reuses a GPU image of the actual emoji subtree through Flutter's cache.
class _FlagRasterCache extends SingleChildRenderObjectWidget {
  const _FlagRasterCache({required super.child});

  @override
  _RenderFlagRasterCache createRenderObject(BuildContext context) =>
      _RenderFlagRasterCache(MediaQuery.devicePixelRatioOf(context));

  @override
  void updateRenderObject(BuildContext context, _RenderFlagRasterCache object) {
    object.devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
  }
}

class _RenderFlagRasterCache extends RenderProxyBox {
  _RenderFlagRasterCache(this._devicePixelRatio);

  double _devicePixelRatio;
  double get devicePixelRatio => _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (_devicePixelRatio == value) return;
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  static int _fontRevision = 0;
  static void _fontsChanged() => _fontRevision++;
  static final Listenable _fonts = PaintingBinding.instance.systemFonts
    ..addListener(_fontsChanged);
  static Duration? _rasterFrame;
  static int _rasterizedThisFrame = 0;
  Object? _paintedKey;

  void _paintTextAndRetry(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) markNeedsPaint();
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // A selectable paragraph can own composited selection layers.
    final cache = PaintingBinding.instance.imageCache;
    if (child!.needsCompositing ||
        cache.maximumSize == 0 ||
        cache.maximumSizeBytes <
            (size.width * devicePixelRatio).ceil() *
                (size.height * devicePixelRatio).ceil() *
                4) {
      super.paint(context, offset);
      return;
    }
    RenderParagraph? paragraph;
    void findParagraph(RenderObject object) {
      if (object is RenderParagraph) {
        paragraph = object;
      } else {
        object.visitChildren(findParagraph);
      }
    }

    findParagraph(child!);
    final text = paragraph!;
    final key = (
      _FlagRasterCache,
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
        _rasterFrame = frame;
        _rasterizedThisFrame = 0;
      }
      if (firstPaint || _rasterizedThisFrame >= 2) {
        _paintTextAndRetry(context, offset);
        return;
      }
      _rasterizedThisFrame++;
    }
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(devicePixelRatio);
    final layer = LayerHandle<OffsetLayer>(OffsetLayer());
    try {
      // Paint on cache hits too: this clears the child's dirty-paint flags so
      // later font/style changes can propagate to the parent normally.
      _FlagCanvasContext(
        layer.layer!,
        Offset.zero & size,
        canvas,
      ).paintChild(child!, Offset.zero);
    } finally {
      layer.layer = null;
    }
    final picture = recorder.endRecording();
    ImageInfo? image;
    ImageStreamCompleterHandle? handle;
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
      final listener = ImageStreamListener((value, _) => image = value);
      completer?.addListener(listener);
      completer?.removeListener(listener);
      if (image case final info?) {
        context.canvas.drawImageRect(
          info.image,
          Rect.fromLTWH(
            0,
            0,
            size.width * devicePixelRatio,
            size.height * devicePixelRatio,
          ),
          offset & size,
          Paint()..filterQuality = FilterQuality.low,
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
