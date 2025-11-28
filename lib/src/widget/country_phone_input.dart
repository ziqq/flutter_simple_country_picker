import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

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
    this.exclude,
    this.favorite,
    this.filter,
    this.placeholder,
    this.autofocus = false,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.shouldReplace8 = true,
    this.useAutofocus = false,
    this.useHaptickFeedback = true,
    this.isScrollControlled = false,
    this.showSearch,
    super.key,
  });

  /// This constructor creates an extended version of [CountryPhoneInput].
  /// {@macro country_phone_input}
  const factory CountryPhoneInput.extended({
    Country? initialCountry,
    ValueNotifier<String>? controller,
    void Function(String phone)? onChanged,
    List<String>? exclude,
    List<String>? favorite,
    List<String>? filter,
    String? placeholder,
    bool autofocus,
    bool showPhoneCode,
    bool showWorldWide,
    bool shouldReplace8,
    bool isScrollControlled,
    bool? showSearch,
  }) = CountryPhoneInput$Extended;

  /// The initial country.
  final Country? initialCountry;

  /// Called whne the phone number is changed.
  final ValueNotifier<String>? controller;

  /// List of country codes to exclude.
  final List<String>? exclude;

  /// List of favorite country codes.
  final List<String>? favorite;

  /// List of filtered country codes.
  final List<String>? filter;

  /// Placeholder text.
  final String? placeholder;

  /// Use autofocus for the search countryies input field.
  final bool autofocus;

  /// Controls the scrolling behavior of the modal window.
  final bool isScrollControlled;

  /// Show phone code in countires list.
  final bool showPhoneCode;

  /// Show "World Wide" in countires list.
  final bool showWorldWide;

  /// Show countryies search bar?
  final bool? showSearch;

  /// Replace 8 with +7 in the phone number.
  final bool shouldReplace8;

  /// Use autofocus for the search countryies input field.
  @Deprecated('Use autofocus instead. This will be removed in v1.0.0 releases.')
  final bool useAutofocus;

  /// Use haptic feedback?
  final bool useHaptickFeedback;

  /// Called when the phone number is changed.
  final void Function(String phone)? onChanged;

  @override
  State<CountryPhoneInput> createState() => _CountryPhoneInputState();
}

/// Mixin for state [CountryPhoneInput].
mixin _CountryPhoneInputStateMixin<T extends CountryPhoneInput> on State<T> {
  final ValueNotifier<CountryPickerTheme?> _pickerTheme = ValueNotifier(null);
  late final TextEditingController _phoneController;
  late final CountryInputFormatter _formater;
  late ValueNotifier<String> _controller;
  late ValueNotifier<Country> _selected;

  @override
  void initState() {
    super.initState();
    final initialCountry = widget.initialCountry ?? Country.ru();
    _phoneController = TextEditingController()..addListener(_onPhoneChanged);
    _controller = widget.controller ?? ValueNotifier<String>('');
    _formater = CountryInputFormatter(
      mask: initialCountry.mask,
      filter: {'0': RegExp('[0-9]')},
    );

    _selected = ValueNotifier<Country>(initialCountry);
    _selected.addListener(_onSelectedChanged);

    // If the controller has an initial value
    if (_controller.value.isNotEmpty) {
      final oldValue = _phoneController.value;
      var text = _controller.value;

      // Check if the phone code is not removed from the text
      final phoneCode = _selected.value.phoneCode;
      if (phoneCode.isNotEmpty) {
        text = text.replaceFirst(RegExp(r'^\+?' + phoneCode + r'\s?'), '');
      }

      // Check if the phone number starts with 8
      if (widget.shouldReplace8 && text.startsWith('8')) {
        text = text.substring(1);
      }

      _phoneController.text = _formater.maskText(text);

      // Apply formatting to the new value
      _formater.formatEditUpdate(oldValue, _phoneController.value);

      // Update the cursor position
      _phoneController.selection = TextSelection.collapsed(
        offset: _phoneController.text.length,
      );
    }
  }

  @override
  void didChangeDependencies() {
    _pickerTheme.value = CountryPickerTheme.resolve(context);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the initial country has changed
    final initialCountry = widget.initialCountry;
    if (widget.initialCountry != oldWidget.initialCountry &&
        initialCountry != null) {
      _selected.value = initialCountry;
      _formater.updateMask(mask: initialCountry.mask);
    }

    // Check if the controller has changed
    if (!identical(oldWidget.controller, widget.controller)) {
      final current = _controller;
      if (oldWidget.controller == null) scheduleMicrotask(current.dispose);
      _controller = widget.controller ?? ValueNotifier<String>('');

      final oldValue = _phoneController.value;
      var text = _controller.value;

      final phoneCode = _selected.value.phoneCode;
      if (phoneCode.isNotEmpty) {
        text = text.replaceFirst(RegExp(r'^\+?' + phoneCode + r'\s?'), '');
      }

      if (widget.shouldReplace8 && text.startsWith('8')) {
        text = text.substring(1);
      }

      _phoneController.text = _formater.maskText(text);
      _formater.formatEditUpdate(oldValue, _phoneController.value);
      _phoneController.selection = TextSelection.collapsed(
        offset: _phoneController.text.length,
      );
    }

    // Check if the shouldReplace8 has changed
    if (widget.shouldReplace8 != oldWidget.shouldReplace8) {
      final oldValue = _phoneController.value;
      var text = _phoneController.text;

      if (widget.shouldReplace8 && text.startsWith('8')) {
        text = text.substring(1);
      }

      _phoneController.text = _formater.maskText(text);
      _formater.formatEditUpdate(oldValue, _phoneController.value);
      _phoneController.selection = TextSelection.collapsed(
        offset: _phoneController.text.length,
      );
    }
  }

  @override
  void dispose() {
    _pickerTheme.dispose();
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    _selected
      ..removeListener(_onSelectedChanged)
      ..dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (!mounted) return;
    _controller.value =
        '+${_selected.value.phoneCode} ${_phoneController.text}';
  }

  void _onSelectedChanged() {
    if (!mounted) return;

    // Check if the mask is present
    final mask = _selected.value.mask;
    if (mask == null || mask.isEmpty) return;

    // Update the formatter mask
    _formater.updateMask(mask: mask);

    // Format the current text in the controller after changing the mask
    final oldValue = _phoneController.value;
    _phoneController.text = _formater.maskText(_phoneController.text);
    _formater.formatEditUpdate(oldValue, _phoneController.value);
  }

  void _onSelect(Country country) {
    if (!mounted) return;
    if (country == _selected.value) return;
    if (country.mask?.isEmpty ?? true) {
      ScaffoldMessenger.maybeOf(context)
        ?..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            backgroundColor: CupertinoDynamicColor.resolve(
              CupertinoColors.systemRed,
              context,
            ),
            content: const Text(
              'Phone mask is not defined. Please add issue from github.',
            ),
          ),
        );
      return;
    }
    _phoneController.clear();
    _formater.clear();
    _selected.value = country;
  }
}

/// State for widget [CountryPhoneInput].
class _CountryPhoneInputState extends State<CountryPhoneInput>
    with _CountryPhoneInputStateMixin {
  late final _BackgroundPainter _painter = _BackgroundPainter(
    pickerTheme: _pickerTheme,
  );

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
      valueListenable: _selected,
      builder: (context, selected, _) => Row(
        spacing: pickerTheme.indent,
        children: [
          ConstrainedBox(
            constraints: constraints,
            child: CupertinoButton(
              key: const ValueKey<String>('country_picker_button'),
              onPressed: () => showCountryPicker(
                context: context,
                exclude: widget.exclude,
                favorite: widget.favorite,
                filter: widget.filter,
                autofocus: widget.autofocus || widget.useAutofocus,
                showSearch: widget.showSearch,
                showPhoneCode: widget.showPhoneCode,
                showWorldWide: widget.showWorldWide,
                isScrollControlled: widget.isScrollControlled,
                useHaptickFeedback: widget.useHaptickFeedback,
                selected: _selected,
                onSelect: _onSelect,
              ),
              padding: EdgeInsets.symmetric(horizontal: pickerTheme.padding),
              color: pickerTheme.secondaryBackgroundColor,
              borderRadius: BorderRadius.all(
                Radius.circular(pickerTheme.radius),
              ),
              pressedOpacity: .6,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 3,
                  children: [
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
                child: CustomPaint(
                  painter: _painter,
                  child: Center(
                    child: TextFormField(
                      key: const ValueKey<String>('country_phone_input'),
                      autofocus: widget.autofocus,
                      controller: _phoneController,
                      inputFormatters: [_formater],
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        widget.onChanged?.call(_controller.value);
                      },
                      decoration: InputDecoration(
                        hintText:
                            widget.placeholder ??
                            selected.mask ??
                            localization.phonePlaceholder,
                        hintStyle: textStyle?.copyWith(
                          color: CupertinoDynamicColor.resolve(
                            CupertinoColors.placeholderText,
                            context,
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
    );
  }
}

/// CountryPhoneInput$Extended widget.
/// {@macro country_phone_input}
class CountryPhoneInput$Extended extends CountryPhoneInput {
  /// {@macro country_phone_input}
  const CountryPhoneInput$Extended({
    super.autofocus,
    super.controller,
    super.onChanged,
    super.exclude,
    super.favorite,
    super.filter,
    super.initialCountry,
    super.isScrollControlled,
    super.placeholder,
    super.shouldReplace8,
    super.showPhoneCode,
    super.showWorldWide,
    super.showSearch,
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
      color: pickerTheme.backgroundColor,
      child: ValueListenableBuilder(
        valueListenable: _selected,
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
                favorite: widget.favorite,
                filter: widget.filter,
                autofocus: widget.autofocus || widget.useAutofocus,
                showSearch: widget.showSearch,
                showPhoneCode: widget.showPhoneCode,
                showWorldWide: widget.showWorldWide,
                isScrollControlled: widget.isScrollControlled,
                useHaptickFeedback: widget.useHaptickFeedback,
                selected: _selected,
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
                        widget.onChanged?.call(_controller.value);
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText:
                            widget.placeholder ??
                            selected.mask ??
                            localization.phonePlaceholder,
                        hintStyle: defaultTextStyle?.copyWith(
                          color: CupertinoDynamicColor.resolve(
                            CupertinoColors.placeholderText,
                            context,
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
  Color? get color => pickerTheme.value?.secondaryBackgroundColor;

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
