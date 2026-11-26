/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 12 October 2024
 */

import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
import 'package:flutter_simple_country_picker/src/constant/country_codes.dart';
import 'package:material_ui/material_ui.dart';

/// Creates a widget for testing purposes.
Widget createWidgetUnderTest({
  required WidgetBuilder builder,
  Locale locale = const Locale('ru'),
  ThemeData? theme,
  TransitionBuilder? appBuilder,
}) => MaterialApp(
  builder: appBuilder,
  locale: locale,
  supportedLocales: CountryLocalizations.supportedLocales,
  theme:
      theme ??
      ThemeData.light().copyWith(splashFactory: NoSplash.splashFactory),
  localizationsDelegates: const <LocalizationsDelegate<Object?>>[
    CountryLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: Builder(builder: (context) => builder(context)),
);

/// Gets [Country] by its ISO2 country code from JSON list.
Country getCountryByISO2asJSON(String iso2) {
  final countryJSON = countries.firstWhere((c) => c['iso2_cc'] == iso2);
  return Country.fromJson(countryJSON);
}
