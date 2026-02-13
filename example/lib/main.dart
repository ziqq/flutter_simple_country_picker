import 'dart:developer' show log;

import 'package:example/src/common/constant/constant.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:example/src/common/util/app_zone.dart';
import 'package:example/src/common/util/country_picker_state_mixin.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:example/src/common/widget/common_app_bar.dart';
import 'package:example/src/common/widget/common_bottom_space.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

/// This file includes basic example for [CountryPhoneInput]
/// that uses of [CountryPicker].
///
/// For more platform examples (android, ios, macOS, web, windows) check on
/// [GitHub](https://github.com/ziqq/flutter_simple_country_picker/tree/master/example/lib/src/preview)
void main() => appZone(() async => runApp(const App(home: Preview())));

/// {@template county_picker_preview}
/// Preview widget.
/// {@endtemplate}
class Preview extends StatefulWidget {
  /// {@macro county_picker_preview}
  const Preview({super.key});

  @override
  State<Preview> createState() => _PreviewState();
}

/// State for [Preview].
class _PreviewState extends State<Preview> with CountryPickerPreviewStateMixin {
  static const _tabs = <int, Text>{
    0: Text('Preview'),
    1: Text('Preview extended'),
  };
  final ValueNotifier<int> _groupValue = ValueNotifier<int>(0);

  @override
  void dispose() {
    _groupValue.dispose();
    super.dispose();
  }

  Widget _buildPreview(BuildContext context) {
    final pickerTheme = CountryPickerTheme.of(context);
    final theme = Theme.of(context);
    return Column(
      spacing: pickerTheme.padding,
      mainAxisAlignment: .center,
      children: <Widget>[
        CountryPhoneInput(
          key: const ValueKey<String>('country_phone_input'),
          controller: countryPhoneController,
          favorites: kFavoritesCountries,
          filter: kFilteredCountries,
        ),

        // --- Password input --- //
        DecoratedBox(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondarySystemBackground,
              context,
            ),
            borderRadius: .all(.circular(pickerTheme.radius)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: pickerTheme.inputHeight),
            child: Center(
              child: TextFormField(
                cursorColor: theme.textTheme.bodyLarge?.color,
                cursorHeight: theme.textTheme.bodyLarge?.fontSize,
                decoration: InputDecoration(
                  hintText: ExampleLocalization.of(context).passwordLable,
                  hintStyle: pickerTheme.textStyle?.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.placeholderText,
                      context,
                    ),
                  ),
                  border: .none,
                  contentPadding: .symmetric(horizontal: pickerTheme.padding),
                ),
              ),
            ),
          ),
        ),

        // --- Submit button --- //
        SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: onSubmit,
            padding: .symmetric(horizontal: pickerTheme.padding),
            child: Text(ExampleLocalization.of(context).submitButton),
          ),
        ),

        // --- Withe space --- //
        const CommonBottomSpacer(),
      ],
    );
  }

  Widget _buildPreviewExtended(BuildContext context) {
    final pickerTheme = CountryPickerTheme.of(context);
    return Column(
      mainAxisAlignment: .center,
      spacing: pickerTheme.padding,
      children: <Widget>[
        CountryPhoneInput.extended(
          onChanged: (phone) => log('Phone changed: $phone'),
          filter: kFilteredCountries,
          // isScrollControlled: true,
        ),

        // --- Submit button --- //
        SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: onSubmit,
            padding: .symmetric(horizontal: pickerTheme.padding),
            child: Text(ExampleLocalization.of(context).submitButton),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CommonAppBar(title: 'Preview'),
      bottomNavigationBar: Padding(
        padding: .only(bottom: CommonBottomSpacer.heightOf(context)),
        child: ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            mainAxisSize: .min,
            children: <Widget>[
              CupertinoButton(
                key: const ValueKey<String>('full_picker_button'),
                padding: .symmetric(horizontal: pickerTheme.padding),
                sizeStyle: .medium,
                onPressed: () => showCountryPicker(
                  context: context,
                  onSelect: onSelect,
                  // Can be used to exclude one ore more country
                  // from the countries list. Optional.
                  exclude: ['AT'],
                  favorites: kFavoritesCountries,
                  expand: true,
                  showGroup: true,
                  // Shows phone code before the country name. Optional.
                  showPhoneCode: true,
                  shouldCloseOnSwipeDown: true,
                ),
                child: const Text('Show picker'),
              ),
              CupertinoButton(
                key: const ValueKey<String>('filtered_picker_button'),
                padding: .symmetric(horizontal: pickerTheme.padding),
                sizeStyle: .medium,
                onPressed: () => showCountryPicker(
                  context: context,
                  isScrollControlled: false,
                  // Can be used to exclude one ore more country
                  // from the countries list. Optional.
                  filter: kFilteredCountries,
                  // Shows phone code before the country name. Optional.
                  showPhoneCode: true,
                  onSelect: onSelect,
                ),
                child: const Text('Show picker (filtered)'),
              ),
              CupertinoButton(
                key: const ValueKey<String>('adaptive_picker_button'),
                padding: .symmetric(horizontal: pickerTheme.padding),
                sizeStyle: .medium,
                onPressed: () => showCountryPicker(
                  context: context,
                  adaptive: true,
                  onSelect: onSelect,
                ),
                child: const Text('Show picker (adaptive)'),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: CommonPadding.of(context),
          child: ValueListenableBuilder(
            valueListenable: _groupValue,
            builder: (_, groupValue, _) => Column(
              mainAxisAlignment: .center,
              children: <Widget>[
                // --- Tabs --- //
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl(
                    children: _tabs,
                    groupValue: groupValue,
                    onValueChanged: (value) => _groupValue.value = value ?? 0,
                  ),
                ),

                // --- Content --- //
                Expanded(
                  child: switch (groupValue) {
                    0 => _buildPreview(context),
                    1 => _buildPreviewExtended(context),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
