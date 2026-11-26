/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 14 October 2024
 */

// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'dart:developer' as dev;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Owns the phone text, manual formatter, and country selection for previews.
mixin CountryPickerPreviewStateMixin<T extends StatefulWidget> on State<T> {
  /// The sample international number used by the manual formatter previews.
  static const String _phone = '+7 888 123 4567';

  /// The controller used by previews built with [CountryPhoneInput].
  final countryPhoneController = CountryPhoneController.empty();

  /// The text controller used by standalone phone fields.
  late final TextEditingController controller;

  /// Applies the selected country's manual mask to standalone phone fields.
  late final CountryInputFormatter formater;

  /// The country selected in the preview.
  late ValueNotifier<Country> selected;

  ScaffoldMessengerState? _messenger;

  @override
  void initState() {
    super.initState();
    final initialCountry = Country.ru();

    controller = TextEditingController();
    controller.addListener(_onPhoneChanged);

    formater = CountryInputFormatter(
      mask: initialCountry.mask,
      filter: {'0': RegExp('[0-9]')},
    );

    selected = ValueNotifier(initialCountry);
    selected.addListener(_onSelectedChanged);

    final oldValue = controller.value;
    // The country selector displays the dialing code separately.
    final nationalNumber = _phone.replaceFirst(
      '+${selected.value.phoneCode} ',
      '',
    );
    controller.text = formater.maskText(nationalNumber);
    formater.formatEditUpdate(oldValue, controller.value);
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    countryPhoneController.dispose();
    controller
      ..removeListener(_onPhoneChanged)
      ..dispose();
    selected
      ..removeListener(_onSelectedChanged)
      ..dispose();
    super.dispose();
  }

  /// Clears the number before changing to [newCountry].
  void onSelect(Country newCountry) {
    dev.log('Selected country $newCountry');
    controller.clear();
    selected.value = newCountry;
  }

  /// Shows the number in a snackbar as a demonstration of form submission.
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
            'PHONE: ${phone ?? countryPhoneController.text}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: CupertinoColors.white),
          ),
        ),
      );
  }

  void _onPhoneChanged() {
    if (!mounted) return;
    if (controller.text == formater.getMaskedText()) return;
    final phone = '+${selected.value.phoneCode} ${controller.text}';
    dev.log('phone: $phone');
  }

  void _onSelectedChanged() {
    if (!mounted) return;

    // Keep the current format when the new country supplies no manual mask.
    final mask = selected.value.mask;
    if (mask == null || mask.isEmpty) return;

    formater.updateMask(mask: mask);

    // Reformat the existing text with the new country’s mask.
    final oldValue = controller.value;
    controller.text = formater.maskText(controller.text);
    formater.formatEditUpdate(oldValue, controller.value);
  }
}
