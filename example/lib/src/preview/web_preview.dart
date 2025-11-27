// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'package:collection/collection.dart';
import 'package:example/src/common/constant/constants.dart';
import 'package:example/src/common/constant/fonts.gen.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:example/src/common/theme/styles.dart';
import 'package:example/src/common/util/app_zone.dart';
import 'package:example/src/common/util/country_picker_state_mixin.dart';
import 'package:example/src/common/widget/app.dart';
import 'package:example/src/common/widget/common_app_bar.dart';
import 'package:example/src/common/widget/common_logo.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

void main() => appZone(() async => runApp(const App(home: WebPreview())));

/// {@template county_picker_web_preview}
/// WebPreview widget.
///
/// This widget is showed another way how to use [CountryPicker].
///
/// You can use [CountryPickerScope] widget to give a list of countries
/// and use countries list how you want.
///
/// And more you can use search controller from [CountryPickerScope]
/// to find a country by name or code.
/// {@endtemplate}
class WebPreview extends StatefulWidget {
  /// {@macro county_picker_web_preview}
  const WebPreview({super.key});

  /// Title of the widget.
  static const String title = 'Web';

  @override
  State<WebPreview> createState() => _WebPreviewState();
}

/// State for widget [WebPreview].
class _WebPreviewState extends State<WebPreview>
    with CountryPickerPreviewStateMixin {
  @override
  Widget build(BuildContext context) {
    final localization = ExampleLocalization.of(context);
    // final mediaQuery = MediaQuery.of(context);
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

            // --- Logo --- //
            const CommonLogo.text(),
            const SizedBox(height: kDefaultPadding * 2),

            // --- Country picker --- //
            CountryPicker$Web(onSelect: onSelect, selected: selected),
            const SizedBox(height: kDefaultPadding),

            // --- Country phone number input --- //
            CountryInput$Web(
              inputFormatters: [formater],
              controller: controller,
              selected: selected,
            ),
            const SizedBox(height: kDefaultPadding),

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

  /// Controller for the phone number input field.
  final TextEditingController? controller;

  /// Input formatters for the phone number input field.
  final List<TextInputFormatter>? inputFormatters;

  /// Selected country.
  final ValueNotifier<Country> selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final textStyle = textTheme.bodyLarge;
    final secodaryTextStyle = textStyle?.copyWith(
      fontSize: 14,
      color: CupertinoDynamicColor.resolve(
        CupertinoColors.secondaryLabel,
        context,
      ),
    );
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        width: 1,
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.separator,
          context,
        ),
      ),
    );
    return ValueListenableBuilder(
      valueListenable: selected,
      builder: (context, selectedCountry, _) => TextFormField(
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelStyle: secodaryTextStyle?.copyWith(
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
            style: secodaryTextStyle?.copyWith(fontSize: 16),
          ),
          prefix: Text('+${selectedCountry.phoneCode} ', style: textStyle),
          hintText: selectedCountry.mask,
          hintStyle: textStyle?.copyWith(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondaryLabel,
              context,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding,
          ),
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
  const CountryPicker$Web({
    this.placeholder = 'Phone number',
    this.onDone,
    this.onSelect,
    this.selected,
    this.exclude,
    this.favorite,
    this.filter,
    this.isScrollControlled = false,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.useAutofocus = false,
    this.useHaptickFeedback = true,
    this.showSearch,
    super.key,
  });

  /// Placeholder text.
  final String? placeholder;

  /// Called when the country was selected.
  final VoidCallback? onDone;

  /// {@macro select_country_callback}
  final SelectCountryCallback? onSelect;

  /// {@macro select_country_notifier}
  final SelectedCountry? selected;

  /// List of country codes to exclude.
  final List<String>? exclude;

  /// List of favorite country codes.
  final List<String>? favorite;

  /// List of filtered country codes.
  final List<String>? filter;

  /// Controls the scrolling behavior of the modal window.
  final bool isScrollControlled;

  /// Show phone code in countires list.
  final bool showPhoneCode;

  /// Show "World Wide" in countires list.
  final bool showWorldWide;

  /// Show countryies search bar?
  final bool? showSearch;

  /// Use autofocus for the search countryies input field.
  final bool useAutofocus;

  /// Use haptic feedback?
  final bool useHaptickFeedback;

  @override
  State<CountryPicker$Web> createState() => _CountryPicker$DesktopState();
}

/// State for widget [CountryPicker$Web].
class _CountryPicker$DesktopState extends State<CountryPicker$Web> {
  // Fix displaing emoji flag for web.
  final String? _fontFamily = kIsWeb ? FontFamily.notoColorEmoji : null;

  @override
  Widget build(BuildContext context) {
    // final isRtl = Directionality.of(context) == TextDirection.rtl;
    final localizations = CountryLocalizations.of(context);
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge?.copyWith(fontSize: 14);
    final secodaryTextStyle = textStyle?.copyWith(
      color: CupertinoDynamicColor.resolve(
        CupertinoColors.secondaryLabel,
        context,
      ),
    );
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
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
                    e.name ==
                    localizations?.getCountryNameByCode(e.countryCode),
              ) ??
              state.countries[0];

          return DropdownMenu(
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: secodaryTextStyle?.copyWith(
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
              ),
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
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
              ),
            ),
            trailingIcon: Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.placeholderText,
                context,
              ),
            ),
            label: const Text('Country'),
            initialSelection: $selected,
            dropdownMenuEntries: state.countries
                .map((e) {
                  final label = localization
                      ?.getCountryNameByCode(e.countryCode)
                      ?.replaceAll(CountryLocalizations.countryNameRegExp, ' ');
                  return DropdownMenuEntry(
                    value: e,
                    label: label.toString(),
                    trailingIcon: Text(
                      '+${e.phoneCode}',
                      style: secodaryTextStyle,
                    ),
                    leadingIcon: Text(
                      e.flagEmoji,
                      style: textStyle?.copyWith(fontFamily: _fontFamily),
                    ),
                    // onTap: () => widget.onSelect?.call(e),
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
