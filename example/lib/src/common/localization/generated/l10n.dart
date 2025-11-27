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

class ExampleGeneratedLocalization {
  ExampleGeneratedLocalization();

  static ExampleGeneratedLocalization? _current;

  static ExampleGeneratedLocalization get current {
    assert(
      _current != null,
      'No instance of ExampleGeneratedLocalization was loaded. Try to initialize the ExampleGeneratedLocalization delegate before accessing ExampleGeneratedLocalization.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<ExampleGeneratedLocalization> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = ExampleGeneratedLocalization();
      ExampleGeneratedLocalization._current = instance;

      return instance;
    });
  }

  static ExampleGeneratedLocalization of(BuildContext context) {
    final instance = ExampleGeneratedLocalization.maybeOf(context);
    assert(
      instance != null,
      'No instance of ExampleGeneratedLocalization present in the widget tree. Did you add ExampleGeneratedLocalization.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static ExampleGeneratedLocalization? maybeOf(BuildContext context) {
    return Localizations.of<ExampleGeneratedLocalization>(
      context,
      ExampleGeneratedLocalization,
    );
  }

  /// `en_US`
  String get localeCode {
    return Intl.message(
      'en_US',
      name: 'localeCode',
      desc: 'Locale code',
      args: [],
    );
  }

  /// `en`
  String get languageCode {
    return Intl.message(
      'en',
      name: 'languageCode',
      desc: 'Language code',
      args: [],
    );
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: 'Language',
      args: [],
    );
  }

  /// `Preview`
  String get title {
    return Intl.message('Preview', name: 'title', desc: '', args: []);
  }

  /// `Check the country code and enter your phone number.`
  String get description {
    return Intl.message(
      'Check the country code and enter your phone number.',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get nextLable {
    return Intl.message('Next', name: 'nextLable', desc: '', args: []);
  }

  /// `Password`
  String get passwordLable {
    return Intl.message('Password', name: 'passwordLable', desc: '', args: []);
  }

  /// `Submit`
  String get submitButton {
    return Intl.message('Submit', name: 'submitButton', desc: '', args: []);
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<ExampleGeneratedLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'cn'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'el'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'et'),
      Locale.fromSubtags(languageCode: 'fr'),
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
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'tw'),
      Locale.fromSubtags(languageCode: 'uk'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<ExampleGeneratedLocalization> load(Locale locale) =>
      ExampleGeneratedLocalization.load(locale);
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
