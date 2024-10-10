import 'dart:math' as math;

import 'package:example/src/common/constant/pubspec.yaml.g.dart';
import 'package:example/src/common/constants/constants.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';

/// {@template county_phone_input_preview}
/// CountyPhoneInputPreview widget.
/// {@endtemplate}
class CountyPhoneInputPreview extends StatefulWidget {
  /// {@macro county_phone_input_preview}
  const CountyPhoneInputPreview({
    super.key, // ignore: unused_element
  });

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  @internal
  // ignore: library_private_types_in_public_api
  static _CountyPhoneInputPreviewState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<_CountyPhoneInputPreviewState>();

  @override
  State<CountyPhoneInputPreview> createState() =>
      _CountyPhoneInputPreviewState();
}

/// State for widget CountyPhoneInputPreview.
class _CountyPhoneInputPreviewState extends State<CountyPhoneInputPreview> {
  final TextEditingController _controller = TextEditingController();

  String _country = '🇷🇺 Россия';
  String _countryCode = '7';
  String? _mask = '000 000 0000';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
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
                    'County Phone Input Preview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Version: ${Pubspec.version.canonical}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              actions: const [AppThemeModeSwitcherButton()],
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
                        onDone: () => l.i('onDone callded...'),
                      );
                    },
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
