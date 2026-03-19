# flutter_simple_country_picker


[![Dart SDK Version](https://badgen.net/pub/sdk-version/flutter_simple_country_picker)](https://pub.dev/packages/flutter_simple_country_picker)
[![Pub Version](https://img.shields.io/pub/v/flutter_simple_country_picker)](https://pub.dev/packages/flutter_simple_country_picker)
[![Actions Status](https://github.com/ziqq/flutter_simple_country_picker/actions/workflows/checkout.yml/badge.svg?branch=main)](https://github.com/ziqq/flutter_simple_country_picker/actions/workflows/checkout.yml)
[![codecov](https://codecov.io/gh/ziqq/flutter_simple_country_picker/graph/badge.svg?token=fpn56ea0L8)](https://codecov.io/gh/ziqq/flutter_simple_country_picker)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)
<!-- [![Pub Likes](https://img.shields.io/pub/likes/flutter_simple_country_picker)](https://pub.dev/packages/flutter_simple_country_picker) -->
<!-- [![GitHub stars](https://img.shields.io/github/stars/ziqq/flutter_simple_country_picker?style=social)](https://github.com/ziqq/flutter_simple_country_picker/) -->


<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_full_light.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_full_dark.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_adaptive_light.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_adaptive_dark.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_filtered_light.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/mobile_preview_filtered_dark.png" width="385px">

<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/macos_preview_light.png" width="770px">
<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/macos_preview_dark.png" width="770px">
<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/web_preview_light.png" width="770px">
<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/main/.github/images/web_preview_dark.png" width="770px">


## Description

An easy-to-use country selection widget for Flutter. Allows users to select a country from a comprehensive list. Supports **Android**, **iOS**, **macOS**, **Web**, **Windows** and **Linux** platforms. Includes a phone-number input widget with automatic mask formatting, adaptive bottom sheet, theme customization, and 35+ locales.


## Quick Start

Add the package and register the localization delegate, then open the picker:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';

MaterialApp(
  localizationsDelegates: [
    CountryLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  // Pass the built-in list directly — no need to enumerate locales manually.
  supportedLocales: CountryLocalizations.supportedLocales,
  home: const MyHomePage(),
);

// Inside your widget:
showCountryPicker(
  context: context,
  onSelect: (Country country) {
    print(country.displayName); // e.g. “Russia (+7)”
  },
);
```


## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
flutter_simple_country_picker: ^latest
```

Import the library in your Dart file:

```dart
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
```


## Setup Localizations

Add `CountryLocalizations.delegate` to your app's `localizationsDelegates` and list the locales you want to support.

```dart
MaterialApp(
  locale: const Locale('en'),
  supportedLocales: const <Locale>[
    Locale('en'),
    Locale('ru'),
  ],
  localizationsDelegates: [
    CountryLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: const HomePage(),
);
```

> **Tip:** pass `CountryLocalizations.supportedLocales` to `supportedLocales` to
> enable all 36 built-in locales at once.

Supported locales: `ar`, `bg`, `ca`, `cs`, `da`, `de`, `el`, `en`, `es`, `et`,
`fa`, `fr`, `he`, `hi`, `hr`, `ht`, `id`, `it`, `ja`, `ko`, `ku`, `lt`, `lv`,
`nb`, `ne`, `nl`, `nn`, `pl`, `pt`, `ro`, `ru`, `sk`, `tr`, `uk`,
`zh-Hans` (Simplified Chinese), `zh-Hant` (Traditional Chinese).

### Custom localizations

`CountryLocalizations` is an `abstract class`. You can extend it to add a new language or override existing strings without forking the package:

```dart
final class CountryLocalizationsMyLang extends CountryLocalizations {
  const CountryLocalizationsMyLang();

  @override
  String get cancelButton => 'Cancel';

  @override
  String get phonePlaceholder => 'Phone number';

  @override
  String get searchPlaceholder => 'Search country';

  @override
  String get selectCountryLabel => 'Select country';

  @override
  String? countryName(String countryCode) => _names[countryCode];
}

const Map<String, String> _names = {
  'US': 'United States',
  'RU': 'Russia',
  // …
};
```

Register it in the delegate by creating your own `LocalizationsDelegate<CountryLocalizations>` that returns your subclass for the desired locale, or contribute it back to the package.


## Usage

## Migration

Upgrade notes are documented in [MIGRATION.md](MIGRATION.md).

- `0.10.0`: [Migrate to 0.10.0](MIGRATION.md#to-0100)
- `0.9.0`: [Migrate to 0.9.0](MIGRATION.md#to-090)

### showCountryPicker

Opens a bottom sheet with a scrollable/searchable country list.

```dart
showCountryPicker(
  context: context,
  exclude: const ['RU'],
  favorites: const ['US', 'GB'],
  onSelect: (Country country) {
    debugPrint('Selected: ${country.displayName}');
  },
  whenComplete: () {
    debugPrint('Picker dismissed');
  },
);
```

#### Parameters

| Parameter              | Type                    | Default | Description                                                                         |
|------------------------|-------------------------|---------|-------------------------------------------------------------------------------------|
| `context`              | `BuildContext`          | —       | **Required.** Build context.                                                        |
| `onSelect`             | `SelectCountryCallback?`| `null`  | Called when a country is selected.                                                  |
| `whenComplete`         | `VoidCallback?`         | `null`  | Called when the picker is dismissed, regardless of selection.                       |
| `exclude`              | `List<String>?`         | `null`  | ISO2 codes of countries to exclude.                                                 |
| `favorites`            | `List<String>?`         | `null`  | ISO2 codes of countries to pin at the top.                                          |
| `filter`               | `List<String>?`         | `null`  | ISO2 codes to show exclusively. Cannot be combined with `exclude`.                  |
| `selected`             | `SelectedCountry?`      | `null`  | Notifier holding the pre-selected country.                                          |
| `expand`               | `bool`                  | `false` | Expand the bottom sheet to full height.                                             |
| `adaptive`             | `bool`                  | `false` | Uses a Cupertino-style modal on iOS.                                                |
| `autofocus`            | `bool`                  | `false` | Automatically focuses the search field.                                             |
| `isDismissible`        | `bool`                  | `true`  | Whether the sheet can be dismissed by tapping the barrier.                          |
| `isScrollControlled`   | `bool`                  | `true`  | Controls scroll behavior of the modal.                                              |
| `shouldCloseOnSwipeDown`| `bool`                 | `false` | Closes the sheet on swipe-down gesture.                                             |
| `showPhoneCode`        | `bool`                  | `false` | Displays the country phone code in the list.                                        |
| `showWorldWide`        | `bool`                  | `false` | Shows a "World Wide" entry at the top.                                              |
| `showGroup`            | `bool?`                 | `null`  | Groups countries by their first letter.                                             |
| `showSearch`           | `bool?`                 | `null`  | Shows or hides the search bar.                                                      |
| `useHaptickFeedback`   | `bool`                  | `true`  | Enables haptic feedback on selection.                                               |
| `useRootNavigator`     | `bool`                  | `true`  | Uses the root navigator to display the sheet above all other routes.                |
| `useSafeArea`          | `bool`                  | `true`  | Wraps the sheet in a `SafeArea`.                                                    |
| `initialChildSize`     | `double?`               | `null`  | Initial fractional height of the draggable sheet.                                   |
| `minChildSize`         | `double?`               | `null`  | Minimum fractional height of the draggable sheet.                                   |


### CountryPhoneInput

A ready-made phone-number text field with an embedded country flag/code selector and automatic mask formatting.

```dart
CountryPhoneInput(
  initialCountry: Country.ru(),
  placeholder: 'Phone number',
  showPhoneCode: true,
  onChanged: (String value) {
    debugPrint('Phone: $value');
  },
  onCountryChanged: (Country country) {
    debugPrint('Country: ${country.displayName}');
  },
);
```

Use `CountryPhoneInput.extended` for additional layout and presentation configuration such as custom scroll sizes.

### CountryPhoneController

A concrete `ValueNotifier<CountryPhoneEditingValue>` that manages phone input
state and exposes the raw text, normalized phone, calling code, national
number, dataset-based resolution, and input-length status.

```dart
// Create with an initial value
final controller = CountryPhoneController.apply('+7 123 456 78 90');

print(controller.text);        // +7 123 456 78 90
print(controller.phone);       // +71234567890
print(controller.number);      // 1234567890
print(controller.resolution.status); // CountryPhoneResolutionStatus.exact
print(controller.resolution.primaryCountryCode); // RU
print(controller.resolution.countryCodes); // [RU]
print(controller.resolution.isAmbiguous); // false
print(controller.valueStatus.currentLength); // 10
print(controller.valueStatus.isIncomplete); // false
print(controller.value.phone); // +71234567890

// Or start empty
final emptyController = CountryPhoneController.empty();

// Or seed the full editing value explicitly
final seededController = CountryPhoneController.fromValue(
  CountryPhoneEditingValue(
    text: '+44 7911 123456',
    valueStatus: const CountryPhoneValueStatus(
      currentLength: 10,
      expectedLength: 10,
      isOverflow: false,
    ),
  ),
);
```

Dispose controllers you create yourself:

```dart
final controller = CountryPhoneController.empty();

@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

Resolution is dataset-based. The controller compares the parsed national number
with bundled example numbers and then uses dataset priority to keep ordering
stable when multiple candidates remain.

This is not a full metadata validator like `libphonenumber`. If you need strict
carrier- or region-level validation, treat `resolution` as a lightweight
bundled heuristic and validate the final number separately.

There is no direct ISO2 getter anymore. Read the primary candidate from
`resolution.primaryCountryCode` and inspect `resolution.status` before assuming
the result is exact.

Pass the controller to `CountryPhoneInput` and observe the whole value:

```dart
ValueListenableBuilder<CountryPhoneEditingValue>(
  valueListenable: controller,
  builder: (context, value, _) {
    final status = value.valueStatus;

    return Column(
      children: [
        CountryPhoneInput(controller: controller),
        Text(
          'digits: ${status.currentLength}/${status.expectedLength}, '
          'complete: ${status.isComplete}, overflow: ${status.isOverflow}, '
          'phone: ${value.phone}',
        ),
      ],
    );
  },
)
```

External updates should go through the immutable value API:

```dart
controller.value = controller.value.copyWith(
  text: '+44 7911 12345',
);

controller.value = controller.value.copyWith(
  valueStatus: controller.valueStatus.copyWith(expectedLength: 10),
);
```

End-to-end example:

```dart
final controller = CountryPhoneController.empty();

CountryPhoneInput(
  controller: controller,
  initialCountry: Country.us(),
  showPhoneCode: true,
  onChanged: (_) {
    switch (controller.resolution.status) {
      case CountryPhoneResolutionStatus.exact:
        debugPrint('ISO2: ${controller.resolution.primaryCountryCode}');
      case CountryPhoneResolutionStatus.ambiguous:
        debugPrint('Candidates: ${controller.resolution.countryCodes}');
      case CountryPhoneResolutionStatus.unresolved:
        debugPrint('No bundled match for ${controller.phone}');
    }
  },
);
```


### CountryInputFormatter

A `TextInputFormatter` that formats input according to a phone mask. Supports `lazy` (default) and `eager` completion modes. When the input exceeds the mask length, the formatter switches to flat mode (digits only). Read `valueStatus` when you need the current formatted-length state.

```dart
final formatter = CountryInputFormatter(
  mask: '000 000-00-00',
);

debugPrint('${formatter.valueStatus.currentLength}/${formatter.valueStatus.expectedLength}');
```

| Symbol | Matches       |
|--------|---------------|
| `0`    | digit `[0-9]` |
| `#`    | digit `[0-9]` |
| `A`    | digit `[0-9]` |


## Gotchas

- `CountryPhoneController.resolution` is dataset-based, not full phone-number
  validation.
- `resolution.primaryCountryCode` can be `null` when the input is unresolved.
- Shared calling codes such as `+1`, `+7`, and `+44` can legitimately produce
  multiple candidates.
- `filter` and `exclude` should not be used together in `showCountryPicker`.
- `CountryInputFormatter` switches to flat mode when input exceeds the mask.
- `mask` describes the national number only. It should not include the calling
  code.


### CountryScope

An `InheritedWidget` that pre-loads and provides the country list to its subtree, avoiding repeated async loading.

```dart
CountryScope(
  exclude: const ['RU'],
  child: MyApp(),
)
```

Access from descendants:

```dart
// Get the controller
final controller = CountryScope.of(context);

// Get the list of countries (subscribes to changes)
final countries = CountryScope.countriesOf(context);

// Look up a country by ISO2 code
final country = CountryScope.getCountryByCode(context, 'US');
```

Set `lazy: true` to defer the country-list load until you trigger it
explicitly — useful when the list is only needed behind a navigation gate:

```dart
CountryScope(
  lazy: true,
  child: Builder(
    builder: (context) {
      // Loading starts here, not on CountryScope creation.
      CountryScope.of(context).getCountries();
      return const MyCountryPage();
    },
  ),
)
```


### CountryPickerTheme

A `ThemeExtension` for full visual customization. Register it in your `MaterialApp` theme:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      CountryPickerTheme(
        backgroundColor: Colors.white,
        onBackgroundColor: Colors.black87,
        secondaryBackgroundColor: Colors.grey.shade100,
        onSecondaryBackgroundColor: Colors.black54,
        accentColor: Colors.blue,
        barrierColor: Colors.black54,
        dividerColor: Colors.grey.shade300,
        textStyle: const TextStyle(fontSize: 16),
        secondaryTextStyle: const TextStyle(fontSize: 13),
        searchTextStyle: const TextStyle(fontSize: 14),
        flagSize: 22,
        inputHeight: 56,
        padding: 16,
        indent: 10,
        radius: 12,
      ),
    ],
  ),
);
```


## All Countries List

See the [All Countries List](https://github.com/ziqq/flutter_simple_country_picker/wiki/All-Countries-list) on the wiki.


## Maintainer Notes

For bundled dataset maintenance, shared calling-code caveats, and a copy-paste
template for new entries, see [docs/country_codes.md](docs/country_codes.md).


## Changelog

See [CHANGELOG.md](https://github.com/ziqq/flutter_simple_country_picker/blob/main/CHANGELOG.md) for all release notes.


## Maintainers

[Anton Ustinoff (ziqq)](https://github.com/ziqq)


## Funding

If you want to support the development of this library:
- [Buy me a coffee](https://www.buymeacoffee.com/ziqq)
- [Subscribe through Boosty](https://boosty.to/ziqq)


## License

[MIT](https://github.com/ziqq/flutter_simple_country_picker/blob/main/LICENSE)


## Coverage

<img src="https://codecov.io/gh/ziqq/flutter_simple_country_picker/graphs/sunburst.svg?token=fpn56ea0L8" width="375" />