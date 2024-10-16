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
  late final TextEditingController controller;

  /// Selected country
  late final ValueNotifier<Country> selected;

  /// Country input formater
  late final CountryInputFormatter formater;

  ScaffoldMessengerState? _messenger;

  /// Selected country
  Country get _selectedCountry => selected.value;

  /// Completed phone number
  String? get completedPhoneNumber =>
      '+${_selectedCountry.countryCode}${controller.text.replaceAll(" ", "")}';

  @override
  void initState() {
    super.initState();
    final initialCountry = Country.mock();

    controller = TextEditingController();
    controller.addListener(_onPhoneChanged);

    selected = ValueNotifier(initialCountry);
    selected.addListener(_onSelectedChanged);

    formater = CountryInputFormatter(mask: initialCountry.mask);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    controller
      ..removeListener(_onPhoneChanged)
      ..dispose();
    selected
      ..removeListener(_onSelectedChanged)
      ..dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (!mounted) return;
    final phone = '+${selected.value.phoneCode} ${controller.text}';
    l.d('phone: $phone');
    // widget.controller?.value = phone;
  }

  void _onSelectedChanged() {
    if (!mounted) return;

    // Check if the mask is present
    final mask = selected.value.mask;
    if (mask == null || mask.isEmpty) return;

    // Update the formatter mask
    formater.updateMask(mask: mask);

    // Format the current text in the controller after changing the mask
    final oldValue = controller.value;
    controller.text = formater.maskText(controller.text);
    formater.formatEditUpdate(oldValue, controller.value);
  }

  /// Select the country.
  void onSelect(Country newCountry) {
    l.d('Selected country $newCountry');
    controller.clear();
    selected.value = newCountry;
  }

  /// Submit the form.
  void onSubmit({String? phone}) {
    HapticFeedback.heavyImpact().ignore();
    _messenger
      ?..clearSnackBars()
      ..showSnackBar(
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
