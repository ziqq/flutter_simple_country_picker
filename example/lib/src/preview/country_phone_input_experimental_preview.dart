import 'package:example/src/common/constant/constants.dart';
import 'package:example/src/common/widget/common_header.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:l/l.dart';

/// {@template county_phone_input_preview}
/// CountryPhoneInputExperimentalPreview widget.
/// {@endtemplate}
class CountryPhoneInputExperimentalPreview extends StatefulWidget {
  /// {@macro county_phone_input_preview}
  const CountryPhoneInputExperimentalPreview({
    super.key, // ignore: unused_element
  });

  @override
  State<CountryPhoneInputExperimentalPreview> createState() =>
      _CountryPhoneInputExperimentalPreviewState();
}

/// State for widget CountryPhoneInputExperimentalPreview.
class _CountryPhoneInputExperimentalPreviewState
    extends State<CountryPhoneInputExperimentalPreview> {
  final TextEditingController _controller = TextEditingController();

  String _country = '🇷🇺 Россия';
  String _countryCode = '7';
  String? _mask = '000 000 0000';

  void _onSelect(Country country) {
    l.i('Selected country $country');
    setState(() {
      _country = '${country.flagEmoji} ${country.nameLocalized}';
      _countryCode = country.phoneCode;
      _mask = country.mask;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              CommonHeader.sliver('County Phone Input Experimental Preview'),
              SliverPadding(
                padding: CommonPadding.of(context),
                sliver: SliverList.list(
                  children: [
                    const SizedBox(height: kDefaultPadding * 2),
                    CountryPhoneInputExperimental(
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
                          onSelect: _onSelect,
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
