import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart'
    show CountryPickerTheme;
import 'package:material_ui/material_ui.dart';

/// {@template common_bottom_space}
/// Leaves room below preview controls for the system bottom inset.
/// {@endtemplate}
class CommonBottomSpacer extends StatelessWidget {
  /// {@macro common_bottom_space}
  const CommonBottomSpacer({super.key});

  /// Returns the safe-area inset, the gesture inset, or the theme padding.
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
