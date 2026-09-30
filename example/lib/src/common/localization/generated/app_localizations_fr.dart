// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get localeCode => 'fr_FR';

  @override
  String get languageCode => 'fr';

  @override
  String get language => 'Français';

  @override
  String get title => 'Preview';

  @override
  String get description => 'Vérifiez le code pays et saisissez votre numéro de téléphone.';

  @override
  String get nextLable => 'Suivant';

  @override
  String get passwordLable => 'Mot de passe';

  @override
  String get submitButton => 'Continuer';
}
