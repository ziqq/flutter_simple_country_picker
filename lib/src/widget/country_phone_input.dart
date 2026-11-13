/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 7 October 2024
 */

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_phone_rules.g.dart';
import 'package:flutter_simple_country_picker/src/util/country_flag_font_util.dart';
import 'package:meta/meta.dart';

/// {@template country_phone_input}
/// CountryPhoneInput widget.
///
/// This widget provides an input field for phone numbers with country selection.
/// {@endtemplate}
class CountryPhoneInput extends StatefulWidget {
  /// {@macro country_phone_input}
  const CountryPhoneInput({
    this.initialCountry,
    this.controller,
    this.onChanged,
    this.countryController,
    this.onCountryChanged,
    this.exclude,
    this.favorites,
    this.filter,
    this.placeholder,
    this.autofocus = false,
    this.expand = true,
    this.enableOpenPicker = true,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.shouldReplace8 = true,
    this.useCountryFormatting = false,
    this.useAutofocus = false,
    @Deprecated(
      'Use useHapticFeedback instead. This parameter will be removed in '
      'v1.0.0 releases.',
    )
    bool useHaptickFeedback = true,
    bool? useHapticFeedback,
    this.isScrollControlled = false,
    this.shouldCloseOnSwipeDown = false,
    this.showGroup,
    this.showSearch,
    this.initialChildSize,
    this.minChildSize,
    this.surfaceBuilder,
    super.key,
  }) : useHaptickFeedback = useHapticFeedback ?? useHaptickFeedback,
       useHapticFeedback = useHapticFeedback ?? useHaptickFeedback;

  /// This constructor creates an extended version of [CountryPhoneInput].
  /// {@macro country_phone_input}
  const factory CountryPhoneInput.extended({
    Country? initialCountry,
    CountryPhoneController? controller,
    ValueChanged<String>? onChanged,
    ValueNotifier<Country>? countryController,
    ValueChanged<Country>? onCountryChanged,
    List<String>? exclude,
    List<String>? favorites,
    List<String>? filter,
    String? placeholder,
    bool autofocus,
    bool expand,
    bool enableOpenPicker,
    bool isScrollControlled,
    bool showPhoneCode,
    bool showWorldWide,
    bool shouldReplace8,
    bool useCountryFormatting,
    bool shouldCloseOnSwipeDown,
    bool? showGroup,
    bool? showSearch,
    @Deprecated(
      'Use autofocus instead. This will be removed in v1.0.0 releases.',
    )
    bool useAutofocus,
    @Deprecated(
      'Use useHapticFeedback instead. This parameter will be removed in '
      'v1.0.0 releases.',
    )
    bool useHaptickFeedback,
    bool? useHapticFeedback,
    double? initialChildSize,
    double? minChildSize,
    CountryPickerSurfaceBuilder? surfaceBuilder,
    Key? key,
  }) = CountryPhoneInput$Extended;

  /// Use autofocus for the search countryies input field.
  final bool autofocus;

  /// The [expand] argument can be used
  /// to expand the bottom sheet to full height.
  /// Default is `true`.
  final bool expand;

  /// Whether tapping the country-code button opens the country picker.
  final bool enableOpenPicker;

  /// Controls the scrolling behavior of the modal window.
  final bool isScrollControlled;

  /// Group countries by their first letter.
  final bool? showGroup;

  /// Show phone code in countires list.
  final bool showPhoneCode;

  /// Show "World Wide" in countires list.
  final bool showWorldWide;

  /// Normalize a leading national prefix for pasted or preset numbers.
  ///
  /// Historically this flag handled Russian numbers that start with `8` before
  /// `+7`. Prefixes now come from the selected country's numbering rules.
  /// Automatic formatting removes a trunk only when the remaining local length
  /// is supported; manual formatting retains its fixed-length normalization.
  final bool shouldReplace8;

  /// Enables country/prefix pattern selection and a non-truncating soft tail.
  ///
  /// False preserves manual Country.mask/null behavior. In automatic mode,
  /// completion uses all supported lengths rather than mask capacity.
  final bool useCountryFormatting;

  /// Should close the bottom sheet on swipe down gesture.
  final bool shouldCloseOnSwipeDown;

  /// Show countryies search bar?
  final bool? showSearch;

  /// Use autofocus for the search countryies input field.
  @Deprecated('Use autofocus instead. This will be removed in v1.0.0 releases.')
  final bool useAutofocus;

  /// Whether to use haptic feedback.
  @Deprecated(
    'Use useHapticFeedback instead. This property will be removed in '
    'v1.0.0 releases.',
  )
  final bool useHaptickFeedback;

  /// Whether to use haptic feedback.
  final bool useHapticFeedback;

  /// Initial child size for the modal bottom sheet.
  final double? initialChildSize;

  /// Min child size for the modal bottom sheet.
  final double? minChildSize;

  /// List of country codes to exclude.
  final List<String>? exclude;

  /// List of favorites country codes.
  final List<String>? favorites;

  /// List of filtered country codes.
  final List<String>? filter;

  /// Placeholder text.
  final String? placeholder;

  /// The initial country.
  final Country? initialCountry;

  /// Controller for the phone number input.
  final CountryPhoneController? controller;

  /// Called when the phone number is changed.
  final ValueChanged<String>? onChanged;

  /// Controller for the selected country.
  final ValueNotifier<Country>? countryController;

  /// Called when the country is changed.
  final ValueChanged<Country>? onCountryChanged;

  /// {@macro country_picker_surface_builder}
  final CountryPickerSurfaceBuilder? surfaceBuilder;

  @override
  State<CountryPhoneInput> createState() => _CountryPhoneInputState();
}

/// Mixin for state [CountryPhoneInput].
mixin _CountryPhoneInputStateMixin<T extends CountryPhoneInput> on State<T> {
  final ValueNotifier<CountryPickerTheme?> _pickerTheme = ValueNotifier(null);
  late final _painter = _BackgroundPainter(pickerTheme: _pickerTheme);
  late final TextEditingController _phoneController;
  late final CountryInputFormatter _formatter;
  final ScrollController _phoneScrollController = ScrollController();
  late CountryPhoneController _controller;
  late ValueNotifier<Country> _countryController;

  /// Get current initial country or default to `Russia` if not provided.
  Country get _initialCountry => widget.initialCountry ?? Country.ru();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController()..addListener(_onPhoneChanged);
    _controller =
        widget.controller ??
        CountryPhoneController.apply(_initialCountry.countryCode);

    _countryController =
        widget.countryController ?? ValueNotifier<Country>(_initialCountry);
    _countryController.addListener(_onCountryChanged);

    final leadingPrefixes = _manualLeadingPrefixes(_countryController.value);
    _formatter = widget.useCountryFormatting
        ? CountryInputFormatter.forCountry(
            country: _countryController.value,
            shouldTryStripLeadingPrefix: widget.shouldReplace8,
          )
        : CountryInputFormatter(
            filter: {'0': RegExp('[0-9]')},
            mask: _countryController.value.mask,
            phoneCode: _countryController.value.phoneCode,
            example: _countryController.value.example,
            shouldTryStripPhoneCode: true,
            shouldTryStripLeadingPrefix:
                widget.shouldReplace8 &&
                (leadingPrefixes == null || leadingPrefixes.isNotEmpty),
            leadingPrefixes: leadingPrefixes ?? const {},
          );

    _syncControllerValue(text: _controller.text);

    // If the controller has an initial value
    if (_controller.text.isNotEmpty) {
      _applyPhoneText(
        _controller.text,
        allowImplicitCountryCodeStrip: true,
        allowLeadingPrefixStrip: widget.shouldReplace8,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pickerTheme.value = CountryPickerTheme.resolve(context);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the initial country has changed
    if (widget.initialCountry != oldWidget.initialCountry) {
      _countryController.value = _initialCountry;
      _updateFormatter();
    }

    // Check if the controller has changed
    if (!identical(oldWidget.controller, widget.controller)) {
      final current = _controller;
      if (oldWidget.controller == null) scheduleMicrotask(current.dispose);
      _controller =
          widget.controller ??
          CountryPhoneController.apply(_initialCountry.countryCode);
      _applyPhoneText(
        _controller.text,
        allowImplicitCountryCodeStrip: true,
        allowLeadingPrefixStrip: widget.shouldReplace8,
      );
    }

    // Check if the country controller has changed
    if (!identical(oldWidget.countryController, widget.countryController)) {
      final current = _countryController;
      if (oldWidget.countryController == null) {
        current.removeListener(_onCountryChanged);
        scheduleMicrotask(current.dispose);
      }
      _countryController =
          widget.countryController ?? ValueNotifier<Country>(_initialCountry);
      _countryController.addListener(_onCountryChanged);
      _updateFormatter();
    }

    // Reconfigure the formatter when its options change.
    if (widget.shouldReplace8 != oldWidget.shouldReplace8 ||
        widget.useCountryFormatting != oldWidget.useCountryFormatting) {
      _updateFormatter();
      if (!widget.useCountryFormatting) {
        _applyPhoneText(
          _phoneController.text,
          allowLeadingPrefixStrip: widget.shouldReplace8,
          selection: _phoneController.selection,
        );
      }
    }
  }

  /// Returns null for countries that use the legacy prefix defaults.
  Set<String>? _manualLeadingPrefixes(Country country) =>
      switch (countryPhoneRules[country.countryCode.toUpperCase()]) {
        null => null,
        CountryPhoneRules(literalTrunkPrefix: String prefix) => {prefix},
        _ => const {},
      };

  void _updateFormatter() {
    final country = _countryController.value;
    if (widget.useCountryFormatting) {
      _phoneController.value = _formatter.updateCountry(
        country,
        newValue: _phoneController.value,
        shouldTryStripLeadingPrefix: widget.shouldReplace8,
      );
      _syncControllerValue();
      return;
    }
    final leadingPrefixes = _manualLeadingPrefixes(country);
    _formatter.updateMask(
      mask: country.mask,
      example: country.example,
      phoneCode: country.phoneCode,
      shouldTryStripPhoneCode: true,
      shouldTryStripLeadingPrefix:
          widget.shouldReplace8 &&
          (leadingPrefixes == null || leadingPrefixes.isNotEmpty),
      leadingPrefixes: leadingPrefixes ?? const {},
    );
    _syncControllerValue();
  }

  void _syncControllerValue({String? text}) {
    final resolvedText =
        text ??
        '+${_countryController.value.phoneCode} ${_phoneController.text}';
    _controller.value = _controller.value.copyWith(
      text: resolvedText,
      valueStatus: _formatter.valueStatus,
    );
  }

  void _applyPhoneText(
    String rawText, {
    bool allowImplicitCountryCodeStrip = false,
    bool allowLeadingPrefixStrip = false,
    TextSelection? selection,
  }) {
    final normalized = _formatter.normalizePhoneText(
      rawText,
      allowImplicitPhoneCodeStrip: allowImplicitCountryCodeStrip,
      allowLeadingPrefixStrip: allowLeadingPrefixStrip,
    );

    _formatter.clear();
    if (normalized.isEmpty) {
      _phoneController.clear();
      return;
    }

    final formattedValue = _formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      ),
    );

    _phoneController.value = formattedValue.copyWith(
      selection: _mapPhoneSelection(rawText, formattedValue.text, selection),
      composing: TextRange.empty,
    );
  }

  /// Restores both selection endpoints by their position among the digits.
  static TextSelection _mapPhoneSelection(
    String rawText,
    String formattedText,
    TextSelection? selection,
  ) {
    if (selection == null || !selection.isValid) {
      return TextSelection.collapsed(offset: formattedText.length);
    }

    final digit = RegExp(r'\d');
    final originalDigits = digit.allMatches(rawText).toList();
    final formattedDigits = digit.allMatches(formattedText).toList();
    final strippedDigits = originalDigits.length - formattedDigits.length;

    int offsetFor(int offset) {
      final precedingDigits = originalDigits
          .takeWhile((match) => match.end <= offset)
          .length;
      final digitIndex = (precedingDigits - strippedDigits).clamp(
        0,
        formattedDigits.length,
      );
      return digitIndex == 0 ? 0 : formattedDigits[digitIndex - 1].end;
    }

    return selection.copyWith(
      baseOffset: offsetFor(selection.baseOffset),
      extentOffset: offsetFor(selection.extentOffset),
    );
  }

  @override
  void dispose() {
    _pickerTheme.dispose();
    _phoneScrollController.dispose();
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    _countryController.removeListener(_onCountryChanged);
    if (widget.controller == null) _controller.dispose();
    if (widget.countryController == null) _countryController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (!mounted) return;
    _syncControllerValue();
  }

  void _onCountryChanged() {
    if (!mounted) return;

    // Update the formatter mask
    _updateFormatter();

    // Manual formatting applies the new mask after changing countries.
    if (!widget.useCountryFormatting) _applyPhoneText(_phoneController.text);
  }

  void _onSelect(Country country) {
    if (!mounted) return;
    if (country == _countryController.value) return;
    _formatter.clear();
    _phoneController.clear();
    _countryController.value = country;
    widget.onCountryChanged?.call(country);
  }

  /// Accessibility label of the country button, e.g. `Russia, +7`.
  String _semanticsLabelOf(CountryLocalizations localization, Country c) =>
      '${localization.getFormatedCountryNameByCode(c.countryCode) ?? c.name}'
      ', +${c.phoneCode}';

  Widget _buildPhoneField(
    BuildContext context, {
    required Key key,
    required Country country,
    required CountryLocalizations localization,
    required CountryPickerTheme pickerTheme,
    required TextStyle? textStyle,
    EdgeInsets? contentPadding,
  }) {
    final showMask =
        widget.useCountryFormatting &&
        widget.placeholder == null &&
        _formatter.maskHint != null;
    final hintStyle = textStyle?.copyWith(
      color: pickerTheme.searchTextStyle?.color?.withValues(alpha: .5),
    );
    var decoration = InputDecoration(
      hintText: showMask
          ? null
          : widget.placeholder ??
                (widget.useCountryFormatting ? null : country.mask) ??
                localization.phonePlaceholder,
      hintStyle: hintStyle,
      contentPadding: contentPadding,
      border: InputBorder.none,
      errorBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );

    _PhoneMaskPainter? maskPainter;
    if (showMask) {
      final theme = Theme.of(context);
      final effectiveDecoration = decoration.applyDefaults(
        theme.inputDecorationTheme,
      );
      final padding =
          effectiveDecoration.contentPadding?.resolve(TextDirection.ltr) ??
          ((effectiveDecoration.isCollapsed ?? false)
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(
                  horizontal: (effectiveDecoration.filled ?? false) ? 12 : 0,
                  vertical: theme.useMaterial3
                      ? (effectiveDecoration.isDense ?? false)
                            ? 4
                            : 8
                      : (effectiveDecoration.isDense ?? false)
                      ? 8
                      : 12,
                ));
      decoration = decoration.copyWith(contentPadding: padding);
      final inputStyle =
          (theme.useMaterial3
                  ? theme.textTheme.bodyLarge
                  : theme.textTheme.titleMedium)
              ?.merge(textStyle) ??
          const TextStyle();
      maskPainter = _PhoneMaskPainter(
        controller: _phoneController,
        scrollController: _phoneScrollController,
        formatter: _formatter,
        country: country,
        padding: padding,
        style: MediaQuery.boldTextOf(context)
            ? inputStyle.merge(const TextStyle(fontWeight: FontWeight.bold))
            : inputStyle,
        hintColor:
            hintStyle?.color ??
            (inputStyle.color ?? theme.colorScheme.onSurface).withValues(
              alpha: .5,
            ),
        textScaler: MediaQuery.textScalerOf(context),
        locale: Localizations.maybeLocaleOf(context),
      );
    }

    final field = TextFormField(
      key: key,
      autofocus: widget.autofocus,
      controller: _phoneController,
      scrollController: showMask ? _phoneScrollController : null,
      inputFormatters: [_formatter],
      keyboardType: TextInputType.number,
      onChanged: (_) => widget.onChanged?.call(_controller.text),
      cursorColor: textStyle?.color,
      style: textStyle,
      textAlignVertical: showMask ? TextAlignVertical.center : null,
      textDirection: showMask ? TextDirection.ltr : null,
      decoration: decoration,
    );
    return Semantics(
      label: localization.phonePlaceholder,
      child: CustomPaint(foregroundPainter: maskPainter, child: field),
    );
  }
}

/// State for widget [CountryPhoneInput].
class _CountryPhoneInputState extends State<CountryPhoneInput>
    with _CountryPhoneInputStateMixin {
  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final textStyle = pickerTheme.textStyle;
    final measuredStyle = MediaQuery.boldTextOf(context)
        ? textStyle?.merge(const TextStyle(fontWeight: FontWeight.bold))
        : textStyle;
    final painter = TextPainter(
      text: TextSpan(text: 'Mg', style: measuredStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final height = painter.height + pickerTheme.padding;
    painter.dispose();
    final constraints = BoxConstraints.tightFor(
      height: height > pickerTheme.inputHeight
          ? height
          : pickerTheme.inputHeight,
    );
    return ValueListenableBuilder(
      valueListenable: _countryController,
      builder: (context, selected, _) => LayoutBuilder(
        builder: (context, available) {
          final label = TextPainter(
            text: TextSpan(
              style: measuredStyle,
              children: [
                TextSpan(
                  text: selected.flagEmoji,
                  style: TextStyle(fontFamily: CountryFlagFontUtil.fontFamily),
                ),
                TextSpan(text: ' +${selected.phoneCode}'),
              ],
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          // Keep a useful number field instead of squeezing it beside a large code.
          final stacked =
              available.maxWidth <
              label.width +
                  pickerTheme.padding * 2 +
                  pickerTheme.padding / 1.6 +
                  pickerTheme.inputHeight * 2;
          label.dispose();
          final button = ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.minHeight),
            child: Semantics(
              enabled: widget.enableOpenPicker,
              child: CupertinoButton(
                key: const ValueKey<String>('country_picker_phone_code'),
                padding: EdgeInsets.symmetric(horizontal: pickerTheme.padding),
                color: pickerTheme.onBackgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(pickerTheme.baseCornerRadius),
                ),
                pressedOpacity: .6,
                onPressed: widget.enableOpenPicker
                    ? () => showCountryPicker(
                        context: context,
                        exclude: widget.exclude,
                        favorites: widget.favorites,
                        filter: widget.filter,
                        expand: widget.expand,
                        autofocus: widget.autofocus || widget.useAutofocus,
                        showGroup: widget.showGroup,
                        showSearch: widget.showSearch,
                        showPhoneCode: widget.showPhoneCode,
                        showWorldWide: widget.showWorldWide,
                        shouldCloseOnSwipeDown: widget.shouldCloseOnSwipeDown,
                        useHapticFeedback: widget.useHapticFeedback,
                        isScrollControlled: widget.isScrollControlled,
                        initialChildSize: widget.initialChildSize,
                        minChildSize: widget.minChildSize,
                        surfaceBuilder: widget.surfaceBuilder,
                        selected: _countryController,
                        onSelect: _onSelect,
                      )
                    : null,
                child: Semantics(
                  // Announce the country instead of the emoji flag name.
                  label: _semanticsLabelOf(localization, selected),
                  child: ExcludeSemantics(
                    child: Center(
                      heightFactor: 1,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 3,
                        children: <Widget>[
                          if (selected.flagEmoji.isNotEmpty) ...[
                            Text.rich(
                              TextSpan(
                                text: selected.flagEmoji,
                                style: TextStyle(
                                  fontFamily: CountryFlagFontUtil.fontFamily,
                                ),
                              ),
                              style: textStyle?.copyWith(letterSpacing: 0),
                            ),
                          ],
                          Text('+${selected.phoneCode}', style: textStyle),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          final field = ConstrainedBox(
            constraints: constraints,
            child: RepaintBoundary(
              key: const ValueKey<String>('country_phone_number_background'),
              child: CustomPaint(
                painter: _painter,
                child: Center(
                  child: _buildPhoneField(
                    context,
                    key: const ValueKey<String>('country_phone_number'),
                    country: selected,
                    localization: localization,
                    pickerTheme: pickerTheme,
                    textStyle: textStyle,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: pickerTheme.padding,
                    ),
                  ),
                ),
              ),
            ),
          );
          if (stacked) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: pickerTheme.padding / 1.6,
              children: [button, field],
            );
          }
          return Row(
            spacing: pickerTheme.padding / 1.6,
            children: [
              button,
              Flexible(child: field),
            ],
          );
        },
      ),
    );
  }
}

/// CountryPhoneInput$Extended widget.
/// {@macro country_phone_input}
@internal
class CountryPhoneInput$Extended extends CountryPhoneInput {
  /// {@macro country_phone_input}
  const CountryPhoneInput$Extended({
    super.initialCountry,
    super.controller,
    super.onChanged,
    super.countryController,
    super.onCountryChanged,
    super.exclude,
    super.favorites,
    super.filter,
    super.autofocus,
    super.expand,
    super.enableOpenPicker,
    super.isScrollControlled,
    super.placeholder,
    super.shouldReplace8,
    super.useCountryFormatting,
    super.shouldCloseOnSwipeDown,
    super.showPhoneCode,
    super.showWorldWide,
    super.showGroup,
    super.showSearch,
    super.useAutofocus,
    super.useHaptickFeedback,
    super.useHapticFeedback,
    super.initialChildSize,
    super.minChildSize,
    super.surfaceBuilder,
    super.key,
  });

  @override
  State<CountryPhoneInput$Extended> createState() =>
      _CountryPhoneInput$ExtendedState();
}

/// Stete for widget [CountryPhoneInput$Extended]
class _CountryPhoneInput$ExtendedState extends State<CountryPhoneInput$Extended>
    with _CountryPhoneInputStateMixin {
  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountryLocalizations.of(context);
    final padding = EdgeInsets.symmetric(
      horizontal: pickerTheme.padding / 2,
      vertical: pickerTheme.padding / 1.6,
    );
    final textStyle = pickerTheme.textStyle?.copyWith(
      fontSize: 20,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: pickerTheme.dividerColor,
    );
    return Material(
      color: pickerTheme.onBackgroundColor,
      child: ValueListenableBuilder(
        valueListenable: _countryController,
        builder: (_, selected, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            divider,

            // --- Country name with flag --- //
            Semantics(
              enabled: widget.enableOpenPicker,
              child: CupertinoButton(
                key: const ValueKey<String>('country_picker_button_extended'),
                padding: EdgeInsets.only(
                  top: pickerTheme.padding / 1.6,
                  left: pickerTheme.padding,
                  bottom: pickerTheme.padding / 1.6,
                  right: pickerTheme.padding / 2,
                ),
                onPressed: widget.enableOpenPicker
                    ? () => showCountryPicker(
                        context: context,
                        exclude: widget.exclude,
                        favorites: widget.favorites,
                        filter: widget.filter,
                        expand: widget.expand,
                        autofocus: widget.autofocus || widget.useAutofocus,
                        showGroup: widget.showGroup,
                        showSearch: widget.showSearch,
                        showPhoneCode: widget.showPhoneCode,
                        showWorldWide: widget.showWorldWide,
                        isScrollControlled: widget.isScrollControlled,
                        useHapticFeedback: widget.useHapticFeedback,
                        shouldCloseOnSwipeDown: widget.shouldCloseOnSwipeDown,
                        initialChildSize: widget.initialChildSize,
                        minChildSize: widget.minChildSize,
                        surfaceBuilder: widget.surfaceBuilder,
                        selected: _countryController,
                        onSelect: _onSelect,
                      )
                    : null,
                child: SizedBox(
                  width: double.infinity,
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: selected.flagEmoji,
                          style: TextStyle(
                            fontFamily: CountryFlagFontUtil.fontFamily,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' ${localization.getFormatedCountryNameByCode(selected.countryCode) ?? selected.name}',
                        ),
                      ],
                    ),
                    // Announce the country instead of the emoji flag name.
                    semanticsLabel: _semanticsLabelOf(localization, selected),
                    style: textStyle?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            // --- Divider --- //
            SizedBox(
              height: 1,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 1),
                painter: _DividerPainter(pickerTheme: _pickerTheme),
              ),
            ),

            // --- Input with mask --- //
            LayoutBuilder(
              builder: (context, constraints) => Row(
                children: <Widget>[
                  // --- Phone code --- //
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth / 2,
                    ),
                    child: Padding(
                      padding: padding,
                      child: Text(
                        '+${selected.phoneCode}',
                        style: textStyle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // --- Divider --- //
                  SizedBox(
                    height: 30,
                    child: VerticalDivider(
                      color: pickerTheme.dividerColor,
                      thickness: 1,
                    ),
                  ),

                  // --- Phone input --- //
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding.horizontal / 2.5,
                      ),
                      child: _buildPhoneField(
                        context,
                        key: const ValueKey<String>(
                          'country_phone_input_extended',
                        ),
                        country: selected,
                        localization: localization,
                        pickerTheme: pickerTheme,
                        textStyle: textStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            divider,
          ],
        ),
      ),
    );
  }
}

/// Paints the unfilled template without adding characters to the text field.
class _PhoneMaskPainter extends CustomPainter {
  _PhoneMaskPainter({
    required this.controller,
    required this.scrollController,
    required this.formatter,
    required this.country,
    required this.padding,
    required this.style,
    required this.hintColor,
    required this.textScaler,
    required this.locale,
  }) : super(repaint: Listenable.merge([controller, scrollController]));

  final TextEditingController controller;
  final ScrollController scrollController;
  final CountryInputFormatter formatter;
  final Country country;
  final EdgeInsets padding;
  final TextStyle style;
  final Color hintColor;
  final TextScaler textScaler;
  final Locale? locale;

  @override
  void paint(Canvas canvas, Size size) {
    final hint = formatter.maskHint;
    final value = controller.value;
    if (hint == null || hint.isEmpty || !value.composing.isCollapsed) return;

    final bounds = padding.deflateRect(Offset.zero & size);
    if (bounds.isEmpty) return;
    final scrollOffset = scrollController.hasClients
        ? scrollController.offset
        : 0.0;
    final painter = TextPainter(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(
            text: value.text,
            style: const TextStyle(color: Colors.transparent),
          ),
          TextSpan(
            text: hint,
            style: TextStyle(color: hintColor),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      locale: locale,
      maxLines: 1,
    )..layout();
    canvas
      ..save()
      ..clipRect(bounds);
    painter.paint(
      canvas,
      Offset(bounds.left - scrollOffset, bounds.center.dy - painter.height / 2),
    );
    canvas.restore();
    painter.dispose();
  }

  @override
  bool shouldRepaint(_PhoneMaskPainter oldDelegate) =>
      controller != oldDelegate.controller ||
      scrollController != oldDelegate.scrollController ||
      formatter != oldDelegate.formatter ||
      country.e164Key != oldDelegate.country.e164Key ||
      country.mask != oldDelegate.country.mask ||
      padding != oldDelegate.padding ||
      style != oldDelegate.style ||
      hintColor != oldDelegate.hintColor ||
      textScaler != oldDelegate.textScaler ||
      locale != oldDelegate.locale;
}

/// Dividre painter for [CountryPhoneInput$Extended].
/// {@macro country_phone_input}
class _DividerPainter extends CustomPainter {
  /// Creates a [_DividerPainter].
  _DividerPainter({required this.pickerTheme}) : super(repaint: pickerTheme);

  /// Notifier for country picker theme.
  final ValueNotifier<CountryPickerTheme?> pickerTheme;

  /// The color to fill in the background of the rounded rectangle.
  Color? get dividerColor => pickerTheme.value?.dividerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset.zero,
      const Offset(22, 0),
      const Offset(30, 8),
      const Offset(38, 0),
      Offset(size.width, 0),
    ];
    final paint = Paint()
      ..color = dividerColor ?? Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    canvas.drawPoints(ui.PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Background painter for [CountryPhoneInput].
/// {@macro country_phone_input}
class _BackgroundPainter extends CustomPainter {
  /// Creates a [CustomPaint] that paints a rounded rectangle.
  const _BackgroundPainter({required this.pickerTheme})
    : super(repaint: pickerTheme);

  /// Notifier for country picker theme.
  final ValueNotifier<CountryPickerTheme?> pickerTheme;

  /// The color to fill in the background of the rounded rectangle.
  Color? get color => pickerTheme.value?.onBackgroundColor;

  /// The radius of the rounded corners of the rectangle.
  double? get radius => pickerTheme.value?.baseCornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveRadius = Radius.circular(radius ?? 10);
    final paint = Paint()..color = color ?? Colors.grey;
    final rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      effectiveRadius,
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}
