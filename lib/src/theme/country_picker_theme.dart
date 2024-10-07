// ignore_for_file: always_put_required_named_parameters_first

import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/src/constant/constant.dart';
import 'package:meta/meta.dart';

/// {@template country_picker_theme}
/// Custom theme for the CountryPicker
/// {@endtemplate}
@immutable
class CountryPickerTheme extends ThemeExtension<CountryPickerTheme>
    with Diagnosticable {
  /// {@macro country_picker_theme}
  factory CountryPickerTheme({
    required Color? backgroundColor,
    required Color? dividerColor,
    required Color? stickyHeaderBackgroundColor,
    required TextStyle? textStyle,
    required TextStyle? searchTextStyle,
    InputDecoration? inputDecoration,
    required double? flagSize,
    required double? padding,
    required double? indent,
    required double? radius,
  }) {
    flagSize ??= kDefaultFlagSize;
    padding ??= kDefaultPadding;
    indent ??= kDefaultIndent;
    radius ??= kDefaultRadius;
    return CountryPickerTheme.raw(
      backgroundColor: backgroundColor,
      dividerColor: dividerColor,
      stickyHeaderBackgroundColor: stickyHeaderBackgroundColor,
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
    required this.backgroundColor,
    required this.dividerColor,
    required this.stickyHeaderBackgroundColor,
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
  /// [PullDownButtonTheme.itemTheme] or [PullDownMenuItemTheme.defaults]
  /// as well as from theme data from [PullDownMenuItem].
  @internal
  factory CountryPickerTheme.resolve(
    BuildContext context, {
    required CountryPickerTheme? other,
  }) {
    final defaults = CountryPickerTheme.defaults(context);
    final theme = CountryPickerTheme.maybeOf(context);
    return CountryPickerTheme(
      backgroundColor: other?.backgroundColor ??
          theme?.backgroundColor ??
          defaults.backgroundColor,
      dividerColor:
          other?.dividerColor ?? theme?.dividerColor ?? defaults.dividerColor,
      stickyHeaderBackgroundColor: other?.stickyHeaderBackgroundColor ??
          theme?.stickyHeaderBackgroundColor ??
          defaults.stickyHeaderBackgroundColor,
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

  /// Get [CountryPickerTheme] from [CountryPickerInheritedTheme].
  ///
  /// If that's null get [CountryPickerTheme] from [ThemeData.extensions]
  /// property of the ambient [Theme].
  static CountryPickerTheme? maybeOf(BuildContext context) =>
      CountryPickerInheritedTheme.maybeOf(context) ??
      Theme.of(context).extensions[CountryPickerTheme] as CountryPickerTheme?;

  // static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
  //       'Out of scope or out of extensions, not found inherited widget '
  //           'a CountryPickerTheme of the exact type',
  //       'out_of_scope or out_of_extensions',
  //     );

  /// The country bottom sheet's background color.
  ///
  /// If null [backgroundColor]
  /// defaults to [BottomSheetThemeData.backgroundColor].
  final Color? backgroundColor;

  /// The divider color.
  ///
  /// If null, [dividerColor] defaults to [CupertinoColors.opaqueSeparator].
  final Color? dividerColor;

  /// The country bottom sheet's sticky header background color.
  ///
  /// If null, [stickyHeaderBackgroundColor]
  /// defaults to [CupertinoColors.secondarySystemBackground].
  final Color? stickyHeaderBackgroundColor;

  /// The style to use for country name text.
  ///
  /// If null, the style will be set to [TextStyle(fontSize: 16)]
  final TextStyle? textStyle;

  /// The style to use for search box text.
  ///
  /// If null, the style will be set to [TextStyle(fontSize: 16)]
  final TextStyle? searchTextStyle;

  /// The decoration used for the inputs
  final InputDecoration? inputDecoration;

  /// The flag size.
  ///
  /// If null, set to 25
  final double? flagSize;

  /// Country list modal height
  ///
  /// By default it's fullscreen the padding of the bottom sheet
  ///
  /// If null, set to 16
  final double padding;

  /// The base indent.
  ///
  /// If null, set to 10
  final double indent;

  /// The border radius of the bottom sheet
  ///
  /// It defaults to 40 for the top-left and top-right values.
  ///
  /// If null, set to 10
  final double radius;

  @override
  CountryPickerTheme copyWith({
    Color? backgroundColor,
    Color? dividerColor,
    Color? stickyHeaderBackgroundColor,
    InputDecoration? inputDecoration,
    TextStyle? searchTextStyle,
    TextStyle? textStyle,
    double? flagSize,
    double? padding,
    double? indent,
    double? radius,
  }) =>
      CountryPickerTheme(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        dividerColor: dividerColor ?? this.dividerColor,
        stickyHeaderBackgroundColor:
            stickyHeaderBackgroundColor ?? this.stickyHeaderBackgroundColor,
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
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      stickyHeaderBackgroundColor: Color.lerp(
        stickyHeaderBackgroundColor,
        other.stickyHeaderBackgroundColor,
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

  /// Controls how it displays when the instance
  /// is being passed to the `print()` method.
  // @override
  // String toString() => 'CupertinoFormSectionTheme('
  //     'indent: $indent'
  //     'padding: $padding'
  //     'accentColor: $accentColor'
  //     'backgroundColor: $backgroundColor'
  //     ')';

  @override
  int get hashCode => Object.hashAll([
        backgroundColor,
        dividerColor,
        inputDecoration,
        stickyHeaderBackgroundColor,
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
        other.backgroundColor == backgroundColor &&
        other.dividerColor == dividerColor &&
        other.stickyHeaderBackgroundColor == stickyHeaderBackgroundColor &&
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
        ColorProperty('backgroundColor', backgroundColor, defaultValue: null),
      )
      ..add(
        ColorProperty('dividerColor', dividerColor, defaultValue: null),
      )
      ..add(
        DiagnosticsProperty<InputDecoration?>(
          'inputDecoration',
          inputDecoration,
          defaultValue: null,
        ),
      )
      ..add(
        ColorProperty(
          'stickyHeaderBackgroundColor',
          stickyHeaderBackgroundColor,
          defaultValue: null,
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

/// Alternative way of defining [UiTheme].
///
/// Example:
///
/// ```dart
/// CupertinoApp(
///    builder: (context, child) => CountryPickerInheritedTheme(
///      data: const UiTheme(
///        ...
///      ),
///      child: child!,
///  ),
/// home: ...,
/// ```
@immutable
class CountryPickerInheritedTheme extends InheritedTheme {
  /// Creates a [CountryPickerInheritedTheme].
  const CountryPickerInheritedTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The configuration of this theme.
  final CountryPickerTheme data;

  /// Returns the current [UiTheme] from the closest
  /// [CountryPickerInheritedTheme] ancestor.
  ///
  /// If there is no ancestor, it returns `null`.
  static CountryPickerTheme? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CountryPickerInheritedTheme>()
      ?.data;

  @override
  bool updateShouldNotify(covariant CountryPickerInheritedTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(
    BuildContext context,
    Widget child,
  ) =>
      CountryPickerInheritedTheme(
        data: data,
        child: child,
      );
}

/// {@template country_picker_theme}
/// Default [CountryPickerTheme]
/// {@endtemplate}
@immutable
class _CountryPickerTheme$Default extends CountryPickerTheme {
  /// Creates [_CountryPickerTheme$Default].
  _CountryPickerTheme$Default(
    this.context, {
    Color? backgroundColor,
    Color? dividerColor,
    Color? stickyHeaderBackgroundColor,
    TextStyle? textStyle,
    TextStyle? searchTextStyle,
    InputDecoration? inputDecoration,
    double? radius,
    double? padding = 16,
    double? indent,
    double? flagSize,
  }) : super.raw(
          stickyHeaderBackgroundColor: stickyHeaderBackgroundColor ??
              CupertinoDynamicColor.resolve(
                CupertinoColors.secondarySystemBackground,
                context,
              ),
          searchTextStyle: searchTextStyle ?? const TextStyle(fontSize: 16),
          backgroundColor: backgroundColor ?? Colors.white,
          dividerColor: dividerColor ?? Colors.white,
          inputDecoration: inputDecoration ?? const InputDecoration(),
          radius: radius ?? 10,
          indent: indent ?? 10,
          padding: padding ?? 16,
          flagSize: flagSize ?? 24,
          textStyle: textStyle ?? const TextStyle(fontSize: 16),
        );

  /// A build context used to resolve [CupertinoDynamicColor]s defined in this
  /// theme.
  final BuildContext context;
}
