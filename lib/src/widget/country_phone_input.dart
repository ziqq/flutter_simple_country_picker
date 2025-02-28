import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

/// Default height for [CountryPhoneInput].
const double _kDefaultCountyInputHeight = 56;

/// {@template county_input}
/// CountryInput widget.
/// {@endtemplate}
class CountryPhoneInput extends StatefulWidget {
  /// {@macro county_input}
  const CountryPhoneInput({
    this.initialCountry,
    this.controller,
    this.exclude,
    this.favorite,
    this.filter,
    this.placeholder,
    this.isScrollControlled = false,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.useAutofocus = false,
    this.shouldReplace8 = true,
    this.useHaptickFeedback = true,
    this.showSearch,
    super.key,
  });

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
  final bool useAutofocus;

  /// Use haptic feedback?
  final bool useHaptickFeedback;

  @override
  State<CountryPhoneInput> createState() => _CountryPhoneInputState();
}

/// State for widget [CountryPhoneInput].
class _CountryPhoneInputState extends State<CountryPhoneInput> {
  static final Country _defaultCountry = Country.ru();
  late final TextEditingController _controller;
  late final CountryInputFormatter _formater;
  late ValueNotifier<Country?> _selected;

  @override
  void initState() {
    super.initState();
    final initialCountry = widget.initialCountry ?? _defaultCountry;

    _controller = TextEditingController();
    _controller.addListener(_onPhoneChanged);

    _formater = CountryInputFormatter(
      mask: initialCountry.mask,
      filter: {'0': RegExp('[0-9]')},
    );

    _selected = ValueNotifier<Country?>(initialCountry);
    _selected.addListener(_onSelectedChanged);

    // If the controller has an initial value
    if (widget.controller?.value != null) {
      final oldValue = _controller.value;
      var text = widget.controller?.value ?? '';

      // Check if the phone code is not removed from the text
      final phoneCode = _selected.value?.phoneCode;
      if (phoneCode != null) {
        text = text.replaceFirst(RegExp(r'^\+?' + phoneCode + r'\s?'), '');
      }

      // Check if the phone number starts with 8
      if (widget.shouldReplace8 && text.startsWith('8')) {
        text = text.substring(1);
      }

      _controller.text = _formater.maskText(text);

      // Apply formatting to the new value
      _formater.formatEditUpdate(oldValue, _controller.value);

      // Update the cursor position
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void didUpdateWidget(covariant CountryPhoneInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the initial country has changed
    if (widget.initialCountry != oldWidget.initialCountry &&
        widget.initialCountry != null) {
      _selected.value = widget.initialCountry;
      _formater.updateMask(mask: widget.initialCountry!.mask);
    }

    // Check if the controller has changed
    if (widget.controller != oldWidget.controller &&
        widget.controller != null) {
      final oldValue = _controller.value;
      var text = widget.controller!.value;

      final phoneCode = _selected.value?.phoneCode;
      if (phoneCode != null) {
        text = text.replaceFirst(RegExp(r'^\+?' + phoneCode + r'\s?'), '');
      }

      if (widget.shouldReplace8 && text.startsWith('8')) {
        text = text.substring(1);
      }

      _controller.text = _formater.maskText(text);
      _formater.formatEditUpdate(oldValue, _controller.value);
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }

    // Check if the shouldReplace8 has changed
    if (widget.shouldReplace8 != oldWidget.shouldReplace8) {
      final oldValue = _controller.value;
      var text = _controller.text;

      if (widget.shouldReplace8 && text.startsWith('8')) {
        text = text.substring(1);
      }

      _controller.text = _formater.maskText(text);
      _formater.formatEditUpdate(oldValue, _controller.value);
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onPhoneChanged)
      ..dispose();
    _selected
      ..removeListener(_onSelectedChanged)
      ..dispose();
    super.dispose();
  }

  void _onSelectedChanged() {
    if (!mounted) return;

    // Check if the mask is present
    final mask = _selected.value?.mask;
    if (mask == null || mask.isEmpty) return;

    // Update the formatter mask
    _formater.updateMask(mask: mask);

    // Format the current text in the controller after changing the mask
    final oldValue = _controller.value;
    _controller.text = _formater.maskText(_controller.text);
    _formater.formatEditUpdate(oldValue, _controller.value);
  }

  void _onPhoneChanged() {
    if (!mounted) return;
    final phone = '+${_selected.value?.phoneCode} ${_controller.text}';
    widget.controller?.value = phone;
  }

  void _onSelect(Country country) {
    if (!mounted) return;
    if (country == _selected.value) return;
    if (country.mask == null || country.mask!.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          backgroundColor: CupertinoDynamicColor.resolve(
            CupertinoColors.systemRed,
            context,
          ),
          content: const Text(
              'Phone mask is not defined. Please add issue from github.'),
        ),
      );
      return;
    }
    _controller.clear();
    _formater.clear();
    _selected.value = country;
  }

  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.resolve(context);
    final localization = CountriesLocalization.of(context);
    final textStyle =
        pickerTheme.textStyle ?? Theme.of(context).textTheme.bodyLarge;
    final painter = _CountryPhoneInput$BackgroundPainter(
      color: pickerTheme.secondaryBackgroundColor,
      radius: pickerTheme.radius,
    );
    const constraints = BoxConstraints(
      minHeight: _kDefaultCountyInputHeight,
      minWidth: _kDefaultCountyInputHeight,
    );
    return ValueListenableBuilder(
      valueListenable: _selected,
      builder: (context, selected, _) => Row(
        children: [
          GestureDetector(
            onTap: () => showCountryPicker(
              context: context,
              exclude: widget.exclude,
              favorite: widget.favorite,
              filter: widget.filter,
              isScrollControlled: widget.isScrollControlled,
              showSearch: widget.showSearch,
              showPhoneCode: widget.showPhoneCode,
              showWorldWide: widget.showWorldWide,
              useAutofocus: widget.useAutofocus,
              useHaptickFeedback: widget.useHaptickFeedback,
              selected: _selected,
              onSelect: _onSelect,
              // onDone: widget.onDone,
            ),
            child: CustomPaint(
              painter: painter,
              child: ConstrainedBox(
                constraints: constraints,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: pickerTheme.padding,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected?.flagEmoji != null &&
                            selected!.flagEmoji.isNotEmpty) ...[
                          Text(selected.flagEmoji, style: textStyle),
                        ],
                        Text('+${selected?.phoneCode}', style: textStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: pickerTheme.indent),
          Flexible(
            child: ConstrainedBox(
              constraints: constraints,
              child: CustomPaint(
                painter: painter,
                child: Center(
                  child: TextFormField(
                    controller: _controller,
                    inputFormatters: [_formater],
                    decoration: InputDecoration(
                      hintText: widget.placeholder ??
                          selected?.mask ??
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
        ],
      ),
    );
  }
}

/// Background painter for [CountryPhoneInput].
///
/// {@macro county_input}
class _CountryPhoneInput$BackgroundPainter extends CustomPainter {
  /// Creates a [CustomPaint] that paints a rounded rectangle.
  const _CountryPhoneInput$BackgroundPainter({
    this.color,
    this.radius,
  });

  /// The color to fill in the background of the rounded rectangle.
  final Color? color;

  /// The radius of the rounded corners of the rectangle.
  final double? radius;

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
}
