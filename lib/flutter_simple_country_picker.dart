/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 24 June 2024
 */

/// A Flutter package providing country and phone-number selection widgets.
///
/// ## Key classes
///
/// | Symbol | Description |
/// |-----|-----|
/// | [showCountryPicker] | Opens a searchable bottom-sheet country picker. |
/// | [CountryPhoneInput] | Phone-number input with embedded country selector. |
/// | [CountryPhoneController] | ValueNotifier-based controller for phone value and status. |
/// | [CountryPhoneEditingValue] | Immutable controller value with text, resolution, and status. |
/// | [CountryInputFormatter] | Masks phone input according to a dial-format. |
/// | [CountryScope] | Pre-loads the country list into the widget tree. |
/// | [CountryPickerTheme] | Visual customization via `ThemeExtension`. |
/// | [CountryLocalizations] | Localization delegate — 36 built-in locales. |
///
/// ## Minimal setup
///
/// 1. Register the localization delegate in your `MaterialApp`:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: [
///     CountryLocalizations.delegate,
///     GlobalWidgetsLocalizations.delegate,
///     GlobalMaterialLocalizations.delegate,
///   ],
///   supportedLocales: CountryLocalizations.supportedLocales,
///   home: const MyHomePage(),
/// );
/// ```
///
/// 2. Open the picker from any widget:
///
/// ```dart
/// showCountryPicker(
///   context: context,
///   onSelect: (Country country) {
///     print(country.displayName); // e.g. "Russia (+7)"
///   },
/// );
/// ```
library;

export 'src/constant/typedef.dart';
export 'src/controller/country_controller.dart' show CountryState;
export 'src/controller/country_phone_controller.dart';
export 'src/localization/country_localizations.dart' show CountryLocalizations;
export 'src/model/country.dart';
export 'src/theme/country_picker_theme.dart';
export 'src/util/country_input_formatter.dart';
export 'src/widget/country_phone_input.dart' hide CountryPhoneInput$Extended;
export 'src/widget/country_scope.dart' show CountryScope;
export 'src/widget/show_country_picker.dart' show showCountryPicker;
