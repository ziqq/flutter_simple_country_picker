import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart'
    show CountryPickerTheme;

/// {@template common_bottom_space}
/// CommonBottomSpacer widget.
/// {@endtemplate}
class CommonBottomSpacer extends StatelessWidget {
  /// {@macro common_bottom_space}
  const CommonBottomSpacer({super.key});

  /// Returns the height of the space box.
  static double heightOf(BuildContext context) {
    final gestureInsets = MediaQuery.systemGestureInsetsOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return viewPadding.bottom > 0
        ? viewPadding.bottom
        : gestureInsets.bottom > 0
        ? gestureInsets.bottom
        : CountryPickerTheme.of(context).padding;
  }

  @override
  Widget build(BuildContext context) => SizedBox(height: heightOf(context));
}
