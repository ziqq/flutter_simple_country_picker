// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:l/l.dart';

/// CountryPickerPreviewStateMixin.
///
/// {@macro county_picker_form_preview}
mixin CountryPickerPreviewStateMixin<T extends StatefulWidget> on State<T> {
  /// Phone controller
  final TextEditingController controller = TextEditingController();

  /// Selected country
  final ValueNotifier<Country?> selected = ValueNotifier(null);

  /// Selected country name
  String country = 'Россия';

  /// Selected country code
  String countryCode = '7';

  /// Selected country flag
  String countryFlag = '🇷🇺';

  /// Selected country mask
  String? mask = '000 000 0000';

  /// Completed phone number
  String? get completedPhoneNumber =>
      '+$countryCode${controller.text.replaceAll(" ", "")}';

  @override
  void dispose() {
    controller.dispose();
    selected.dispose();
    super.dispose();
  }

  /// Select the country.
  void onSelect(Country newCountry) {
    l.i('Selected country $country');
    selected.value = newCountry;
    setState(() {
      country = '${newCountry.flagEmoji} ${newCountry.nameLocalized}';
      countryCode = newCountry.phoneCode;
      countryFlag = newCountry.flagEmoji;
      mask = newCountry.mask;
    });
    l
      ..i('country: $country')
      ..i('countryCode: $countryCode')
      ..i('countryFlag: $countryFlag')
      ..i('mask: $mask');
  }

  /// Submit the form.
  void onSubmit() {
    HapticFeedback.heavyImpact().ignore();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        backgroundColor: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGreen,
          context,
        ),
        content: Text(
          'PHONE: $completedPhoneNumber',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: CupertinoColors.white),
        ),
      ),
    );
  }
}
