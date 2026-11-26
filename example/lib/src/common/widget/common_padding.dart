import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// {@template common_padding}
/// Horizontal insets that keep the preview form compact on wider screens.
/// {@endtemplate}
class CommonPadding extends EdgeInsets {
  const CommonPadding._(final double value)
    : super.symmetric(horizontal: value);

  /// Centers a form up to 375 logical pixels wide with at least 16 pixels
  /// of padding on either side.
  factory CommonPadding.of(BuildContext context) => CommonPadding._(
    math.max((MediaQuery.sizeOf(context).width - 375) / 2, 16),
  );
}
