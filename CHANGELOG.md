## 0.6.4
- **ADDED**: mask field for `Iran` and `Indonesia` country code in country codes

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
