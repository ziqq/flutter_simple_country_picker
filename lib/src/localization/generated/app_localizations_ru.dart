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
  String get search => 'Поиск';

  @override
  String get cancel => 'Отмена';

  @override
  String get phonePlaceholder => 'Номер телефона';
}
