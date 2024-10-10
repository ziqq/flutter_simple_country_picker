import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

/// App theme mode
final themeModeSwitcher = ValueNotifier(ThemeMode.system);

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({this.home, super.key});

  /// Home widget.
  final Widget? home;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Key builderKey = GlobalKey(); // Disable recreate widget tree

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: themeModeSwitcher,
        builder: (context, themeMode, _) => MaterialApp(
          title: 'Country picker: example',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            cupertinoOverrideTheme: const CupertinoThemeData(
              primaryColor: CupertinoColors.black,
              primaryContrastingColor: CupertinoColors.white,
            ),
            scaffoldBackgroundColor: CupertinoColors.systemBackground,
            appBarTheme: const AppBarTheme(
              backgroundColor: CupertinoColors.systemBackground,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            cupertinoOverrideTheme: const CupertinoThemeData(
              primaryColor: CupertinoColors.white,
              primaryContrastingColor: CupertinoColors.black,
            ),
            scaffoldBackgroundColor: CupertinoColors.systemBackground.darkColor,
            appBarTheme: AppBarTheme(
              backgroundColor: CupertinoColors.systemBackground.darkColor,
            ),
          ),
          themeMode: themeMode,
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
          builder: (context, navigator) => MediaQuery(
            key: builderKey,
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: navigator ?? const SizedBox.shrink(),
          ),
          home: widget.home,
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
        themeModeSwitcher.value = _decodeBrightness(brightness);
      },
    );
  }
}
