// ignore_for_file: library_private_types_in_public_api

import 'package:example/src/common/router/example_navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

/// App light theme.
final ThemeData _themeLight = ThemeData.light().copyWith(
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: CupertinoColors.black,
    primaryContrastingColor: CupertinoColors.white,
  ),
  scaffoldBackgroundColor: CupertinoColors.systemBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: CupertinoColors.systemBackground,
  ),
);

/// App dark theme.
final ThemeData _themeDark = ThemeData.dark().copyWith(
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: CupertinoColors.white,
    primaryContrastingColor: CupertinoColors.black,
  ),
  scaffoldBackgroundColor: CupertinoColors.systemBackground.darkColor,
  appBarTheme: AppBarTheme(
    backgroundColor: CupertinoColors.systemBackground.darkColor,
  ),
);

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({required this.home, super.key});

  /// Home widget.
  final Widget home;

  @override
  State<App> createState() => _AppState();

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `AppState.maybeOf(context)`.
  static _AppState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>();

  static Never _notFoundStateOfType() => throw ArgumentError(
        'Out of scope, not found state of type _AppState',
        'out_of_scope',
      );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `AppState.of(context)`
  static _AppState? of(BuildContext context) =>
      maybeOf(context) ?? _notFoundStateOfType();
}

class _AppState extends State<App> {
  /// Disable recreate widget tree
  final Key _builderKey = GlobalKey();

  /// App theme mode
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  @override
  void dispose() {
    themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: themeMode,
        builder: (context, themeMode, _) => MaterialApp(
          title: 'Country picker example',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: _themeLight,
          darkTheme: _themeDark,
          locale: const Locale('ru'),
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('es'),
            Locale('de'),
            Locale('fr'),
            Locale('el'),
            Locale('et'),
            Locale('nb'),
            Locale('nn'),
            Locale('pl'),
            Locale('pt'),
            Locale('ru'),
            Locale('hi'),
            Locale('ne'),
            Locale('uk'),
            Locale('hr'),
            Locale('tr'),
            Locale('lv'),
            Locale('lt'),
            Locale('ku'),
            Locale('nl'),
            Locale('it'),
            // Generic Simplified Chinese 'zh_Hans'
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
            // Generic traditional Chinese 'zh_Hant'
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
          ],
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,

            /// Add [CountriesLocalization] in app [localizationsDelegates]
            CountriesLocalization.delegate,
          ],
          builder: (context, _) => MediaQuery(
            key: _builderKey,
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: ExampleNavigator(
              key: const ValueKey<String>('home'),
              home: MaterialPage(child: widget.home),
            ),
          ),
        ),
      );
}

/// AppThemeModeSwitcherButton widget.
class AppThemeModeSwitcherButton extends StatelessWidget {
  /// {@macro app}
  const AppThemeModeSwitcherButton({super.key});

  ThemeMode _decodeBrightness(Brightness brightness) =>
      brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return IconButton(
      icon: brightness == Brightness.light
          ? const Icon(Icons.dark_mode_rounded)
          : const Icon(Icons.light_mode_rounded),
      onPressed: () {
        HapticFeedback.heavyImpact();
        App.of(context)?.themeMode.value = _decodeBrightness(brightness);
      },
    );
  }
}
