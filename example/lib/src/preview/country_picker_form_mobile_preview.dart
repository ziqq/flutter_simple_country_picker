import 'package:example/src/common/constant/constants.dart';
import 'package:example/src/common/util/country_picker_state_mixin.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

/// {@template country_picker_mobile_preview}
/// CountryPickerForm$MobilePreview widget.
/// {@endtemplate}
class CountryPickerForm$MobilePreview extends StatelessWidget {
  /// {@macro country_picker_mobile_preview}
  const CountryPickerForm$MobilePreview({
    super.key, // ignore: unused_element
  });

  /// Title of the widget.
  static const String title = 'Mobile';

  @override
  Widget build(BuildContext context) => const _Mobile();
}

/// {@template county_picker_form_preview}
/// _Mobile widget.
/// {@endtemplate}
class _Mobile extends StatefulWidget {
  /// {@macro county_picker_form_preview}
  const _Mobile({
    super.key, // ignore: unused_element
  });

  @override
  State<_Mobile> createState() => _MobileState();
}

/// State for widget [_Mobile].
class _MobileState extends State<_Mobile> with CountryPickerPreviewStateMixin {
  @override
  Widget build(BuildContext context) => Padding(
        padding: CommonPadding.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mobile',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kDefaultPadding),
            Text(
              'Проверьте код страны и введите свой номер телефона.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel,
                      context,
                    ),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kDefaultPadding * 2),

            // --- Country phone input --- //
            CountryPhoneInput(
              filter: kFilteredCountries,
              onSelect: onSelect,
              selected: selected,
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
                onPressed: onSubmit,
                child: const Text('Submit'),
              ),
            ),

            // --- Withe space --- //
            const _WhiteSpaceBox(),
          ],
        ),
      );
}

/// {@template county_picker_form_preview}
/// _WhiteSpaceBox widget.
/// {@endtemplate}
class _WhiteSpaceBox extends StatelessWidget {
  /// {@macro county_picker_form_preview}
  const _WhiteSpaceBox({
    super.key, // ignore: unused_element
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).viewPadding.bottom == 0)
      return const SizedBox(height: kToolbarHeight);
    else
      return const SizedBox(height: kDefaultPadding);
  }
}
