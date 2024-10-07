// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:ui' as ui show PointMode;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/constant.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:platform_info/platform_info.dart';

final _kDefaultFilter = {'0': RegExp('[0-9]')};

/// {@template country_phone_input}
/// CountryPhoneInput widget.
/// {@endtemplate}
class CountryPhoneInput extends StatefulWidget {
  /// {@macro country_phone_input}
  const CountryPhoneInput({
    this.autofocus = true,
    this.country = '🇷🇺 Россия',
    this.countryCode = '7',
    this.mask,
    this.textStyle,
    this.countryPickerThemeData,
    this.controller,
    this.onTap,
    this.onLongPress,
    this.onChanged,
    super.key,
  });

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// The country name.
  final String country;

  /// The country code.
  final String countryCode;

  /// An optional argument for customizing the mask.
  final String? mask;

  /// An optional argument for customizing the [Text] widget.
  final TextStyle? textStyle;

  /// An optional argument for customizing the [CountryPhoneInput].
  final CountryPickerTheme? countryPickerThemeData;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Called when the country name is tapped.
  final VoidCallback? onTap;

  /// Called when the country name is long pressed.
  final VoidCallback? onLongPress;

  /// Called when the text being edited changes.
  final void Function(String)? onChanged;

  @override
  State<CountryPhoneInput> createState() => CountryPhoneInputState();
}

/// Stete of [CountryPhoneInput]
class CountryPhoneInputState extends State<CountryPhoneInput> {
  late String? _mask;
  late String _country;
  late String _countryCode;

  late final TextEditingController _effectiveController;
  late final MaskTextInputFormatter _maskFormatter;

  @override
  void initState() {
    super.initState();

    _country = widget.country;
    _countryCode = widget.countryCode;
    _mask = widget.mask ?? kDefaultPhoneMask;

    _effectiveController = widget.controller ?? TextEditingController();

    _maskFormatter = MaskTextInputFormatter(
      mask: _mask,
      filter: _kDefaultFilter,
      initialText: _effectiveController.text,
    );
  }

  @override
  void dispose() {
    _effectiveController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CountryPhoneInput oldWidget) {
    if (widget.countryCode != oldWidget.countryCode) {
      _countryCode = widget.countryCode;
    }
    if (widget.country != oldWidget.country) {
      _country = widget.country;
    }
    if (widget.mask != oldWidget.mask) {
      _mask = widget.mask ?? kDefaultPhoneMask;
      _effectiveController.text = '';

      _maskFormatter.updateMask(
        mask: _mask,
        filter: _kDefaultFilter,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData = widget.countryPickerThemeData;

    final defaultTextStyle = (widget.textStyle ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: platform.iOS ? -0.3 : 0,
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.label,
          context,
        ),
        fontFamily: platform.iOS ? 'SF-Pro-Rounded' : null);

    final effectiveBackgroundColor =
        customThemeData?.backgroundColor ?? CupertinoDynamicColor.resolve(CupertinoColors.systemBackground, context);

    final effectiveDividerColor =
        customThemeData?.dividerColor ?? CupertinoDynamicColor.resolve(CupertinoColors.opaqueSeparator, context);

    final effectiveHintColor = customThemeData?.inputDecoration?.hintStyle?.color ??
        CupertinoDynamicColor.resolve(CupertinoColors.placeholderText, context);

    final effectiveCountryNamePadding = customThemeData != null
        ? EdgeInsets.only(
            top: customThemeData.indent,
            bottom: customThemeData.indent,
            left: customThemeData.padding,
            right: customThemeData.padding / 2,
          )
        : const EdgeInsets.only(
            top: kDefaultIndent,
            bottom: kDefaultIndent,
            left: kDefaultPadding,
            right: kDefaultPadding / 2,
          );

    final effectiveInputPadding = customThemeData != null
        ? EdgeInsets.symmetric(
            horizontal: customThemeData.padding / 2,
            vertical: customThemeData.indent,
          )
        : const EdgeInsets.symmetric(
            horizontal: kDefaultPadding / 2,
            vertical: kDefaultIndent,
          );

    return Material(
      color: effectiveBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: effectiveDividerColor),

          // Country name with flag
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            },
            onLongPress: widget.onLongPress,
            child: Container(
              width: double.infinity,
              padding: effectiveCountryNamePadding,
              child: Text(
                _country,
                style: defaultTextStyle?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Divider
          SizedBox(
            height: 1,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 1),
              painter: _CustomDividerPainter(
                color: effectiveDividerColor,
              ),
            ),
          ),

          // Input with mask
          Row(
            children: [
              Padding(
                padding: effectiveInputPadding,
                child: Text(
                  '+ $_countryCode',
                  style: defaultTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 30,
                child: VerticalDivider(
                  color: effectiveDividerColor,
                  thickness: 1,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: effectiveInputPadding.horizontal / 2.5,
                  ),
                  child: TextFormField(
                    autofocus: widget.autofocus,
                    controller: _effectiveController,
                    inputFormatters: [_maskFormatter],
                    keyboardType: TextInputType.number,
                    style: defaultTextStyle,
                    cursorColor: defaultTextStyle?.color,
                    cursorHeight: defaultTextStyle?.fontSize,
                    onChanged: (_) => widget.onChanged?.call(
                      '+ $_countryCode ${_effectiveController.text}',
                    ),
                    decoration: InputDecoration(
                      hintText: _mask,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                      hintStyle: defaultTextStyle?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: effectiveHintColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1, thickness: 1, color: effectiveDividerColor),
        ],
      ),
    );
  }
}

class _CustomDividerPainter extends CustomPainter {
  _CustomDividerPainter({this.color});
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = ui.PointMode.polygon;
    final points = [
      Offset.zero,
      const Offset(22, 0),
      const Offset(30, 8),
      const Offset(38, 0),
      Offset(size.width, 0),
    ];
    final paint = Paint()
      ..color = color ?? Colors.black
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
