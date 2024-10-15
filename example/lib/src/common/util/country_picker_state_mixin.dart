// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:l/l.dart';

/// CountryPickerPreviewStateMixin.
///
/// Provide:
///
/// - [controller] - phone controller.
/// - [selected] - selected country.
/// - [country] - selected country name.
/// - [countryCode] - selected country code.
/// - [countryFlag] - selected country flag.
/// - [mask] - selected country mask.
/// - [completedPhoneNumber] - completed phone number.
/// - [onSelect] - select the country.
/// - [onSubmit] - submit the form.
///
/// {@macro county_picker_form_preview}
mixin CountryPickerPreviewStateMixin<T extends StatefulWidget> on State<T> {
  /// Phone controller
  final TextEditingController controller = TextEditingController();

  /// Selected country
  final ValueNotifier<Country> selected = ValueNotifier(Country.mock());

  /// Selected country
  Country get _selectedCountry => selected.value;

  /// Country input formater
  late final CountryInputFormater formater;

  /// Completed phone number
  String? get completedPhoneNumber =>
      '+${_selectedCountry.countryCode}${controller.text.replaceAll(" ", "")}';

  @override
  void initState() {
    super.initState();
    formater = CountryInputFormater(
      mask: _selectedCountry.mask,
      filter: {'0': RegExp('[0-9]')},
    );
  }

  @override
  void dispose() {
    controller.dispose();
    selected.dispose();
    super.dispose();
  }

  /// Select the country.
  void onSelect(Country newCountry) {
    l.i('Selected country $newCountry');
    controller.clear();
    selected.value = newCountry;
    formater.updateMask(mask: newCountry.mask);
    setState(() {
      // country = '${newCountry.flagEmoji} ${newCountry.nameLocalized}';
      // countryCode = newCountry.phoneCode;
      // countryFlag = newCountry.flagEmoji;
      // mask = newCountry.mask;
    });
  }

  /// Submit the form.
  void onSubmit({String? phone}) {
    HapticFeedback.heavyImpact().ignore();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        backgroundColor: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGreen,
          context,
        ),
        content: Text(
          'PHONE: ${phone ?? completedPhoneNumber}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: CupertinoColors.white),
        ),
      ),
    );
  }
}
