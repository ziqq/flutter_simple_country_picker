// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'package:collection/collection.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/src/common/constant/fonts.gen.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:example/src/common/theme/styles.dart';
import 'package:example/src/common/util/app_zone.dart';
import 'package:example/src/common/util/country_picker_state_mixin.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:example/src/common/widget/common_app_bar.dart';
import 'package:example/src/common/widget/common_logo.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Launches the Web picker preview.
void main() => appZone(() async => runApp(const App(home: WebPreview())));

/// {@template county_picker_web_preview}
/// Demonstrates a country drop-down and a manually formatted phone field.
///
/// The drop-down reads the available countries from [CountryScope].
/// {@endtemplate}
class WebPreview extends StatefulWidget {
  /// {@macro county_picker_web_preview}
  const WebPreview({super.key});

  /// Title of the widget.
  static String title = 'Web';

  @override
  State<WebPreview> createState() => _WebPreviewState();
}

/// State for widget [WebPreview].
class _WebPreviewState extends State<WebPreview>
    with CountryPickerPreviewStateMixin {
  @override
  Widget build(BuildContext context) {
    final localization = ExampleLocalization.of(context);
    final pickerTheme = CountryPickerTheme.of(context);
    return Scaffold(
      backgroundColor: AppStyles.of(context).backgroundColor,
      appBar: CommonAppBar(
        title: WebPreview.title,
        backgroundColor: AppStyles.of(context).backgroundColor,
      ),
      body: Padding(
        padding: CommonPadding.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),

            const CommonLogo.text(),
            SizedBox(height: pickerTheme.padding * 2),

            CountryPicker$Web(onSelect: onSelect, selected: selected),
            SizedBox(height: pickerTheme.padding),

            CountryInput$Web(
              inputFormatters: [formater],
              controller: controller,
              selected: selected,
            ),
            SizedBox(height: pickerTheme.padding),

            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                child: Text(localization.nextLable),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// {@template country_input_desktop}
/// CountryInput$Web widget.
/// {@endtemplate}
class CountryInput$Web extends StatelessWidget {
  /// {@macro country_input_desktop}
  const CountryInput$Web({
    required this.selected,
    this.controller,
    this.inputFormatters,
    super.key, // ignore: unused_element
  });

  /// Selected country.
  final ValueNotifier<Country> selected;

  /// Controller for the phone number input field.
  final TextEditingController? controller;

  /// Input formatters for the phone number input field.
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final textStyle = textTheme.bodyLarge;
    final secondaryTextStyle = textStyle?.copyWith(
      fontSize: 14,
      color: CupertinoDynamicColor.resolve(
        CupertinoColors.secondaryLabel,
        context,
      ),
    );
    final defaultBorder = OutlineInputBorder(
      borderRadius: .circular(10),
      borderSide: BorderSide(
        width: 1,
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.separator,
          context,
        ),
      ),
    );
    final pickerTheme = CountryPickerTheme.of(context);
    return ValueListenableBuilder(
      valueListenable: selected,
      builder: (context, selectedCountry, _) => TextFormField(
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelStyle: secondaryTextStyle?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          border: defaultBorder,
          enabledBorder: defaultBorder,
          focusedBorder: defaultBorder.copyWith(
            borderSide: defaultBorder.borderSide.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          label: Text(
            'CountryLocalizations.of(context).phonePlaceholder',
            style: secondaryTextStyle?.copyWith(fontSize: 16),
          ),
          prefix: Text('+${selectedCountry.phoneCode} ', style: textStyle),
          hintText: selectedCountry.mask,
          hintStyle: textStyle?.copyWith(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondaryLabel,
              context,
            ),
          ),
          contentPadding: .symmetric(horizontal: pickerTheme.padding),
        ),
      ),
    );
  }
}

/// {@template county_input}
/// CountryPicker$Web widget.
/// {@endtemplate}
class CountryPicker$Web extends StatefulWidget {
  /// {@macro county_input}
  const CountryPicker$Web({this.onSelect, this.selected, super.key});

  /// Called when the user chooses a country.
  final SelectCountryCallback? onSelect;

  /// Notifies the control when the current selection changes.
  final SelectedCountry? selected;

  @override
  State<CountryPicker$Web> createState() => _CountryPicker$DesktopState();
}

/// State for widget [CountryPicker$Web].
class _CountryPicker$DesktopState extends State<CountryPicker$Web> {
  /// Uses the bundled emoji font when running this preview in a browser.
  final String? _fontFamily = kIsWeb ? FontFamily.notoColorEmoji : null;

  @override
  Widget build(BuildContext context) {
    final localizations = CountryLocalizations.of(context);
    final pickerTheme = CountryPickerTheme.of(context);
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge?.copyWith(fontSize: 14);
    final secondaryTextStyle = textStyle?.copyWith(
      color: CupertinoDynamicColor.resolve(
        CupertinoColors.secondaryLabel,
        context,
      ),
    );
    final defaultBorder = OutlineInputBorder(
      borderRadius: .circular(10),
      borderSide: BorderSide(
        width: 1,
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.separator,
          context,
        ),
      ),
    );

    Widget scope({
      required Widget Function(BuildContext context, CountryState state)
      builder,
    }) => CountryScope(
      child: Builder(
        builder: (context) => ValueListenableBuilder(
          valueListenable: CountryScope.of(context),
          builder: (context, state, _) {
            if (state.isLoading || state.countries.isEmpty) {
              return const Center(
                child: SizedBox(
                  height: 44,
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }
            return builder(context, state);
          },
        ),
      ),
    );

    return scope(
      builder: (context, state) => ValueListenableBuilder(
        valueListenable: widget.selected ?? ValueNotifier(null),
        builder: (context, selected, _) {
          final localization = CountryLocalizations.of(context);
          final $selected =
              selected ??
              state.countries.firstWhereOrNull(
                (e) =>
                    e.name == localizations.getCountryNameByCode(e.countryCode),
              ) ??
              state.countries[0];

          return DropdownMenu(
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: secondaryTextStyle?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              border: defaultBorder,
              enabledBorder: defaultBorder,
              focusedBorder: defaultBorder.copyWith(
                borderSide: defaultBorder.borderSide.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              contentPadding: .symmetric(horizontal: pickerTheme.padding),
            ),
            menuHeight: MediaQuery.of(context).size.height * 0.4,
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (_) => Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF212121)
                    : null,
              ),
              elevation: WidgetStateProperty.resolveWith<double?>((_) => 6),
              shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
                (_) => const RoundedRectangleBorder(
                  borderRadius: .vertical(bottom: Radius.circular(10)),
                ),
              ),
            ),
            trailingIcon: Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: pickerTheme.searchTextStyle?.color?.withValues(alpha: .5),
            ),
            label: const Text('Country'),
            initialSelection: $selected,
            dropdownMenuEntries: state.countries
                .map((e) {
                  final label = localization.getFormatedCountryNameByCode(
                    e.countryCode,
                  );
                  return DropdownMenuEntry(
                    value: e,
                    label: label.toString(),
                    trailingIcon: Text(
                      '+${e.phoneCode}',
                      style: secondaryTextStyle,
                    ),
                    leadingIcon: Text(
                      e.flagEmoji,
                      style: textStyle?.copyWith(fontFamily: _fontFamily),
                    ),
                  );
                })
                .toList(growable: false),
            onSelected: (country) {
              if (country == null) return;
              widget.onSelect?.call(country);
            },
          );
        },
      ),
    );
  }
}
