// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get localeCode => 'ru_RU';

  @override
  String get languageCode => 'ru';

  @override
  String get language => 'Русский';

  @override
  String get title => 'Preview';

  @override
  String get description => 'Проверьте код страны и введите свой номер телефона.';

  @override
  String get nextLable => 'Далее';

  @override
  String get passwordLable => 'Пароль';

  @override
  String get submitButton => 'Продолжить';
}
