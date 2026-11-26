// Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 October 2024

import 'package:collection/collection.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/src/common/constant/fonts.gen.dart';
import 'package:example/src/common/localization/localization.dart';
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

/// Default height of a country row in the Linux preview.
const double _kDefaultCountyInputHeight = 44;

/// Launches the Linux picker preview.
void main() => appZone(() async => runApp(const App(home: LinuxPreview())));

/// {@template county_picker_linux_preview}
/// Demonstrates a country menu and a manually formatted phone field.
///
/// The menu reads the available countries from [CountryScope].
/// {@endtemplate}
class LinuxPreview extends StatefulWidget {
  /// {@macro county_picker_linux_preview}
  const LinuxPreview({super.key});

  /// Title of the widget.
  static const String title = 'Linux';

  @override
  State<LinuxPreview> createState() => _LinuxPreviewState();
}

/// State for widget [LinuxPreview].
class _LinuxPreviewState extends State<LinuxPreview>
    with CountryPickerPreviewStateMixin {
  @override
  Widget build(BuildContext context) {
    final localization = ExampleLocalization.of(context);
    final pickerTheme = CountryPickerTheme.of(context);
    return Scaffold(
      appBar: const CommonAppBar(title: LinuxPreview.title),
      body: Padding(
        padding: CommonPadding.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CommonLogo.text(),
            SizedBox(height: pickerTheme.padding * 2),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                  CountryPicker$Linux(onSelect: onSelect, selected: selected),
                  CountryInput$Linux(
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template country_input_linux}
/// CountryInput$Linux widget.
/// {@endtemplate}
class CountryInput$Linux extends StatelessWidget {
  /// {@macro country_input_linux}
  const CountryInput$Linux({
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
    final pickerTheme = CountryPickerTheme.of(context);
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
          padding: .only(
            left: pickerTheme.padding,
            right: pickerTheme.padding / 1.5,
          ),
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const .only(left: 5),
              child: CupertinoTextField(
                controller: controller,
                inputFormatters: inputFormatters,
                placeholder: selectedCountry.mask,
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

/// {@template county_picker_macos}
/// CountryPicker$Linux widget.
/// {@endtemplate}
class CountryPicker$Linux extends StatefulWidget {
  /// {@macro county_picker_macos}
  const CountryPicker$Linux({this.onSelect, this.selected, super.key});

  /// Called when the user chooses a country.
  final SelectCountryCallback? onSelect;

  /// Notifies the control when the current selection changes.
  final SelectedCountry? selected;

  @override
  State<CountryPicker$Linux> createState() => _CountryPicker$LinuxState();
}

/// State for widget [CountryPicker$Linux].
class _CountryPicker$LinuxState extends State<CountryPicker$Linux> {
  /// Uses the bundled emoji font when running this preview in a browser.
  final String? _effectiveFontFamily = kIsWeb
      ? FontFamily.notoColorEmoji
      : null;

  /// Builds country menu items with each flag and dialing code.
  List<CupertinoMenuItem> _itemBuilder(List<Country> countries) {
    final localization = CountryLocalizations.of(context);
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontSize: 14);
    return [
      for (final country in countries)
        CupertinoMenuItem(
          leading: Text(
            country.flagEmoji,
            style: textStyle?.copyWith(fontFamily: _effectiveFontFamily),
          ),
          onPressed: () => widget.onSelect?.call(country),
          child: Text(
            '${localization.getFormatedCountryNameByCode(country.countryCode)}'
            ' +${country.phoneCode}',
            style: textStyle,
          ),
        ),
    ];
  }

  /// Builds the country row that opens the preview menu.
  Widget _buttonBuilder(
    BuildContext context,
    VoidCallback showMenu,
    Country selected,
  ) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final pickerTheme = CountryPickerTheme.of(context);
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
          padding: .only(
            left: pickerTheme.padding,
            right: pickerTheme.padding / 1.5,
          ),
          child: SizedBox(
            height: _kDefaultCountyInputHeight,
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
        valueListenable: widget.selected ?? ValueNotifier(null),
        builder: (context, selected, _) {
          final $selected =
              selected ??
              state.countries.firstWhereOrNull(
                (e) =>
                    e.name == localizations.getCountryNameByCode(e.countryCode),
              ) ??
              state.countries[0];

          return CupertinoMenuAnchor(
            consumeOutsideTaps: true,
            constrainCrossAxis: true,
            menuChildren: _itemBuilder(state.countries),
            builder: (context, controller, child) =>
                _buttonBuilder(context, controller.open, $selected),
          );
        },
      ),
    );
  }
}
