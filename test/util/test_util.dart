// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';

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

/// Gets [Country] by its ISO2 country code from JSON list.
Country getCountryByISO2asJSON(String iso2) {
  final countryJSON = countries.firstWhere((c) => c['iso2_cc'] == iso2);
  return Country.fromJson(countryJSON);
}
