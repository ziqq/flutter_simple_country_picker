import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
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
    this.expand = false,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.shouldReplace8 = true,
    this.useAutofocus = false,
    this.useHaptickFeedback = true,
    this.isScrollControlled = false,
    this.shouldCloseOnSwipeDown = false,
    this.showGroup,
    this.showSearch,
    this.initialChildSize,
    this.minChildSize,
    super.key,
  });

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
    bool isScrollControlled,
    bool showPhoneCode,
    bool showWorldWide,
    bool shouldReplace8,
    bool shouldCloseOnSwipeDown,
    bool? showGroup,
    bool? showSearch,
    @Deprecated(
      'Use autofocus instead. This will be removed in v1.0.0 releases.',
    )
    bool useAutofocus,
    bool useHaptickFeedback,
    double? initialChildSize,
    double? minChildSize,
    Key? key,
  }) = CountryPhoneInput$Extended;

  /// Use autofocus for the search countryies input field.
  final bool autofocus;

  /// The [expand] argument can be used
  /// to expand the bottom sheet to full height.
  /// Default is `false`.
  final bool expand;

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
  /// `+7`. It now applies a generic normalization rule: when the inserted
  /// number is longer than the selected country's local example by one digit,
  /// the leading national prefix is removed before the mask is applied.
  final bool shouldReplace8;

  /// Should close the bottom sheet on swipe down gesture.
  final bool shouldCloseOnSwipeDown;

  /// Show countryies search bar?
  final bool? showSearch;

  /// Use autofocus for the search countryies input field.
  @Deprecated('Use autofocus instead. This will be removed in v1.0.0 releases.')
  final bool useAutofocus;

  /// Use haptic feedback?
  final bool useHaptickFeedback;

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

  @override
  State<CountryPhoneInput> createState() => _CountryPhoneInputState();
}

/// Mixin for state [CountryPhoneInput].
mixin _CountryPhoneInputStateMixin<T extends CountryPhoneInput> on State<T> {
  final ValueNotifier<CountryPickerTheme?> _pickerTheme = ValueNotifier(null);
  late final _painter = _BackgroundPainter(pickerTheme: _pickerTheme);
  late final TextEditingController _phoneController;
  late final CountryInputFormatter _formater;
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

    _formater = CountryInputFormatter(
      filter: {'0': RegExp('[0-9]')},
      mask: _countryController.value.mask,
      phoneCode: _countryController.value.phoneCode,
      example: _countryController.value.example,
      shouldTryStripPhoneCode: true,
      shouldTryStripLeadingPrefix: widget.shouldReplace8,
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

    // Check if the shouldReplace8 has changed
    if (widget.shouldReplace8 != oldWidget.shouldReplace8) {
      _updateFormatter();
      _applyPhoneText(
        _phoneController.text,
        allowLeadingPrefixStrip: widget.shouldReplace8,
      );
    }
  }

  void _updateFormatter() {
    final country = _countryController.value;
    _formater.updateMask(
      mask: country.mask,
      example: country.example,
      phoneCode: country.phoneCode,
      shouldTryStripPhoneCode: true,
      shouldTryStripLeadingPrefix: widget.shouldReplace8,
    );
    _syncControllerValue();
  }

  void _syncControllerValue({String? text}) {
    final resolvedText =
        text ??
        '+${_countryController.value.phoneCode} ${_phoneController.text}';
    _controller.value = _controller.value.copyWith(
      text: resolvedText,
      valueStatus: _formater.valueStatus,
    );
  }

  void _applyPhoneText(
    String rawText, {
    bool allowImplicitCountryCodeStrip = false,
    bool allowLeadingPrefixStrip = false,
  }) {
    final normalized = _formater.normalizePhoneText(
      rawText,
      allowImplicitPhoneCodeStrip: allowImplicitCountryCodeStrip,
      allowLeadingPrefixStrip: allowLeadingPrefixStrip,
    );

    _formater.clear();
    if (normalized.isEmpty) {
      _phoneController.clear();
      return;
    }

    final formattedValue = _formater.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      ),
    );

    _phoneController.value = formattedValue.copyWith(
      selection: TextSelection.collapsed(offset: formattedValue.text.length),
      composing: TextRange.empty,
    );
  }

  @override
  void dispose() {
    _pickerTheme.dispose();
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

    // Format the current text in the controller after changing the mask
    _applyPhoneText(_phoneController.text);
  }

  void _onSelect(Country country) {
    if (!mounted) return;
    if (country == _countryController.value) return;
    _formater.clear();
    _phoneController.clear();
    _countryController.value = country;
    widget.onCountryChanged?.call(country);
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
    final constraints = BoxConstraints(
      minHeight: pickerTheme.inputHeight,
      maxHeight: pickerTheme.inputHeight,
      minWidth: pickerTheme.inputHeight,
    );
    return ValueListenableBuilder(
      valueListenable: _countryController,
      builder: (context, selected, _) => Row(
        spacing: pickerTheme.indent,
        children: <Widget>[
          ConstrainedBox(
            constraints: constraints,
            child: CupertinoButton(
              key: const ValueKey<String>('country_picker_phone_code'),
              padding: EdgeInsets.symmetric(horizontal: pickerTheme.padding),
              color: pickerTheme.onBackgroundColor,
              borderRadius: BorderRadius.all(
                Radius.circular(pickerTheme.radius),
              ),
              pressedOpacity: .6,
              onPressed: () => showCountryPicker(
                context: context,
                exclude: widget.exclude,
                favorites: widget.favorites,
                filter: widget.filter,
                autofocus: widget.autofocus || widget.useAutofocus,
                showGroup: widget.showGroup,
                showSearch: widget.showSearch,
                showPhoneCode: widget.showPhoneCode,
                showWorldWide: widget.showWorldWide,
                shouldCloseOnSwipeDown: widget.shouldCloseOnSwipeDown,
                useHaptickFeedback: widget.useHaptickFeedback,
                isScrollControlled: widget.isScrollControlled,
                initialChildSize: widget.initialChildSize,
                minChildSize: widget.minChildSize,
                selected: _countryController,
                onSelect: _onSelect,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 3,
                  children: <Widget>[
                    if (selected.flagEmoji.isNotEmpty) ...[
                      Text(
                        selected.flagEmoji,
                        style: textStyle?.copyWith(letterSpacing: 0),
                      ),
                    ],
                    Text('+${selected.phoneCode}', style: textStyle),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: constraints,
              child: RepaintBoundary(
                key: const ValueKey<String>('country_phone_number_background'),
                child: CustomPaint(
                  painter: _painter,
                  child: Center(
                    child: TextFormField(
                      key: const ValueKey<String>('country_phone_number'),
                      autofocus: widget.autofocus,
                      controller: _phoneController,
                      inputFormatters: [_formater],
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        widget.onChanged?.call(_controller.text);
                      },
                      cursorHeight: textStyle?.fontSize,
                      cursorColor: textStyle?.color,
                      style: textStyle,
                      decoration: InputDecoration(
                        hintText:
                            widget.placeholder ??
                            selected.mask ??
                            localization.phonePlaceholder,
                        hintStyle: textStyle?.copyWith(
                          color: pickerTheme.searchTextStyle?.color?.withValues(
                            alpha: .5,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(
                          right: pickerTheme.padding,
                          left: pickerTheme.padding,
                        ),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ); // +79378032888
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
    super.isScrollControlled,
    super.placeholder,
    super.shouldReplace8,
    super.shouldCloseOnSwipeDown,
    super.showPhoneCode,
    super.showWorldWide,
    super.showGroup,
    super.showSearch,
    super.useAutofocus,
    super.useHaptickFeedback,
    super.initialChildSize,
    super.minChildSize,
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
      vertical: pickerTheme.indent,
    );
    final textStyle = pickerTheme.textStyle;
    final defaultTextStyle = textStyle?.copyWith(
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
            CupertinoButton(
              key: const ValueKey<String>('country_picker_button_extended'),
              padding: EdgeInsets.only(
                top: pickerTheme.indent,
                left: pickerTheme.padding,
                bottom: pickerTheme.indent,
                right: pickerTheme.padding / 2,
              ),
              onPressed: () => showCountryPicker(
                context: context,
                exclude: widget.exclude,
                favorites: widget.favorites,
                filter: widget.filter,
                autofocus: widget.autofocus || widget.useAutofocus,
                showGroup: widget.showGroup,
                showSearch: widget.showSearch,
                showPhoneCode: widget.showPhoneCode,
                showWorldWide: widget.showWorldWide,
                isScrollControlled: widget.isScrollControlled,
                useHaptickFeedback: widget.useHaptickFeedback,
                shouldCloseOnSwipeDown: widget.shouldCloseOnSwipeDown,
                initialChildSize: widget.initialChildSize,
                minChildSize: widget.minChildSize,
                selected: _countryController,
                onSelect: _onSelect,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  '${selected.flagEmoji} ${localization.getFormatedCountryNameByCode(selected.countryCode)}',
                  style: defaultTextStyle,
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
            Row(
              children: <Widget>[
                // --- Phone code --- //
                Padding(
                  padding: padding,
                  child: Text(
                    '+${selected.phoneCode}',
                    style: defaultTextStyle?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
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
                    child: TextFormField(
                      key: const ValueKey<String>(
                        'country_phone_input_extended',
                      ),
                      autofocus: widget.autofocus,
                      controller: _phoneController,
                      inputFormatters: [_formater],
                      style: defaultTextStyle,
                      cursorColor: defaultTextStyle?.color,
                      cursorHeight: defaultTextStyle?.fontSize,
                      onChanged: (_) {
                        widget.onChanged?.call(_controller.text);
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText:
                            widget.placeholder ??
                            selected.mask ??
                            localization.phonePlaceholder,
                        hintStyle: defaultTextStyle?.copyWith(
                          color: pickerTheme.searchTextStyle?.color?.withValues(
                            alpha: .5,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            divider,
          ],
        ),
      ),
    );
  }
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
  double? get radius => pickerTheme.value?.radius;

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
