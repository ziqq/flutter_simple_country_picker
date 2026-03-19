# Changelog

## 0.10.1
- **ADDED**: `enableOpenPicker` to `CountryPhoneInput` and `CountryPhoneInput.extended` so the country-prefix button can stay visible while the picker opening is disabled

## 0.10.0
- **BREAKING CHANGES**: `CountryPhoneController` is now a concrete `ValueNotifier<CountryPhoneEditingValue>` controller instead of an `extension type`
- **BREAKING CHANGES**: removed `overflowNotifier`, `onOverflowChanged`, `incompleteNotifier`, and `onIncompleteChanged` from `CountryPhoneInput`; observe `CountryPhoneController` itself or `CountryPhoneController.valueStatus` instead
- **BREAKING CHANGES**: removed `onOverflowChanged`, `overflowNotifier`, `onIncompleteChanged`, and `incompleteNotifier` from `CountryInputFormatter`; read `valueStatus` instead
- **ADDED**: `CountryPhoneEditingValue` to keep raw text, normalized phone, resolution, and `CountryPhoneValueStatus` inside one controller value
- **ADDED**: `CountryPhoneController.fromValue(...)` for SDK-style initialization from a complete `CountryPhoneEditingValue`
- **CHANGED**: hidden the internal `CountryPhoneInput$Extended` implementation from the package root export; use `CountryPhoneInput.extended(...)` as the public entry point
- **CHANGED**: marked `CountryPhoneInput$Extended` as internal to make the intended public API explicit

## 0.9.0
- **BREAKING CHANGES**: removed `CountryPhoneController.countryCode`, `matchingCountryCodes`, `isCountryCodeAmbiguous`, and `isCountryCodeExact`; use `resolution` as the source of truth
- **ADDED**: phone example to each country, [#11](https://github.com/ziqq/flutter_simple_country_picker/issues/11)
- **ADDED**: phone mask to each country, [#12](https://github.com/ziqq/flutter_simple_country_picker/issues/12)
- **ADDED**: optional formatter support for normalizing pasted and preset phone numbers before applying a mask
- **ADDED**: `CountryPhoneController.resolution` with explicit `status` and ordered candidate country codes
- **ADDED**: the simplified dataset-based `CountryPhoneController` resolution flow in the README
- **ADDED**: contributor workflow and invariants for maintaining `country_codes.dart` and the generated `country_codes.json`
- **ADDED**: a dedicated maintainer guide for `country_codes` with concrete good and bad examples for shared calling-code groups
- **ADDED**: README migration notes for `CountryPhoneController`, runtime gotchas, and maintainer policies for choosing sources, `level`, and stable dataset diffs
- **FIXED**: pasted numbers with full country code or national prefix are now normalized before formatting
- **FIXED**: formatter no longer strips the selected country code from numbers that belong to another country
- **FIXED**: `CC` and `CX` reference examples in the bundled country dataset so shared `+61` plans resolve to the correct territory
- **CHANGED**: `CountryPhoneController` resolution now relies only on the bundled dataset because shared country groups for `+61`, `+212`, and `+590` were removed from the source dataset

## 0.8.0
- **BREAKING CHANGES**: `CountryLocalizations` is now an `abstract class` — previously `final class`; it can now be extended to provide custom or additional translations
- **BREAKING CHANGES**: `CountryLocalizations()` constructor no longer accepts a `Locale` argument — the `locale` field has been removed; use `Localizations.localeOf(context)` in your own code if the locale is needed
- **BREAKING CHANGES**: `CountryLocalizations.of()` no longer throws `ArgumentError` when no delegate is found — falls back to English (`CountryLocalizationsEn`)
- **DEPRECATED**: `CountryLocalizations.countryNameRegExp` — use `getFormatedCountryNameByCode` instead
- **CHANGED**: `CountryLocalizations` — complete internal rewrite following the Flutter SDK localization pattern:
  - Each supported language is now a concrete `final class CountryLocalizationsXx extends CountryLocalizations`
  - Country name maps moved from shared module-level variables to per-class `const Map<String, String> _names`
  - UI strings (`cancelButton`, `phonePlaceholder`, `searchPlaceholder`, `selectCountryLabel`) are now typed abstract getters instead of map entries
  - Delegate uses `SynchronousFuture` instead of `Future.value`
  - `isSupported` uses a `Set<String>` O(1) lookup instead of `List.contains` O(n)
  - `supportedLocales` is now `const List<Locale>`
  - `country_parser.dart` uses `Localizations.localeOf(context)` and polymorphic `countryName()` calls
- **ADDED**:
  - Abstract typed API on `CountryLocalizations`: `String get cancelButton`, `String get phonePlaceholder`, `String get searchPlaceholder`, `String get selectCountryLabel`, `String? countryName(String countryCode)`
  - `String? getFormatedCountryNameByCode(String countryCode)` concrete method — returns the country name with collapsed whitespace
  - Unit tests covering all 36 locales, delegate behaviour, fallback, and content correctness (`test/unit_test/country_localizations_test.dart`)
  - Widget tests exercising `CountryLocalizations.of()` inside a widget tree for every locale (`test/widget_test/country_localizations_test.dart`)
  - **FIXED**: The height of the search field in the "CountryListView" to now take into the height of the bottom border of the app bar, which is 1 pixel, so the total height of the search field is now 56 pixels instead of 55 pixels

## 0.7.0
- **BREAKING CHANGES**: `CountryInputFormatter` overflow behavior changed — previously input longer than mask was truncated to mask length; now when input exceeds mask length, mask is reset and the value becomes flat (digits-only)
- **CHANGED**: `CountryInputFormatter`
  - Mask symbol lookup from `List.contains()` to `Set.contains()` for `O(1)` checks
  - `TextMatcher.length` to be cached `(O(1))` instead of calculating via fold() each time
- **ADDED**: `CountryInputFormatter`
  - Flat-mode support to `CountryInputFormatter` (digits-only output) when mask length is exceeded
  - `onOverflowChanged` and `overflowNotifier` to notify when input exceeds mask length
- **ADDED**: `onBackground` and `onSecodaryBackground` color's to `CountryPickerTheme`

## 0.6.5
- **BREAKING CHANGES**: `getAll()` method in `CountryProvider` to `getCountries()`
- **ADDED**: `mask` field to `CY` - `Cyprus` country
- **CHANGED**: removed checking on mask field in `CountryPhoneInput` widget, now if mask field is not null, it will be applied to phone number input
- **CHANGED**: `showGroup` in `CountryController` to be set based only on `showGroup` parameter, not on the number of countries in the list
- **CHANGED**: Grouping countries by data structure instead of grouping them in the widget

## 0.6.4
- **ADDED**: mask field for `Indonesia`, `Iran`
- **CHANGED**: `useGroup` to `showGroup` in `CountryController`
- **FIXED**: mask field for `Thailand` -> now it is `0 0000 0000` instead of `000 000 000`
- **FIXED**: country code for `ID` - `Indonesia` instead of `India` for `tr` and `ru` localizations

## 0.6.3
- **FIXED**: `CountryPhoneInput` widget to apply `textStyle` to cursor properties

## 0.6.2
- **FIXED**: `Country` model to include `mask` field in `toJson` method

## 0.6.1
- **FIXED**: `CountryInputFormatter` the default mask filter has been fixed, now it is possible to have a mask with values ​`​0`, `#`, `A`

## 0.6.0
- **BREAKING CHANGES**: Bahamas coutry code from `12421` to `1242`
- **BREAKING CHANGES**: `CountryPhoneInput` widget now requires `CountryPhoneController` in exchange for `ValueNotifier<String>`
- **ADDED**: `CountryPhoneController` to manage country and phone number state, formatting, and validation
- **ADDED**: Tests for country codes data completeness in `CountryPhoneController` tests
- **CHANGED**: Refactoring country codes data to include `mask` field with `null` values
- **CHANGED**: Updated unit tests to handle new country codes data structure
- **FIXED**: Bahamas coutry code from `12421` to `1242`

## 0.5.2
- **ADDED**: `countryController` to `CountryPhoneInput` widget
-
## 0.5.1
- **ADDED**: `onCountryChanged` callback to `CountryPhoneInput` widget

## 0.5.0
- **ADDED**: Adaptive modal presentation for `iOS` platform in `showCountryPicker` function

## 0.4.0
- **ADDED**: `CountryPhoneInput.extended` constructor for extended functionality
- **CHANGED**: Updated documentation for `CountryPhoneInput` widget

## 0.3.0
- **ADDED**: More localizations support
- **CHANGED**: Refactoring `CountryController.getCountries` to measure performance
- **REMOVED**: `flutter_localizations` and `flutter_intl` from dependencies
- **CHANGED**: Make controller method as `async`

## 0.2.9
- **ADDED**: New `autofocus` argument to replace `useAutofocus`
- **CHANGED**: Make `useAutofocus` deprecated
- **CHANGED**: Refactoring controller and state
- **CHANGED**: `CountryPickerTheme` make properties nullable

## 0.2.8
- **CHANGED**: `README`
- **CHANGED**: Package metadata
- **UPDATED**: Bump dependencies

## 0.2.7
- **CHANGED**: Refactoring `CountryPickerTheme`, `CountryUtil`
- **CHANGED**: Bump dependencies

## 0.2.6
- **ADDED**: Default `keyboardType` to `CountryPhoneInput`
- **ADDED**: Windows preview

## 0.2.5
- **UPDATED**: CountryPickerInput placeholer text style

## 0.2.4
- **FIXED**: CountryPhoneInput formater
- **UPDATED**: CountryPickerTheme

## 0.2.3
- **CHANGED**: Bump dependencies

## 0.2.1
- **CHANGED**: Refactoring

## 0.2.0
- **ADDED**: Tests

## 0.1.3
- **UPDATED**: `SafeArea` from `CountriesList`

## 0.1.2
- **UPDATED**: Bump `flutter_lints`

## 0.1.1
- **UPDATED**: [README](https://github.com/ziqq/flutter_simple_country_picker/blob/master/README.md)

## 0.1.0
- **UPDATED**: `example's`

## 0.0.2
- **CHANGED**: Refactoring

## 0.0.1
- **UPDATED**: Localizations

## 0.0.1-pre.4
- **ADDED**: `CountryInputFormatter`
- **UPDATED**: `CountryUtil`

## 0.0.1-pre.3
- **ADDED**: Selected country to show mark intro list of countries
- **FIXED**: `Android`
- **FIXED**: `iOS`

## 0.0.1-pre.2
- **ADDED**:  `localizations`

## 0.0.1-pre.1
- **CHANGED**: Refactoring

## 0.0.1-pre.0
- **ADDED**: Initial publication
