// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'dart:math' as math;

import 'package:collection/collection.dart';
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

/// Default height for [CountryPicker] for macOS.
const double _kDefaultCountyInputHeight = 44;
const double _kCountryMenuMaxHeight = 220;

Color _cardFieldColor(BuildContext context) =>
    CupertinoTheme.brightnessOf(context) == Brightness.light
    ? const Color(0xFFF7F8FA)
    : CupertinoColors.tertiarySystemBackground.resolveFrom(context);

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
  bool _showCard = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor:
        _showCard && CupertinoTheme.brightnessOf(context) == Brightness.light
        ? const Color(0xFFF1F3F6)
        : null,
    appBar: const CommonAppBar(title: MacOSPreview.title),
    body: Padding(
      padding: _showCard
          ? const EdgeInsets.symmetric(horizontal: 16)
          : CommonPadding.of(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: CupertinoSlidingSegmentedControl<bool>(
              groupValue: _showCard,
              children: const {false: Text('Grouped'), true: Text('Card')},
              onValueChanged: (value) {
                if (value == null) return;
                setState(() => _showCard = value);
              },
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: _showCard
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: _CardPhoneForm(
                              onSubmit: (phone) => onSubmit(phone: phone),
                            ),
                          )
                        : _buildGroupedForm(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildGroupedForm(BuildContext context) {
    final localization = ExampleLocalization.of(context);
    final pickerTheme = CountryPickerTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- Logo --- //
        const CommonLogo.text(),
        SizedBox(height: pickerTheme.padding * 2),
        ClipRRect(
          borderRadius: const .all(.circular(10)),
          child: CupertinoListSection.insetGrouped(
            margin: .zero,
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
        SizedBox(height: pickerTheme.padding),
        SizedBox(
          height: 32,
          width: 100,
          child: CupertinoButton(
            padding: .zero,
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemBlue,
              context,
            ),
            onPressed: onSubmit,
            child: Text(
              localization.nextLable,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: CupertinoColors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardPhoneForm extends StatefulWidget {
  const _CardPhoneForm({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<_CardPhoneForm> createState() => _CardPhoneFormState();
}

class _CardPhoneFormState extends State<_CardPhoneForm> {
  final _selected = ValueNotifier<Country>(Country.ru());
  final _controller = TextEditingController();
  late final _formatter = CountryInputFormatter.forCountry(
    country: _selected.value,
    shouldTryStripLeadingPrefix: true,
  );
  late String? _emptyMask = _formatterHint;

  // Use the package's template in this custom example in the same repository.
  // ignore: invalid_use_of_internal_member
  String? get _formatterHint => _formatter.maskHint;

  @override
  void dispose() {
    _controller.dispose();
    _selected.dispose();
    super.dispose();
  }

  void _selectCountry(Country country) {
    if (country == _selected.value) return;
    _formatter.updateCountry(
      country,
      newValue: TextEditingValue.empty,
      shouldTryStripLeadingPrefix: true,
    );
    _controller.clear();
    _selected.value = country;
    setState(() => _emptyMask = _formatterHint);
  }

  @override
  Widget build(BuildContext context) {
    final localization = ExampleLocalization.of(context);
    final phoneLabel = CountryLocalizations.of(context).phonePlaceholder;
    final textTheme = Theme.of(context).textTheme;
    final isLight = CupertinoTheme.brightnessOf(context) == Brightness.light;
    return SizedBox(
      width: 392,
      child: Column(
        mainAxisSize: .min,
        children: [
          const CommonLogo(size: 112),
          const SizedBox(height: 20),
          Text(
            phoneLabel,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: .w700,
              height: 1.2,
            ),
            textAlign: .center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 320,
            child: Text(
              localization.description,
              style: textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
              textAlign: .center,
            ),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const .all(.circular(16)),
              color: isLight
                  ? CupertinoColors.white
                  : CupertinoColors.secondarySystemBackground.resolveFrom(
                      context,
                    ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _cardFieldColor(context),
                      borderRadius: const .all(.circular(12)),
                    ),
                    child: Column(
                      children: [
                        CountryPicker$MacOS(
                          selected: _selected,
                          onSelect: _selectCountry,
                          showSearch: true,
                          rowHeight: 53,
                          chevron: CupertinoIcons.chevron_down,
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                          color: CupertinoColors.separator.resolveFrom(context),
                        ),
                        CountryInput$MacOS(
                          controller: _controller,
                          inputFormatters: [_formatter],
                          selected: _selected,
                          placeholder: _emptyMask,
                          showCodeDivider: true,
                          rowHeight: 53,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) => CupertinoButton.filled(
                      color: CupertinoColors.systemBlue,
                      disabledColor: isLight
                          ? const Color(0xFF71ADDF)
                          : CupertinoColors.tertiarySystemFill,
                      foregroundColor: CupertinoColors.white,
                      borderRadius: const .all(.circular(24)),
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: _formatter.valueStatus.isComplete
                          ? () => widget.onSubmit(
                              '+${_selected.value.phoneCode}'
                              '${_formatter.getUnmaskedText()}',
                            )
                          : null,
                      child: child!,
                    ),
                    child: Row(
                      mainAxisSize: .min,
                      spacing: 8,
                      children: [
                        Text(localization.nextLable),
                        const Icon(CupertinoIcons.arrow_right, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    this.placeholder,
    this.showCodeDivider = false,
    this.rowHeight = _kDefaultCountyInputHeight,
    super.key, // ignore: unused_element
  });

  /// Controller for the phone number input field.
  final TextEditingController? controller;

  /// Input formatters for the phone number input field.
  final List<TextInputFormatter>? inputFormatters;

  /// Overrides the placeholder based on the selected country's mask.
  final String? placeholder;

  /// Whether to draw a separator after the calling code.
  final bool showCodeDivider;

  /// The height of the input row.
  final double rowHeight;

  /// Selected country.
  final ValueNotifier<Country> selected;

  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: const .all(.circular(10)),
      child: ValueListenableBuilder(
        valueListenable: selected,
        builder: (context, selectedCountry, _) => CupertinoFormRow(
          prefix: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: .min,
              children: [
                Text(
                  '+${selectedCountry.phoneCode}',
                  style: textTheme.bodyLarge?.copyWith(height: 1),
                ),
                if (showCodeDivider)
                  SizedBox(
                    height: 24,
                    child: VerticalDivider(color: pickerTheme.dividerColor),
                  ),
              ],
            ),
          ),
          padding: .only(
            left: pickerTheme.padding,
            right: pickerTheme.padding / 1.5,
          ),
          child: SizedBox(
            height: rowHeight,
            child: Padding(
              padding: const .only(left: 5),
              child: CupertinoTextField(
                controller: controller,
                inputFormatters: inputFormatters,
                placeholder: placeholder ?? selectedCountry.mask,
                style: textTheme.bodyLarge,
                padding: .zero,
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
    this.favorites, // ignore: unused_element
    this.filter, // ignore: unused_element
    this.isScrollControlled = false, // ignore: unused_element
    this.showPhoneCode = false, // ignore: unused_element
    this.showWorldWide = false, // ignore: unused_element
    this.useAutofocus = false, // ignore: unused_element
    this.useHapticFeedback = true, // ignore: unused_element
    this.showSearch, // ignore: unused_element
    this.rowHeight = _kDefaultCountyInputHeight,
    this.chevron = CupertinoIcons.chevron_right,
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

  /// List of favorites country codes.
  final List<String>? favorites;

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
  final bool useHapticFeedback;

  /// The height of the country row.
  final double rowHeight;

  /// The icon shown at the end of the country row.
  final IconData chevron;

  @override
  State<CountryPicker$MacOS> createState() => _CountryPicker$MacOSState();
}

/// State for widget [CountryPicker$MacOS].
class _CountryPicker$MacOSState extends State<CountryPicker$MacOS> {
  final _searchMenu = MenuController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  // Fix corrent emoji flag for web.
  final String? _effectiveFontFamily = kIsWeb
      ? FontFamily.notoColorEmoji
      : null;

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Iterable<Country> _matchingCountries(
    List<Country> countries,
    CountryLocalizations localization,
    String text,
  ) {
    final query = text.trim().toLowerCase();
    if (query.isEmpty) return countries;
    return countries.where(
      (country) =>
          country.startsWith(query, localization) ||
          country.name.toLowerCase().contains(query) ||
          (country.nameLocalized?.toLowerCase().contains(query) ?? false),
    );
  }

  void _selectSearchResult(Country country) {
    _searchMenu.close();
    widget.onSelect?.call(country);
  }

  Widget _searchAnchor(
    List<Country> countries,
    Country selected,
    CountryLocalizations localization,
  ) => RawMenuAnchor(
    controller: _searchMenu,
    onOpen: _searchFocus.requestFocus,
    onClose: () {
      _searchFocus.unfocus();
      _searchController.clear();
    },
    builder: (context, controller, _) {
      if (!controller.isOpen) {
        return _buttonBuilder(context, controller.open, selected);
      }
      final secondaryLabel = CupertinoColors.secondaryLabel.resolveFrom(
        context,
      );
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): controller.close,
        },
        child: SizedBox(
          height: widget.rowHeight,
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  placeholder: localization.searchPlaceholder,
                  placeholderStyle: TextStyle(color: secondaryLabel),
                  decoration: const BoxDecoration(),
                  padding: const EdgeInsetsDirectional.fromSTEB(6, 8, 0, 8),
                  prefix: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    child: Icon(
                      CupertinoIcons.search,
                      color: secondaryLabel,
                      size: 18,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  onSubmitted: (text) {
                    final result = _matchingCountries(
                      countries,
                      localization,
                      text,
                    ).firstOrNull;
                    if (result != null) _selectSearchResult(result);
                  },
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                onPressed: controller.close,
                child: Icon(
                  CupertinoIcons.chevron_up,
                  color: secondaryLabel,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      );
    },
    overlayBuilder: (context, info) {
      final anchor = info.anchorRect;
      final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
      final availableHeight =
          info.overlaySize.height - anchor.bottom - bottomInset - 8;
      if (availableHeight <= 0) return const SizedBox.shrink();
      return Positioned(
        top: anchor.bottom,
        left: anchor.left,
        width: anchor.width,
        child: TapRegion(
          groupId: info.tapRegionGroupId,
          onTapOutside: (_) => _searchMenu.close(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math.min(_kCountryMenuMaxHeight, availableHeight),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: ColoredBox(
                color: _cardFieldColor(context),
                child: _searchResults(countries, localization),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _searchResults(
    List<Country> countries,
    CountryLocalizations localization,
  ) => ValueListenableBuilder<TextEditingValue>(
    valueListenable: _searchController,
    builder: (context, value, _) {
      final matches = _matchingCountries(
        countries,
        localization,
        value.text,
      ).toList(growable: false);
      if (matches.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No countries found'),
        );
      }
      final separator = Divider(
        height: 1,
        thickness: 1,
        color: CupertinoColors.separator.resolveFrom(context),
      );
      final codeStyle = TextStyle(
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
        fontSize: 14,
      );
      return ListView.separated(
        key: ValueKey(value.text),
        shrinkWrap: true,
        primary: false,
        padding: EdgeInsets.zero,
        itemCount: matches.length,
        separatorBuilder: (_, _) => separator,
        itemBuilder: (context, index) {
          final country = matches[index];
          final name =
              localization.getFormatedCountryNameByCode(country.countryCode) ??
              country.name;
          return CupertinoMenuItem(
            leading: _flag(country),
            trailingWidth: 64,
            trailing: SizedBox(
              width: 64,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: Text(
                  '+${country.phoneCode}',
                  style: codeStyle,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                ),
              ),
            ),
            requestCloseOnActivate: false,
            requestFocusOnHover: false,
            onPressed: () => _selectSearchResult(country),
            child: Text(name),
          );
        },
      );
    },
  );

  Widget _flag(Country country) => Text(
    country.flagEmoji,
    style: TextStyle(fontSize: 14, fontFamily: _effectiveFontFamily),
  );

  List<CupertinoMenuItem> _menuItems(List<Country> countries) {
    final localization = CountryLocalizations.of(context);
    return countries
        .map((e) {
          final title = localization.getFormatedCountryNameByCode(
            e.countryCode,
          );
          return CupertinoMenuItem(
            leading: _flag(e),
            onPressed: () => widget.onSelect?.call(e),
            child: Text('$title +${e.phoneCode}'),
          );
        })
        .toList(growable: false);
  }

  Widget _buttonBuilder(
    BuildContext context,
    VoidCallback showMenu,
    Country selected,
  ) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final pickerTheme = CountryPickerTheme.of(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: showMenu,
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
        padding: .only(
          left: pickerTheme.padding,
          right: pickerTheme.padding / 1.5,
        ),
        child: SizedBox(
          height: widget.rowHeight,
          child: Padding(
            padding: const .only(left: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected.name,
                    style: textStyle?.copyWith(height: 1),
                  ),
                ),
                Icon(
                  widget.chevron,
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
                    e.name == localizations.getCountryNameByCode(e.countryCode),
              ) ??
              state.countries[0];

          if (widget.showSearch ?? false) {
            return _searchAnchor(state.countries, $selected, localizations);
          }
          return CupertinoMenuAnchor(
            constraints: const BoxConstraints(
              maxWidth: 262,
              maxHeight: _kCountryMenuMaxHeight,
            ),
            constrainCrossAxis: true,
            menuChildren: _menuItems(state.countries),
            builder: (context, controller, _) =>
                _buttonBuilder(context, controller.open, $selected),
          );
        },
      ),
    );
  }
}
