// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'package:collection/collection.dart';
import 'package:example/src/common/constant/constants.dart';
import 'package:example/src/common/constant/fonts.gen.dart';
import 'package:example/src/common/localization/localization.dart';
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
import 'package:pull_down_button/pull_down_button.dart';

/// Default height for [CountryPicker] for macOS.
const double _kDefaultCountyInputHeight = 44;

void main() => appZone(() async => runApp(const App(home: MacOSPreview())));

/// {@template county_picker_macos_preview}
/// MacOSPreview widget.
///
/// This widget is showed another way how to use [CountryPicker] in macOS.
///
/// You can use [CountryPickerScope] widget to give a list of countries
/// and use countries list how you want.
///
/// And more you can use search controller from [CountryPickerScope]
/// to find a country by name or code.
/// {@endtemplate}
class MacOSPreview extends StatefulWidget {
  /// {@macro county_picker_macos_preview}
  const MacOSPreview({
    super.key, // ignore: unused_element
  });

  /// Title of the widget.
  static const String title = 'macOS';

  @override
  State<MacOSPreview> createState() => _MacOSPreviewState();
}

/// State for widget [MacOSPreview].
class _MacOSPreviewState extends State<MacOSPreview>
    with CountryPickerPreviewStateMixin {
  @override
  Widget build(BuildContext context) {
    final localization = ExampleLocalization.of(context);
    return Scaffold(
      appBar: const CommonAppBar(title: MacOSPreview.title),
      body: Padding(
        padding: CommonPadding.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Logo --- //
            const CommonLogo.text(),
            const SizedBox(height: kDefaultPadding * 2),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: CupertinoListSection.insetGrouped(
                margin: EdgeInsets.zero,
                additionalDividerMargin: 0,
                backgroundColor: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondarySystemBackground,
                  context,
                ),
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondarySystemBackground,
                    context,
                  ),
                ),
                children: [
                  CountryPicker$MacOS(onSelect: onSelect, selected: selected),
                  CountryInput$MacOS(
                    controller: controller,
                    inputFormatters: [formater],
                    selected: selected,
                  ),
                ],
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            SizedBox(
              height: 32,
              width: 100,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBlue,
                  context,
                ),
                onPressed: onSubmit,
                child: Text(
                  localization.nextLable,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CountryInput$MacOS widget.
/// {@macro county_picker_macos}
class CountryInput$MacOS extends StatelessWidget {
  /// {@macro country_input_macos}
  const CountryInput$MacOS({
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
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: ValueListenableBuilder(
        valueListenable: selected,
        builder: (context, selectedCountry, _) => CupertinoFormRow(
          prefix: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '+${selectedCountry.phoneCode}',
              style: textTheme.bodyLarge?.copyWith(height: 1),
            ),
          ),
          padding: const EdgeInsets.only(
            left: kDefaultPadding,
            right: kDefaultPadding / 1.5,
          ),
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: CupertinoTextField(
                controller: controller,
                inputFormatters: inputFormatters,
                placeholder: selectedCountry.mask,
                style: textTheme.bodyLarge,
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CountryPicker$MacOS widget.
/// {@macro county_picker_macos}
class CountryPicker$MacOS extends StatefulWidget {
  /// {@macro county_picker_macos}
  const CountryPicker$MacOS({
    this.placeholder = 'Phone number', // ignore: unused_element
    this.onDone, // ignore: unused_element
    this.onSelect,
    this.selected,
    this.exclude, // ignore: unused_element
    this.favorite, // ignore: unused_element
    this.filter, // ignore: unused_element
    this.isScrollControlled = false, // ignore: unused_element
    this.showPhoneCode = false, // ignore: unused_element
    this.showWorldWide = false, // ignore: unused_element
    this.useAutofocus = false, // ignore: unused_element
    this.useHaptickFeedback = true, // ignore: unused_element
    this.showSearch, // ignore: unused_element
    super.key, // ignore: unused_element
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
  State<CountryPicker$MacOS> createState() => _CountryPicker$MacOSState();
}

/// State for widget [CountryPicker$MacOS].
class _CountryPicker$MacOSState extends State<CountryPicker$MacOS> {
  // Fix corrent emoji flag for web.
  final String? _effectiveFontFamily = kIsWeb
      ? FontFamily.notoColorEmoji
      : null;

  List<PullDownMenuItem> _itemBuilder(
    List<Country> countries, [
    Country? selected,
  ]) {
    final localization = CountryLocalizations.of(context);
    final itemTheme = PullDownMenuItemTheme(
      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
    );
    return countries
        .map((e) {
          final title = localization
              ?.getCountryNameByCode(e.countryCode)
              ?.replaceAll(CountryLocalizations.countryNameRegExp, ' ');
          return PullDownMenuItem(
            itemTheme: itemTheme,
            iconWidget: Text(
              e.flagEmoji,
              style: itemTheme.textStyle?.copyWith(
                fontSize: 14,
                fontFamily: _effectiveFontFamily,
              ),
            ),
            title: '$title +${e.phoneCode}',
            onTap: () => widget.onSelect?.call(e),
          );
        })
        .toList(growable: false);
  }

  Widget _buttonBuilder(
    BuildContext context,
    Future<void> Function() showMenu,
    Country selected,
  ) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return GestureDetector(
      onTap: showMenu,
      child: ColoredBox(
        color: Colors.transparent,
        child: CupertinoFormRow(
          prefix: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              selected.flagEmoji,
              style: textStyle?.copyWith(
                height: 1.6,
                fontSize: 14,
                fontFamily: _effectiveFontFamily,
              ),
            ),
          ),
          padding: const EdgeInsets.only(
            left: kDefaultPadding,
            right: kDefaultPadding / 1.5,
          ),
          child: SizedBox(
            height: _kDefaultCountyInputHeight,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selected.name,
                      style: textStyle?.copyWith(height: 1),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: Theme.of(context).textTheme.bodyMedium?.fontSize,
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.inactiveGray,
                      context,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final isRtl = Directionality.of(context) == TextDirection.rtl;
    final localizations = CountryLocalizations.of(context);

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
        valueListenable: widget.selected ?? ValueNotifier<Country?>(null),
        builder: (context, selected, _) {
          final $selected =
              selected ??
              state.countries.firstWhereOrNull(
                (e) =>
                    e.name ==
                    localizations?.getCountryNameByCode(e.countryCode),
              ) ??
              state.countries[0];

          return PullDownButton(
            menuOffset: kDefaultPadding,
            itemBuilder: (_) => _itemBuilder(state.countries, $selected),
            buttonBuilder: (_, showMenu) =>
                _buttonBuilder(context, showMenu, $selected),
          );
        },
      ),
    );
  }
}
