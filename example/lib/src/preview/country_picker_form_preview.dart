import 'package:example/src/common/widget/common_header.dart';
import 'package:example/src/preview/country_picker_form_desktop_review.dart';
import 'package:example/src/preview/country_picker_form_mobile_preview.dart';
import 'package:flutter/material.dart';

/// List of tab previews.
final List<Widget> _tabs = <Widget>[
  const CountryPickerForm$DesktopPreview(),
  const CountryPickerForm$MobilePreview(),
];

/// {@template county_picker_preview}
/// CountryPickerFormPreview widget.
/// {@endtemplate}
class CountryPickerFormPreview extends StatelessWidget {
  /// {@macro county_picker_preview}
  const CountryPickerFormPreview({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CommonHeader('Country Form Preview'),
        body: LayoutBuilder(
          builder: (context, constraints) => SafeArea(
            child: DefaultTabController(
              length: _tabs.length,
              child: Column(
                children: [
                  const SizedBox(
                    height: 48,
                    child: TabBar(
                      // indicatorColor: Colors.transparent,
                      tabAlignment: TabAlignment.center,
                      padding: EdgeInsets.zero,
                      dividerHeight: 0,
                      tabs: [
                        Tab(text: CountryPickerForm$DesktopPreview.title),
                        Tab(text: CountryPickerForm$MobilePreview.title),
                      ],
                    ),
                  ),
                  Expanded(child: TabBarView(children: _tabs)),
                ],
              ),
            ),
          ),
        ),
      );
}
