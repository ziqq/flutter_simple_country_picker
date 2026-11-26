# Migration Guide

This document collects upgrade notes for package releases with breaking or
behavior-changing API updates.

## Contents

- [To 1.0.0](#to-100)
- [To 0.11.1](#to-0111)
- [To 0.10.0](#to-0100)
- [To 0.9.0](#to-090)

## To 1.0.0

Version 1.0.0 requires Flutter 3.44.0 and Dart 3.12.0. The picker and
`CountryPickerTheme` now use the standalone Flutter design packages.
Import `MaterialApp`, `ThemeData`, and `ThemeExtension` from `material_ui`
when configuring the picker. Use `cupertino_ui` for the Cupertino
widgets and theme in the same widget tree. Add each package you import
as a direct dependency of your app.

Replace the old Material and Cupertino localization delegates with
`GlobalMaterialLocalizations.delegates` from `material_ui` and keep
`CountryLocalizations.delegate`. This also supplies the Cupertino and
Widgets delegates. For a root `CupertinoApp`, use the same Material
delegate list because the country picker opens a Material bottom sheet.

The picker now has one interface. Remove `CountryPickerStyle` and the `style:`
argument from `CountryPickerTheme`. Groups have scrolling letter headers;
the alphabet index and floating search remain available through `showGroup`
and `showSearch`. Light mode uses inset white groups and dark mode uses a
continuous dark list. Flags retain their native, uncropped glyphs.

Use `baseCornerRadius` for input fields and `sheetCornerRadius` for picker sheets.
Remove the old `radius` argument and replace `indent` with `padding` if you
need to adjust spacing. Remove `inputDecoration` from the picker theme.

```dart
CountryPickerTheme(baseCornerRadius: 12, sheetCornerRadius: 38);
```

An explicit `sheetCornerRadius: 0` permits square sheet corners.

Remove `adaptive` from `showCountryPicker`. It now uses the Material modal on
all platforms. Pickers open at full available height by default. Use
`expand: false` for a partial sheet, or supply an explicit `initialChildSize`.
Both phone input variants forward their `expand` setting to the picker.

Use `whenComplete` in place of `onDone`, `autofocus` in place of
`useAutofocus`, and `useHapticFeedback` in place of `useHaptickFeedback`.
Omit `useHapticFeedback` to keep feedback enabled.

Replace `Country.getTranslatedName` with `Country.toLocalizedString`. For
formatted country names, use `CountryLocalizations.getFormatedCountryNameByCode`
in place of `CountryLocalizations.countryNameRegExp`.

The package declares a Windows-only font asset for flags.

Behavior changes to be aware of:

- `showWorldWide` now adds the World Wide option; it was ignored before.
- In grouped mode favorites are shown in a leading section without a letter
  header.
- Names with diacritics are sorted with their base letter, and search ignores
  diacritics.

## To 0.11.1

`useHaptickFeedback` is deprecated because of its spelling. Replace it with
`useHapticFeedback` in `showCountryPicker`, `CountryPhoneInput`, and
`CountryPhoneInput.extended`.

Before 0.11.1:

```dart
showCountryPicker(
  context: context,
  useHaptickFeedback: false,
);
```

After 0.11.1:

```dart
showCountryPicker(
  context: context,
  useHapticFeedback: false,
);
```

The deprecated parameter continues to work until v1.0.0. If both parameters
are supplied, `useHapticFeedback` takes precedence.

## To 0.10.0

`CountryPhoneController` is now the single reactive source for phone-input
status.

- Update your dependency to `flutter_simple_country_picker: ^0.10.0`.
- `CountryPhoneController` is now a concrete class extending
  `ValueNotifier<CountryPhoneEditingValue>`.
- Removed from `CountryPhoneInput`: `overflowNotifier`,
  `onOverflowChanged`, `incompleteNotifier`, `onIncompleteChanged`.
- Removed from `CountryInputFormatter`: `onOverflowChanged`,
  `overflowNotifier`, `onIncompleteChanged`, `incompleteNotifier`.
- Use `CountryPhoneController.value`, `CountryPhoneController.text`, or
  `CountryPhoneController.valueStatus` in widget flows.
- If you use `CountryInputFormatter` directly, read
  `formatter.valueStatus` instead.
- Dispose externally owned `CountryPhoneController` instances the same way you
  would dispose a `TextEditingController`.

If you are migrating from `0.9.x`, the most important change is that the
controller is no longer observed as a plain string value. The reactive source
is now `CountryPhoneEditingValue`.

### Replace old bool notifier flows

Before `0.10.0`:

```dart
final overflowNotifier = ValueNotifier<bool>(false);
final incompleteNotifier = ValueNotifier<bool>(false);

CountryPhoneInput(
  controller: controller,
  overflowNotifier: overflowNotifier,
  incompleteNotifier: incompleteNotifier,
);
```

After `0.10.0`:

```dart
final controller = CountryPhoneController.empty();

ValueListenableBuilder<CountryPhoneEditingValue>(
  valueListenable: controller,
  builder: (context, value, _) {
    final status = value.valueStatus;

    return Column(
      children: [
        CountryPhoneInput(controller: controller),
        Text('overflow: ${status.isOverflow}'),
        Text('incomplete: ${status.isIncomplete}'),
      ],
    );
  },
)
```

If you use the formatter without `CountryPhoneInput`, replace the removed
callbacks/notifiers with `formatter.valueStatus`.

### Replace string-based controller listeners

Before `0.10.0`:

```dart
final controller = CountryPhoneController.apply('+7 123 456 78 90');

ValueListenableBuilder<String>(
  valueListenable: controller,
  builder: (context, phone, _) {
    return Text(phone);
  },
)
```

After `0.10.0`:

```dart
final controller = CountryPhoneController.apply('+7 123 456 78 90');

ValueListenableBuilder<CountryPhoneEditingValue>(
  valueListenable: controller,
  builder: (context, value, _) {
    return Text(value.phone);
  },
)
```

### Replace direct string writes

Before `0.10.0`:

```dart
controller.value = '+44 7911 123456';
```

After `0.10.0` choose the narrowest API that matches your intent:

```dart
controller.text = '+44 7911 123456';

controller.value = controller.value.copyWith(
  text: '+44 7911 123456',
);
```

Use `controller.text = ...` when only the raw text changes.
Use `controller.value = controller.value.copyWith(...)` when you want to
update text and preserve or override the current `CountryPhoneValueStatus`
explicitly.

## To 0.9.0

`CountryPhoneController` now uses `resolution` as the source of truth.

- Removed: `countryCode`
- Removed: `matchingCountryCodes`
- Removed: `isCountryCodeAmbiguous`
- Removed: `isCountryCodeExact`
- Use `resolution.primaryCountryCode` when you need the primary ISO2 result.
- Use `resolution.countryCodes` when you need all ordered candidates.
- Use `resolution.status` when you need to distinguish exact, ambiguous, and
  unresolved states.
