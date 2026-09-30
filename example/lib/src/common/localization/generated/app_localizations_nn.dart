// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Nynorsk (`nn`).
class AppLocalizationsNn extends AppLocalizations {
  AppLocalizationsNn([String locale = 'nn']) : super(locale);

  @override
  String get localeCode => 'nn_NO';

  @override
  String get languageCode => 'nn';

  @override
  String get language => 'Norsk Nynorsk';

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
