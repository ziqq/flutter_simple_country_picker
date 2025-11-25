// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get localeCode => 'pl_PL';

  @override
  String get languageCode => 'pl';

  @override
  String get language => 'Polski';

  @override
  String get title => 'Podgląd';

  @override
  String get description => 'Sprawdź kod kraju i wprowadź swój numer telefonu.';

  @override
  String get nextLable => 'Dalej';

  @override
  String get passwordLable => 'Hasło';

  @override
  String get submitButton => 'Kontynuuj';
}
