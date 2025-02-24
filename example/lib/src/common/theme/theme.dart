import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// {@template theme}
/// App theme data.
/// {@endtemplate}
extension type AppThemeData._(ThemeData data) implements ThemeData {
  /// {@macro theme}
  factory AppThemeData.light() => AppThemeData._(_appLightTheme);

  /// {@macro theme}
  factory AppThemeData.dark() => AppThemeData._(_appDarkTheme);
}

MaterialColor _$getMaterialColor(Color color) {
  final red = color.r.toInt();
  final green = color.g.toInt();
  final blue = color.b.toInt();

  final shades = <int, Color>{
    50: Color.fromRGBO(red, green, blue, .1),
    100: Color.fromRGBO(red, green, blue, .2),
    200: Color.fromRGBO(red, green, blue, .3),
    300: Color.fromRGBO(red, green, blue, .4),
    400: Color.fromRGBO(red, green, blue, .5),
    500: Color.fromRGBO(red, green, blue, .6),
    600: Color.fromRGBO(red, green, blue, .7),
    700: Color.fromRGBO(red, green, blue, .8),
    800: Color.fromRGBO(red, green, blue, .9),
    900: Color.fromRGBO(red, green, blue, 1),
  };

  return MaterialColor(color.toARGB32(), shades);
}

/// App accent color.
const _primaryColor = Color(0xFF4a5cec);

/// App light theme.
final ThemeData _appLightTheme = ThemeData.light().copyWith(
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: CupertinoColors.black,
    primaryContrastingColor: CupertinoColors.white,
  ),
  scaffoldBackgroundColor: CupertinoColors.systemBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: CupertinoColors.systemBackground,
  ),
  colorScheme: ColorScheme.fromSwatch(
    // primarySwatch: _$getMaterialColor(const Color(0xFF8673e0)),
    // primarySwatch: _$getMaterialColor(const Color(0xFF66c5ff)),
    // primarySwatch: _$getMaterialColor(const Color(0xFF8fad43)),
    primarySwatch: _$getMaterialColor(_primaryColor),
    // primarySwatch: _$getMaterialColor(const Color(0xFF16b5e4)),
    // primarySwatch: _$getMaterialColor(const Color(0xFF71f5cb)),
    accentColor: _$getMaterialColor(const Color(0xFF16b5e4)),
    brightness: Brightness.light,
  ),
  buttonTheme: const ButtonThemeData(
    height: 56,
    buttonColor: Color(0xFF4a5cec),
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all<double>(0),
      backgroundColor: WidgetStateProperty.all<Color>(_primaryColor),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
    ),
  ),
);

/// App dark theme.
final ThemeData _appDarkTheme = ThemeData.dark().copyWith(
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: CupertinoColors.white,
    primaryContrastingColor: CupertinoColors.black,
  ),
  scaffoldBackgroundColor: CupertinoColors.systemBackground.darkColor,
  appBarTheme: AppBarTheme(
    backgroundColor: CupertinoColors.systemBackground.darkColor,
  ),
  colorScheme: ColorScheme.fromSwatch(
    // primarySwatch: _$getMaterialColor(const Color(0xFF8673e0)),
    // primarySwatch: _$getMaterialColor(const Color(0xFF66c5ff)),
    // primarySwatch: _$getMaterialColor(const Color(0xFF8fad43)),
    primarySwatch: _$getMaterialColor(_primaryColor),
    // primarySwatch: _$getMaterialColor(const Color(0xFF16b5e4)),
    // primarySwatch: _$getMaterialColor(const Color(0xFF71f5cb)),
    accentColor: _$getMaterialColor(const Color(0xFF16b5e4)),
    brightness: Brightness.dark,
  ),
  buttonTheme: const ButtonThemeData(
    height: 56,
    buttonColor: Color(0xFF4a5cec),
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all<double>(0),
      backgroundColor: WidgetStateProperty.all<Color>(_primaryColor),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
    ),
  ),
);
