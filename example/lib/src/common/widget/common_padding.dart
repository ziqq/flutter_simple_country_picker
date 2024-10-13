import 'dart:math' as math;

import 'package:flutter/material.dart';

/// {@template common_padding}
/// CommonPadding widget.
/// {@endtemplate}
class CommonPadding extends EdgeInsets {
  const CommonPadding._(final double value)
      : super.symmetric(horizontal: value);

  /// {@macro common_padding}
  factory CommonPadding.of(BuildContext context) => CommonPadding._(
      math.max((MediaQuery.sizeOf(context).width - 375) / 2, 16));

  /// {@macro common_padding}
  static Widget widget(BuildContext context, [Widget? child]) =>
      Padding(padding: CommonPadding.of(context), child: child);

  /// {@macro common_padding}
  static Widget sliver(BuildContext context, [Widget? child]) =>
      SliverPadding(padding: CommonPadding.of(context), sliver: child);
}
