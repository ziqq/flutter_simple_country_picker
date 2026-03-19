# Example App

This folder contains the bundled example application for `flutter_simple_country_picker`.

It demonstrates:

- `showCountryPicker(...)`
- `CountryPhoneInput` and `CountryPhoneInput.extended(...)`
- `CountryPhoneController` with `CountryPhoneEditingValue`
- `CountryPickerTheme` and localization setup

## Run The Example

```sh
flutter pub get
flutter run
```

The example depends on the local package via `path: ..`.

If you want to use the package in a separate app, add:

```yaml
dependencies:
  flutter_simple_country_picker: ^latest
```

## Minimal Picker Example

```dart
showCountryPicker(
  context: context,
  favorites: ['RU'],
  exclude: ['KN', 'MF'],
  showPhoneCode: true,
  showSearch: true,
  whenComplete: () => debugPrint('Picker closed'),
  onSelect: (Country country) {
    debugPrint('Selected: ${country.displayName}');
  },
);
```

Useful options in the current API:

- `exclude`
- `favorites`
- `filter`
- `selected`
- `whenComplete`
- `adaptive`
- `autofocus`
- `showPhoneCode`
- `showWorldWide`
- `showGroup`
- `showSearch`
- `initialChildSize`
- `minChildSize`

Use either `filter` or `exclude`, not both.

## Minimal Phone Input Example

```dart
final controller = CountryPhoneController.empty();

ValueListenableBuilder<CountryPhoneEditingValue>(
  valueListenable: controller,
  builder: (context, value, _) {
    final status = value.valueStatus;

    return Column(
      children: [
        CountryPhoneInput(
          controller: controller,
          initialCountry: Country.us(),
          enableOpenPicker: false,
          showPhoneCode: true,
        ),
        Text('phone: ${value.phone}'),
        Text(
          'digits: ${status.currentLength}/${status.expectedLength}, '
          'complete: ${status.isComplete}',
        ),
      ],
    );
  },
)
```

For seeded state, use `CountryPhoneController.fromValue(...)`.

Use `enableOpenPicker: false` when the country must stay fixed and tapping the
prefix button should not open the picker.

## Theme And Localization

Register localization delegates in your `MaterialApp` and optionally provide a
`CountryPickerTheme` through `ThemeData.extensions`:

```dart
MaterialApp(
  localizationsDelegates: const [
    CountryLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: CountryLocalizations.supportedLocales,
  theme: ThemeData(
    extensions: const [
      CountryPickerTheme(
        radius: 16,
        flagSize: 24,
      ),
    ],
  ),
)
```

## Notes

- Dispose controllers you create yourself.
- If you use `CountryInputFormatter` directly, read `formatter.valueStatus`.
- `CountryPhoneController.resolution` is a bundled heuristic, not a full phone validator.
