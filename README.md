<!-- [![Pub Version](https://img.shields.io/pub/v/flutter_simple_country_picker?color=blueviolet)](https://pub.dev/packages/flutter_simple_country_picker)
[![popularity](https://img.shields.io/pub/popularity/flutter_simple_country_picker?logo=dart)](https://pub.dev/packages/flutter_simple_country_picker/score)
[![likes](https://img.shields.io/pub/likes/flutter_simple_country_picker?logo=dart)](https://pub.dev/packages/flutter_simple_country_picker/score)
[![codecov](https://codecov.io/gh/ziqq/flutter_simple_country_picker/graph/badge.svg?token=S5CVNZKDAE)](https://codecov.io/gh/ziqq/flutter_simple_country_picker)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints) -->



# flutter_simple_country_picker



##  Description

The Flutter package that provides an easy-to-use country selection widget. It allows users to select a country from a comprehensive list of countries, making it simple to integrate country picking functionality into your Flutter applications. The package supports Android, iOS, and web platforms, and offers customization options for fonts and styles.



## Getting Started

 Add the package to your pubspec.yaml:

 ```yaml
 flutter_simple_country_picker: ^0.0.1-pre.0
 ```



## Example

 In your dart file, import the library:

 ```Dart
 import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
 ```

Show country picker using `showCountryPicker`:
```Dart
showCountryPicker(
  context: context,
  showPhoneCode: true, // Optional. Shows phone code before the country name.
  onSelect: (Country country) {
    print('Select country: ${country.displayName}');
  },
);
```

### For localization:

Add the `CountriesLocalization.delegate` in the list of your app delegates.

```Dart
MaterialApp(
  locale: const Locale('ru'), // Locale('en'),
  supportedLocales: const <Locale>[
    Locale('ru'),
    Locale('en'),
  ],
  localizationsDelegates: [
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,

    /// Add [CountriesLocalization] in app [localizationsDelegates]
    CountriesLocalization.delegate,
  ],
  home: HomePage(),
);
```



## Changelog

Refer to the [Changelog](https://github.com/ziqq/flutter_simple_country_picker/blob/master/CHANGELOG.md) to get all release notes.



## Maintainers

[Anton Ustinoff (ziqq)](https://github.com/ziqq)



## License

[MIT](https://github.com/ziqq/flutter_in_store_app_version_checker/blob/main/LICENSE)



## Funding

If you want to support the development of our library, there are several ways you can do it:

- [Buy me a coffee](https://www.buymeacoffee.com/ziqq)
- [Support on Patreon](https://www.patreon.com/ziqq)
- [Subscribe through Boosty](https://boosty.to/ziqq)



## Contributions

Contributions of any kind are more than welcome! Feel free to fork and improve country_code_picker in any way you want, make a pull request, or open an issue.
