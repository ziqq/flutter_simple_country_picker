// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'package:collection/collection.dart';
import 'package:example/src/common/constant/constants.dart';
import 'package:example/src/common/constant/fonts.gen.dart';
import 'package:example/src/common/localization/generated/l10n.dart';
import 'package:example/src/common/util/country_picker_state_mixin.dart';
import 'package:example/src/common/widget/common_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// Default height for [CountryPickerDesktop].
const double _kDefaultCountyInputHeight = 44;

/// {@template county_picker_desktop_preview}
/// CountryPickerForm$DesktopPreview widget.
///
/// This widget is showed another way how to use [CountryPicker].
///
/// You can use [CountryPickerScope] widget to give a list of countries
/// and use countries list how you want.
///
/// And more you can use search controller from [CountryPickerScope]
/// to find a country by name or code.
/// {@endtemplate}
class CountryPickerForm$DesktopPreview extends StatefulWidget {
  /// {@macro county_picker_desktop_preview}
  const CountryPickerForm$DesktopPreview({
    super.key, // ignore: unused_element
  });

  /// Title of the widget.
  static const String title = 'Destop';

  @override
  State<CountryPickerForm$DesktopPreview> createState() =>
      _CountryPickerForm$DesktopPreviewState();
}

/// State for widget [CountryPickerForm$DesktopPreview].
class _CountryPickerForm$DesktopPreviewState
    extends State<CountryPickerForm$DesktopPreview>
    with CountryPickerPreviewStateMixin {
  @override
  Widget build(BuildContext context) {
    final localization = ExampleLocalization.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: CommonPadding.of(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 38,
            child: ClipOval(
              child: Image.asset(
                'assets/icons/icon-1024x1024.jpg',
                width: 100,
                height: 100,
              ),
            ),
          ),
          const SizedBox(height: kDefaultPadding),
          Text(
            localization.title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kDefaultPadding),
          Text(
            localization.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondaryLabel,
                context,
              ),
            ),
            textAlign: TextAlign.center,
          ),
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
                CountryPickerDesktop(
                  onSelect: onSelect,
                  selected: selected,
                ),
                CountryInputDesktop(
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// {@template country_input_desktop}
/// CountryInputDesktop widget.
/// {@endtemplate}
class CountryInputDesktop extends StatelessWidget {
  /// {@macro country_input_desktop}
  const CountryInputDesktop({
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
                keyboardType: TextInputType.phone,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// {@template county_input}
/// CountryInput widget.
/// {@endtemplate}
class CountryPickerDesktop extends StatefulWidget {
  /// {@macro county_input}
  const CountryPickerDesktop({
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
  State<CountryPickerDesktop> createState() => _CountryPickerDesktopState();
}

/// State for widget [CountryPickerDesktop].
class _CountryPickerDesktopState extends State<CountryPickerDesktop> {
  // Fix corrent emoji flag for web.
  final String? _effectiveFontFamily =
      kIsWeb ? FontFamily.notoColorEmoji : null;

  List<PullDownMenuItem> _itemBuilder(
    List<Country> countries, [
    Country? selected,
  ]) {
    final localization = CountriesLocalization.of(context);
    final itemTheme = PullDownMenuItemTheme(
      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
    );
    return countries.map((e) {
      final title = localization
          .getCountryNameByCode(e.countryCode)
          ?.replaceAll(CountriesLocalization.countryNameRegExp, ' ');
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
    }).toList(growable: false);
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
    final localizations = CountriesLocalization.of(context);

    Widget scope({
      required Widget Function(
        BuildContext context,
        CountriesState state,
      ) builder,
    }) =>
        CountriesScope(
          child: Builder(
            builder: (context) => ValueListenableBuilder(
              valueListenable: CountriesScope.of(context),
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
          final $selected = selected ??
              state.countries.firstWhereOrNull((e) =>
                  e.name ==
                  localizations.getCountryNameByCode(e.countryCode)) ??
              state.countries[0];

          return PullDownButton(
            menuOffset: kDefaultPadding,
            itemBuilder: (_) => _itemBuilder(state.countries, $selected),
            buttonBuilder: (_, showMenu) => _buttonBuilder(
              context,
              showMenu,
              $selected,
            ),
          );
        },
      ),
    );
  }
}
