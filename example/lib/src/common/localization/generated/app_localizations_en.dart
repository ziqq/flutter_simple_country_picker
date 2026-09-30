// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get localeCode => 'en_US';

  @override
  String get languageCode => 'en';

  @override
  String get language => 'English';

  @override
  String get title => 'Preview';

  @override
  String get description => 'Check the country code and enter your phone number.';

  @override
  String get nextLable => 'Next';

  @override
  String get passwordLable => 'Password';

  @override
  String get submitButton => 'Submit';
}
