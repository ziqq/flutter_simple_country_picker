// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

/// Creates a widget for testing purposes.
Widget createWidgetUnderTest({
  required WidgetBuilder builder,
  Locale locale = const Locale('ru'),
}) => MaterialApp(
  locale: locale,
  supportedLocales: CountryLocalizations.supportedLocales,
  localizationsDelegates: const <LocalizationsDelegate<Object?>>[
    CountryLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Builder(builder: (context) => builder(context)),
);
