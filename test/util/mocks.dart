import 'dart:ui';

import 'package:flutter_simple_country_picker/src/controller/countries_provider.dart';
import 'package:meta/meta.dart';
import 'package:mockito/annotations.dart';

export 'mocks.mocks.dart';

@GenerateNiceMocks([MockSpec<CountriesProvider>()])
void mocks() {}

/// Supported locales
@internal
@isTest
final supportedLocales = <Locale>[
  const Locale('en'),
  const Locale('ar'),
  const Locale('es'),
  const Locale('de'),
  const Locale('fr'),
  const Locale('el'),
  const Locale('et'),
  const Locale('nb'),
  const Locale('nn'),
  const Locale('pl'),
  const Locale('pt'),
  const Locale('ru'),
  const Locale('hi'),
  const Locale('ne'),
  const Locale('uk'),
  const Locale('hr'),
  const Locale('tr'),
  const Locale('lv'),
  const Locale('lt'),
  const Locale('ku'),
  const Locale('nl'),
  const Locale('it'),
  // Generic simplified Chinese 'zh_Hans'
  const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  // Generic traditional Chinese 'zh_Hant'
  const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
];
