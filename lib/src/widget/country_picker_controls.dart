/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 3 November 2026
 */

import 'dart:async' show Timer;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_simple_country_picker/src/constant/constants.dart';
import 'package:flutter_simple_country_picker/src/localization/country_localizations.dart';
import 'package:flutter_simple_country_picker/src/model/country.dart';
import 'package:flutter_simple_country_picker/src/theme/country_picker_theme.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_scroll_edge.dart';
import 'package:flutter_simple_country_picker/src/widget/country_picker_surface.dart';
import 'package:material_ui/material_ui.dart';

/// Measures one text line using the same scale and direction as the list.
double _ios26TextHeight(BuildContext context, TextStyle? style) {
  final painter = TextPainter(
    text: TextSpan(text: 'Mg', style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final height = painter.height;
  painter.dispose();
  return height;
}

/// Whether enlarged text needs the calling code below the country names.
/// This keeps the flag and name usable when a trailing code consumes the row.
@internal
bool countryPickerUsesLargeRows(
  BuildContext context,
  CountryPickerTheme theme,
) {
  final style = theme.textStyle ?? DefaultTextStyle.of(context).style;
  final fontSize = style.fontSize ?? 14;
  return MediaQuery.textScalerOf(context).scale(fontSize) *
          (style.height ?? 1.2) >
      kMinInteractiveDimension;
}

/// Measures a country row at the current text scale.
@internal
double countryPickerCountryHeight(
  BuildContext context,
  CountryPickerTheme theme,
) =>
    math.max(
      MediaQuery.textScalerOf(context).scale(theme.flagSize ?? 22),
      _ios26TextHeight(context, theme.textStyle?.copyWith(height: 1.2)),
    ) +
    _ios26TextHeight(context, theme.secondaryTextStyle) +
    (countryPickerUsesLargeRows(context, theme)
        ? _ios26TextHeight(context, theme.textStyle?.copyWith(height: 1.2))
        : 0) +
    theme.padding * 1.25;

/// Measures a scrolling letter header.
/// The first header omits the larger spacing that separates later groups.
@internal
double countryPickerGroupHeight(
  BuildContext context,
  CountryPickerTheme theme, {
  bool first = false,
}) => math.max(
  first ? 26 : theme.padding * 3.5,
  MediaQuery.textScalerOf(context).scale(13) +
      (first ? theme.padding / 2 : theme.padding * 2),
);

/// Separates light country groups while retaining the dark list surface.
///
/// All callers pass a resolved theme with both background colors populated.
@internal
Color countryPickerSheetBackgroundColor(
  BuildContext context,
  CountryPickerTheme theme,
) =>
    (Theme.of(context).brightness == Brightness.light
        ? theme.secondaryBackgroundColor ?? theme.backgroundColor
        : theme.backgroundColor) ??
    Theme.of(context).colorScheme.surface; // coverage:ignore-line

/// Insets header controls below the rounded edge with space before the list.
@internal
EdgeInsets countryPickerHeaderPadding(CountryPickerTheme theme) =>
    EdgeInsets.only(top: theme.padding, bottom: theme.padding / 2);

/// Minimum touch target from the platform's SDK control convention.
@internal
double countryPickerMinimumControlHeight(BuildContext context) =>
    Theme.of(context).platform == TargetPlatform.android
    ? kMinInteractiveDimension
    : kCountryPickerControlHeight;

/// Measures a search or close control at the current text scale.
@internal
double countryPickerControlHeight(
  BuildContext context,
  CountryPickerTheme theme,
) => math.max(
  countryPickerMinimumControlHeight(context),
  _ios26TextHeight(context, theme.textStyle?.copyWith(height: 1.3)) +
      theme.padding,
);

/// Exact offsets share the row and header geometry used by the lazy delegate.
/// No offstage country widgets are built to support alphabet navigation.
/// A null [target] returns the total extent of all groups.
@internal
double countryPickerGroupOffset(
  BuildContext context,
  CountryPickerTheme theme,
  List<(String, List<Country>)> groups,
  String? target,
) {
  final row = countryPickerCountryHeight(context, theme);
  final divider = 1 / MediaQuery.devicePixelRatioOf(context);
  var offset = 0.0;
  for (final (letter, countries) in groups) {
    if (letter == target) return offset;
    if (letter.isNotEmpty) {
      offset += countryPickerGroupHeight(context, theme, first: offset == 0);
    }
    offset += countries.length * row;
    if (countries.length > 1) offset += (countries.length - 1) * divider;
  }
  return offset;
}

/// Keeps alphabet jumps independent of the currently built viewport children.
@internal
class CountryPickerExtentDelegate extends SliverChildBuilderDelegate {
  /// Creates a lazy delegate with an exact total content extent.
  CountryPickerExtentDelegate(
    super.builder, {
    required super.childCount,
    required this.extent,
  });

  /// The measured total extent of all rows, dividers and letter headers.
  final double extent;

  @override
  double estimateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) => extent;
}

/// Resolves the stock floating search surface for the current brightness.
ShapeDecoration _countryPickerSurfaceDecoration(
  BuildContext context,
  OutlinedBorder shape,
) {
  final theme = CountryPickerTheme.resolve(context);
  final materialTheme = Theme.of(context);
  final border = BorderSide(
    color: theme.dividerColor ?? materialTheme.dividerColor,
    width: 1 / MediaQuery.devicePixelRatioOf(context),
  );
  return ShapeDecoration(
    // The resolved theme always supplies a secondary background color.
    color:
        (theme.secondaryBackgroundColor ??
                // coverage:ignore-start
                materialTheme.colorScheme.surfaceContainer
            // coverage:ignore-end
            )
            .withValues(alpha: .8),
    shape: shape.copyWith(side: border),
  );
}

/// An accessible close control with theme-driven fake-glass painting.
class _CountryPickerCloseButton extends StatelessWidget {
  /// Creates a close control whose gesture and semantics are owned by the picker.
  const _CountryPickerCloseButton({
    required this.onClose,
    this.surfaceBuilder,
    this.pressAlignment = Alignment.center,
    this.isHeader = false,
    super.key,
  });

  /// Dismisses the enclosing picker route.
  final VoidCallback onClose;

  /// Replaces the stock glass painting while retaining picker interactions.
  final CountryPickerSurfaceBuilder? surfaceBuilder;

  /// Keeps expansion inside the sheet when the control touches its upper edge.
  final AlignmentGeometry pressAlignment;

  /// Identifies the close control in the picker header.
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    const shape = CircleBorder();
    final theme = CountryPickerTheme.resolve(context);
    final materialTheme = Theme.of(context);
    final highContrast = MediaQuery.highContrastOf(context);
    final dark = materialTheme.brightness == Brightness.dark;
    final foreground =
        theme.textStyle?.color ?? materialTheme.colorScheme.onSurface;
    // The resolved theme always supplies a secondary background color.
    final fill =
        theme.secondaryBackgroundColor ??
        materialTheme.colorScheme.surfaceContainer; // coverage:ignore-line
    final android = materialTheme.platform == TargetPlatform.android;
    final background =
        theme.backgroundColor ?? materialTheme.colorScheme.surface;
    final ShapeDecoration? interactionDecoration;
    if (isHeader && android && !highContrast) {
      interactionDecoration = ShapeDecoration(
        color: Color.alphaBlend(
          foreground.withValues(alpha: dark ? .18 : .05),
          background,
        ),
        shape: shape.copyWith(
          side: BorderSide(
            width: 2,
            color: Color.alphaBlend(
              foreground.withValues(alpha: dark ? .09 : 0),
              background,
            ),
          ),
        ),
      );
    } else {
      interactionDecoration = null;
    }
    return SizedBox.square(
      dimension: countryPickerControlHeight(context, theme),
      child: _Surface(
        builder: surfaceBuilder,
        pressAlignment: pressAlignment,
        type: CountryPickerSurfaceType.closeButton,
        interactionDecoration: interactionDecoration,
        shape: shape,
        decoration: ShapeDecoration(
          color: highContrast ? fill : fill.withValues(alpha: .65),
          shape: shape.copyWith(
            side: BorderSide(
              width: android ? 1 / MediaQuery.devicePixelRatioOf(context) : 1,
              color: highContrast
                  ? foreground
                  : theme.dividerColor ?? materialTheme.dividerColor,
            ),
          ),
          shadows: dark || highContrast
              ? null
              : [
                  BoxShadow(
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                    color: foreground.withValues(alpha: .05),
                  ),
                ],
        ),
        onPressed: onClose,
        semanticsLabel: CountryLocalizations.of(context).cancelButton,
        child: Center(child: Icon(CupertinoIcons.xmark, color: foreground)),
      ),
    );
  }
}

/// Paints a glass surface and animates its press and hover feedback.
/// Actions and semantics remain in [_Surface] or the native text-field child.
class _GlassFake extends StatefulWidget {
  const _GlassFake({
    required this.surface,
    required this.child,
    required this.pressAlignment,
    this.interactionDecoration,
  });

  final CountryPickerSurface surface;
  final Widget child;

  /// Origin of stock press scaling; custom painters retain their own animation.
  final AlignmentGeometry pressAlignment;

  /// Surface reached at the end of the press animation, when configured.
  final ShapeDecoration? interactionDecoration;

  @override
  State<_GlassFake> createState() => _GlassFakeState();
}

/// Animates glass feedback while the surface or its child owns interaction.
class _GlassFakeState extends State<_GlassFake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );

  Timer? _releaseTimer;
  bool _hovered = false;
  bool _animate = true;

  @override
  void initState() {
    super.initState();
    widget.surface.pressed.addListener(_pressChanged);
  }

  @override
  void didUpdateWidget(_GlassFake oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A mounted _SurfaceState uses its final notifier on every rebuild.
    if (oldWidget.surface.pressed != widget.surface.pressed) {
      // coverage:ignore-start
      oldWidget.surface.pressed.removeListener(_pressChanged);
      widget.surface.pressed.addListener(_pressChanged);
      _pressChanged();
      // coverage:ignore-end
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate = !MediaQuery.disableAnimationsOf(context);
    if (!_animate) {
      _releaseTimer?.cancel();
      _progress.value = 0;
    }
  }

  /// Holds the final press briefly before returning to the hover/rest state.
  void _pressChanged() {
    _releaseTimer?.cancel();
    if (!_animate) return;
    if (widget.surface.pressed.value) {
      _progress.animateTo(1, curve: Curves.easeInOut);
    } else {
      _releaseTimer = Timer(
        const Duration(milliseconds: 50),
        () => _progress.animateTo(_hovered ? .3 : 0, curve: Curves.easeInOut),
      );
    }
  }

  /// Uses the source control's intermediate hover progress on pointer devices.
  void _hoverChanged({required bool hovered}) {
    _hovered = hovered;
    if (!_animate || widget.surface.pressed.value) return;
    _releaseTimer?.cancel();
    _progress.animateTo(hovered ? .3 : 0, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    widget.surface.pressed.removeListener(_pressChanged);
    _releaseTimer?.cancel();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = MediaQuery.highContrastOf(context);
    final search = widget.surface.type == CountryPickerSurfaceType.searchField;
    final androidClose =
        !search && Theme.of(context).platform == TargetPlatform.android;
    final restingDecoration = widget.surface.decoration;
    final filter = ui.ImageFilter.blur(
      sigmaX: 8,
      sigmaY: 8,
      tileMode: search ? TileMode.clamp : TileMode.mirror,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final double scaleDelta;
        if (size.isFinite && size.longestSide > 0) {
          // Expand wide fields by the same absolute amount as round controls.
          // The dock gap bounds growth so neighboring surfaces keep their space.
          final growth = math.min(
            size.shortestSide * .17,
            CountryPickerTheme.resolve(context).padding / 1.6 * 2,
          );
          scaleDelta = growth / size.longestSide;
        } else {
          scaleDelta = 0;
        }
        return MouseRegion(
          onEnter: (_) => _hoverChanged(hovered: true),
          onExit: (_) => _hoverChanged(hovered: false),
          child: AnimatedBuilder(
            animation: _progress,
            child: widget.child,
            builder: (context, child) {
              final progress = _progress.value;
              final opacity = androidClose
                  ? 1 - .18 * progress
                  : progress <= .3
                  ? 1 - .28 * (progress / .3)
                  : .72 - .37 * ((progress - .3) / .7);
              final content = Opacity(opacity: opacity, child: child);
              final decoration = switch (widget.interactionDecoration) {
                ShapeDecoration active when progress > 0 =>
                  ShapeDecoration.lerp(restingDecoration, active, progress) ??
                      restingDecoration,
                _ => restingDecoration,
              };
              // Keep the search field's resting paint and grouped backdrop intact.
              final Widget surface;
              if (search) {
                surface = ClipPath(
                  clipper: ShapeBorderClipper(shape: widget.surface.shape),
                  child: BackdropFilter.grouped(
                    filter: filter,
                    child: DecoratedBox(decoration: decoration, child: content),
                  ),
                );
              } else {
                final shape = switch (decoration.shape) {
                  OutlinedBorder shape => shape,
                  _ => const CircleBorder(),
                };
                surface = DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: shape.copyWith(side: BorderSide.none),
                    shadows: decoration.shadows,
                  ),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(shape: shape),
                    position: DecorationPosition.foreground,
                    child: ClipPath(
                      clipper: ShapeBorderClipper(shape: shape),
                      child: RepaintBoundary(
                        child: BackdropFilter(
                          enabled: !highContrast,
                          filter: filter,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              shape: shape.copyWith(side: BorderSide.none),
                              color: decoration.color,
                            ),
                            child: content,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return Transform.scale(
                alignment: widget.pressAlignment,
                // Keep Android feedback inside the control's resting outline.
                scale: androidClose
                    ? 1 - .04 * progress
                    : 1 + scaleDelta * progress,
                child: surface,
              );
            },
          ),
        );
      },
    );
  }
}

/// Displays the picker title using the platform-appropriate toolbar.
///
/// Android renderers without shader filters use a Material [AppBar].
@internal
class CountryPickerHeader extends StatelessWidget {
  /// Creates the fixed title and close control.
  const CountryPickerHeader({
    required this.onClose,
    required this.onScrollToTop,
    this.surfaceBuilder,
    super.key,
  });

  /// Scrolls the country list to its beginning.
  final VoidCallback onScrollToTop;

  /// Dismisses the enclosing picker route.
  final VoidCallback onClose;

  /// Overrides stock control painting while retaining picker interactions.
  final CountryPickerSurfaceBuilder? surfaceBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = CountryPickerTheme.resolve(context);
    final background = countryPickerSheetBackgroundColor(context, theme);
    final padding = countryPickerHeaderPadding(theme);
    final controlHeight = countryPickerMinimumControlHeight(context);
    // Use the solid SDK toolbar on Android renderers without shader filters.
    final useMaterialAppBar =
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        !ui.ImageFilter.isShaderFilterSupported;
    final textStyle = CountryPickerTheme.maybeOf(context)?.textStyle;
    final titleStyle = CupertinoTheme.of(context).textTheme.navTitleTextStyle
        .copyWith(color: theme.textStyle?.color)
        .merge(textStyle)
        .copyWith(
          inherit: false,
          // The stock Android font on Skia uses its bold face for w600.
          fontWeight: useMaterialAppBar && textStyle?.fontFamily == null
              ? .w500
              : .w600,
        );
    final title = Text(
      CountryLocalizations.of(context).selectCountryLabel,
      style: titleStyle,
      overflow: .ellipsis,
      maxLines: 1,
    );

    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: <Widget>[
        if (!useMaterialAppBar)
          Positioned.fill(
            child: CountryPickerScrollEdgeEffect(
              color: background,
              extent: theme.padding * 2,
            ),
          ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onScrollToTop,
          child: useMaterialAppBar
              ? AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  toolbarHeight: controlHeight + padding.vertical,
                  // Keep the centered title clear of the floating close control.
                  titleSpacing: theme.padding + controlHeight,
                  backgroundColor: background,
                  foregroundColor: titleStyle.color,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  title: Padding(
                    padding: EdgeInsets.only(top: padding.top - padding.bottom),
                    child: title,
                  ),
                )
              : Padding(
                  padding: padding,
                  child: CupertinoNavigationBar(
                    bottom: Theme.of(context).platform == TargetPlatform.android
                        ? const PreferredSize(
                            preferredSize: Size.fromHeight(4),
                            child: SizedBox(height: 4),
                          )
                        : null,
                    backgroundColor: background.withValues(alpha: 0),
                    border: null,
                    automaticBackgroundVisibility: false,
                    enableBackgroundFilterBlur: false,
                    automaticallyImplyLeading: false,
                    automaticallyImplyMiddle: false,
                    transitionBetweenRoutes: false,
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: theme.padding,
                    ),
                    // The control paints above the toolbar's background clip.
                    leading: const SizedBox.square(
                      dimension: kCountryPickerControlHeight,
                    ),
                    middle: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      excludeFromSemantics: true,
                      onTap: onScrollToTop,
                      child: title,
                    ),
                  ),
                ),
        ),
        Positioned.fill(
          child: Padding(
            padding: padding,
            child: SafeArea(
              top: !CupertinoSheetRoute.hasParentSheet(context),
              bottom: false,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: theme.padding),
                  child: SizedBox.square(
                    dimension: controlHeight,
                    child: _CountryPickerCloseButton(
                      key: const ValueKey<String>(
                        'country_picker_header_close_button',
                      ),
                      onClose: onClose,
                      surfaceBuilder: surfaceBuilder,
                      pressAlignment: Alignment.topCenter,
                      isHeader: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Places a search field beside its close control within the floating dock.
@internal
class CountryPickerSearchDock extends StatelessWidget {
  /// Creates the controls whose position is supplied by the picker scaffold.
  const CountryPickerSearchDock({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.onClose,
    this.surfaceBuilder,
    super.key,
  });

  /// Holds the query used by the country controller.
  final TextEditingController controller;

  /// Notifies the picker when search should expand its sheet.
  final FocusNode focusNode;

  /// Whether to focus search when the picker opens.
  final bool autofocus;

  /// Dismisses the enclosing picker route.
  final VoidCallback onClose;

  /// Overrides painting of the search and close surfaces.
  final CountryPickerSurfaceBuilder? surfaceBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = CountryPickerTheme.resolve(context);
    final color =
        theme.textStyle?.color ?? Theme.of(context).colorScheme.onSurface;
    const shape = StadiumBorder();
    return SizedBox(
      height: countryPickerControlHeight(context, theme),
      child: Row(
        crossAxisAlignment: .stretch,
        spacing: theme.padding / 1.6,
        children: <Widget>[
          Expanded(
            child: _Surface(
              decoration: _countryPickerSurfaceDecoration(context, shape),
              builder: surfaceBuilder,
              type: .searchField,
              shape: shape,
              child: Semantics(
                label: CountryLocalizations.of(context).searchPlaceholder,
                child: CupertinoSearchTextField(
                  autofocus: autofocus,
                  focusNode: focusNode,
                  controller: controller,
                  onSuffixTap: controller.clear,
                  onSubmitted: (_) => focusNode.unfocus(),
                  style: theme.searchTextStyle?.copyWith(
                    height: theme.searchTextStyle?.height ?? 1.3,
                  ),
                  placeholderStyle: theme.searchTextStyle?.copyWith(
                    color: theme.searchTextStyle?.color?.withValues(alpha: .5),
                    height: 1.3,
                  ),
                  placeholder: CountryLocalizations.of(
                    context,
                  ).searchPlaceholder,
                  prefixInsets: EdgeInsetsDirectional.only(
                    start: theme.padding,
                  ),
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: theme.padding / 2,
                  ),
                  suffixInsets: EdgeInsetsDirectional.only(
                    end: theme.padding / 1.6,
                  ),
                  decoration: const BoxDecoration(),
                  itemColor: color,
                  itemSize: 22,
                ),
              ),
            ),
          ),
          _CountryPickerCloseButton(
            onClose: onClose,
            surfaceBuilder: surfaceBuilder,
            key: const ValueKey<String>('country_picker_close_button'),
          ),
        ],
      ),
    );
  }
}

/// Provides tap and drag navigation through the currently available letters.
@internal
class CountryPickerAlphabet extends StatefulWidget {
  /// Creates a rail that derives its labels from the displayed groups.
  const CountryPickerAlphabet({
    required this.groups,
    required this.onSelect,
    super.key,
  });

  /// Width of the alphabet's hit target, reserved beside Android country rows.
  static const double width = 24;

  /// The displayed groups; entries with an empty label are omitted.
  final List<(String, List<Country>)> groups;

  /// Requests navigation to the section selected by tap or drag.
  final ValueChanged<String> onSelect;

  @override
  State<CountryPickerAlphabet> createState() => _CountryPickerAlphabetState();
}

/// Keeps the adjustable accessibility value in sync with direct rail gestures.
class _CountryPickerAlphabetState extends State<CountryPickerAlphabet> {
  String? _selected;
  int? _previousGestureIndex;

  @override
  Widget build(BuildContext context) {
    final letters = <String>[
      for (final (letter, _) in widget.groups)
        if (letter.isNotEmpty) letter,
    ];
    if (letters.isEmpty) return const SizedBox.shrink();
    final theme = CountryPickerTheme.resolve(context);
    // The hit target stays wide while glyphs center in the outer list padding.
    final shift = (CountryPickerAlphabet.width - theme.padding) / 2;
    final letterOffset = Offset(
      Directionality.of(context) == TextDirection.rtl ? -shift : shift,
      0,
    );
    final selected = math.max(0, letters.indexOf(_selected ?? ''));
    void selectIndex(int index) {
      if (_selected != letters[index]) {
        setState(() => _selected = letters[index]);
      }
      widget.onSelect(letters[index]);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = math.min(constraints.maxHeight, letters.length * 14.0);
        void select(Offset point) {
          final index = (point.dy / height * letters.length).floor().clamp(
            0,
            letters.length - 1,
          );
          if (index == _previousGestureIndex) return;
          _previousGestureIndex = index;
          selectIndex(index);
        }

        return Semantics(
          slider: true,
          label: CountryLocalizations.of(context).selectCountryLabel,
          value: letters[selected],
          increasedValue: selected < letters.length - 1
              ? letters[selected + 1]
              : null,
          decreasedValue: selected > 0 ? letters[selected - 1] : null,
          onIncrease: selected < letters.length - 1
              ? () => selectIndex(selected + 1)
              : null,
          onDecrease: selected > 0 ? () => selectIndex(selected - 1) : null,
          excludeSemantics: true,
          child: Center(
            child: SizedBox(
              width: CountryPickerAlphabet.width,
              height: height,
              child: GestureDetector(
                key: const ValueKey<String>('country_picker_alphabet'),
                onPanUpdate: (details) => select(details.localPosition),
                onPanDown: (details) {
                  _previousGestureIndex = null;
                  select(details.localPosition);
                },
                behavior: .opaque,
                child: Column(
                  children: <Widget>[
                    for (final letter in letters)
                      Expanded(
                        child: ExcludeSemantics(
                          child: Transform.translate(
                            offset: letterOffset,
                            child: Center(
                              child: Text(
                                letter,
                                style: TextStyle(
                                  fontSize: math.min(
                                    11,
                                    height / letters.length / 1.2,
                                  ),
                                  height: 1,
                                  fontWeight: .w600,
                                  color: theme.accentColor,
                                ),
                                textScaler: .noScaling,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Connects a picker control to its stock or custom surface painter.
///
/// Owns taps, pressed state and accessibility so custom painters only draw.
class _Surface extends StatefulWidget {
  const _Surface({
    required this.type,
    required this.shape,
    required this.decoration,
    required this.child,
    this.builder,
    this.onPressed,
    this.semanticsLabel,
    this.pressAlignment = Alignment.center,
    this.interactionDecoration,
    super.key, // ignore: unused_element_parameter
  });

  /// Identifies the control for custom surface builders.
  final CountryPickerSurfaceType type;

  /// The control outline and its default paint.
  final ShapeBorder shape;
  final ShapeDecoration decoration;

  /// The content painted in front of the surface.
  final Widget child;

  /// Overrides the stock surface painter when provided.
  final CountryPickerSurfaceBuilder? builder;

  /// Handles the control action directly when the surface is interactive.
  final VoidCallback? onPressed;

  /// Names an interactive surface for assistive technologies.
  final String? semanticsLabel;

  /// Origin of the stock surface's press transform.
  final AlignmentGeometry pressAlignment;

  /// Optional stock surface paint for hover and press feedback.
  final ShapeDecoration? interactionDecoration;

  @override
  State<_Surface> createState() => _SurfaceState();
}

/// Exposes one shared pressed state to stock and custom surface painters.
class _SurfaceState extends State<_Surface> {
  /// Both pointer feedback and the painter read this shared press state.
  final ValueNotifier<bool> _pressed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = CountryPickerSurface(
      decoration: widget.decoration,
      onPressed: widget.onPressed,
      shape: widget.shape,
      type: widget.type,
      pressed: _pressed,
    );
    final child = switch (widget.builder) {
      CountryPickerSurfaceBuilder builder => builder(
        context,
        surface,
        widget.child,
      ),
      null => _GlassFake(
        surface: surface,
        pressAlignment: widget.pressAlignment,
        interactionDecoration: widget.interactionDecoration,
        child: widget.child,
      ),
    };
    final onPressed = widget.onPressed;
    if (onPressed == null) {
      if (widget.type != CountryPickerSurfaceType.searchField) return child;
      // Observe input without competing with the text field's gesture arena.
      return Listener(
        onPointerDown: (_) => _pressed.value = true,
        onPointerUp: (_) => _pressed.value = false,
        onPointerCancel: (_) => _pressed.value = false,
        child: child,
      );
    }
    return Semantics(
      button: true,
      container: true,
      label: widget.semanticsLabel,
      child: GestureDetector(
        behavior: .opaque,
        onTapCancel: () => _pressed.value = false,
        onTapDown: (_) => _pressed.value = true,
        onTapUp: (_) => _pressed.value = false,
        onTap: onPressed,
        child: ExcludeSemantics(child: child),
      ),
    );
  }
}
