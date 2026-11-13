/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 11 October 2026
 */

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, internal, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show
        BackdropFilterLayer,
        BackdropKey,
        ClipRectLayer,
        ContainerLayer,
        OffsetLayer,
        OpacityLayer,
        TransformLayer,
        ImageFilterConfig,
        ImageFilterContext,
        PaintingContext,
        LayerHandle,
        PictureLayer,
        RenderDecoratedBox,
        PipelineOwner,
        RenderBackdropFilter,
        RenderClipRSuperellipse;

// At DPR 3 this retains the backdrop filter while Impeller returns its input snapshot without Gaussian passes.
const double _scrollEdgeIdentitySigma = .0003;

/// {@template country_picker_scroll_edge_effect}
/// Content scrolling under a header blurs and fades into [color].
/// Blur decreases towards the bottom edge, where the content becomes sharp again.
///
/// Fill the header with it, for example as [SliverAppBar.flexibleSpace] with `clipBehavior: Clip.none`,
/// so content is obscured under the header, including at rest. Its intensity does not depend on a scroll controller.
///
/// The filter blends progressively narrower kernels towards the trailing edge.
/// Without blur, only the shade is needed.
/// The shade eases towards full transparency before the trailing clip, avoiding a visible toolbar boundary.
/// Renderers without shader filters keep the continuous shade as a fallback.
/// Scrolling updates the backdrop without rebuilding the effect.
/// {@endtemplate}
@internal
class CountryPickerScrollEdgeEffect extends StatefulWidget {
  /// {@macro country_picker_scroll_edge_effect}
  const CountryPickerScrollEdgeEffect({
    required this.color,
    required this.extent,
    super.key,
  });

  /// Background shade resolved by the picker theme.
  final Color color;

  /// Fade distance below the compact navigation bar.
  final double extent;

  /// The asset path of the scroll edge shader.
  static const String _shaderAsset =
      'packages/flutter_simple_country_picker/assets/shaders/scroll_edge.frag';
  static const String _contributionShaderAsset =
      'packages/flutter_simple_country_picker/assets/shaders/scroll_edge_contribution.frag';
  static const String _separatedShaderAsset =
      'packages/flutter_simple_country_picker/assets/shaders/scroll_edge_separated.frag';
  static const String _windowsShaderAsset =
      'packages/flutter_simple_country_picker/assets/shaders/scroll_edge_windows.frag';
  static const String _windowsSeparatedShaderAsset =
      'packages/flutter_simple_country_picker/assets/shaders/scroll_edge_windows_separated.frag';

  @override
  State<CountryPickerScrollEdgeEffect> createState() =>
      _CountryPickerScrollEdgeEffectState();
}

/// State for widget [CountryPickerScrollEdgeEffect].
class _CountryPickerScrollEdgeEffectState
    extends State<CountryPickerScrollEdgeEffect> {
  final _ScrollEdgeShaders _shaders = _ScrollEdgeShaders();

  @override
  void initState() {
    super.initState();
    if (ui.ImageFilter.isShaderFilterSupported) _shaders.initialize();
  }

  @override
  void didUpdateWidget(CountryPickerScrollEdgeEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (ui.ImageFilter.isShaderFilterSupported) _shaders.initialize();
  }

  @override
  void dispose() {
    _shaders.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color;
    final extent = widget.extent;
    final isLight = theme.brightness == Brightness.light;
    return IgnorePointer(
      child: Stack(
        clipBehavior: .none,
        fit: .expand,
        children: <Widget>[
          if (ui.ImageFilter.isShaderFilterSupported) ...<Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: -extent * 1.5,
              child: ClipRect(
                child: _ScrollEdgeBackdropFilter(
                  shaders: _shaders,
                  component: 5,
                  filterConfig: _ScrollEdgeFilter(
                    _shaders,
                    context,
                    MediaQuery.devicePixelRatioOf(context),
                    extent,
                    color,
                    null,
                    5,
                    isLight: isLight,
                    view: View.maybeOf(context),
                  ),
                  child: Stack(
                    fit: .expand,
                    children: <Widget>[
                      for (var component = 0; component < 5; component++)
                        _ScrollEdgeBackdropFilter(
                          shaders: _shaders,
                          component: component,
                          filterConfig: _ScrollEdgeFilter(
                            _shaders,
                            context,
                            MediaQuery.devicePixelRatioOf(context),
                            extent,
                            color,
                            null,
                            component,
                            isLight: isLight,
                            view: View.maybeOf(context),
                          ),
                          child: const SizedBox.expand(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: -extent * 1.5,
            child: ListenableBuilder(
              listenable: _shaders,
              builder: (context, child) {
                if (ui.ImageFilter.isShaderFilterSupported &&
                    _shaders.isReady) {
                  return const SizedBox.shrink();
                }
                return child ?? const SizedBox.shrink();
              },
              child: _ScrollEdgeShade(
                color: color,
                extent: extent,
                isLight: isLight,
                blurOpacity: null,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: .topCenter,
                    end: .bottomCenter,
                    stops: const <double>[
                      0,
                      .35,
                      .5,
                      .55,
                      .6,
                      .65,
                      .7,
                      .75,
                      .8,
                      .85,
                      .9,
                      .95,
                      1,
                    ],
                    colors: <Color>[
                      for (final opacity in const <double>[
                        1,
                        1,
                        .975,
                        .947,
                        .891,
                        .765,
                        .61,
                        .45,
                        .285,
                        .16,
                        .076,
                        .027,
                        0,
                      ])
                        color.withValues(alpha: opacity * .85),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uses the same adaptive shade while shader filters are loading or unavailable.
class _ScrollEdgeShade extends DecoratedBox {
  const _ScrollEdgeShade({
    required this.color,
    required this.extent,
    required this.isLight,
    required this.blurOpacity,
    required super.decoration,
  });

  final Color color;
  final double extent;
  final bool isLight;
  final ValueGetter<double>? blurOpacity;

  @override
  RenderDecoratedBox createRenderObject(BuildContext context) =>
      _RenderScrollEdgeShade(this);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderScrollEdgeShade renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject.shadeConfiguration = this;
  }
}

/// Retains the fallback shade while its geometry and configuration are stable.
class _RenderScrollEdgeShade extends RenderDecoratedBox {
  _RenderScrollEdgeShade(this._configuration)
    : super(decoration: _configuration.decoration);

  final LayerHandle<_ScrollEdgeShadeLayer> _shadeLayer =
      LayerHandle<_ScrollEdgeShadeLayer>();
  _ScrollEdgeShade _configuration;

  _ScrollEdgeShade get shadeConfiguration => _configuration;

  set shadeConfiguration(_ScrollEdgeShade value) {
    if (identical(value, _configuration)) return;
    _configuration = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    var shade = _shadeLayer.layer;
    if (shade == null || shade.canvasBounds.size != size) {
      shade = _ScrollEdgeShadeLayer(Offset.zero & size);
      _shadeLayer.layer = shade;
    }
    shade
      ..renderObject = this
      ..paintOffset = offset;
    context.addLayer(shade);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _shadeLayer.layer?.renderObject = this;
  }

  @override
  void detach() {
    _shadeLayer.layer?.renderObject = null;
    super.detach();
  }

  @override
  void dispose() {
    _shadeLayer.layer?.renderObject = null;
    _shadeLayer.layer = null;
    super.dispose();
  }
}

/// Retained SDK opacity layers can change without repainting the header.
class _ScrollEdgeShadeLayer extends PictureLayer {
  _ScrollEdgeShadeLayer(super.canvasBounds);

  _RenderScrollEdgeShade? renderObject;
  Offset paintOffset = Offset.zero;
  (Size, Offset, _ScrollEdgeShade, double)? _snapshot;

  @override
  bool get alwaysNeedsAddToScene => renderObject?.attached ?? false;

  @override
  void markNeedsAddToScene() {
    if (!alwaysNeedsAddToScene) super.markNeedsAddToScene();
  }

  @override
  void addToScene(ui.SceneBuilder builder) {
    if (renderObject case _RenderScrollEdgeShade target when target.attached) {
      final configuration = target.shadeConfiguration;
      final visibility = configuration.blurOpacity?.call() ?? 1;
      final opacity = visibility.isFinite ? visibility.clamp(0.0, 1.0) : 0.0;
      final snapshot = (target.size, paintOffset, configuration, opacity);
      if (_snapshot != snapshot) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final extent = configuration.extent;
        final top = (target.size.height - extent * 5.5) * opacity;
        final bottom = target.size.height;
        final baseBottom = bottom - extent * .5;
        final gradient = switch (configuration.decoration) {
          BoxDecoration(gradient: LinearGradient gradient) => gradient,
          // The shade's only constructor call supplies this gradient type.
          // coverage:ignore-start
          _ => throw StateError(
            'The scroll edge shade requires a linear gradient.',
          ),
          // coverage:ignore-end
        };
        final glass = <double>[
          1,
          .988235294,
          .894117647,
          .792156862,
          .690196078,
          .588235294,
          .464705882,
          .341176471,
          .217647059,
          .1488235295,
          .08,
          if (extent > 0) ...const <double>[
            .039655,
            .016232,
          ] else ...const <double>[.0382, 0],
        ];
        const maxAlpha = .85;
        final profile = <double>[
          for (var index = 0; index < glass.length; index++)
            glass[index] * (1 - opacity) +
                gradient.colors[index].a / .85 * opacity,
          for (final value in const <double>[.010933, .007116, .002349, 0])
            value * (1 - opacity),
        ];
        final rawSpan = bottom - top;
        final span = rawSpan > 0 ? rawSpan : 1.0;
        final stops = <double>[
          for (final stop in gradient.stops ?? const <double>[])
            (baseBottom - top) / span * stop,
          for (final fraction in const <double>[.25, .5, .75, 1])
            (baseBottom - top + extent * .5 * fraction) / span,
        ];
        final start = paintOffset + Offset(0, top);
        final end = paintOffset + Offset(0, bottom);
        canvas.drawRect(
          paintOffset & target.size,
          Paint()
            ..shader = ui.Gradient.linear(
              start,
              bottom > top ? end : start + const Offset(0, 1),
              <Color>[
                for (final value in profile)
                  configuration.color.withValues(alpha: maxAlpha * value),
              ],
              stops,
            ),
        );
        // The shade's only constructor call passes a null opacity callback,
        // so the fallback visibility is always 1.
        if (configuration.isLight && opacity < 1) {
          // coverage:ignore-start
          canvas.drawRect(
            paintOffset & target.size,
            Paint()
              ..shader = ui.Gradient.linear(
                start,
                bottom > top ? end : start + const Offset(0, 1),
                <Color>[
                  for (final value in profile)
                    Color.from(
                      alpha: .013 * (1 - opacity) * value,
                      red: 0,
                      green: 0,
                      blue: 0,
                    ),
                ],
                stops,
              ),
          );
          // coverage:ignore-end
        }
        picture = recorder.endRecording();
        _snapshot = snapshot;
      }
    }
    super.addToScene(builder);
  }
}

/// Owns shader handles and publishes readiness to the filter's render object.
final class _ScrollEdgeShaders extends ChangeNotifier {
  ui.FragmentShader? horizontal;
  ui.FragmentShader? vertical;
  ui.Image? _sampling;
  final BackdropKey backdropKey = BackdropKey();
  final BackdropKey rawBackdropKey = BackdropKey();
  final BackdropKey gaussianBackdropKey = BackdropKey();
  final List<ui.FragmentShader> contributions = <ui.FragmentShader>[];
  final List<ui.FragmentShader> sdkContributions = <ui.FragmentShader>[];
  bool _disposed = false;
  Future<void>? _$initialization;
  Future<void>? _$genericInitialization;
  bool _genericReady = false;

  double? _kernelSigma;

  /// Pairs adjacent Gaussian samples while preserving their combined weights.
  void configureKernels(double sigma) {
    if (_kernelSigma == sigma) return;
    final shader = vertical;
    if (shader == null) return;
    final counts = <int>[];
    var index = 15;
    for (final width in <double>[sigma * 2 / 5.55, sigma * 4 / 5.55, sigma]) {
      final pairShaders = <ui.FragmentShader>[
        contributions[counts.length * 2 + 1],
        contributions[counts.length * 2 + 2],
      ];
      final weights = <int, double>{};
      for (var tap = -15; tap <= 15; tap++) {
        final offset = tap * .2;
        final position = offset * width;
        final pixel = position.floor();
        final fraction = position - pixel;
        final weight = math.exp(-.5 * offset * offset);
        weights
          ..update(
            pixel,
            (value) => value + weight * (1 - fraction),
            ifAbsent: () => weight * (1 - fraction),
          )
          ..update(
            pixel + 1,
            (value) => value + weight * fraction,
            ifAbsent: () => weight * fraction,
          );
      }
      // Ignore floating-point spill at integer texel boundaries before pairing.
      final pixels =
          weights.entries.where((pixel) => pixel.value > 1e-12).toList()
            ..sort((first, second) => first.key.compareTo(second.key));
      final total = weights.values.fold<double>(
        0,
        (sum, weight) => sum + weight,
      );
      var count = 0;
      for (var pixel = 0; pixel < pixels.length; pixel++) {
        final first = pixels[pixel];
        final firstWeight = first.value;
        var secondWeight = 0.0;
        if (pixel + 1 < pixels.length &&
            pixels[pixel + 1].key == first.key + 1) {
          secondWeight = pixels[++pixel].value;
        }
        final weight = firstWeight + secondWeight;
        final offset = first.key + secondWeight / weight;
        final normalizedWeight = weight / total;
        final pairIndex = index;
        shader
          ..setFloat(index++, offset)
          ..setFloat(index++, normalizedWeight);
        for (final pairShader in pairShaders) {
          pairShader
            ..setFloat(pairIndex, offset)
            ..setFloat(pairIndex + 1, normalizedWeight);
        }
        count++;
      }
      // Each tap covers at most two adjacent pixels. Greedy pairing on each
      // contiguous run uses the fewest samples, so 31 taps suffice to cover it.
      if (count > 31)
        // coverage:ignore-start
        throw StateError(
          'A 31-tap kernel cannot require more than 31 linear samples.',
        );
      // coverage:ignore-end
      for (var padding = count; padding < 31; padding++) {
        final pairIndex = index;
        shader
          ..setFloat(index++, 0)
          ..setFloat(index++, 0);
        for (final pairShader in pairShaders) {
          pairShader
            ..setFloat(pairIndex, 0)
            ..setFloat(pairIndex + 1, 0);
        }
      }
      for (final pairShader in pairShaders)
        pairShader.setFloat(201 + counts.length, count.toDouble());
      counts.add(count);
    }
    for (final count in counts) shader.setFloat(index++, count.toDouble());
    _kernelSigma = sigma;
  }

  /// Whether every shader needed for separable contributions is ready.
  bool get isReady =>
      horizontal != null && vertical != null && contributions.length == 10;

  /// Starts one shared initialization operation for this effect instance.
  void initialize() => unawaited(_$initialization ??= _initialize());

  Future<void> _initialize() async {
    if (!await _separatedShader.ensureLoaded() || _disposed) return;
    if (isReady) return;
    final program = _separatedShader.program;
    if (program == null) return;
    ui.FragmentShader? horizontalShader;
    ui.FragmentShader? verticalShader;
    ui.Image? sampling;
    final loadedContributions = <ui.FragmentShader>[];
    try {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.transparent, BlendMode.src);
      final picture = recorder.endRecording();
      final ui.Image image;
      try {
        image = picture.toImageSync(1, 1);
      } finally {
        picture.dispose();
      }
      sampling = image;
      horizontalShader = program.fragmentShader();
      verticalShader = program.fragmentShader();
      // The engine replaces the first texture with the backdrop, retaining its sampling mode.
      horizontalShader.setImageSampler(
        0,
        image,
        filterQuality: ui.FilterQuality.low,
      );
      verticalShader.setImageSampler(
        0,
        image,
        filterQuality: ui.FilterQuality.low,
      );
      for (var index = 0; index < 10; index++) {
        // The two-dimensional fallback belongs only to the generic pass. A
        // smaller contribution program avoids compiling its nested loops in
        // the OpenGL driver while retaining identical separable arithmetic.
        final shader = program.fragmentShader();
        loadedContributions.add(shader);
        shader.setImageSampler(0, image, filterQuality: ui.FilterQuality.low);
      }
    } on Object catch (error, stackTrace) {
      horizontalShader?.dispose();
      verticalShader?.dispose();
      for (final shader in loadedContributions) shader.dispose();
      sampling?.dispose();
      if (!kReleaseMode) {
        dev.log(
          'Failed to initialize shader: $error',
          error: error,
          stackTrace: stackTrace,
          name: 'CountryPickerScrollEdgeEffect',
        );
      }
      return;
    }
    _sampling = sampling;
    horizontal = horizontalShader;
    vertical = verticalShader;
    contributions.addAll(loadedContributions);
    notifyListeners();
    await _initializeSdkContributions();
  }

  /// Loads the two-dimensional fallback only when a transform or opacity layer
  /// prevents separate contributions. Until then, the same shader paints the
  /// ordinary loading shade without introducing a large unused GPU program.
  void ensureGeneric() =>
      unawaited(_$genericInitialization ??= _initializeGeneric());

  Future<void> _initializeGeneric() async {
    if (!await _scrollEdgeShader.ensureLoaded() || _disposed) return;
    final program = _scrollEdgeShader.program;
    final image = _sampling;
    if (program == null || image == null) return;
    ui.FragmentShader? nextHorizontal;
    ui.FragmentShader? nextVertical;
    try {
      nextHorizontal = program.fragmentShader()
        ..setImageSampler(0, image, filterQuality: ui.FilterQuality.low);
      nextVertical = program.fragmentShader()
        ..setImageSampler(0, image, filterQuality: ui.FilterQuality.low);
    } on Object catch (error, stackTrace) {
      // Both fresh shaders bind the same sampler and image synchronously.
      // Sampler validation fails before the first assignment. No operation
      // follows the second assignment inside the try block.
      // coverage:ignore-start
      nextHorizontal?.dispose();
      nextVertical?.dispose();
      // coverage:ignore-end
      if (!kReleaseMode) {
        dev.log(
          'Failed to initialize fallback shader: $error',
          error: error,
          stackTrace: stackTrace,
          name: 'CountryPickerScrollEdgeEffect',
        );
      }
      return;
    }
    horizontal?.dispose();
    vertical?.dispose();
    horizontal = nextHorizontal;
    vertical = nextVertical;
    _kernelSigma = null;
    _genericReady = true;
    notifyListeners();
  }

  /// Adds native-Gaussian contributions after the separable path is ready.
  Future<void> _initializeSdkContributions() async {
    if (_disposed || !await _contributionShader.ensureLoaded() || _disposed)
      return;
    final program = _contributionShader.program;
    final image = _sampling;
    if (program == null || image == null) return;
    final loadedContributions = <ui.FragmentShader>[];
    try {
      for (var component = 0; component < 3; component++) {
        final shader = program.fragmentShader();
        loadedContributions.add(shader);
        shader.setImageSampler(0, image, filterQuality: ui.FilterQuality.low);
      }
    } on Object catch (error, stackTrace) {
      for (final shader in loadedContributions) shader.dispose();
      if (!kReleaseMode) {
        dev.log(
          'Failed to initialize contribution shader: $error',
          error: error,
          stackTrace: stackTrace,
          name: 'CountryPickerScrollEdgeEffect',
        );
      }
      return;
    }
    sdkContributions.addAll(loadedContributions);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    horizontal?.dispose();
    vertical?.dispose();
    for (final shader in sdkContributions) shader.dispose();
    sdkContributions.clear();
    for (final shader in contributions) shader.dispose();
    contributions.clear();
    _sampling?.dispose();
    _sampling = null;
    horizontal = null;
    vertical = null;
    super.dispose();
  }
}

/// Connects shader readiness and each contribution to its retained backdrop.
class _ScrollEdgeBackdropFilter extends SingleChildRenderObjectWidget {
  const _ScrollEdgeBackdropFilter({
    required this.shaders,
    required this.component,
    required this.filterConfig,
    required super.child,
  });

  final _ScrollEdgeShaders shaders;
  final int component;
  final ImageFilterConfig filterConfig;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderScrollEdgeBackdropFilter(shaders, filterConfig, component);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderScrollEdgeBackdropFilter renderObject,
  ) {
    renderObject
      ..shaders = shaders
      ..backdropKey = component == 5
          ? shaders.rawBackdropKey
          : shaders.backdropKey
      ..blendMode = component == 0 || component == 5
          ? BlendMode.src
          : component == 4
          ? BlendMode.dstOver
          : BlendMode.plus
      ..filterConfig = filterConfig;
  }
}

/// Repaints on shader readiness and preserves contributions between frames.
class _RenderScrollEdgeBackdropFilter extends RenderBackdropFilter {
  _RenderScrollEdgeBackdropFilter(
    this._shaders,
    ImageFilterConfig filterConfig,
    int component,
  ) : super(
        filterConfig: filterConfig,
        enabled: _shaders.isReady,
        backdropKey: component == 5
            ? _shaders.rawBackdropKey
            : _shaders.backdropKey,
        blendMode: component == 0 || component == 5
            ? BlendMode.src
            : component == 4
            ? BlendMode.dstOver
            : BlendMode.plus,
      );

  _ScrollEdgeShaders _shaders;

  _ScrollEdgeShaders get shaders => _shaders;

  set shaders(_ScrollEdgeShaders value) {
    if (identical(value, _shaders)) return;
    // The effect state retains one final shader owner across every update.
    // coverage:ignore-start
    if (attached) _shaders.removeListener(_onReady);
    _shaders = value;
    backdropKey = switch (filterConfig) {
      _ScrollEdgeFilter(component: 5) => value.rawBackdropKey,
      _ => value.backdropKey,
    };
    if (attached) _shaders.addListener(_onReady);
    _onReady();
    // coverage:ignore-end
  }

  void _onReady() {
    enabled = _shaders.isReady;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (layer case _ScrollEdgeBackdropLayer retained)
      retained.renderObject = this;
    _shaders.addListener(_onReady);
    _onReady();
  }

  @override
  void detach() {
    if (layer case _ScrollEdgeBackdropLayer retained)
      retained.renderObject = null;
    _shaders.removeListener(_onReady);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!enabled) {
      super.paint(context, offset);
      return;
    }
    final child = this.child;
    if (child == null) {
      layer = null;
      return;
    }
    assert(
      needsCompositing,
      'An enabled scroll edge backdrop requires compositing.',
    );
    final retained = (layer ??= _ScrollEdgeBackdropLayer(this))
      ..blendMode = blendMode
      ..backdropKey = backdropKey;
    context.pushLayer(
      retained,
      (context, offset) => context.paintChild(child, offset),
      offset,
    );
    assert(() {
      retained.debugCreator = debugCreator;
      return true;
    }(), 'Backdrop diagnostics must reference the current render object.');
  }

  @override
  void dispose() {
    if (layer case _ScrollEdgeBackdropLayer retained)
      retained.renderObject = null;
    super.dispose();
  }
}

/// Snapshots uniforms after ancestor transforms, including retained opacity layers.
class _ScrollEdgeBackdropLayer extends BackdropFilterLayer {
  _ScrollEdgeBackdropLayer(this.renderObject);

  _RenderScrollEdgeBackdropFilter? renderObject;
  final LayerHandle<_ScrollEdgeGaussianLayer> _gaussianLayer =
      LayerHandle<_ScrollEdgeGaussianLayer>();
  ui.ClipRectEngineLayer? _gaussianClip;
  Rect? _gaussianCrop;
  bool _gaussianFirst = false;
  bool _restoresBackdrop = false;

  void _clearGaussian() {
    _gaussianLayer.layer = null;
    _gaussianClip?.dispose();
    _gaussianClip = null;
  }

  @override
  void dispose() {
    _clearGaussian();
    super.dispose();
  }

  @override
  void addChildrenToScene(ui.SceneBuilder builder) {
    final crop = _gaussianCrop;
    final shaders = renderObject?.shaders;
    if (crop == null || shaders == null) {
      _clearGaussian();
      super.addChildrenToScene(builder);
      return;
    }
    final parts = <_ScrollEdgeBackdropLayer>[];
    for (var child = firstChild; child != null; child = child.nextSibling) {
      if (child is! _ScrollEdgeBackdropLayer) break;
      final target = child.renderObject;
      if (target == null ||
          !target.attached ||
          !target.enabled ||
          !identical(target.shaders, shaders) ||
          target.size != renderObject?.size)
        break;
      if (target.filterConfig case _ScrollEdgeFilter(
        component: int component,
      ) when component == parts.length) {
        parts.add(child);
      } else {
        break;
      }
    }
    if (parts.length != 5 || !identical(parts.last, lastChild)) {
      _clearGaussian();
      super.addChildrenToScene(builder);
      return;
    }
    var gaussian = _gaussianLayer.layer;
    if (gaussian == null)
      _gaussianLayer.layer = gaussian = _ScrollEdgeGaussianLayer();
    gaussian
      ..filter = ui.ImageFilter.blur(
        sigmaX: _scrollEdgeIdentitySigma,
        sigmaY: _scrollEdgeIdentitySigma,
      )
      ..backdropKey = shaders.backdropKey
      ..gaussianKey = shaders.gaussianBackdropKey;
    parts.first.addToScene(builder);
    final previousClip = _gaussianClip;
    _gaussianClip = builder.pushClipRect(crop, oldLayer: previousClip);
    previousClip?.dispose();
    gaussian.parts = parts;
    try {
      gaussian.addToScene(builder);
    } finally {
      gaussian.parts = null;
      builder.pop();
    }
    parts.last.addToScene(builder);
  }

  @override
  bool get alwaysNeedsAddToScene => renderObject?.enabled ?? false;

  @override
  void markNeedsAddToScene() {
    if (!alwaysNeedsAddToScene) super.markNeedsAddToScene();
  }

  @override
  void addToScene(ui.SceneBuilder builder) {
    _gaussianCrop = null;
    if (renderObject case _RenderScrollEdgeBackdropFilter target
        when target.attached && target.enabled) {
      final filterContext = ImageFilterContext(
        bounds: Offset.zero & target.size,
      );
      final configuration = target.filterConfig;
      if (configuration is _ScrollEdgeFilter) {
        if (configuration.component == 4) {
          final outer = parent;
          if (outer is _ScrollEdgeBackdropLayer &&
              outer._restoresBackdrop &&
              identical(outer.lastChild, this) &&
              identical(outer.renderObject?.shaders, configuration.shaders)) {
            engineLayer = null;
            addChildrenToScene(builder);
            return;
          }
        }
        final visibility = configuration.blurOpacity?.call() ?? 1;
        final opacity = visibility.isFinite ? visibility.clamp(0.0, 1.0) : 0.0;
        final translation = MatrixUtils.getAsTranslation(
          target.getTransformTo(null),
        );
        var singlePass = opacity == 0 || translation == null;
        final requiredBottom = configuration.requiredParentBottom(
          target.size,
          opacity,
        );
        var boundedParent =
            translation == Offset.zero && requiredBottom != null;
        final fullHeight = target.size.height * configuration.devicePixelRatio;
        var fullParent = true;
        for (
          var ancestor = parent;
          ancestor != null;
          ancestor = ancestor.parent
        ) {
          if (ancestor is OpacityLayer && ancestor.alpha != 255)
            singlePass = true;
          if (ancestor
              case _ScrollEdgeBackdropLayer(
                renderObject: _RenderScrollEdgeBackdropFilter(
                  shaders: _ScrollEdgeShaders owner,
                  filterConfig: _ScrollEdgeFilter(component: 5),
                ),
              )
              when configuration.component != 5 &&
                  identical(owner, configuration.shaders)) {
            continue;
          }
          {
            final ancestorType = ancestor.runtimeType;
            if ((ancestorType != ContainerLayer &&
                    ancestorType != OffsetLayer &&
                    ancestorType != TransformLayer &&
                    ancestorType != OpacityLayer &&
                    ancestorType != ClipRectLayer) ||
                (ancestor is OpacityLayer && ancestor.alpha != 255)) {
              boundedParent = false;
            }
            if (ancestor is OffsetLayer && ancestor.offset != Offset.zero)
              boundedParent = false;
            if (ancestor is TransformLayer && ancestor.parent != null) {
              final transform = ancestor.transform;
              if (transform == null ||
                  MatrixUtils.getAsTranslation(transform) != Offset.zero)
                boundedParent = false;
            }
            if (ancestor is ClipRectLayer && requiredBottom != null) {
              final clip = ancestor.clipRect;
              if (clip == null ||
                  clip.bottom * configuration.devicePixelRatio < fullHeight)
                fullParent = false;
              if (ancestor.clipBehavior == Clip.antiAliasWithSaveLayer ||
                  clip == null ||
                  !clip.isFinite ||
                  clip.left > 0 ||
                  clip.top > 0 ||
                  clip.right < target.size.width ||
                  (clip.bottom * configuration.devicePixelRatio)
                          .floorToDouble() <
                      requiredBottom) {
                boundedParent = false;
              }
            }
          }
        }
        if (configuration.component == 5) {
          if (singlePass || !boundedParent) {
            engineLayer = null;
            addChildrenToScene(builder);
            return;
          }
        } else if (singlePass && configuration.component != 0) {
          return;
        }
        if (configuration.component == 5 &&
            !singlePass &&
            boundedParent &&
            fullParent &&
            opacity == 1 &&
            configuration.devicePixelRatio == 3 &&
            fullHeight == fullHeight.floorToDouble() &&
            fullHeight <= (configuration.view?.physicalSize.height ?? 0) &&
            requiredBottom != null) {
          // Preserve the half-scale Gaussian's padding phase, including odd source heights.
          final gaussianBottom = configuration.requiredParentBottom(
            target.size,
            opacity,
            gaussianOnly: true,
          );
          if (gaussianBottom != null) {
            var bottom = gaussianBottom.ceil();
            if (bottom.isOdd != fullHeight.toInt().isOdd) bottom++;
            if (bottom > 0 && bottom < fullHeight) {
              _gaussianCrop = Rect.fromLTRB(
                0,
                0,
                target.size.width,
                bottom / 3,
              );
            }
          }
        }
        blendMode = _gaussianFirst
            ? BlendMode.src
            : singlePass
            ? BlendMode.srcOver
            : target.blendMode;
        filter = configuration.resolve(
          filterContext,
          paintOpacity: opacity,
          singlePass: singlePass,
          sdkGaussian: boundedParent,
        );
        if (configuration.component == 5) {
          if (lastChild case _ScrollEdgeBackdropLayer(
            renderObject: _RenderScrollEdgeBackdropFilter(
              shaders: _ScrollEdgeShaders owner,
              filterConfig: _ScrollEdgeFilter(component: 4),
              attached: true,
              enabled: true,
            ),
          ) when identical(owner, configuration.shaders)) {
            final originalBlend = blendMode;
            final wasRestoringBackdrop = _restoresBackdrop;
            try {
              blendMode = BlendMode.srcOver;
              _restoresBackdrop = true;
              super.addToScene(builder);
            } finally {
              _restoresBackdrop = wasRestoringBackdrop;
              blendMode = originalBlend;
            }
            return;
          }
        }
      } else {
        filter = configuration.resolve(filterContext);
      }
    }
    super.addToScene(builder);
  }
}

/// Gives the Gaussian contributions a smaller current-frame input without cropping the shade or alpha restoration.
class _ScrollEdgeGaussianLayer extends BackdropFilterLayer {
  _ScrollEdgeGaussianLayer() : super(blendMode: BlendMode.plus);

  List<_ScrollEdgeBackdropLayer>? parts;
  BackdropKey? gaussianKey;

  @override
  void addChildrenToScene(ui.SceneBuilder builder) {
    final children = parts;
    if (children == null) return;
    for (var index = 1; index <= 3; index++) {
      final child = children[index];
      final originalKey = child.backdropKey;
      final originalBlend = child.blendMode;
      final originalFirst = child._gaussianFirst;
      child
        ..backdropKey = gaussianKey
        .._gaussianFirst = index == 1;
      try {
        child.addToScene(builder);
      } finally {
        child
          ..backdropKey = originalKey
          ..blendMode = originalBlend
          .._gaussianFirst = originalFirst;
      }
    }
  }
}

/// Loads and caches one program used by the progressive scroll edge.
final class _ScrollEdgeShaderLoader {
  _ScrollEdgeShaderLoader(this._asset);

  final String _asset;

  /// The loaded shader program, if available.
  ui.FragmentProgram? get program => _program;
  ui.FragmentProgram? _program;

  /// Ensures that the shader program is loaded and returns it.
  Future<bool> ensureLoaded() => _$load ??= _load();
  Future<bool>? _$load;

  Future<bool> _load() async {
    try {
      _program = await ui.FragmentProgram.fromAsset(
        _asset,
      ).timeout(const Duration(seconds: 5));
      return true;
    } on Object catch (error, stackTrace) {
      if (!kReleaseMode && error is! UnsupportedError) {
        dev.log(
          'Failed to load shader: $error',
          error: error,
          stackTrace: stackTrace,
          name: 'CountryPickerScrollEdgeEffect',
        );
      }
      return false;
    }
  }
}

final _ScrollEdgeShaderLoader _scrollEdgeShader = _ScrollEdgeShaderLoader(
  defaultTargetPlatform == TargetPlatform.windows
      ? CountryPickerScrollEdgeEffect._windowsShaderAsset
      : CountryPickerScrollEdgeEffect._shaderAsset,
);
final _ScrollEdgeShaderLoader _contributionShader = _ScrollEdgeShaderLoader(
  CountryPickerScrollEdgeEffect._contributionShaderAsset,
);

final _ScrollEdgeShaderLoader _separatedShader = _ScrollEdgeShaderLoader(
  defaultTargetPlatform == TargetPlatform.windows
      ? CountryPickerScrollEdgeEffect._windowsSeparatedShaderAsset
      : CountryPickerScrollEdgeEffect._separatedShaderAsset,
);

/// Resolves the blur bounds at paint time, including the status bar and trailing edge.
class _ScrollEdgeFilter implements ImageFilterConfig {
  const _ScrollEdgeFilter(
    this.shaders,
    this.context,
    this.devicePixelRatio,
    this.extent,
    this.color,
    this.blurOpacity,
    this.component, {
    required this.isLight,
    this.view,
  });

  final _ScrollEdgeShaders shaders;
  final BuildContext context;
  final double devicePixelRatio;
  final double extent;
  final Color color;
  final bool isLight;
  final ValueGetter<double>? blurOpacity;
  final int component;
  final ui.FlutterView? view;

  /// Required physical crop bottom for a full-view-width, zero-origin layer with qualified framework ancestors.
  double? requiredParentBottom(
    Size size,
    double opacity, {
    bool gaussianOnly = false,
  }) {
    final viewport = view;
    if (viewport == null ||
        !devicePixelRatio.isFinite ||
        devicePixelRatio <= 0 ||
        devicePixelRatio != viewport.devicePixelRatio ||
        !size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0 ||
        size.width != viewport.physicalSize.width / devicePixelRatio ||
        !extent.isFinite ||
        opacity <= 0) {
      return null;
    }
    final physicalBottom = size.height * devicePixelRatio;
    if (!physicalBottom.isFinite || !viewport.physicalSize.height.isFinite)
      return null;
    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox ||
        !renderBox.hasSize ||
        !renderBox.size.height.isFinite)
      return null;
    final headerHeight = renderBox.size.height.clamp(0.0, size.height);
    final top =
        renderBox.localToGlobal(Offset(0, headerHeight - extent * 1.6)).dy *
        devicePixelRatio;
    final trailing =
        renderBox.localToGlobal(Offset(0, headerHeight + extent * .2)).dy *
        devicePixelRatio;
    final height = math.max(trailing - top, 1.0);
    final sigma = 1.85 * devicePixelRatio * math.sqrt(opacity);
    // Gaussian weights vanish before the shade tail; retain the calibrated kernel's source halo.
    final lastRequiredRow = gaussianOnly
        ? trailing + (height / 1.8) * (.223958333 - .2) + 3 * sigma * 1.2 + 4
        : trailing + (height / 1.8) * .25 + 3 * sigma + 4;
    if (!top.isFinite || !trailing.isFinite || !lastRequiredRow.isFinite)
      return null;
    final requiredBottom = (lastRequiredRow + 1).ceilToDouble();
    final cropBottom = math
        .min(physicalBottom, viewport.physicalSize.height)
        .floorToDouble();
    return cropBottom >= requiredBottom ? requiredBottom : null;
  }

  @override
  ui.ImageFilter? get filter => null;

  @override
  String get debugShortDescription => 'scroll edge';

  @override
  ui.ImageFilter resolve(
    ImageFilterContext filterContext, {
    double? paintOpacity,
    bool singlePass = false,
    bool sdkGaussian = false,
  }) {
    final (horizontal, vertical) = switch ((
      shaders.horizontal,
      shaders.vertical,
    )) {
      (ui.FragmentShader horizontal, ui.FragmentShader vertical) => (
        horizontal,
        vertical,
      ),
      _ => throw StateError(
        'Scroll edge shaders must be ready before resolving the filter.',
      ),
    };
    final renderBox = switch (context.findRenderObject()) {
      RenderBox renderBox => renderBox,
      // The effect's context resolves to the IgnorePointer built by its state.
      // coverage:ignore-start
      _ => throw FlutterError('The scroll edge filter requires a RenderBox.'),
      // coverage:ignore-end
    };
    // An isolated sheet backdrop starts at its clipped surface, not the screen
    // origin. Keep the blur and shade aligned when the sheet moves or expands.
    final origin = switch (context
        .findAncestorRenderObjectOfType<RenderClipRSuperellipse>()) {
      RenderClipRSuperellipse clip
          when clip.clipBehavior == Clip.antiAliasWithSaveLayer =>
        clip.localToGlobal(Offset.zero).dy,
      _ => 0.0,
    };
    double physicalY(double y) =>
        (renderBox.localToGlobal(Offset(0, y)).dy - origin) * devicePixelRatio;
    final headerHeight = renderBox.size.height.clamp(
      0.0,
      filterContext.bounds.height,
    );
    final top = physicalY(headerHeight - extent * 1.6);
    final trailing = physicalY(headerHeight + extent * .2);
    final visibility = paintOpacity ?? blurOpacity?.call() ?? 1;
    final opacity = visibility.isFinite ? visibility.clamp(0.0, 1.0) : 0.0;
    final sigma = 1.85 * devicePixelRatio * math.sqrt(opacity);
    final shadeTop = physicalY((headerHeight - extent * 4) * opacity);
    final shadeBottom = physicalY(headerHeight + extent);
    horizontal
      ..setFloat(2, top)
      ..setFloat(3, trailing)
      ..setFloat(4, sigma)
      ..setFloat(5, 1)
      ..setFloat(6, 0);
    vertical
      ..setFloat(2, top)
      ..setFloat(3, trailing)
      ..setFloat(4, sigma)
      ..setFloat(5, 0)
      ..setFloat(6, 1)
      ..setFloat(7, color.r)
      ..setFloat(8, color.g)
      ..setFloat(9, color.b)
      ..setFloat(10, .85)
      ..setFloat(11, shadeTop)
      ..setFloat(12, shadeBottom)
      ..setFloat(13, isLight ? .013 * (1 - opacity) : 0)
      ..setFloat(14, opacity)
      ..setFloat(204, 0)
      ..setFloat(205, 0);
    shaders.configureKernels(sigma);
    if (singlePass || opacity == 0) {
      if (!shaders._genericReady) {
        shaders.ensureGeneric();
        vertical.setFloat(205, 7);
      }
      return ui.ImageFilter.shader(vertical);
    }
    if (component >= 4) {
      if (sdkGaussian && devicePixelRatio == 3) {
        return ui.ImageFilter.blur(
          sigmaX: _scrollEdgeIdentitySigma,
          sigmaY: _scrollEdgeIdentitySigma,
        );
      }
      final identity = shaders.contributions[component == 5 ? 8 : 7]
        ..setFloat(205, 4);
      return ui.ImageFilter.shader(identity);
    }
    final first = component == 0
        ? shaders.contributions[0]
        : shaders.contributions[component * 2 - 1];
    final last = component == 0 ? first : shaders.contributions[component * 2];
    for (final shader in <ui.FragmentShader>[first, if (component != 0) last]) {
      shader
        ..setFloat(2, top)
        ..setFloat(3, trailing)
        ..setFloat(4, sigma)
        ..setFloat(5, 0)
        ..setFloat(6, 1)
        ..setFloat(7, color.r)
        ..setFloat(8, color.g)
        ..setFloat(9, color.b)
        ..setFloat(10, .85)
        ..setFloat(11, shadeTop)
        ..setFloat(12, shadeBottom)
        ..setFloat(13, isLight ? .013 * (1 - opacity) : 0)
        ..setFloat(14, opacity)
        ..setFloat(204, component == 0 ? 0.0 : (component - 1).toDouble());
    }
    if (component == 0) {
      first.setFloat(205, 1);
      return ui.ImageFilter.shader(first);
    }
    if (!sdkGaussian) {
      first.setFloat(205, 2);
      last.setFloat(205, 3);
      return ui.ImageFilter.compose(
        outer: ui.ImageFilter.shader(last),
        inner: ui.ImageFilter.shader(first),
      );
    }
    // The native Gaussian receives local sigma; the retained shader uses physical coordinates.
    final logicalSigma = sigma / devicePixelRatio;
    final width =
        (component == 3
            ? logicalSigma
            : logicalSigma * (component == 1 ? 2 : 4) / 5.55) *
        1.2;
    last.setFloat(205, 6);
    final ui.FragmentShader contribution;
    if (shaders.sdkContributions.length == 3) {
      contribution = shaders.sdkContributions[component - 1]
        ..setFloat(2, top)
        ..setFloat(3, trailing)
        ..setFloat(4, sigma)
        ..setFloat(5, .85)
        ..setFloat(6, shadeTop)
        ..setFloat(7, shadeBottom)
        ..setFloat(8, isLight ? .013 * (1 - opacity) : 0)
        ..setFloat(9, opacity)
        ..setFloat(10, (component - 1).toDouble());
    } else {
      contribution = last;
    }
    return ui.ImageFilter.compose(
      outer: ui.ImageFilter.shader(contribution),
      inner: ui.ImageFilter.blur(
        sigmaX: width,
        sigmaY: width,
        tileMode: ui.TileMode.mirror,
      ),
    );
  }
}
