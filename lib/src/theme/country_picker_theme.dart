/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_simple_country_picker/src/constant/constants.dart';
import 'package:material_ui/material_ui.dart';

/// {@template country_picker_theme}
/// Visual configuration for all `flutter_simple_country_picker` widgets.
///
/// Register it as a [ThemeExtension] in your [MaterialApp]:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [
///       CountryPickerTheme(
///         backgroundColor: Colors.white,
///         accentColor: Colors.blue,
///         baseCornerRadius: 16,
///         flagSize: 22,
///         textStyle: const TextStyle(fontSize: 16),
///       ),
///     ],
///   ),
/// );
/// ```
///
/// Retrieve the active theme from any widget:
///
/// ```dart
/// final theme = CountryPickerTheme.of(context);
/// ```
///
/// All properties are optional — omitted values fall back to the ambient
/// [Theme]'s color scheme and text styles.
///
/// [baseCornerRadius] controls input fields; [sheetCornerRadius] controls sheets.
/// {@endtemplate}
@immutable
class CountryPickerTheme extends ThemeExtension<CountryPickerTheme>
    with Diagnosticable {
  /// {@macro country_picker_theme}
  factory CountryPickerTheme({
    Color? accentColor,
    Color? backgroundColor,
    Color? onBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? onSecondaryBackgroundColor,
    Color? barrierColor,
    Color? dividerColor,
    double? flagSize,
    double? padding,
    double? baseCornerRadius,
    double? sheetCornerRadius,
    double? inputHeight,
    TextStyle? textStyle,
    TextStyle? secondaryTextStyle,
    TextStyle? searchTextStyle,
  }) {
    inputHeight ??= kCountryPickerDefaultInputHeight;
    flagSize ??= kCountryPickerDefaultFlagSize;
    padding ??= kCountryPickerDefaultPadding;
    baseCornerRadius ??= kCountryPickerDefaultBaseCornerRadius;
    sheetCornerRadius ??= kCountryPickerDefaultSheetCornerRadius;
    return CountryPickerTheme.raw(
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      onBackgroundColor: onBackgroundColor ?? secondaryBackgroundColor,
      secondaryBackgroundColor: secondaryBackgroundColor,
      onSecondaryBackgroundColor: onSecondaryBackgroundColor ?? backgroundColor,
      barrierColor: barrierColor,
      dividerColor: dividerColor,
      inputHeight: inputHeight,
      secondaryTextStyle: secondaryTextStyle,
      searchTextStyle: searchTextStyle,
      textStyle: textStyle,
      flagSize: flagSize,
      padding: padding,
      baseCornerRadius: baseCornerRadius,
      sheetCornerRadius: sheetCornerRadius,
    );
  }

  /// Create a [CountryPickerTheme] given a set of exact values.
  const CountryPickerTheme.raw({
    required this.accentColor,
    required this.backgroundColor,
    required this.onBackgroundColor,
    required this.secondaryBackgroundColor,
    required this.onSecondaryBackgroundColor,
    required this.barrierColor,
    required this.dividerColor,
    required this.inputHeight,
    required this.secondaryTextStyle,
    required this.searchTextStyle,
    required this.textStyle,
    required this.flagSize,
    required this.padding,
    double? baseCornerRadius,
    this.sheetCornerRadius = kCountryPickerDefaultSheetCornerRadius,
  }) : baseCornerRadius =
           baseCornerRadius ?? kCountryPickerDefaultBaseCornerRadius;

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

  /// Resolves the picker theme using app defaults and explicit overrides.
  @internal
  factory CountryPickerTheme.resolve(
    BuildContext context, [
    CountryPickerTheme? other,
  ]) {
    final theme = CountryPickerTheme.maybeOf(context);
    final defaults = CountryPickerTheme.defaults(context);
    final defaultTextStyle = defaults.textStyle ?? const TextStyle();
    var textStyle = defaultTextStyle
        .merge(theme?.textStyle)
        .merge(other?.textStyle);
    if (textStyle.color == null && textStyle.foreground == null) {
      final fallback =
          defaultTextStyle.color != null || defaultTextStyle.foreground != null
          ? defaultTextStyle
          : DefaultTextStyle.of(context).style;
      textStyle = textStyle.copyWith(
        color: fallback.color,
        foreground: fallback.foreground,
      );
    }
    return CountryPickerTheme(
      accentColor:
          other?.accentColor ?? theme?.accentColor ?? defaults.accentColor,
      backgroundColor:
          other?.backgroundColor ??
          theme?.backgroundColor ??
          defaults.backgroundColor,
      onBackgroundColor:
          other?.onBackgroundColor ??
          theme?.onBackgroundColor ??
          defaults.onBackgroundColor,
      secondaryBackgroundColor:
          other?.secondaryBackgroundColor ??
          theme?.secondaryBackgroundColor ??
          defaults.secondaryBackgroundColor,
      onSecondaryBackgroundColor:
          other?.onSecondaryBackgroundColor ??
          theme?.onSecondaryBackgroundColor ??
          defaults.onSecondaryBackgroundColor,
      barrierColor:
          other?.barrierColor ?? theme?.barrierColor ?? defaults.barrierColor,
      dividerColor:
          other?.dividerColor ?? theme?.dividerColor ?? defaults.dividerColor,
      inputHeight:
          other?.inputHeight ?? theme?.inputHeight ?? defaults.inputHeight,
      secondaryTextStyle: defaults.secondaryTextStyle
          ?.merge(theme?.secondaryTextStyle)
          .merge(other?.secondaryTextStyle),
      searchTextStyle: textStyle
          .merge(theme?.searchTextStyle)
          .merge(other?.searchTextStyle),
      textStyle: textStyle,
      flagSize: other?.flagSize ?? theme?.flagSize ?? defaults.flagSize,
      padding: other?.padding ?? theme?.padding ?? defaults.padding,
      baseCornerRadius:
          other?.baseCornerRadius ??
          theme?.baseCornerRadius ??
          defaults.baseCornerRadius,
      sheetCornerRadius:
          other?.sheetCornerRadius ??
          theme?.sheetCornerRadius ??
          defaults.sheetCornerRadius,
    );
  }

  /// Get [CountryPickerTheme] from [InheritedCountryPickerTheme].
  ///
  /// If that's null get [CountryPickerTheme] from [ThemeData.extensions]
  /// property of the ambient [Theme].
  static CountryPickerTheme? maybeOf(BuildContext context) =>
      InheritedCountryPickerTheme.maybeOf(context) ??
      switch (Theme.of(context).extensions[CountryPickerTheme]) {
        CountryPickerTheme theme => theme,
        _ => null,
      };

  /// The accent color.
  final Color? accentColor;

  /// The background color.
  final Color? backgroundColor;

  /// The background color for elements on top of the background.
  final Color? onBackgroundColor;

  /// The secondary background color.
  final Color? secondaryBackgroundColor;

  /// The background color for elements on top of the secondary background.
  final Color? onSecondaryBackgroundColor;

  /// The barrierColor color.
  final Color? barrierColor;

  /// The divider color.
  final Color? dividerColor;

  /// Base text style.
  final TextStyle? textStyle;

  /// The style to use for country name text.
  final TextStyle? secondaryTextStyle;

  /// The style to use for search field text.
  final TextStyle? searchTextStyle;

  /// The height of the phone input.
  /// Default is `56.0`.
  final double inputHeight;

  /// The flag size.
  /// If null, set to `22.0`
  final double? flagSize;

  /// The padding around elements.
  /// If null, set to `16.0`
  final double padding;

  /// The corner radius of phone input fields. Defaults to `12.0`.
  final double baseCornerRadius;

  /// The corner radius of the picker sheet.
  ///
  /// Defaults to `38.0`, matching the native UIKit sheet measured on iOS 26.5.
  /// Sheets use a superellipse; set this to zero for square corners.
  /// This property does not change the phone input [baseCornerRadius].
  final double sheetCornerRadius;

  @override
  CountryPickerTheme copyWith({
    Color? accentColor,
    Color? backgroundColor,
    Color? onBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? onSecondaryBackgroundColor,
    Color? barrierColor,
    Color? dividerColor,
    double? inputHeight,
    double? flagSize,
    double? padding,
    double? baseCornerRadius,
    double? sheetCornerRadius,
    TextStyle? secondaryTextStyle,
    TextStyle? searchTextStyle,
    TextStyle? textStyle,
  }) => CountryPickerTheme.raw(
    accentColor: accentColor ?? this.accentColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    onBackgroundColor:
        onBackgroundColor ?? this.onBackgroundColor ?? secondaryBackgroundColor,
    secondaryBackgroundColor:
        secondaryBackgroundColor ?? this.secondaryBackgroundColor,
    onSecondaryBackgroundColor:
        onSecondaryBackgroundColor ??
        this.onSecondaryBackgroundColor ??
        backgroundColor,
    barrierColor: barrierColor ?? this.barrierColor,
    dividerColor: dividerColor ?? this.dividerColor,
    inputHeight: inputHeight ?? this.inputHeight,
    flagSize: flagSize ?? this.flagSize,
    padding: padding ?? this.padding,
    baseCornerRadius: baseCornerRadius ?? this.baseCornerRadius,
    sheetCornerRadius: sheetCornerRadius ?? this.sheetCornerRadius,
    secondaryTextStyle: secondaryTextStyle ?? this.secondaryTextStyle,
    searchTextStyle: searchTextStyle ?? this.searchTextStyle,
    textStyle: textStyle ?? this.textStyle,
  );

  /// Controls how the properties change on theme changes
  @override
  ThemeExtension<CountryPickerTheme> lerp(
    ThemeExtension<CountryPickerTheme>? other,
    double t,
  ) {
    if (other is! CountryPickerTheme || identical(this, other)) return this;
    return CountryPickerTheme.raw(
      accentColor: Color.lerp(accentColor, other.accentColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      onBackgroundColor: Color.lerp(
        onBackgroundColor,
        other.onBackgroundColor,
        t,
      ),
      secondaryBackgroundColor: Color.lerp(
        secondaryBackgroundColor,
        other.secondaryBackgroundColor,
        t,
      ),
      onSecondaryBackgroundColor: Color.lerp(
        onSecondaryBackgroundColor,
        other.onSecondaryBackgroundColor,
        t,
      ),
      barrierColor: Color.lerp(barrierColor, other.barrierColor, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      secondaryTextStyle: TextStyle.lerp(
        secondaryTextStyle,
        other.secondaryTextStyle,
        t,
      ),
      searchTextStyle: TextStyle.lerp(
        searchTextStyle,
        other.searchTextStyle,
        t,
      ),
      inputHeight:
          ui.lerpDouble(inputHeight, other.inputHeight, t) ?? inputHeight,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      flagSize: ui.lerpDouble(flagSize, other.flagSize, t),
      padding: ui.lerpDouble(padding, other.padding, t) ?? padding,
      baseCornerRadius: ui.lerpDouble(
        baseCornerRadius,
        other.baseCornerRadius,
        t,
      ),
      // lerpDouble returns null only when both inputs are null.
      sheetCornerRadius:
          ui.lerpDouble(sheetCornerRadius, other.sheetCornerRadius, t) ??
          sheetCornerRadius, // coverage:ignore-line
    );
  }

  @override
  int get hashCode => Object.hashAll([
    accentColor,
    backgroundColor,
    onBackgroundColor,
    secondaryBackgroundColor,
    onSecondaryBackgroundColor,
    barrierColor,
    dividerColor,
    inputHeight,
    secondaryTextStyle,
    searchTextStyle,
    textStyle,
    flagSize,
    padding,
    baseCornerRadius,
    sheetCornerRadius,
  ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CountryPickerTheme &&
        other.accentColor == accentColor &&
        other.backgroundColor == backgroundColor &&
        other.onBackgroundColor == onBackgroundColor &&
        other.secondaryBackgroundColor == secondaryBackgroundColor &&
        other.onSecondaryBackgroundColor == onSecondaryBackgroundColor &&
        other.barrierColor == barrierColor &&
        other.dividerColor == dividerColor &&
        other.secondaryTextStyle == secondaryTextStyle &&
        other.searchTextStyle == searchTextStyle &&
        other.inputHeight == inputHeight &&
        other.textStyle == textStyle &&
        other.flagSize == flagSize &&
        other.padding == padding &&
        other.baseCornerRadius == baseCornerRadius &&
        other.sheetCornerRadius == sheetCornerRadius;
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
          'onBackgroundColor',
          onBackgroundColor,
          defaultValue: CupertinoColors.secondarySystemBackground,
        ),
      )
      ..add(
        ColorProperty(
          'secondaryBackgroundColor',
          secondaryBackgroundColor,
          defaultValue: CupertinoColors.secondarySystemBackground,
        ),
      )
      ..add(
        ColorProperty(
          'onSecondaryBackgroundColor',
          onSecondaryBackgroundColor,
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
        DiagnosticsProperty<double>(
          'inputHeight',
          inputHeight,
          defaultValue: kCountryPickerDefaultInputHeight,
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
          'secondaryTextStyle',
          secondaryTextStyle,
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
          defaultValue: kCountryPickerDefaultFlagSize,
        ),
      )
      ..add(
        DiagnosticsProperty<double>(
          'padding',
          padding,
          defaultValue: kCountryPickerDefaultPadding,
        ),
      )
      ..add(
        DiagnosticsProperty<double>(
          'baseCornerRadius',
          baseCornerRadius,
          defaultValue: kCountryPickerDefaultBaseCornerRadius,
        ),
      )
      ..add(
        DiagnosticsProperty<double>(
          'sheetCornerRadius',
          sheetCornerRadius,
          defaultValue: kCountryPickerDefaultSheetCornerRadius,
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
  Widget wrap(BuildContext context, Widget child) =>
      InheritedCountryPickerTheme(data: data, child: child);
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
    Color? onBackgroundColor,
    Color? barrierColor,
    Color? dividerColor,
    Color? secondaryBackgroundColor,
    Color? onSecondaryBackgroundColor,
    double? inputHeight,
    double? baseCornerRadius,
    double? sheetCornerRadius,
    double? padding,
    double? flagSize,
    TextStyle? textStyle,
    TextStyle? secondaryTextStyle,
    super.searchTextStyle,
  }) : super.raw(
         accentColor:
             accentColor ??
             CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
         secondaryBackgroundColor:
             secondaryBackgroundColor ??
             CupertinoDynamicColor.resolve(
               CupertinoColors.secondarySystemBackground,
               context,
             ),
         onSecondaryBackgroundColor:
             onSecondaryBackgroundColor ??
             backgroundColor ??
             CupertinoDynamicColor.resolve(
               CupertinoColors.systemBackground,
               context,
             ),
         backgroundColor:
             backgroundColor ??
             CupertinoDynamicColor.resolve(
               CupertinoColors.systemBackground,
               context,
             ),
         onBackgroundColor:
             onBackgroundColor ??
             secondaryBackgroundColor ??
             CupertinoDynamicColor.resolve(
               CupertinoColors.secondarySystemBackground,
               context,
             ),
         barrierColor: barrierColor ?? kCupertinoModalBarrierColor,
         dividerColor:
             dividerColor ??
             CupertinoDynamicColor.resolve(
               CupertinoColors.opaqueSeparator,
               context,
             ),
         inputHeight: inputHeight ?? kCountryPickerDefaultInputHeight,
         baseCornerRadius:
             baseCornerRadius ?? kCountryPickerDefaultBaseCornerRadius,
         sheetCornerRadius:
             sheetCornerRadius ?? kCountryPickerDefaultSheetCornerRadius,
         padding: padding ?? kCountryPickerDefaultPadding,
         flagSize: flagSize ?? kCountryPickerDefaultFlagSize,
         textStyle:
             textStyle ??
             Theme.of(context).textTheme.bodyLarge?.copyWith(
               letterSpacing: defaultTargetPlatform == TargetPlatform.iOS
                   ? -0.41
                   : 0,
               fontWeight: FontWeight.normal,
               fontSize: 17,
             ),
         secondaryTextStyle:
             secondaryTextStyle ??
             Theme.of(context).textTheme.bodyLarge?.copyWith(
               fontWeight: FontWeight.normal,
               fontSize: 12,
               height: 1.2,
             ),
       );

  /// A build context used to resolve [CupertinoDynamicColor]
  /// defined in this theme.
  final BuildContext context;
}
