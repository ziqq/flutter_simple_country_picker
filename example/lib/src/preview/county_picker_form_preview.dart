import 'package:example/src/common/constant/constants.dart';
import 'package:example/src/common/widget/common_header.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:l/l.dart';

/// {@template county_picker_preview}
/// CountryFormPreview widget.
/// {@endtemplate}
class CountryFormPreview extends StatefulWidget {
  /// {@macro county_picker_preview}
  const CountryFormPreview({super.key});

  @override
  State<CountryFormPreview> createState() => _CountryPickerPreviewState();
}

/// State for [CountryFormPreview].
class _CountryPickerPreviewState extends State<CountryFormPreview> {
  final TextEditingController _controller = TextEditingController();

  String _country = '🇷🇺 Россия'; // ignore: unused_field
  String _countryCode = '7'; // ignore: prefer_final_fields
  String _countryFlag = '🇷🇺'; // ignore: prefer_final_fields
  String? _mask = '000 000 0000'; // ignore: unused_field

  String? get _completedPhoneNumber =>
      '+$_countryCode${_controller.text.replaceAll(" ", "")}';

  void _onSelect(Country country) {
    l.i('Selected country $country');
    setState(() {
      _country = '${country.flagEmoji} ${country.nameLocalized}';
      _countryCode = country.phoneCode;
      _countryFlag = country.flagEmoji;
      _mask = country.mask;
    });
  }

  void _onSubmit() {
    HapticFeedback.heavyImpact().ignore();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        backgroundColor: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGreen,
          context,
        ),
        content: Text(
          'PHONE: $_completedPhoneNumber',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: CupertinoColors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CommonHeader('Country Form Preview'),
        body: LayoutBuilder(
          builder: (context, constraints) => SafeArea(
            child: Padding(
              padding: CommonPadding.of(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Country phone input --- //
                  CountryPhoneInput(
                    countryCode: _countryCode,
                    countryFlag: _countryFlag,
                    filter: kFilteredCountries,
                    onSelect: _onSelect,
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
                            hintText: 'Password',
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
                      onPressed: _onSubmit,
                      child: const Text('Submit'),
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
        ),
      );
}
