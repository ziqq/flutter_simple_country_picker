import 'package:example/src/common/widget/common_app_bar.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

/// {@template county_phone_input_preview}
/// ExperimentalPreview widget.
/// {@endtemplate}
class ExperimentalPreview extends StatefulWidget {
  /// {@macro county_phone_input_preview}
  const ExperimentalPreview({
    super.key, // ignore: unused_element
  });

  @override
  State<ExperimentalPreview> createState() => _ExperimentalPreviewState();
}

/// State for widget ExperimentalPreview.
class _ExperimentalPreviewState extends State<ExperimentalPreview> {
  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            CommonAppBar.sliver('County Phone Input Experimental Preview'),
            SliverPadding(
              padding: CommonPadding.of(context),
              sliver: SliverList.list(
                children: [
                  SizedBox(height: pickerTheme.padding * 2),
                  const CountryPhoneInput.extended(autofocus: false),
                  if (MediaQuery.of(context).viewPadding.bottom == 0) ...[
                    SizedBox(height: pickerTheme.padding),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
