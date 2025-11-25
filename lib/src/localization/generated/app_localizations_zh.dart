// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get localeCode => 'zh_CN';

  @override
  String get languageCode => 'zh';

  @override
  String get language => '中文';

  @override
  String get search => '搜索';

  @override
  String get cancel => '取消';

  @override
  String get phonePlaceholder => '电话号码';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn(): super('zh_CN');

  @override
  String get localeCode => 'zh_CN';

  @override
  String get languageCode => 'zh';

  @override
  String get language => '简体中文';

  @override
  String get search => '搜索';

  @override
  String get cancel => '取消';

  @override
  String get phonePlaceholder => '电话号码';
}
