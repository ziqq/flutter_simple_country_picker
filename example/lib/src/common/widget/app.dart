// ignore_for_file: library_private_types_in_public_api

import 'package:example/src/common/constant/constant.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:example/src/common/router/example_navigator.dart';
import 'package:example/src/common/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:pull_down_button/pull_down_button.dart';

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

/// State for [App] widget.
class _AppState extends State<App> {
  /// Disable recreate widget tree
  final Key _builderKey = GlobalKey(debugLabel: 'AppBuilderKey');

  /// Localization delegates
  final localizationsDelegates = const <LocalizationsDelegate<Object?>>[
    /// Example localization
    ExampleLocalization.delegate,

    /// Add [CountriesLocalization] in app [localizationsDelegates]
    CountryLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Current locale of the app.
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  /// App theme mode
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  /// Combined listenable
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
      /* localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return supportedLocales.first;
        }
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      }, */
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

/// AppThemeModeSwitcherButton widget.
class AppThemeModeSwitcherButton extends StatelessWidget {
  /// {@macro app}
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

/// AppLocaleSwitcherButton widget.
///
/// Switch app locale.
class AppLocaleSwitcherButton extends StatelessWidget {
  /// {@macro app}
  const AppLocaleSwitcherButton({
    super.key, // ignore: unused_element
  });

  List<PullDownMenuItem> _itemBuilder(BuildContext context) {
    final itemTheme = PullDownMenuItemTheme(
      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
    );
    final locale = App.of(context)?.locale;
    return ExampleLocalization.supportedLocales
        .map<PullDownMenuItem>(
          (e) => PullDownMenuItem.selectable(
            selected: locale?.value == e,
            title: e.languageCode,
            itemTheme: itemTheme,
            onTap: () {
              HapticFeedback.mediumImpact().ignore();
              locale?.value = e;
            },
          ),
        )
        .toList(growable: false);
  }

  Widget _buttonBuilder(
    BuildContext context,
    Future<void> Function() showMenu,
  ) {
    final locale = Localizations.localeOf(context);
    return SizedBox(
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
          showMenu.call();
        },
        child: Text(
          locale.languageCode.toUpperCase(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 40,
    height: 28,
    child: PullDownButton(
      menuOffset: kDefaultPadding,
      buttonBuilder: _buttonBuilder,
      itemBuilder: (_) => _itemBuilder(context),
    ),
  );
}
