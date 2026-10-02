/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 30 September 2026
 */

/// The visual style of the country picker.
///
/// Set it with `CountryPickerTheme.style`.
///
/// More styles may be added in minor releases, so a `switch` over this enum
/// should always have a fallback branch.
enum CountryPickerStyle {
  /// The original style: flat search bar with a text "Cancel" button,
  /// full-width list and emoji flags.
  classic,

  /// A style close to the native iOS 26 country picker.
  ///
  /// Pill-shaped search field with a round close button, inset rounded
  /// list section, circular flags, the phone code shown before the country
  /// name and a checkmark badge on the selected flag. Scrolling the list
  /// expands the sheet.
  ios26,
}
