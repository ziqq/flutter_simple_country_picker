// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get localeCode => 'et_EE';

  @override
  String get languageCode => 'et';

  @override
  String get language => 'Eesti';

  @override
  String get title => 'Preview';

  @override
  String get description => 'Kontrollige riigikoodi ja sisestage oma telefoninumber.';

  @override
  String get nextLable => 'Järgmine';

  @override
  String get passwordLable => 'Parool';

  @override
  String get submitButton => 'Jätka';
}
