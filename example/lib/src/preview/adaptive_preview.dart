import 'package:example/src/common/util/screen_unit.dart';
import 'package:example/src/preview/mobile_preview.dart';
import 'package:example/src/preview/web_preview.dart';
import 'package:flutter/material.dart';

/// {@template county_picker_adaptive_preview}
/// AdaptivePreview widget.
/// {@endtemplate}
class AdaptivePreview extends StatelessWidget {
  /// {@macro county_picker_adaptive_preview}
  const AdaptivePreview({super.key});

  @override
  Widget build(BuildContext context) => context.screenSizeWhen(
        desktop: WebPreview.new,
        tablet: WebPreview.new,
        phone: MobilePreview.new,
      );
}
