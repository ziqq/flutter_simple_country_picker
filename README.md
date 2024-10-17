[![Dart SDK Version](https://badgen.net/pub/sdk-version/flutter_simple_country_picker)](https://pub.dev/packages/flutter_simple_country_picker)
[![Pub Version](https://img.shields.io/pub/v/flutter_simple_country_picker)](https://pub.dev/packages/flutter_simple_country_picker)
[![Actions Status](https://github.com/ziqq/flutter_simple_country_picker/actions/workflows/checkout.yml/badge.svg?branch=master)](https://github.com/ziqq/flutter_simple_country_picker/actions/workflows/checkout.yml)
[![Pub Likes](https://img.shields.io/pub/likes/flutter_simple_country_picker)](https://pub.dev/packages/flutter_simple_country_picker)
[![codecov](https://codecov.io/gh/ziqq/flutter_simple_country_picker/graph/badge.svg?token=fpn56ea0L8)](https://codecov.io/gh/ziqq/flutter_simple_country_picker)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)
<!-- [![GitHub stars](https://img.shields.io/github/stars/ziqq/flutter_simple_country_picker?style=social)](https://github.com/ziqq/flutter_simple_country_picker/) -->



# flutter_simple_country_picker



<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/master/.docs/images/full_example_light.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/master/.docs/images/full_example_dark.png"  width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/master/.docs/images/filtered_example_light.png" width="385px">  <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/master/.docs/images/filtered_example_dark.png" width="385px">



##  Description

The Flutter package that provides an easy-to-use country selection widget. It allows users to select a country from a comprehensive list of countries, making it simple to integrate country picking functionality into your Flutter applications. The package supports Android, iOS, and web platforms, and offers customization options for fonts and styles.



## Getting Started

 Add the package to your pubspec.yaml:

 ```yaml
 flutter_simple_country_picker: <version>
 ```



## Installation

 In your dart file, import the library:

 ```Dart
 import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
 ```


## Example

Add the `CountriesLocalization.delegate` in the list of your app delegates. Set supported locales [Locale('ru'), Locale('en')]. And set your locale `ru` or `en`.

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

Example usage of the `showCountryPicker` function:

```Dart
showCountryPicker(
  context: context,
  exclude: ['RU', 'EN'],
  onDone: () {
    print('CountryPicker dismissed');
  },
  onSelect: (Country country) {
    print('Selected country: ${country.displayName}');
  },
);
```

Optional argumets of the `showCountryPicker` function:

| Argument            | Description                                                                         |
|---------------------|-------------------------------------------------------------------------------------|
| `exclude`           | List of countries to exclude from the list.                                         |
| `filter`            | List of countries to filter the list.                                               |
| `favorite`          | List of countries to show at the top of the list.                                   |
| `showPhoneCode`     | Displays the phone code before the country name.                                    |
| `showWorldWide`     | Shows the "World Wide" option at the beginning of the list.                         |
| `useAutofocus`      | Automatically opens the keyboard when the picker is loaded.                         |
| `showSearch`        | Enables or disables the search bar.                                                 |
| `isDismissible`     | Allows the user to close the modal by swiping it down.                              |
| `isScrollControlled`| Controls the scrolling behavior of the modal window.                                |
| `useHaptickFeedback`| Enables haptic feedback.                                                            |
| `useSafeArea`       | Enables the safe area for the modal window.                                         |
| `onSelect`          | Callback when the select a country.                                                 |
| `onDone`            | Callback when the CountryPicker is dismissed, whether a country is selected or not. |



## All countries list

To view a complete list of countries, please refer to the [All countries list](https://github.com/ziqq/flutter_simple_country_picker/wiki/All-Countries-list).



## Changelog

Refer to the [Changelog](https://github.com/ziqq/flutter_simple_country_picker/blob/master/CHANGELOG.md) to get all release notes.



## Maintainers

[Anton Ustinoff (ziqq)](https://github.com/ziqq)



## Funding

If you want to support the development of our library, there are several ways you can do it:

- [Buy me a coffee](https://www.buymeacoffee.com/ziqq)
- [Support on Patreon](https://www.patreon.com/ziqq)
- [Subscribe through Boosty](https://boosty.to/ziqq)



## License

[MIT](https://github.com/ziqq/flutter_simple_country_picker/blob/master/LICENSE)



## Coverage

<img src="https://codecov.io/gh/ziqq/flutter_simple_country_picker/graphs/sunburst.svg?token=fpn56ea0L8" width="375" />