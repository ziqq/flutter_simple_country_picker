import 'dart:math' as math;

import 'package:example/src/common/constant/pubspec.yaml.g.dart';
import 'package:example/src/common/constants/constants.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:l/l.dart';

/// Filtered countries
final _filter =
    List<String>.unmodifiable(['RU', 'AM', 'BY', 'KG', 'MD', 'TJ', 'UZ']);

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
  final TextEditingController _controller = TextEditingController();

  String _country = '🇷🇺 Россия';
  String _countryCode = '7';
  String? _mask = '000 000 0000';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Country picker: CountryPickerPreview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Version: ${Pubspec.version.canonical}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: brightness == Brightness.light
                      ? const Icon(Icons.dark_mode_rounded)
                      : const Icon(Icons.light_mode_rounded),
                  onPressed: () {
                    themeModeSwitcher.value = brightness == Brightness.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                ),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: math.max((size.width - 900) / 2, 16),
                vertical: 24,
              ),
              sliver: SliverList.list(
                children: [
                  const SizedBox(height: kDefaultPadding * 2),
                  CountryPhoneInput(
                    autofocus: false,
                    controller: _controller,
                    mask: _mask,
                    country: _country,
                    countryCode: _countryCode,
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        favorite: ['RU'],
                        exclude: ['KN', 'MF'],
                        showPhoneCode: true,
                        onSelect: (country) {
                          l.i('Selected country $country');
                          setState(() {
                            _country =
                                '${country.flagEmoji} ${country.nameLocalized}';
                            _countryCode = country.phoneCode;
                            _mask = country.mask;
                          });
                        },
                        onDone: () => l.i('onDone called...'),
                      );
                    },
                  ),
                  const SizedBox(height: kDefaultPadding * 2),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                      ),
                      onPressed: () {
                        // ignore: lines_longer_than_80_chars
                        l.i("PHONE: +$_countryCode${_controller.text.replaceAll(" ", "")}");
                      },
                      child: const Text('Submit'),
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
                        // Optional.
                        // Can be used to exclude (remove) one ore more country
                        // from the countries list (optional).
                        exclude: ['KN', 'MF'],
                        favorite: ['RU'],
                        // Optional. Shows phone code before the country name.
                        showPhoneCode: true,
                        onSelect: (country) {
                          l.i('Selected country $country');
                        },
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
                        // Optional.
                        // Can be used to exclude (remove) one ore more country
                        // from the countries list (optional).
                        filter: _filter,
                        // Optional. Shows phone code before the country name.
                        showPhoneCode: true,
                        onSelect: (country) {
                          l.i('Selected country $country');
                        },
                      ),
                      child: const Text('Show filtered picker'),
                    ),
                  ),
                  if (MediaQuery.of(context).viewPadding.bottom == 0) ...[
                    const SizedBox(height: kDefaultPadding),
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
