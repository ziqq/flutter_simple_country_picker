# Migration Guide

This document collects upgrade notes for package releases with breaking or
behavior-changing API updates.

## Contents

- [To 0.10.0](#to-0100)
- [To 0.9.0](#to-090)

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