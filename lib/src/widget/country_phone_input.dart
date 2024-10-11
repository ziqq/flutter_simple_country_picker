import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:meta/meta.dart';

/// Default height for [CountryPhoneInput].
const double _kDefaultCountyInputHeight = 56;

@experimental
void _log(String message) =>
    kDebugMode ? dev.log(message, name: 'county_phone_input') : null;

/// {@template county_input}
/// CountryInput widget.
/// {@endtemplate}
class CountryPhoneInput extends StatelessWidget {
  /// {@macro county_input}
  const CountryPhoneInput({
    required this.countryCode,
    this.countryFlag,
    this.placeholder = 'Phone number',
    this.onDone,
    this.onSelect,
    this.exclude,
    this.favorite,
    this.filter,
    this.showPhoneCode = false,
    this.showWorldWide = false,
    this.useAutofocus = false,
    this.useHaptickFeedback = true,
    this.useSafeArea = false,
    this.showSearch,
    super.key,
  });

  /// Current country code.
  final String countryCode;

  /// Current country flag as emoji.
  final String? countryFlag;

  /// Placeholder text.
  final String? placeholder;

  /// Called when the country was selected.
  final VoidCallback? onDone;

  /// Called when the country be select.
  final ValueChanged<Country>? onSelect;

  /// List of country codes to exclude.
  final List<String>? exclude;

  /// List of favorite country codes.
  final List<String>? favorite;

  /// List of filtered country codes.
  final List<String>? filter;

  /// Show phone code in countires list.
  final bool showPhoneCode;

  /// Show "World Wide" in countires list.
  final bool showWorldWide;

  /// Use autofocus for the search countryies input field.
  final bool useAutofocus;

  /// Use haptic feedback?
  final bool useHaptickFeedback;

  /// Use safe area?
  final bool useSafeArea;

  /// Show countryies search bar?
  final bool? showSearch;

  @override
  Widget build(BuildContext context) {
    final pickerTheme = CountryPickerTheme.resolve(context);
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
    return Row(
      children: [
        GestureDetector(
          onTap: () => showCountryPicker(
            context: context,
            exclude: exclude,
            favorite: favorite,
            filter: filter,
            showPhoneCode: showPhoneCode,
            showWorldWide: showWorldWide,
            useAutofocus: useAutofocus,
            useHaptickFeedback: useHaptickFeedback,
            useSafeArea: useSafeArea,
            showSearch: showSearch,
            onSelect: (country) {
              _log('Selected country $country');
              onSelect?.call(country);
              // setState(() {
              //   _country = '${country.countryFlag} ${country.nameLocalized}';
              //   _countryCode = country.phoneCode;
              //   _mask = country.mask;
              // });
            },
            onDone: () {
              _log('onDone called...');
              onDone?.call();
            },
          ),
          child: CustomPaint(
            painter: painter,
            child: ConstrainedBox(
              constraints: constraints,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pickerTheme.padding),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (countryFlag != null && countryFlag!.isNotEmpty) ...[
                        Text('$countryFlag', style: textStyle),
                      ],
                      Text('+$countryCode', style: textStyle),
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
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: textStyle,
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

  /// The radii of the rounded corners of the rectangle.
  // final BorderRadius borderRadius;

  /// The border to draw around the rounded rectangle.
  // final Border border;

  /// The size of the gap in the border where the label is.
  // final double gapExtent;

  /// The fraction of the border along the gap that should be painted.
  // final double gapPercentage;

  /// The text direction to use for painting the border.
  // final TextDirection? textDirection;

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
