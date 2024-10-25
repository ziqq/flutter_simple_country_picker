import 'package:example/src/common/constant/constants.dart';
import 'package:flutter/material.dart';

/// {@template common_space_box}
/// CommonSpaceBox widget.
/// {@endtemplate}
class CommonSpaceBox extends StatelessWidget {
  /// {@macro common_space_box}
  const CommonSpaceBox({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).viewPadding.bottom == 0)
      return const SizedBox(height: kToolbarHeight);
    else
      return const SizedBox(height: kDefaultPadding);
  }
}
