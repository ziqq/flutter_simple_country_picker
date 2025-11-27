import 'package:example/src/common/constant/constants.dart';
import 'package:flutter/material.dart';

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
        : kDefaultPadding;
  }

  @override
  Widget build(BuildContext context) => SizedBox(height: heightOf(context));
}
