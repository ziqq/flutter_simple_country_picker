// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'dart:developer' as dev show log;

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

void main() => appZone(() async => runApp(const App(home: MobilePreview())));

/// {@template county_picker_mobile_preview}
/// MobilePreview widget.
/// {@endtemplate}
class MobilePreview extends StatefulWidget {
  /// {@macro county_picker_mobile_preview}
  const MobilePreview({super.key});

  /// Title of the widget.
  static const String title = 'Preview Mobile';

  @override
  State<MobilePreview> createState() => _MobilePreviewState();
}

/// State for [MobilePreview].
class _MobilePreviewState extends State<MobilePreview>
    with CountryPickerPreviewStateMixin {
  final _countryPhoneController = CountryPhoneController.apply(
    '88881234567',
  ) /* 78881234567 */ /* +78881234567 */;

  @override
  void dispose() {
    _countryPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CommonAppBar(title: MobilePreview.title),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: CommonBottomSpacer.heightOf(context)),
        child: ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoButton(
                key: const ValueKey<String>('full_picker_button'),
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
                sizeStyle: CupertinoButtonSize.medium,
                onPressed: () => showCountryPicker(
                  context: context,
                  // Can be used to exclude one ore more country
                  // from the countries list. Optional.
                  exclude: ['KN', 'MF'],
                  favorite: ['RU'],
                  // Shows phone code before the country name. Optional.
                  showPhoneCode: true,
                  onSelect: onSelect,
                ),
                child: const Text('Show picker'),
              ),
              CupertinoButton(
                key: const ValueKey<String>('filtered_picker_button'),
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
                sizeStyle: CupertinoButtonSize.medium,
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
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: CommonPadding.of(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: kDefaultPadding,
            children: <Widget>[
              CountryPhoneInput(
                key: const ValueKey<String>('country_phone_input'),
                controller: _countryPhoneController,
                filter: kFilteredCountries,
                onCountryChanged: (c) => dev.log('Country changed: $c'),
                // isScrollControlled: true,
              ),

              // --- Password input --- //
              DecoratedBox(
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondarySystemBackground,
                    context,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(pickerTheme.radius),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: pickerTheme.inputHeight,
                  ),
                  child: Center(
                    child: TextFormField(
                      cursorColor: theme.textTheme.bodyLarge?.color,
                      cursorHeight: theme.textTheme.bodyLarge?.fontSize,
                      decoration: InputDecoration(
                        hintText: ExampleLocalization.of(context).passwordLable,
                        hintStyle: theme.textTheme.bodyLarge,

                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Submit button --- //
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding,
                  ),
                  onPressed: onSubmit,
                  child: Text(ExampleLocalization.of(context).submitButton),
                ),
              ),

              // --- Withe space --- //
              const CommonBottomSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}
