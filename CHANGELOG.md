# Changelog

## 0.12.0-pre.1
- **DEPRECATED**: `CountryPickerTheme.indent`; it no longer has an effect and will be removed in v1.0.0. Gaps between controls, the search clear icon inset and the vertical padding of `CountryPhoneInput.extended` are now derived from `padding` (`padding / 1.6`, `padding / 3.2`); with the default `padding` the layout is unchanged, [#17](https://github.com/ziqq/flutter_simple_country_picker/issues/17)
- **DEPRECATED**: `CountryPickerTheme.radius`; use `baseCornerRadius` instead, which takes precedence when both parameters are supplied; the getter, constructors and `copyWith` retain the alias for compatibility
- **ADDED**: scrolling the country list expands the sheet, which snaps to its initial or full height
- **ADDED**: `surfaceBuilder` to `showCountryPicker`, `CountryPhoneInput` and `CountryPhoneInput.extended`, and `CountryPickerSurface`, to paint custom surfaces (e.g. liquid glass) behind the search field and close button
- **ADDED**: semantics for country tiles, group headers and the `CountryPhoneInput` country buttons; emoji flags are no longer announced
- **ADDED**: first-opening frame timings, total frame latency, raster-queue delay, complete action durations and image-cache memory diagnostics in the grouped picker profile benchmark, with archived comparisons of picker implementations. [A8 raster and native flag measurements](docs/ios26-raster-performance.md) cover first-opening shader costs and data preparation. [November device measurements](docs/picker-raster-2026-11-06.md) cover cache hints, direct flag rendering and the F2 and F3 candidates. [Filter attribution on physical devices](docs/picker-filter-attribution-2026-11-09.md) records the first-opening backdrop passes on iPhone 7 Plus and the close-button tint trials on Galaxy A8. [Galaxy A8 first-opening attribution](docs/picker-a8-first-open-2026-11-10.md) separates country preparation, lazy row layout and cold Skia/OpenGL program linking
- **ADDED**: accessibility regression coverage for Android/iOS, large and bold system text, nonlinear text scaling, phone/tablet and landscape layouts, RTL, safe areas, keyboard geometry, contrast, labelled touch targets and screen-reader country selection
- **ADDED**: flag-cache regression tests for bounded preparation, selection, text scaling, RTL, pixel density, font loading, memory pressure, eviction, disabled caching and selectable text
- **ADDED**: integration checks for iOS 26 scroll-before-dismiss gestures, short pulls, disabled dismissal, app-bar and native status-bar scroll-to-top, and search expansion from a partial sheet
- **CHANGED**: **BREAKING**: one picker implementation replaces the legacy interface; `CountryPickerStyle` and `CountryPickerTheme.style` are removed, and compact native flags, localized names, English subtitles, trailing phone codes and selected-row checkmarks are always used
- **CHANGED**: sheet corners use superellipse geometry and `CountryPickerTheme.sheetCornerRadius`, defaulting to 38 logical pixels to match the native UIKit sheet measured on iOS 26.5; theme overrides apply in both modal presentations, including smaller and square corners; phone fields retain `baseCornerRadius: 12`, and the adaptive route retains SDK transitions and inherited themes
- **CHANGED**: grouped countries use white rounded sections on the light theme's secondary background, with equal horizontal theme padding; dark mode keeps the continuous dark list, the alphabet is centered in the outer padding, and the first letter header is compact
- **CHANGED**: pickers open at full available height by default; `expand: false` retains partial nonadaptive presentation, and explicit initial sheet sizes remain supported
- **CHANGED**: the grouped example opens an alphabetically sorted list with first-letter headers and an alphabet index, without pinned favorites preceding it
- **CHANGED**: the minimum Flutter version is now 3.44.0, required by the Cupertino sheet scrollableBuilder API
- **CHANGED**: the country picker follows the supplied Telegram reference: centered title, flat country rows with scrolling letter headers and an alphabet index, plus floating bottom search that follows the keyboard; letter headers scroll with their groups, a nonzero bottom safe area replaces the search padding, search focus expands the sheet, results hide letter navigation, and list dragging dismisses the keyboard
- **CHANGED**: the compact header uses a transparent `CupertinoNavigationBar` above the country list and an adaptation of `tetradka_app`'s `UIScrollEdgeEffect`: blur narrows toward the list and the shade continues below the header as a soft tail; initial spacing and alphabet jumps keep countries below the title, the `Glass$Fake` close control keeps its size and feedback, and renderers without shader-filter support retain the shade
- **CHANGED**: progressive-header contribution passes use a separate shader program with the same separable kernels; the generic two-dimensional fallback is loaded only when ancestor opacity or transforms require it, retaining the loading shade until it is ready
- **CHANGED**: close buttons use a Flutter-only adaptation of `tetradka_app`'s `UILiquidGlass$Fake`, including its fill, outline, blur and press feedback; custom `surfaceBuilder` overrides remain supported, reduced motion disables feedback, and high contrast uses opaque close buttons
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
- **FIXED**: the full-width header shade stays inside the sheet's rounded outline on Android; one antialiased clip replaces the obsolete inset-header background shortcut that left a rectangular surface visible behind the upper corners; [earlier inset-header measurements](docs/ios26-raster-performance.md#opaque-android-sheet-background--2223-october-2026) describe the previous layout
- **FIXED**: glass backdrop filters no longer restore a rectangular surface behind sheet corners; the isolated sheet clip also supplies the coordinate origin for the progressive header blur in partial and full-height presentations
- **FIXED**: countries without a translation (e.g. Croatia in Turkish) use their original name for sorting and grouping and remain visible
- **FIXED**: grouped pickers virtualize country rows in one lazy list with scrolling letter headers and alphabet navigation
- **FIXED**: repeated color-emoji raster work in the picker: flags reuse GPU images through Flutter's bounded `ImageCache` and refresh after text-style, density or system-font changes; preparation is limited to two images per frame while original text remains visible, and disabled caching or selectable text retains the original renderer
- **FIXED**: repeated diacritic folding and case normalization while sorting localized countries: comparison keys are computed once per country while preserving the existing display order and original-name fallback
- **FIXED**: the default `InkSparkle` shader is no longer created for country-row presses; the gray highlight, country selection and flag rendering are preserved, while custom splash factories retain their effects; [Galaxy A8 before/after measurements](docs/ios26-raster-performance.md#ios26-row-presses-without-inksparkle--23-october-2026)
- **FIXED**: the grouped picker profile benchmark now uses `benchmarkLive` to capture framework-requested animation frames and records raw timing samples, action windows, the frame policy and protocol version; first-opening capture also drains the final timing batch while keeping the action window separate; earlier measurement protocols and the A8 GPU-compiler experiments remain documented separately, with no shader warm-up or public API change
- **FIXED**: CI limits mise lockfile checksum refreshes to the runner's platform instead of downloading every desktop Flutter archive during installation

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
