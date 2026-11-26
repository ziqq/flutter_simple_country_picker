// ignore_for_file: library_private_types_in_public_api

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:example/src/common/router/example_navigator.dart';
import 'package:example/src/common/theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:material_ui/material_ui.dart';

/// {@template app}
/// Provides the example themes, localizations, and root navigator.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({required this.home, super.key});

  /// Home widget.
  final Widget home;

  /// Returns the nearest example app state, if one exists.
  static _AppState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>();

  /// Returns the nearest example app state or throws an [ArgumentError].
  static _AppState? of(BuildContext context) =>
      maybeOf(context) ?? _notFoundStateOfType();

  static Never _notFoundStateOfType() => throw ArgumentError(
    'Out of scope, not found state of type _AppState',
    'out_of_scope',
  );

  @override
  State<App> createState() => _AppState();
}

/// State for [App] widget.
class _AppState extends State<App> {
  /// Keeps the navigator mounted when changing the app locale.
  final Key _builderKey = GlobalKey(debugLabel: 'AppBuilderKey');

  /// Loads the example, country, and Material widget translations.
  final localizationsDelegates = const <LocalizationsDelegate<Object?>>[
    ExampleLocalization.delegate,

    CountryLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ];

  /// Current locale of the app.
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  /// The current theme mode, initially inherited from the platform.
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  /// Rebuilds the Material app when its locale or theme changes.
  late final Listenable _listenable = Listenable.merge([themeMode, locale]);

  @override
  void initState() {
    super.initState();
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    locale.value =
        ExampleLocalization.supportedLocales.any(
          (l) => l.languageCode == systemLocale.languageCode,
        )
        ? systemLocale
        : const Locale('en');
  }

  @override
  void dispose() {
    themeMode.dispose();
    locale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _listenable,
    builder: (context, _) => MaterialApp(
      key: ValueKey(locale.value),
      title: 'Country picker example',
      debugShowCheckedModeBanner: false,
      darkTheme: AppThemeData.dark(),
      theme: AppThemeData.light(),
      themeMode: themeMode.value,
      locale: locale.value,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: ExampleLocalization.supportedLocales,
      builder: (context, _) => MediaQuery(
        key: _builderKey,
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: ExampleNavigator(
          key: const ValueKey<String>('home'),
          pages: <ExamplePage>[HomePage<Object?>(child: widget.home)],
        ),
      ),
    ),
  );
}

/// Switches the example between light and dark themes.
class AppThemeModeSwitcherButton extends StatelessWidget {
  /// Creates the theme switcher.
  const AppThemeModeSwitcherButton({super.key});

  ThemeMode _themeModeFromBrightness(Brightness brightness) =>
      brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return IconButton(
      icon: brightness == Brightness.light
          ? const Icon(Icons.dark_mode_rounded)
          : const Icon(Icons.light_mode_rounded),
      onPressed: () {
        HapticFeedback.heavyImpact().ignore();
        App.of(context)?.themeMode.value = _themeModeFromBrightness(brightness);
      },
    );
  }
}

/// Opens a menu of supported example languages.
class AppLocaleSwitcherButton extends StatelessWidget {
  /// Creates the language switcher.
  const AppLocaleSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = App.of(context)?.locale;
    final languageCode = Localizations.localeOf(context).languageCode;
    final textTheme = Theme.of(context).textTheme;
    return CupertinoMenuAnchor(
      consumeOutsideTaps: true,
      menuChildren: [
        for (final option in ExampleLocalization.supportedLocales)
          CupertinoMenuItem(
            trailing: locale?.value == option
                ? const Icon(CupertinoIcons.check_mark)
                : null,
            onPressed: () {
              HapticFeedback.mediumImpact().ignore();
              locale?.value = option;
            },
            child: Text(
              option.languageCode,
              style: textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
          ),
      ],
      builder: (context, controller, child) => SizedBox(
        width: 40,
        height: 28,
        child: CupertinoButton(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondarySystemFill,
            context,
          ),
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.heavyImpact().ignore();
            controller.open();
          },
          child: Text(
            languageCode.toUpperCase(),
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
