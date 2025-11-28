# flutter_simple_country_picker


[![Dart SDK Version](https://badgen.net/pub/sdk-version/flutter_simple_country_picker)](https://pub.dev/packages/flutter_simple_country_picker)
[![Pub Version](https://img.shields.io/pub/v/flutter_simple_country_picker)](https://pub.dev/packages/flutter_simple_country_picker)
[![Actions Status](https://github.com/ziqq/flutter_simple_country_picker/actions/workflows/checkout.yml/badge.svg?branch=master)](https://github.com/ziqq/flutter_simple_country_picker/actions/workflows/checkout.yml)
[![Tests Passed](https://camo.githubusercontent.com/acf27a132bef86c9cd722078b5c6cd66762ec77873aec8323703da46b55431ce/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f74657374732d3130372532307061737365642d73756363657373)](https://camo.githubusercontent.com/acf27a132bef86c9cd722078b5c6cd66762ec77873aec8323703da46b55431ce/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f74657374732d3130372532307061737365642d73756363657373)
[![codecov](https://codecov.io/gh/ziqq/flutter_simple_country_picker/graph/badge.svg?token=fpn56ea0L8)](https://codecov.io/gh/ziqq/flutter_simple_country_picker)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)
<!-- [![Pub Likes](https://img.shields.io/pub/likes/flutter_simple_country_picker)](https://pub.dev/packages/flutter_simple_country_picker) -->
<!-- [![GitHub stars](https://img.shields.io/github/stars/ziqq/flutter_simple_country_picker?style=social)](https://github.com/ziqq/flutter_simple_country_picker/) -->


<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_full_light.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_full_dark.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_adaptive_light.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_adaptive_dark.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_filtered_light.png" width="385px">  <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_filtered_dark.png" width="385px">

<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/macos_preview_light.png" width="770px">
<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/macos_preview_dark.png" width="770px">
<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/web_preview_light.png" width="770px">
<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/web_preview_dark.png" width="770px">


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
Add the `CountryLocalizations.delegate` in the list of your app delegates. Set supported locales [Locale('ru'), Locale('en')]. And set your locale `ru` or `en`.

```Dart
MaterialApp(
  locale: const Locale('en'),
  supportedLocales: const <Locale>[
    Locale('en'),
    Locale('ru'),
  ],
  localizationsDelegates: [
    /// Add [CountryLocalizations] in app [localizationsDelegates]
    CountryLocalizations.delegate,

    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: HomePage(),
);
```

Example usage of the `showCountryPicker` function:

```Dart
showCountryPicker(
  context: context,
  exclude: ['RU', 'EN'],
  whenComplete: () {
    print('CountryPicker dismissed');
  },
  onSelect: (Country country) {
    print('Selected country: ${country.displayName}');
  },
);
```

Optional argumets of the `showCountryPicker` function:

| Argument            | Description                                                                           |
|---------------------|---------------------------------------------------------------------------------------|
| `exclude`           | List of countries to exclude from the list.                                           |
| `favorite`          | List of countries to show at the top of the list.                                     |
| `filter`            | List of countries to filter the list.                                                 |
| `selected`          | Selected country notifier. Used to notify listeners when a country is selected.       |
| `adaptive`          | Can be used to show iOS style bottom sheet on iOS platform.                           |
| `autofocus`         | Can be used to initially expand virtual keyboard.                                     |
| `isDismissible`     | Allows the user to close the modal by swiping it down.                                |
| `isScrollControlled`| Controls the scrolling behavior of the modal window.                                  |
| `showSearch`        | Enables or disables the search bar.                                                   |
| `showPhoneCode`     | Displays the phone code before the country name.                                      |
| `showWorldWide`     | Shows the "World Wide" option at the beginning of the list.                           |
| `useHaptickFeedback`| Enables haptic feedback.                                                              |
| `useSafeArea`       | Enables the safe area for the modal window.                                           |
| `onSelect`          | Callback when the select a country.                                                   |
| `whenComplete`      | Callback when the `CountryPicker` is dismissed, whether a country is selected or not. |


## All countries list
To view a complete list of countries, please refer to the [All countries list](https://github.com/ziqq/flutter_simple_country_picker/wiki/All-Countries-list).


## Changelog
Refer to the [Changelog](https://github.com/ziqq/flutter_simple_country_picker/blob/master/CHANGELOG.md) to get all release notes.


## Maintainers
[Anton Ustinoff (ziqq)](https://github.com/ziqq)


## Funding
If you want to support the development of our library, there are several ways you can do it:
- [Buy me a coffee](https://www.buymeacoffee.com/ziqq)
- [Subscribe through Boosty](https://boosty.to/ziqq)


## License
[MIT](https://github.com/ziqq/flutter_simple_country_picker/blob/master/LICENSE)


## Coverage
<img src="https://codecov.io/gh/ziqq/flutter_simple_country_picker/graphs/sunburst.svg?token=fpn56ea0L8" width="375" />