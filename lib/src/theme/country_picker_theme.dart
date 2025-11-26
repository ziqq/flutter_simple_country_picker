/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/src/constant/constant.dart';

/// {@template country_picker_theme}
/// Custom country picker theme.
/// {@endtemplate}
@immutable
class CountryPickerTheme extends ThemeExtension<CountryPickerTheme>
    with Diagnosticable {
  /// {@macro country_picker_theme}
  factory CountryPickerTheme({
    Color? accentColor,
    Color? backgroundColor,
    Color? barrierColor,
    Color? dividerColor,
    Color? secondaryBackgroundColor,
    double? flagSize,
    double? padding,
    double? indent,
    double? radius,
    TextStyle? textStyle,
    TextStyle? searchTextStyle,
    InputDecoration? inputDecoration,
  }) {
    flagSize ??= kDefaultFlagSize;
    padding ??= kDefaultPadding;
    indent ??= kDefaultIndent;
    radius ??= kDefaultRadius;
    return CountryPickerTheme.raw(
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      dividerColor: dividerColor,
      secondaryBackgroundColor: secondaryBackgroundColor,
      inputDecoration: inputDecoration,
      searchTextStyle: searchTextStyle,
      textStyle: textStyle,
      flagSize: flagSize,
      padding: padding,
      indent: indent,
      radius: radius,
    );
  }

  /// Create a [CountryPickerTheme] given a set of exact values.
  const CountryPickerTheme.raw({
    required this.accentColor,
    required this.backgroundColor,
    required this.barrierColor,
    required this.dividerColor,
    required this.secondaryBackgroundColor,
    required this.inputDecoration,
    required this.searchTextStyle,
    required this.textStyle,
    required this.flagSize,
    required this.padding,
    required this.indent,
    required this.radius,
  });

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `CountryPickerTheme.of(context)`
  factory CountryPickerTheme.of(BuildContext context) =>
      maybeOf(context) ?? CountryPickerTheme.defaults(context);

  /// Creates default set of properties used to configure
  /// [CountryPickerTheme].
  @internal
  factory CountryPickerTheme.defaults(BuildContext context) =
      _CountryPickerTheme$Default;

  /// The helper method to quickly resolve [PullDownMenuItemTheme] from
  /// various sources.
  @internal
  factory CountryPickerTheme.resolve(
    BuildContext context, [
    CountryPickerTheme? other,
  ]) {
    final defaults = CountryPickerTheme.defaults(context);
    final theme = CountryPickerTheme.maybeOf(context);
    return CountryPickerTheme(
      accentColor:
          other?.accentColor ?? theme?.accentColor ?? defaults.accentColor,
      backgroundColor: other?.backgroundColor ??
          theme?.backgroundColor ??
          defaults.backgroundColor,
      barrierColor:
          other?.barrierColor ?? theme?.barrierColor ?? defaults.barrierColor,
      dividerColor:
          other?.dividerColor ?? theme?.dividerColor ?? defaults.dividerColor,
      secondaryBackgroundColor: other?.secondaryBackgroundColor ??
          theme?.secondaryBackgroundColor ??
          defaults.secondaryBackgroundColor,
      inputDecoration: other?.inputDecoration ??
          theme?.inputDecoration ??
          defaults.inputDecoration,
      searchTextStyle: defaults.textStyle
          ?.merge(theme?.searchTextStyle)
          .merge(other?.searchTextStyle),
      textStyle:
          defaults.textStyle?.merge(theme?.textStyle).merge(other?.textStyle),
      flagSize: other?.flagSize ?? theme?.flagSize ?? defaults.flagSize,
      padding: other?.padding ?? theme?.padding ?? defaults.padding,
      indent: other?.indent ?? theme?.indent ?? defaults.indent,
      radius: other?.radius ?? defaults.radius,
    );
  }

  /// A default light theme.
  // factory CountryPickerTheme.light() => CountryPickerTheme();

  /// A default dark theme.
  // factory CountryPickerTheme.dark() => CountryPickerTheme();

  /// Get [CountryPickerTheme] from [InheritedCountryPickerTheme].
  ///
  /// If that's null get [CountryPickerTheme] from [ThemeData.extensions]
  /// property of the ambient [Theme].
  static CountryPickerTheme? maybeOf(BuildContext context) =>
      InheritedCountryPickerTheme.maybeOf(context) ??
      Theme.of(context).extensions[CountryPickerTheme] as CountryPickerTheme?;

  // static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
  //   'Out of scope or out of extensions, not found inherited widget '
  //       'a CountryPickerTheme of the exact type',
  //   'out_of_scope or out_of_extensions',
  // );

  /// The accent color.
  final Color? accentColor;

  /// The background color.
  final Color? backgroundColor;

  /// The barrierColor color.
  final Color? barrierColor;

  /// The divider color.
  final Color? dividerColor;

  /// The secondary background color.
  final Color? secondaryBackgroundColor;

  /// The style to use for country name text.
  final TextStyle? textStyle;

  /// The style to use for search field text.
  final TextStyle? searchTextStyle;

  /// The decoration used for the inputs.
  final InputDecoration? inputDecoration;

  /// The flag size.
  ///
  /// If null, set to `25`
  final double? flagSize;

  /// The padding around elements.
  ///
  /// If null, set to `16.0`
  final double padding;

  /// The indent of the divider.
  ///
  /// If null, set to `10.0`
  final double indent;

  /// The border radius of elements.
  ///
  /// If null, set to `10.0`
  final double radius;

  @override
  CountryPickerTheme copyWith({
    Color? accentColor,
    Color? backgroundColor,
    Color? barrierColor,
    Color? dividerColor,
    Color? secondaryBackgroundColor,
    InputDecoration? inputDecoration,
    TextStyle? searchTextStyle,
    TextStyle? textStyle,
    double? flagSize,
    double? padding,
    double? indent,
    double? radius,
  }) =>
      CountryPickerTheme(
        accentColor: accentColor ?? this.accentColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        barrierColor: barrierColor ?? this.barrierColor,
        dividerColor: dividerColor ?? this.dividerColor,
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? this.secondaryBackgroundColor,
        inputDecoration: inputDecoration ?? this.inputDecoration,
        searchTextStyle: searchTextStyle ?? this.searchTextStyle,
        textStyle: textStyle ?? this.textStyle,
        flagSize: flagSize ?? this.flagSize,
        padding: padding ?? this.padding,
        indent: indent ?? this.indent,
        radius: radius ?? this.radius,
      );

  /// Controls how the properties change on theme changes
  @override
  ThemeExtension<CountryPickerTheme> lerp(
    ThemeExtension<CountryPickerTheme>? other,
    double t,
  ) {
    if (other is! CountryPickerTheme || identical(this, other)) return this;
    return CountryPickerTheme(
      accentColor: Color.lerp(accentColor, other.accentColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      barrierColor: Color.lerp(barrierColor, other.barrierColor, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      secondaryBackgroundColor: Color.lerp(
        secondaryBackgroundColor,
        other.secondaryBackgroundColor,
        t,
      ),
      searchTextStyle: TextStyle.lerp(
        searchTextStyle,
        other.searchTextStyle,
        t,
      ),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      flagSize: ui.lerpDouble(flagSize, other.flagSize, t),
      padding: ui.lerpDouble(padding, other.padding, t),
      indent: ui.lerpDouble(indent, other.indent, t),
      radius: ui.lerpDouble(radius, other.radius, t),
    );
  }

  @override
  int get hashCode => Object.hashAll([
        accentColor,
        backgroundColor,
        barrierColor,
        dividerColor,
        inputDecoration,
        secondaryBackgroundColor,
        searchTextStyle,
        textStyle,
        flagSize,
        padding,
        indent,
        radius,
      ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CountryPickerTheme &&
        other.accentColor == accentColor &&
        other.backgroundColor == backgroundColor &&
        other.dividerColor == dividerColor &&
        other.secondaryBackgroundColor == secondaryBackgroundColor &&
        other.searchTextStyle == searchTextStyle &&
        other.inputDecoration == inputDecoration &&
        other.textStyle == textStyle &&
        other.flagSize == flagSize &&
        other.padding == padding &&
        other.indent == indent &&
        other.radius == radius;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ColorProperty(
          'accentColor',
          accentColor,
          defaultValue: CupertinoColors.systemBlue,
        ),
      )
      ..add(
        ColorProperty(
          'backgroundColor',
          backgroundColor,
          defaultValue: CupertinoColors.systemBackground,
        ),
      )
      ..add(
        ColorProperty(
          'barrierColor',
          barrierColor,
          defaultValue: kCupertinoModalBarrierColor,
        ),
      )
      ..add(
        ColorProperty(
          'dividerColor',
          dividerColor,
          defaultValue: CupertinoColors.opaqueSeparator,
        ),
      )
      ..add(
        DiagnosticsProperty<InputDecoration?>(
          'inputDecoration',
          inputDecoration,
          defaultValue: const InputDecoration(),
        ),
      )
      ..add(
        ColorProperty(
          'secondaryBackgroundColor',
          secondaryBackgroundColor,
          defaultValue: CupertinoColors.systemGroupedBackground,
        ),
      )
      ..add(
        DiagnosticsProperty<TextStyle?>(
          'textStyle',
          textStyle,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<TextStyle?>(
          'searchTextStyle',
          searchTextStyle,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<double>(
          'flagSize',
          flagSize,
          defaultValue: kDefaultFlagSize,
        ),
      )
      ..add(
        DiagnosticsProperty<double>(
          'padding',
          padding,
          defaultValue: kDefaultPadding,
        ),
      )
      ..add(
        DiagnosticsProperty<double>(
          'indent',
          indent,
          defaultValue: kDefaultIndent,
        ),
      )
      ..add(
        DiagnosticsProperty<double>(
          'radius',
          radius,
          defaultValue: kDefaultIndent,
        ),
      );
  }
}

/// Alternative way of defining [CountryPickerTheme].
///
/// Example:
///
/// ```dart
/// MaterialApp(
///    builder: (context, child) => InheritedCountryPickerTheme(
///      data: const CountryPickerTheme(
///        ...
///      ),
///      child: child ?? const SizedBox.shrink(),
///  ),
/// home: ...,
/// ```
@immutable
class InheritedCountryPickerTheme extends InheritedTheme {
  /// Creates a [InheritedCountryPickerTheme].
  const InheritedCountryPickerTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The configuration of this theme.
  final CountryPickerTheme data;

  /// Returns the current [CountryPickerTheme] from the closest
  /// [InheritedCountryPickerTheme] ancestor.
  ///
  /// If there is no ancestor, it returns `null`.
  static CountryPickerTheme? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedCountryPickerTheme>()
      ?.data;

  @override
  bool updateShouldNotify(covariant InheritedCountryPickerTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(
    BuildContext context,
    Widget child,
  ) =>
      InheritedCountryPickerTheme(
        data: data,
        child: child,
      );
}

/// Default [CountryPickerTheme]
/// {@macro country_picker_theme}
@immutable
final class _CountryPickerTheme$Default extends CountryPickerTheme {
  /// Creates [_CountryPickerTheme$Default].
  /// {@macro country_picker_theme}
  _CountryPickerTheme$Default(
    this.context, {
    Color? accentColor,
    Color? backgroundColor,
    Color? barrierColor,
    Color? dividerColor,
    Color? secondaryBackgroundColor,
    InputDecoration? inputDecoration,
    double? radius,
    double? padding,
    double? indent,
    double? flagSize,
    super.textStyle,
    super.searchTextStyle,
  }) : super.raw(
          accentColor: accentColor ??
              CupertinoDynamicColor.resolve(
                CupertinoColors.systemBlue,
                context,
              ),
          secondaryBackgroundColor: secondaryBackgroundColor ??
              CupertinoDynamicColor.resolve(
                CupertinoColors.secondarySystemBackground,
                context,
              ),
          backgroundColor: backgroundColor ??
              CupertinoDynamicColor.resolve(
                CupertinoColors.systemBackground,
                context,
              ),
          barrierColor: barrierColor ?? kCupertinoModalBarrierColor,
          dividerColor: dividerColor ??
              CupertinoDynamicColor.resolve(
                CupertinoColors.opaqueSeparator,
                context,
              ),
          inputDecoration: inputDecoration ?? const InputDecoration(),
          radius: radius ?? kDefaultRadius,
          indent: indent ?? kDefaultIndent,
          padding: padding ?? kDefaultPadding,
          flagSize: flagSize ?? kDefaultFlagSize,
        );

  /// A build context used to resolve [CupertinoDynamicColor]s defined in this
  /// theme.
  final BuildContext context;
}
