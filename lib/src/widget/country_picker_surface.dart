/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 26 September 2026
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Identifies the control a [CountryPickerSurfaceBuilder] is painting.
///
/// Include a fallback when switching over these values. Future releases
/// can add new control types.
enum CountryPickerSurfaceType {
  /// The floating pill-shaped search field above the keyboard.
  searchField,

  /// A round close button in the header or next to the search field.
  closeButton,
}

/// {@template country_picker_surface}
/// Describes a control surface of the country picker
/// that is passed to [CountryPickerSurfaceBuilder].
///
/// Custom builders paint the control background and place its content on top.
/// Use [decoration] to reproduce the default paint.
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
  /// Includes pointer presses handled by the search field's child.
  /// Useful to drive press animations of a custom surface.
  final ValueListenable<bool> pressed;

  /// Called when an interactive surface is activated.
  ///
  /// The picker already handles taps and accessibility around the surface,
  /// so a builder does not have to call it. If the builder adds its own
  /// gesture detector that consumes taps, it must call [onPressed] itself.
  ///
  /// `null` for the search field, whose child handles text input itself.
  final VoidCallback? onPressed;

  /// Whether the picker owns an activation callback for this surface.
  ///
  /// Search handles interaction in its text-field child and returns `false`.
  bool get isInteractive => onPressed != null;
}

/// {@template country_picker_surface_builder}
/// Builds a control surface of the country picker.
///
/// `child` is the surface content without the background.
///
/// Passed to `showCountryPicker` or `CountryPhoneInput`, like
/// `TextField.contextMenuBuilder`. When `null`, glass controls paint
/// [CountryPickerSurface.decoration] with backdrop blur and animate on press.
///
/// ```dart
/// Widget glassSurface(
///   BuildContext context,
///   CountryPickerSurface surface,
///   Widget child,
/// ) => GlassWidget(
///   shape: surface.shape,
///   pressed: surface.pressed,
///   child: child,
/// );
///
/// showCountryPicker(context: context, surfaceBuilder: glassSurface);
/// ```
/// {@endtemplate}
typedef CountryPickerSurfaceBuilder =
    Widget Function(
      BuildContext context,
      CountryPickerSurface surface,
      Widget child,
    );
