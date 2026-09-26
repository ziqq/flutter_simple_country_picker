/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 26 September 2026
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The kind of a [CountryPickerSurface].
///
/// More kinds may be added in minor releases, so a `switch` over this enum
/// should always have a fallback branch.
enum CountryPickerSurfaceType {
  /// The pill-shaped search field in the picker header.
  searchField,

  /// The round close button next to the search field.
  closeButton,
}

/// {@template country_picker_surface}
/// Describes a control surface of the iOS 26 styled country picker
/// that is passed to [CountryPickerSurfaceBuilder].
///
/// The builder receives the control content **without** the background,
/// so it can paint its own one (for example a shader-based liquid glass).
/// Use [decoration] to reproduce the default background.
/// {@endtemplate}
@immutable
class CountryPickerSurface {
  /// {@macro country_picker_surface}
  const CountryPickerSurface({
    required this.type,
    required this.shape,
    required this.decoration,
    required this.pressed,
    this.onPressed,
  });

  /// The kind of the surface.
  final CountryPickerSurfaceType type;

  /// The outline of the surface, e.g. [StadiumBorder] or [CircleBorder].
  final ShapeBorder shape;

  /// The decoration the picker paints by default.
  final ShapeDecoration decoration;

  /// Whether the surface is currently pressed.
  ///
  /// Always `false` for non-interactive surfaces.
  /// Useful to drive press animations of a custom surface.
  final ValueListenable<bool> pressed;

  /// Called when an interactive surface is activated.
  ///
  /// The picker already handles taps and accessibility around the surface,
  /// so a builder does not have to call it. If the builder adds its own
  /// gesture detector that consumes taps, it must call [onPressed] itself.
  ///
  /// `null` for non-interactive surfaces.
  final VoidCallback? onPressed;

  /// Whether the surface reacts to taps.
  bool get isInteractive => onPressed != null;
}

/// {@template country_picker_surface_builder}
/// Builds a control surface of the iOS 26 styled country picker.
///
/// `child` is the surface content without the background.
///
/// Prefer a top-level or static function, because [CountryPickerTheme]
/// compares builders by identity.
///
/// ```dart
/// Widget glassSurface(
///   BuildContext context,
///   CountryPickerSurface surface,
///   Widget child,
/// ) => MyLiquidGlass(
///   shape: surface.shape,
///   pressed: surface.pressed,
///   child: child,
/// );
///
/// CountryPickerTheme(useIOS26: true, surfaceBuilder: glassSurface);
/// ```
/// {@endtemplate}
typedef CountryPickerSurfaceBuilder =
    Widget Function(
      BuildContext context,
      CountryPickerSurface surface,
      Widget child,
    );
