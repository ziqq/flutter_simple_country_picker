// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:async';
import 'dart:ui' as ui show PointMode;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/src/constant/constant.dart';
import 'package:flutter_simple_country_picker/src/theme/country_picker_theme.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:meta/meta.dart';
import 'package:platform_info/platform_info.dart';

/// Default phone mask filter.
final _kDefaultFilter = {'0': RegExp('[0-9]')};

/// {@template country_phone_input}
/// CountryPhoneInputExperimental widget.
/// {@endtemplate}
@experimental
class CountryPhoneInputExperimental extends StatefulWidget {
  /// {@macro country_phone_input}
  const CountryPhoneInputExperimental({
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

  /// An optional argument for customizing the [CountryPhoneInputExperimental].
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
  State<CountryPhoneInputExperimental> createState() =>
      _CountryPhoneInputExperimentalState();
}

/// Stete for widget [CountryPhoneInputExperimental]
class _CountryPhoneInputExperimentalState
    extends State<CountryPhoneInputExperimental> {
  late final MaskTextInputFormatter _maskFormatter;
  late final TextEditingController _controller;

  late String? _mask;
  late String _country;
  late String _countryCode;

  @override
  void initState() {
    super.initState();

    _country = widget.country;
    _countryCode = widget.countryCode;
    _mask = widget.mask ?? kDefaultPhoneMask;

    _controller = widget.controller ?? TextEditingController();

    _maskFormatter = MaskTextInputFormatter(
      mask: _mask,
      filter: _kDefaultFilter,
      initialText: _controller.text,
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CountryPhoneInputExperimental oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      final current = _controller;
      if (oldWidget.controller == null) scheduleMicrotask(current.dispose);
      _controller = widget.controller ?? TextEditingController();
    }

    if (widget.country != oldWidget.country) {
      _country = widget.country;
    }

    if (widget.countryCode != oldWidget.countryCode) {
      _countryCode = widget.countryCode;
    }

    if (widget.mask != oldWidget.mask) {
      _controller.text = '';
      _mask = widget.mask ?? kDefaultPhoneMask;
      _maskFormatter.updateMask(mask: _mask, filter: _kDefaultFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickerTheme =
        CountryPickerTheme.resolve(context, widget.countryPickerThemeData);
    final inputPadding = EdgeInsets.symmetric(
        horizontal: pickerTheme.padding / 2, vertical: pickerTheme.indent);

    final textStyle = widget.textStyle ?? Theme.of(context).textTheme.bodyLarge;
    final defaultTextStyle = textStyle?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: platform.iOS ? -0.3 : 0,
      color: CupertinoDynamicColor.resolve(
        CupertinoColors.label,
        context,
      ),
    );

    return Material(
      color: pickerTheme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: pickerTheme.dividerColor),

          // Country name with flag
          GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(
                  top: pickerTheme.indent,
                  bottom: pickerTheme.indent,
                  left: pickerTheme.padding,
                  right: pickerTheme.padding / 2,
                ),
                child: Text(
                  _country,
                  style: defaultTextStyle?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Divider
          SizedBox(
            height: 1,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 1),
              painter: _CustomDividerPainter(color: pickerTheme.dividerColor),
            ),
          ),

          // Input with mask
          Row(
            children: [
              Padding(
                padding: inputPadding,
                child: Text(
                  '+ $_countryCode',
                  style: defaultTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 30,
                child: VerticalDivider(
                  color: pickerTheme.dividerColor,
                  thickness: 1,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: inputPadding.horizontal / 2.5,
                  ),
                  child: TextFormField(
                    autofocus: widget.autofocus,
                    controller: _controller,
                    inputFormatters: [_maskFormatter],
                    keyboardType: TextInputType.number,
                    style: defaultTextStyle,
                    cursorColor: defaultTextStyle?.color,
                    cursorHeight: defaultTextStyle?.fontSize,
                    onChanged: (_) => widget.onChanged?.call(
                      '+ $_countryCode ${_controller.text}',
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
                        color: pickerTheme.inputDecoration?.hintStyle?.color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1, thickness: 1, color: pickerTheme.dividerColor),
        ],
      ),
    );
  }
}

/// Custom painter for divider.
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
