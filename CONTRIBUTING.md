# Contributing rules

Thank you for your help! Before you start, let's take a look at some agreements.

## Pull request rules

Make sure that your code:

1.	Does not contain analyzer errors.
2.	Follows a [official style](https://dart.dev/guides/language/effective-dart/style).
3.  Follows the official [style of formatting](https://flutter.dev/docs/development/tools/formatting).
4.	Contains no errors.
5.	New functionality is covered by tests. New functionality passes old tests.
6.	Create example that demonstrate new functionality if it is possible.

## Updating `country_codes`

`lib/src/constant/country_codes.dart` is the source of truth for the bundled
country dataset. `lib/src/constant/country_codes.json` is a generated mirror and
must never be edited manually.

For a deeper maintainer guide with concrete shared-calling-code examples, see
`docs/country_codes.md`.

### Update workflow

1. Edit `lib/src/constant/country_codes.dart`.
2. Regenerate the JSON mirror:

	 ```shell
	 fvm dart --disable-analytics run tool/generate_json.dart
	 ```

3. Run the country dataset tests. At minimum, run:

	 ```shell
	 fvm flutter test test/unit_test/country_codes_test.dart
	 ```

4. If the new entry changes phone resolution behavior, also run:

	 ```shell
	 fvm flutter test test/unit_test/country_phone_controller_test.dart
	 ```

### Required field invariants

Every country entry should keep these invariants:

- `e164_cc`: digits only, without `+`.
- `iso2_cc`: uppercase ISO alpha-2 code.
- `e164_sc`: integer sub-code. Use `0` when the dataset does not distinguish a
	more specific sub-code.
- `geographic`: boolean only.
- `level`: integer priority inside the same calling-code group. Lower values win
	when multiple entries have the same best prefix match.
- `name`: English country or territory name.
- `example`: representative national number without the calling code.
- `full_example_with_plus_sign`: representative full number with `+` and the
	country calling code.
- `mask`: national number mask only. Do not include the country calling code in
	the mask.
- `display_name`: keep consistent with `name`, `iso2_cc`, and `e164_cc`.
- `display_name_no_e164_cc`: keep consistent with `name` and `iso2_cc`.
- `e164_key`: unique stable key for the entry. Today the dataset uses the
	`e164_cc-iso2_cc-e164_sc` format.

### What the tests enforce

`test/unit_test/country_codes_test.dart` already checks the most important
dataset rules:

- `name`, `e164_cc`, and `e164_key` must be present and non-empty.
- `iso2_cc` must match `^[A-Z]{2}$`.
- `geographic` must be a non-null `bool`.
- `e164_key` must be unique.
- `country_codes.json` must match `country_codes.dart` exactly by `e164_key`,
	key set, and values.
- When `full_example_with_plus_sign` is present, formatter normalization of the
	full example must produce the same national number as `example`.

### Choosing a good example number

The controller resolves a phone number by comparing the national-number prefix
against `example` values inside the same `e164_cc` group. Because of that,
`example` is not just documentation. It directly affects runtime resolution.

When adding or changing a country:

- Use a realistic national number for that country or territory.
- Keep `example` and `full_example_with_plus_sign` aligned. The full example
	should normalize back to the same national number.
- If several entries share the same `e164_cc`, choose examples that diverge as
	early as possible. This reduces ambiguity during resolution.
- Do not copy the same example across countries that share a calling code unless
	the ambiguity is intentional.
- If you change `mask`, verify that the example still formats correctly with the
	formatter.

### Shared calling codes are valid

Duplicate `e164_cc` values are not automatically a bug. The dataset still has
real shared calling-code groups such as `+1`, `+7`, and `+44`. Different
`iso2_cc` values identify different entries, but the controller still needs
representative examples to resolve numbers within the shared group.

Before adding a new country under an existing `e164_cc`:

- Check all existing entries with the same calling code.
- Compare their `example`, `level`, and `e164_sc` values.
- Confirm that the new example improves or at least preserves resolution
	quality.
- Add or update controller tests if the shared group behavior changes.

### Common mistakes

- Editing `country_codes.json` by hand instead of regenerating it.
- Adding `+` to `e164_cc`.
- Using lowercase or non-ISO values in `iso2_cc`.
- Reusing an example number from another country in the same calling-code group.
- Changing `display_name` fields but forgetting to update `name`, `e164_cc`, or
	`iso2_cc` to match.
- Adding a mask that includes the calling code or no longer matches the example
	length.

## Accepting the changes

After your pull request passes the review code, the project maintainers will merge the changes
into the branch to which the pull request was sent.

## Issues

Feel free to report any issues and bugs.

1.	To report about the problem, create an issue on GitHub.
2.	In the issue add the description of the problem.
3.	Do not forget to mention your development environment, Flutter version, libraries required for
illustration of the problem.
4.	It is necessary to attach the code part that causes an issue or to make a small demo project
that shows the issue.
5.	Attach stack trace so it helps us to deal with the issue.
6.	If the issue is related to graphics, screen recording is required.
