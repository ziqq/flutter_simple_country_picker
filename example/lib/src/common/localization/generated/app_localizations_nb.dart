// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get localeCode => 'nb_NO';

  @override
  String get languageCode => 'nb';

  @override
  String get language => 'Norsk Bokmål';

  @override
  String get title => 'Preview';

  @override
  String get description => 'Sjekk landskoden og skriv inn telefonnummeret ditt.';

  @override
  String get nextLable => 'Neste';

  @override
  String get passwordLable => 'Passord';

  @override
  String get submitButton => 'Fortsett';
}
