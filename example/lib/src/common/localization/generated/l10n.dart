// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class ExampleLocalization {
  ExampleLocalization();

  static ExampleLocalization? _current;

  static ExampleLocalization get current {
    assert(_current != null,
        'No instance of ExampleLocalization was loaded. Try to initialize the ExampleLocalization delegate before accessing ExampleLocalization.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<ExampleLocalization> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = ExampleLocalization();
      ExampleLocalization._current = instance;

      return instance;
    });
  }

  static ExampleLocalization of(BuildContext context) {
    final instance = ExampleLocalization.maybeOf(context);
    assert(instance != null,
        'No instance of ExampleLocalization present in the widget tree. Did you add ExampleLocalization.delegate in localizationsDelegates?');
    return instance!;
  }

  static ExampleLocalization? maybeOf(BuildContext context) {
    return Localizations.of<ExampleLocalization>(context, ExampleLocalization);
  }

  /// `ru_RU`
  String get localeCode {
    return Intl.message(
      'ru_RU',
      name: 'localeCode',
      desc: 'Locale code',
      args: [],
    );
  }

  /// `ru`
  String get languageCode {
    return Intl.message(
      'ru',
      name: 'languageCode',
      desc: 'Language code',
      args: [],
    );
  }

  /// `Русский`
  String get language {
    return Intl.message(
      'Русский',
      name: 'language',
      desc: 'Language',
      args: [],
    );
  }

  /// `Tetradka`
  String get title {
    return Intl.message(
      'Tetradka',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Проверьте код страны и введите свой номер телефона.`
  String get description {
    return Intl.message(
      'Проверьте код страны и введите свой номер телефона.',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Далее`
  String get nextLable {
    return Intl.message(
      'Далее',
      name: 'nextLable',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<ExampleLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'cn'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'et'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'gr'),
      Locale.fromSubtags(languageCode: 'hr'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ku'),
      Locale.fromSubtags(languageCode: 'lt'),
      Locale.fromSubtags(languageCode: 'lv'),
      Locale.fromSubtags(languageCode: 'nb'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'nn'),
      Locale.fromSubtags(languageCode: 'np'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'tw'),
      Locale.fromSubtags(languageCode: 'uk'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<ExampleLocalization> load(Locale locale) =>
      ExampleLocalization.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
