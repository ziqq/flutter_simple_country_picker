import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// {@template theme}
/// The light and dark Material themes used by the example app.
/// {@endtemplate}
extension type AppThemeData._(ThemeData data) implements ThemeData {
  /// Returns the light theme with a light Cupertino override.
  factory AppThemeData.light() => AppThemeData._(_appLightTheme);

  /// Returns the dark theme with a dark Cupertino override.
  factory AppThemeData.dark() => AppThemeData._(_appDarkTheme);
}

/// Uses the example primary color at different opacities for Material swatches.
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
    primarySwatch: _$getMaterialColor(_primaryColor),
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
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    primarySwatch: _$getMaterialColor(_primaryColor),
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
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
