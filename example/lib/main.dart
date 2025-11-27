import 'package:example/src/common/constant/constants.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:example/src/common/util/app_zone.dart';
import 'package:example/src/common/util/country_picker_state_mixin.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:example/src/common/widget/common_bottom_space.dart';
import 'package:example/src/common/widget/common_header.dart';
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

  /// Title of the widget.
  static const String title = 'Preview';

  @override
  State<Preview> createState() => _MobilePreviewState();
}

/// State for [Preview].
class _MobilePreviewState extends State<Preview>
    with CountryPickerPreviewStateMixin {
  final ValueNotifier<String> _countryPhoneController = ValueNotifier('');

  @override
  void dispose() {
    _countryPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CommonHeader(title: Preview.title),
    body: SafeArea(
      child: Padding(
        padding: CommonPadding.of(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CountryPhoneInput(
              key: const ValueKey<String>('country_phone_input'),
              filter: kFilteredCountries,
              controller: _countryPhoneController,
            ),
            const SizedBox(height: kDefaultPadding),

            // --- Password input --- //
            DecoratedBox(
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondarySystemBackground,
                  context,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Center(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context).textTheme.bodyLarge,
                      hintText: ExampleLocalization.of(context).passwordLable,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: kDefaultPadding * 2),

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
            const SizedBox(height: kDefaultPadding * 2),

            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                key: const ValueKey<String>('full_picker_button'),
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
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
                child: const Text('Show full picker'),
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                key: const ValueKey<String>('filtered_picker_button'),
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
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
                child: const Text('Show filtered picker'),
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
