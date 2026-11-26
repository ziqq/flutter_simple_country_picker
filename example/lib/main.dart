/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 7 October 2024
 */

import 'dart:developer' show log;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/src/common/constant/constant.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:example/src/common/util/app_zone.dart';
import 'package:example/src/common/util/country_picker_state_mixin.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:example/src/common/widget/common_app_bar.dart';
import 'package:example/src/common/widget/common_bottom_space.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Launches the example for the standard and extended [CountryPhoneInput].
///
/// Platform-specific demos are in [the previews directory][previews].
///
/// [previews]: https://github.com/ziqq/flutter_simple_country_picker/tree/main/example/lib/src/preview
void main() => appZone(() async => runApp(const App(home: Preview())));

/// {@template county_picker_preview}
/// Shows two phone input layouts and standalone picker configurations.
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

  /// Shows a compact phone input alongside a second form field.
  Widget _buildPreview(BuildContext context) {
    final pickerTheme = CountryPickerTheme.of(context);
    final theme = Theme.of(context);
    return Column(
      spacing: pickerTheme.padding,
      mainAxisAlignment: .center,
      children: <Widget>[
        CountryPhoneInput(
          useCountryFormatting: true,
          key: const ValueKey<String>('country_phone_input'),
          controller: countryPhoneController,
          favorites: kFavoritesCountries,
          filter: kFilteredCountries,
          showGroup: true,
        ),

        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: .all(.circular(pickerTheme.baseCornerRadius)),
            color: pickerTheme.onBackgroundColor,
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
                    color: pickerTheme.searchTextStyle?.color?.withValues(
                      alpha: .5,
                    ),
                  ),
                  border: .none,
                  contentPadding: .symmetric(horizontal: pickerTheme.padding),
                ),
              ),
            ),
          ),
        ),

        SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: onSubmit,
            padding: .symmetric(horizontal: pickerTheme.padding),
            child: Text(ExampleLocalization.of(context).submitButton),
          ),
        ),

        const CommonBottomSpacer(),
      ],
    );
  }

  /// Shows the extended phone input with a separate country selector.
  Widget _buildPreviewExtended(BuildContext context) {
    final pickerTheme = CountryPickerTheme.of(context);
    return Column(
      mainAxisAlignment: .center,
      spacing: pickerTheme.padding,
      children: <Widget>[
        CountryPhoneInput.extended(
          useCountryFormatting: true,
          onChanged: (phone) => log('Phone changed: $phone'),
          filter: kFilteredCountries,
        ),

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
                  exclude: ['AT'],
                  favorites: kFavoritesCountries,
                  expand: true,
                  showGroup: true,
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
                  onSelect: onSelect,
                  favorites: ['RU'],
                  filter: kFilteredCountries,
                  isScrollControlled: false,
                  showPhoneCode: true,
                  showGroup: true,
                ),
                child: const Text('Show picker (filtered)'),
              ),
              CupertinoButton(
                key: const ValueKey<String>('country_picker_button'),
                padding: .symmetric(horizontal: pickerTheme.padding),
                sizeStyle: .medium,
                onPressed: () => showCountryPicker(
                  context: context,
                  onSelect: onSelect,
                  selected: selected,
                  showGroup: true,
                  showSearch: true,
                  shouldCloseOnSwipeDown: true,
                ),
                child: const Text('Show grouped picker'),
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
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl(
                    children: _tabs,
                    groupValue: groupValue,
                    onValueChanged: (value) => _groupValue.value = value ?? 0,
                  ),
                ),

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
