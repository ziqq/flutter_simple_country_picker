import 'package:example/src/common/constant/constants.dart';
import 'package:example/src/common/widget/common_header.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:l/l.dart';

/// {@template county_picker_preview}
/// CountryPickerPreview widget.
/// {@endtemplate}
class CountryPickerPreview extends StatefulWidget {
  /// {@macro county_picker_preview}
  const CountryPickerPreview({super.key});

  @override
  State<CountryPickerPreview> createState() => _CountryPickerPreviewState();
}

/// State for [CountryPickerPreview].
class _CountryPickerPreviewState extends State<CountryPickerPreview> {
  final ValueNotifier<Country> _selected = ValueNotifier(Country.mock());

  void _onSelect(Country country) {
    HapticFeedback.heavyImpact().ignore();
    l.i('New country $country');
    _selected.value = country;
    _showSnackBar();
  }

  void _showSnackBar() {
    HapticFeedback.heavyImpact().ignore();
    ScaffoldMessenger.maybeOf(context)
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: CupertinoDynamicColor.resolve(
            CupertinoColors.secondarySystemBackground,
            context,
          ),
          content: Text('Selected country: ${_selected.value.name}'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CommonHeader('Country Picker Preview'),
        body: SafeArea(
          child: Padding(
            padding: CommonPadding.of(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      onSelect: _onSelect,
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
                      onSelect: _onSelect,
                    ),
                    child: const Text('Show filtered picker'),
                  ),
                ),

                // --- Withe space --- //
                if (MediaQuery.of(context).viewPadding.bottom == 0) ...[
                  const SizedBox(height: kToolbarHeight),
                ] else ...[
                  const SizedBox(height: kDefaultPadding),
                ],
              ],
            ),
          ),
        ),
      );
}
