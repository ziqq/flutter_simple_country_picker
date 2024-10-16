import 'package:example/src/common/util/screen_unit.dart';
import 'package:example/src/common/widget/common_header.dart';
import 'package:example/src/preview/country_picker_form_desktop_preview.dart';
import 'package:example/src/preview/country_picker_form_mobile_preview.dart';
import 'package:flutter/material.dart';

/// {@template county_picker_preview}
/// CountryPickerFormPreview widget.
/// {@endtemplate}
class CountryPickerFormPreview extends StatelessWidget {
  /// {@macro county_picker_preview}
  const CountryPickerFormPreview({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CommonHeader('Country Form Preview'),
        body: SafeArea(
          child: context.screenSizeWhen(
            desktop: CountryPickerForm$DesktopPreview.new,
            tablet: CountryPickerForm$DesktopPreview.new,
            phone: CountryPickerForm$MobilePreview.new,
          ),
        ),
      );
}
