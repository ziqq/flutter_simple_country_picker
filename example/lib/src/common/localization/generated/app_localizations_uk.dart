// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get localeCode => 'uk_UA';

  @override
  String get languageCode => 'uk';

  @override
  String get language => 'Українська';

  @override
  String get title => 'Preview';

  @override
  String get description => 'Перевірте код країни та введіть свій номер телефону.';

  @override
  String get nextLable => 'Далі';

  @override
  String get passwordLable => 'Пароль';

  @override
  String get submitButton => 'Продовжити';
}
