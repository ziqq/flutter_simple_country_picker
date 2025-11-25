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
  String get language => '简体中文';

  @override
  String get title => 'Preview';

  @override
  String get description => '检查国家代码并输入您的电话号码。';

  @override
  String get nextLable => '下一步';

  @override
  String get passwordLable => '密码';

  @override
  String get submitButton => '继续';
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
  String get title => 'Preview';

  @override
  String get description => '检查国家代码并输入您的电话号码。';

  @override
  String get nextLable => '下一步';

  @override
  String get passwordLable => '密码';

  @override
  String get submitButton => '继续';
}
