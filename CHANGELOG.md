# Changelog

## 1.0.0
- **ADDED**: scrolling the country list expands the sheet, which snaps to its initial or full height
- **ADDED**: `surfaceBuilder` to `showCountryPicker`, `CountryPhoneInput` and `CountryPhoneInput.extended`, and `CountryPickerSurface`, to paint custom surfaces (e.g. liquid glass) behind the search field and close button
- **ADDED**: semantics for country tiles, group headers and the `CountryPhoneInput` country buttons; emoji flags are no longer announced
- **ADDED**: first-opening frame timings, total frame latency, raster-queue delay, complete action durations and image-cache memory diagnostics in the grouped picker profile benchmark
- **ADDED**: accessibility regression coverage for Android/iOS, large and bold system text, nonlinear text scaling, phone/tablet and landscape layouts, RTL, safe areas, keyboard geometry, contrast, labelled touch targets and screen-reader country selection
- **ADDED**: flag-cache regression tests for bounded preparation, selection, text scaling, RTL, pixel density, font loading, memory pressure, eviction, disabled caching and selectable text
- **ADDED**: integration checks for iOS 26 scroll-before-dismiss gestures, short pulls, disabled dismissal, app-bar and native status-bar scroll-to-top, and search expansion from a partial sheet
- **CHANGED**: **BREAKING**: migrated the picker, phone inputs and `CountryPickerTheme` to the standalone `material_ui` and `cupertino_ui` packages. Upgrade the host app's design imports and localization delegates as described in the [migration guide](MIGRATION.md#to-100)
- **CHANGED**: **BREAKING**: removed deprecated picker options `adaptive`, `onDone`, `useAutofocus` and `useHaptickFeedback`. The picker uses a Material modal on every platform. Use `whenComplete`, `autofocus` and `useHapticFeedback` for the remaining options
- **CHANGED**: **BREAKING**: removed `CountryPickerTheme.indent`, `radius` and `inputDecoration`. Spacing uses `padding` and the theme exposes separate `baseCornerRadius` and `sheetCornerRadius` values, [#17](https://github.com/ziqq/flutter_simple_country_picker/issues/17)
- **CHANGED**: **BREAKING**: removed `Country.getTranslatedName` and `CountryLocalizations.countryNameRegExp`. Use `toLocalizedString` and `getFormatedCountryNameByCode`
- **CHANGED**: **BREAKING**: one picker implementation replaces the legacy interface; `CountryPickerStyle` and `CountryPickerTheme.style` are removed, and compact native flags, localized names, English subtitles, trailing phone codes and selected-row checkmarks are always used
- **CHANGED**: sheet corners use superellipse geometry and `CountryPickerTheme.sheetCornerRadius`, defaulting to 38 logical pixels to match the native UIKit sheet measured on iOS 26.5; theme overrides include smaller and square corners, and phone fields retain `baseCornerRadius: 12`
- **CHANGED**: grouped countries use white rounded sections on the light theme's secondary background, with equal horizontal theme padding; dark mode keeps the continuous dark list, the alphabet is centered in the outer padding, and the first letter header is compact
- **CHANGED**: pickers open at full available height by default; `expand: false` retains partial presentation, and explicit initial sheet sizes remain supported
- **CHANGED**: the grouped example opens an alphabetically sorted list with first-letter headers and an alphabet index, without pinned favorites preceding it
- **CHANGED**: the example uses standalone Cupertino menus for language selection and the Linux country preview
- **CHANGED**: the minimum SDK versions are Flutter 3.44.0 and Dart 3.12.0
- **CHANGED**: the country picker follows the supplied Telegram reference: centered title, flat country rows with scrolling letter headers and an alphabet index, plus floating bottom search that follows the keyboard; letter headers scroll with their groups, a nonzero bottom safe area replaces the search padding, search focus expands the sheet, results hide letter navigation, and list dragging dismisses the keyboard
- **CHANGED**: the compact header uses a transparent `CupertinoNavigationBar` above the country list and an adaptation of `tetradka_app`'s `UIScrollEdgeEffect`: blur narrows toward the list and the shade continues below the header as a soft tail; initial spacing and alphabet jumps keep countries below the title, the `GlassFake` close control keeps its size and feedback
- **CHANGED**: Android uses a solid Material `AppBar` when shader filters are unavailable. The Android header close button animates a themed fill and rim on hover and press. The fallback keeps the compact header height, floating bottom search and tap-to-scroll-to-top behavior
- **CHANGED**: progressive-header contribution passes use a separate shader program with the same separable kernels; the generic two-dimensional fallback is loaded only when ancestor opacity or transforms require it, retaining the loading shade until it is ready
- **CHANGED**: close buttons use a Flutter-only adaptation of the glass controls in `tetradka_app`, including its fill, outline, blur and press feedback; custom `surfaceBuilder` overrides remain supported, reduced motion disables feedback, and high contrast uses opaque close buttons
- **CHANGED**: the search field shares close-button press and hover feedback, including content opacity, duration and reduced-motion handling; expansion adapts to the control size and available spacing, text input retains its own focus and selection gestures, and custom surface builders receive search press state
- **CHANGED**: picker controls, scroll-edge painting and flag caching are independent Dart libraries with regular imports instead of `part` files
- **CHANGED**: package, example and release-helper internals use checked type patterns and nullable-value handling instead of explicit type casts and forced null assertions
- **CHANGED**: picker control colors come from `CountryPickerTheme` and the ambient theme; secondary country names use the resolved `secondaryTextStyle` without overriding its font size or line height, and row measurement uses the same style; the close control is a standalone widget, and pattern bindings use explicit types
- **FIXED**: enlarged text no longer overflows country rows or compact phone inputs; rows move calling codes below names at accessibility sizes, compact inputs stack when needed and field heights follow scaled text; search and phone labels persist while editing, disabled country buttons expose their disabled state, alphabet navigation is adjustable by screen readers, letter headers retain theme contrast and Android close targets meet the 48 dp minimum
- **FIXED**: flags on Windows: the Windows emoji font has no country flags, so the package now bundles the "Twemoji Country Flags" font as a Windows-only asset and uses it for flags in the picker and `CountryPhoneInput` while preserving custom package fonts and their fallbacks, [#19](https://github.com/ziqq/flutter_simple_country_picker/issues/19)
- **FIXED**: Windows progressive-header shaders use the original Gaussian sums without paired uniform indexing and retain the backdrop texture's top-left orientation, avoiding native D3D compiler crashes and keeping country rows visible in light, dark and ancestor-opacity presentations; the shader programs used on other platforms are unchanged
- **FIXED**: countries with diacritics (e.g. `Österreich`, `Égypte`) are sorted and grouped with their base letter instead of after `Z`, and search ignores diacritics, [#18](https://github.com/ziqq/flutter_simple_country_picker/issues/18)
- **FIXED**: `showWorldWide` was accepted but ignored; the World Wide option is now shown on top of the list
- **FIXED**: in grouped mode favorites no longer split a letter group into two sections with the same header
- **FIXED**: in grouped mode a search without results no longer keeps showing the previous groups
- **FIXED**: the expanded picker accepts the first upward drag at the start of the country list when swipe-to-close is disabled; a fixed-height sheet no longer consumes that drag as an impossible resize
- **FIXED**: picker sheets honor `shouldCloseOnSwipeDown` for sheet dragging and dismissal at the minimum extent; the example enables swipe-to-close through this existing option
- **FIXED**: a fast scroll back to the beginning no longer closes the picker sheet; dismissal requires a separate gesture started at the beginning, while list inertia remains scrolling; tapping the compact app bar scrolls to the beginning through the same handler as the SDK status-bar action
- **FIXED**: the alphabet keeps its size and position when the keyboard opens and continues behind it instead of shrinking; Android close buttons use an inset press animation, retain icon contrast and use a one-pixel outline to avoid clipped expansion
- **FIXED**: the header close button paints outside the navigation bar's clip and expands into the sheet without truncating its circle
- **FIXED**: Android list spacing matches iOS: light groups have `padding` outside and inside their surfaces, dark rows use `padding * 2`, and country codes stay clear of the alphabet without a second Android-only inset; header controls use `padding` above and beside the close button, with `padding / 2` below the navigation bar
- **FIXED**: the full-width header shade stays inside the sheet's rounded outline on Android; one antialiased clip replaces the obsolete inset-header background shortcut that left a rectangular surface visible behind the upper corners
- **FIXED**: glass backdrop filters no longer restore a rectangular surface behind sheet corners; the isolated sheet clip also supplies the coordinate origin for the progressive header blur in partial and full-height presentations
- **FIXED**: countries without a translation (e.g. Croatia in Turkish) use their original name for sorting and grouping and remain visible
- **FIXED**: grouped pickers virtualize country rows in one lazy list with scrolling letter headers and alphabet navigation
- **FIXED**: repeated color-emoji raster work in the picker: flags reuse GPU images through Flutter's bounded `ImageCache` and refresh after text-style, density or system-font changes; preparation is limited to two images per frame while original text remains visible, and disabled caching or selectable text retains the original renderer
- **FIXED**: repeated diacritic folding and case normalization while sorting localized countries: comparison keys are computed once per country while preserving the existing display order and original-name fallback
- **FIXED**: the default `InkSparkle` shader is no longer created for country-row presses; the gray highlight, country selection and flag rendering are preserved, while custom splash factories retain their effects
- **FIXED**: the grouped picker profile benchmark now uses `benchmarkLive` to capture framework-requested animation frames and records raw timing samples, action windows, the frame policy and protocol version; first-opening capture also drains the final timing batch while keeping the action window separate
- **FIXED**: CI limits mise lockfile checksum refreshes to the runner's platform instead of downloading every desktop Flutter archive during installation

## 0.11.4
- **DEPRECATED**: `adaptive` in `showCountryPicker`. The Cupertino sheet remains available until `1.0.0`. Omit `adaptive` to use the Material sheet
- **FIXED**: align the automatic mask hint with the editable text at custom and default phone field heights, [#27](https://github.com/ziqq/flutter_simple_country_picker/issues/27)
- **FIXED**: inherit the app's text color for both phone inputs and derive mask hints from the same text style, with independent styling for country search
- **FIXED**: detach the old country controller and preserve the values of both external controllers when `initialCountry` changes during replacement
- **FIXED**: parse the new number using the newly selected country when both phone input controllers are replaced together
- **FIXED**: keep an empty replacement phone controller unchanged when only the phone controller is replaced
- **FIXED**: recognize barrier color changes, preserve exact theme values and background color fallbacks in `copyWith`, and retain `inputDecoration` during theme transitions
- **FIXED**: preserve local themes and follow app theme changes in open adaptive iOS sheets, and refresh grouped headers when the theme changes
- **FIXED**: preserve explicit local picker themes in adaptive iOS sheets, including shared theme instances, and keep app theme updates when local Material styling reuses the app's extensions
- **FIXED**: apply `searchTextStyle` to the query and clear grouped results when no countries match
- **FIXED**: honor `showPhoneCode` and show favorite calling-code entries only once
- **FIXED**: show the selectable World Wide entry when `showWorldWide` is enabled
- **FIXED**: keep `CountryState` snapshots and their hash codes stable when the source country list changes
- **FIXED**: reject pasted international numbers with a different calling code and preserve the committed phone value during IME composition
- **FIXED**: recognize international calling codes written in parentheses before formatting pasted phone numbers
- **FIXED**: synchronize programmatic phone controller changes with both input variants and apply explicit text styles in the extended input
- **FIXED**: preserve foreign phone numbers when reconfiguring the field, leave replaced controllers untouched, and suppress change callbacks for rejected input
- **FIXED**: keep the committed number when changing masks during IME composition and respect controller clears from listeners during reformatting
- **FIXED**: publish initial phone status after the widget tree builds and preserve E.164 rewrites from controller listeners without repeating notifications
- **FIXED**: apply initial country changes to external controllers after build and keep controller values unchanged on selection-only phone edits
- **FIXED**: preserve the controller's E.164 text when input is rejected and keep the manual mask when non-digit characters are appended
- **FIXED**: strip the matching international calling code after `00` before checking manual phone input length
- **FIXED**: leave the national field empty when a pasted number contains only the selected calling code
- **FIXED**: keep picker drag, full-height mode, and navigation after selection working through the route's public options
- **FIXED**: honor `shouldCloseOnSwipeDown` when dragging the Material country list to its minimum height, including when it opens at that height, and allow header drag dismissal
- **FIXED**: restore country list scrolling in the full-height Material picker when swipe-down dismissal is disabled
- **FIXED**: keep country search results visible above the keyboard by default in both phone inputs
- **FIXED**: focus the cleared phone field after selecting a different country so the numeric keyboard opens
- **FIXED**: preserve grouped countries without translations, refresh grouped results when the locale changes, and honor lazy `CountryScope` loading
- **FIXED**: refresh the mounted `CountryScope` when its country filters change
- **FIXED**: preserve explicit null colors when interpolating raw picker themes
- **FIXED**: run the build targets for `make generate` and refresh example dependencies with `make update`
- **FIXED**: refuse to tag a release when the current branch has unpushed commits
- **CHANGED**: declare Flutter 3.44.0 as the minimum SDK for the Cupertino sheet and ship a smaller flags-only font with the example
- **REMOVED**: the unused experimental `CountryPickerOptions` class

## 0.11.3
- **ADDED**: expanded the picker to 75 built-in locales, including all 71 entries in the Telegram Translations catalog and separate Brazilian (`pt-BR`) and European (`pt-PT`) Portuguese translations
- **FIXED**: phone input completion rejects national numbers made entirely of zeros, [#25](https://github.com/ziqq/flutter_simple_country_picker/issues/25)
- **FIXED**: Hindi (`hi`) uses its own translations, and Turkish (`tr`) includes the six missing country names
- **FIXED**: the extended phone input falls back to the original country name when a translation is missing
- **CHANGED**: automatic phone formatting uses country templates with the longest matching prefix, shows the unfilled template in gray in both input variants, and retains digits beyond the template without regrouping, [#25](https://github.com/ziqq/flutter_simple_country_picker/issues/25)

## 0.11.2
- **ADDED**: opt-in phone formatting by country and prefix through `CountryInputFormatter.forCountry`, `updateCountry` and `CountryPhoneInput.useCountryFormatting` (including `extended`); pinned libphonenumber rules for 238 countries recognize every supported length and retain digits beyond the pattern
- **FIXED**: pasted Indonesian numbers preserve their significant leading `8`; input widgets strip country-declared national prefixes, retain manual prefix normalization for custom countries and preserve selection when switching formatting modes
- **CHANGED**: renamed the generated dataset mirror to `country_codes.g.json`

## 0.11.1
- **DEPRECATED**: `useHaptickFeedback`; use `useHapticFeedback` instead. When both are provided, `useHapticFeedback` takes precedence
- **ADDED**: `useHapticFeedback` to `showCountryPicker`, `CountryPickerOptions`, `CountryPhoneInput`, and `CountryPhoneInput.extended`
- **CHANGED**: the publish workflow now listens to the repository's `vX.Y.Z` release tags

## 0.11.0
- **ADDED**: static `Country.fromLocale`, `Country.fromLocaleOrNull`, `Country.fromCountryCode`, `Country.fromCountryCodeOrNull`, and `Country.normalizeRegionCode` helpers
- **ADDED**: bundled region alias normalization for non-standard territory codes such as `AC`, `IC`, and `TA`
- **CHANGED**: package root export and README now document the locale-to-country resolution flow

## 0.10.3
- **CHANGED**: Updating [SelectedCountry] when country is selected from the list of countries

## 0.10.2
- **CHANGED**: `CountryPhoneInput.extended` now applies a single resolved picker text style consistently to the country label, country code, input text, cursor, and hint text

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
