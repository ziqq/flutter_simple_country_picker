# country_codes maintenance guide

This document explains how the bundled country dataset works and what to check
before adding or changing entries in
`lib/src/constant/country_codes.dart`.

## Source of truth

- `lib/src/constant/country_codes.dart` is the canonical dataset.
- `lib/src/constant/country_codes.json` is generated from the Dart file.
- Never edit `country_codes.json` by hand.

After changing the Dart dataset, regenerate the JSON mirror:

```shell
fvm dart --disable-analytics run tool/generate_json.dart
```

Then run at least:

```shell
fvm flutter test test/unit_test/country_codes_test.dart
```

If the change can affect phone resolution, also run:

```shell
fvm flutter test test/unit_test/country_phone_controller_test.dart
```

## Where data should come from

Prefer authoritative public numbering-plan sources first and use secondary
sources only for cross-checking.

- telecom regulator or official numbering-plan publications,
- official country or territory telecom documentation,
- well-maintained public metadata such as libphonenumber only as a secondary
  verification source,
- real example numbers only when they are clearly documented as examples or
  test values.

Avoid adding or changing entries based only on random websites, user-generated
tables, or undocumented examples.

## Why this file matters at runtime

`country_codes.dart` is not just static reference data.

- `Country.fromJson()` reads these fields directly.
- `CountryPhoneController` resolves candidate countries by comparing the parsed
  national number against `example` values inside the same `e164_cc` group.
- `level` is used as a tie-breaker when multiple countries have the same best
  prefix match. Lower `level` wins.
- `CountryInputFormatter` tests use `example`, `mask`, and
  `full_example_with_plus_sign` to verify normalization and formatting.

Because of that, changing a single record can affect both formatting and phone
resolution behavior.

## Field reference

### Core identity fields

- `e164_cc`: country calling code, digits only, no leading `+`.
- `iso2_cc`: uppercase ISO alpha-2 code.
- `e164_sc`: sub-code used by the dataset when needed. Use `0` when no extra
  split is represented.
- `e164_key`: unique stable key. Current format is `e164_cc-iso2_cc-e164_sc`.

### Resolution-related fields

- `example`: representative national number without the calling code.
- `level`: priority within the same calling-code group.
  Lower values win after prefix comparison.
- `geographic`: boolean marker used by the public model.

### How to choose `level`

`level` is a dataset priority, not a confidence score.

- use `1` for the main entry in a calling-code group,
- use higher values such as `2` for related territories or lower-priority
  siblings under the same `e164_cc`,
- do not change `level` casually because it affects tie-breaking in
  `CountryPhoneController`,
- if two entries have the same prefix quality and the same `level`, ordering is
  still deterministic, but the semantic intent of the dataset becomes less
  clear.

### Display and formatting fields

- `name`: English country or territory name.
- `display_name`: display label including ISO2 and calling code.
- `display_name_no_e164_cc`: display label without calling code.
- `mask`: formatting mask for the national number only.
- `full_example_with_plus_sign`: full number with leading `+` and calling code.

## Invariants you should preserve

- `name`, `e164_cc`, and `e164_key` must be non-empty.
- `iso2_cc` must match `^[A-Z]{2}$`.
- `geographic` must always be a boolean.
- `e164_key` must remain unique across the whole dataset.
- `full_example_with_plus_sign` must normalize back to the same national number
  as `example`.
- `mask` must describe only the national number. Do not include the calling
  code in the mask.
- `display_name` and `display_name_no_e164_cc` must stay consistent with
  `name`, `iso2_cc`, and `e164_cc`.

These rules are enforced mainly by
`test/unit_test/country_codes_test.dart`.

## Shared calling-code groups

Duplicate `e164_cc` values are valid. They are part of the dataset today.
Examples include `+1`, `+7`, and `+44`.

Different `iso2_cc` values do not remove the runtime problem. The controller
still has to decide which country best matches an incoming number inside the
shared group.

When you add a country under an existing `e164_cc`, you are editing a resolution
group, not just adding a row.

### Good current example: `+7`

Current active records include:

```dart
{
  'e164_cc': '7',
  'iso2_cc': 'RU',
  'level': 1,
  'example': '9123456789',
  'full_example_with_plus_sign': '+79123456789',
}

{
  'e164_cc': '7',
  'iso2_cc': 'KZ',
  'level': 2,
  'example': '7710009998',
  'full_example_with_plus_sign': '+77710009998',
}
```

Why this is good:

- both entries share the same calling code,
- the examples diverge immediately after the calling code,
- the full examples round-trip back to the national examples,
- `level` provides a deterministic fallback if prefix quality is equal.

### Good current example: `+44`

Current active records include:

```dart
{
  'e164_cc': '44',
  'iso2_cc': 'GB',
  'level': 1,
  'example': '7400123456',
}

{
  'e164_cc': '44',
  'iso2_cc': 'GG',
  'level': 2,
  'example': '7781123456',
}

{
  'e164_cc': '44',
  'iso2_cc': 'IM',
  'level': 2,
  'example': '7924123456',
}

{
  'e164_cc': '44',
  'iso2_cc': 'JE',
  'level': 2,
  'example': '7797123456',
}
```

Why this is good:

- all entries use the same national mask shape,
- the examples diverge early enough to help prefix-based resolution,
- the main entry keeps `level: 1`, while related territories stay lower
  priority with `level: 2`.

## Bad patterns to avoid

### Bad: reusing the same example in a shared group

```dart
{
  'e164_cc': '44',
  'iso2_cc': 'GB',
  'example': '7400123456',
}

{
  'e164_cc': '44',
  'iso2_cc': 'GG',
  'example': '7400123456',
}
```

This removes the prefix signal that the resolver needs and can turn an exact
match into an ambiguous one.

### Bad: full example does not match the national example

```dart
{
  'e164_cc': '44',
  'iso2_cc': 'GB',
  'example': '7400123456',
  'full_example_with_plus_sign': '+447911123456',
}
```

This breaks the formatter round-trip expectation and will fail the dataset
coverage tests.

### Bad: mask includes the calling code

```dart
{
  'e164_cc': '44',
  'iso2_cc': 'GB',
  'mask': '+44 0000 000000',
}
```

`mask` must describe only the national part. The calling code is handled
outside the mask.

### Bad: adding a new shared-code entry without checking the whole group

If you add a new `+1`, `+7`, or `+44` record in isolation, you can easily
degrade resolution for existing countries. Always inspect every entry with the
same `e164_cc` before merging.

## Updating, removing, and keeping entries stable

- update an existing entry when the numbering data changed but the identity of
  the record is still the same,
- add a new entry only when the dataset truly needs another ISO2 or sub-code
  record,
- remove an entry only when you are sure the package should stop exposing it,
  not just because the current examples are weak,
- avoid unnecessary renames of `e164_key` because it is the stable identifier
  used by tests and data synchronization.

If you are unsure whether a record should be updated or split, prefer the
smaller change first and add tests around the affected resolution group.

## Ordering and diff hygiene

Keep new records consistent with the existing file structure.

- preserve the current ordering style used in `country_codes.dart`,
- add the record near related calling-code neighbors instead of appending it at
  random,
- avoid opportunistic reformatting or reordering unrelated entries,
- keep changes small so JSON diffs and review are easy to audit.

## Practical checklist for adding a new country

1. Verify that `iso2_cc` is correct and uppercase.
2. Verify that `e164_cc` contains digits only.
3. Choose a realistic national `example`.
4. Build `full_example_with_plus_sign` from the same example.
5. Make sure `mask` matches the national-number shape only.
6. Build a unique `e164_key` using the existing convention.
7. If the calling code already exists in the dataset, compare the new record
   against every existing sibling entry.
8. Regenerate `country_codes.json`.
9. Run dataset tests.
10. Run controller tests if the change can affect resolution.

## Before opening a PR

1. Re-read the edited group in `country_codes.dart`.
2. Regenerate `country_codes.json`.
3. Run `test/unit_test/country_codes_test.dart`.
4. Run `test/unit_test/country_phone_controller_test.dart` if shared calling
  codes or examples changed.
5. Check that the diff does not include accidental reordering of unrelated
  countries.

## Copy-paste templates

### Basic template

Use this when adding a country with a unique calling code or when the new entry
does not need special discussion inside a shared group.

```dart
{
  'e164_cc': '000',
  'iso2_cc': 'XX',
  'e164_sc': 0,
  'geographic': true,
  'level': 1,
  'name': 'Example Country',
  'example': '123456789',
  'display_name': 'Example Country (XX) [+000]',
  'mask': '000 000 000',
  'full_example_with_plus_sign': '+000123456789',
  'display_name_no_e164_cc': 'Example Country (XX)',
  'e164_key': '000-XX-0',
},
```

Before merging, replace every placeholder and verify that the example and mask
match the real national numbering shape.

### Shared calling-code template

Use this when adding a country under an `e164_cc` that already exists in the
dataset.

```dart
{
  'e164_cc': '44',
  'iso2_cc': 'XX',
  'e164_sc': 0,
  'geographic': true,
  'level': 2,
  'name': 'Example Territory',
  'example': '7812123456',
  'display_name': 'Example Territory (XX) [+44]',
  'mask': '0000 000000',
  'full_example_with_plus_sign': '+447812123456',
  'display_name_no_e164_cc': 'Example Territory (XX)',
  'e164_key': '44-XX-0',
},
```

Extra checks for shared groups:

- compare the new `example` against every existing sibling entry,
- make sure the new prefix diverges early enough to help resolution,
- choose `level` intentionally instead of copying it blindly,
- update controller tests if the new entry changes exact or ambiguous outcomes.

## When a test update is required

You usually need to update or add controller tests when:

- a new country is added under an already-used `e164_cc`,
- an `example` changes inside a shared calling-code group,
- `level` changes for an existing shared-group entry,
- a previous ambiguous number should now resolve exactly,
- a previous exact number should intentionally become ambiguous.

If the change only fixes display fields and does not touch `example`, `mask`,
`level`, or `e164_cc`, dataset tests are usually enough.