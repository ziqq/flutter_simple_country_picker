// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

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
  String? _phone = '+7 888 123 4567'; // ignore: prefer_final_fields

  /// Phone controller
  late final TextEditingController controller;

  /// Country input formater
  late final CountryInputFormatter formater;

  /// Selected country
  late ValueNotifier<Country> selected;

  /// Snackbar manager
  ScaffoldMessengerState? _messenger;

  /// Selected country
  Country get _selectedCountry => selected.value;

  /// Completed phone number
  String? get completedPhoneNumber =>
      '+${_selectedCountry.phoneCode}${controller.text.replaceAll(" ", "")}';

  @override
  void initState() {
    super.initState();
    final initialCountry = Country.mock();

    controller = TextEditingController();
    controller.addListener(_onPhoneChanged);

    formater = CountryInputFormatter(
      mask: initialCountry.mask,
      filter: {'0': RegExp('[0-9]')},
    );

    selected = ValueNotifier(initialCountry);
    selected.addListener(_onSelectedChanged);

    // If the controller has an initial value
    if (_phone != null && _phone!.isNotEmpty) {
      final oldValue = controller.value;
      var text = _phone ?? '';

      // Check if the phone code is not removed from the text
      if (text.startsWith('+')) {
        text = text.replaceFirst('+${selected.value.phoneCode} ', '');
      }

      controller.text = formater.maskText(text);

      // Apply formatting to the new value
      formater.formatEditUpdate(oldValue, controller.value);

      // Update the cursor position
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
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
    if (controller.text == formater.getMaskedText()) return;
    final phone = '+${selected.value.phoneCode} ${controller.text}';
    dev.log('phone: $phone');
    // Update the external controller if it is present
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
    dev.log('Selected country $newCountry');
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
