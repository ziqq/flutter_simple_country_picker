# AGENTS.md

## Cursor Cloud specific instructions

### What this repo is

Flutter/Dart repository for the **flutter_simple_country_picker** package and its example app. The package provides:

- a country picker bottom sheet
- a phone input with country selection and mask formatting
- bundled country metadata and localizations

Treat this repository as a **published package**, not an app-first codebase.

### Public API boundaries

- Everything under `lib/` is part of the package surface and must be treated as potentially public API.
- Prefer additive, backward-compatible changes.
- Avoid renaming or removing public symbols unless the change is intentionally breaking and documented.
- If a symbol is intended to stay internal, keep it out of the root export in `lib/flutter_simple_country_picker.dart`.

### Repository layout

- `lib/flutter_simple_country_picker.dart`: root package export surface
- `lib/src/model/`: core public model types such as `Country`
- `lib/src/widget/`: picker and input widgets
- `lib/src/controller/`: state and phone parsing/resolution logic
- `lib/src/constant/country_codes.dart`: bundled source-of-truth dataset
- `lib/src/constant/country_codes.json`: generated JSON mirror of the dataset
- `lib/src/localization/`: localization delegate and translations
- `example/`: example application that is published with sources but not platform/build artifacts
- `tool/generate_json.dart`: regenerates the JSON mirror from the Dart dataset

### Toolchain (pre-installed on the VM snapshot)

- **Flutter**: `~/flutter` (stable channel). Ensure `$HOME/flutter/bin` is on `PATH`.
- **Android SDK**: `$HOME/Android/Sdk` with latest platforms, build-tools, emulator, and an x86_64 system image. Set `ANDROID_HOME` and point Flutter at it with `flutter config --android-sdk "$ANDROID_HOME"`.
- **JDK 21**: OpenJDK 21 (`JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64`).

### Bootstrap (after `git pull`)

From repo root:

```bash
fvm flutter pub get
```

The VM update script runs the dependency refresh steps above automatically.

### Common commands

| Task | Command |
|------|---------|
| Full local validation | `make ci` |
| Unit and widget tests | `make test-unit` |
| Analyze package | `make analyze` |
| Format code | `make format` |
| Regenerate JSON mirror | `make generate-json` |
| Dry-run publish checks | `make check` |
| Get dependencies | `make get` |

### Testing expectations

- Prefer focused test runs first, then use `make test-unit` when validating the full package test suite.
- Keep tests grouped semantically by the method, getter, or behavior under test.
- Prefer minimal unit coverage additions over production changes when the goal is to raise coverage without changing behavior.
- When changing widget behavior, ensure both unit-level and widget-level expectations still hold.

### Country dataset rules

- `lib/src/constant/country_codes.dart` is the authoritative bundled dataset.
- `lib/src/constant/country_codes.json` must stay in sync with the Dart dataset.
- After editing the Dart dataset, run:

```bash
make generate-json
```

- Do not replace the bundled phone-oriented dataset with a generic country metadata source unless the phone parsing and formatting behavior remains intact.
- Be careful with shared calling codes and alias normalization. Small data edits can change phone resolution behavior.

### Localization rules

- Built-in localizations are part of the product value. Keep `CountryLocalizations`, translations, README examples, and tests aligned.
- If you add or rename locale-facing API, validate both unit and widget localization tests.
- Avoid introducing unresolved dartdoc references in localization or widget docs.

### Example and publishing rules

- The repository publishes package sources plus the example source code.
- Do not publish build artifacts, generated coverage output, or rendered docs.
- `.pubignore` intentionally excludes `coverage/`, `build/`, `reports/`, and `doc/api/`, while keeping example source files.
- If you add large example assets or generated files, confirm they are intended to ship in the package archive.

### Release checklist

- Update `CHANGELOG.md` for user-visible package changes.
- Keep README examples aligned with the actual exported API.
- Run `make ci` before declaring release readiness.
- Treat `dart analyze` issues and `pub publish --dry-run` failures as release blockers.
- Informational messages about newer incompatible dependency versions are not blockers by themselves.

### Notes for agents

- Prefer `fvm`-prefixed commands, matching the repository Makefile.
- If coverage drops after an API addition, first add focused tests before changing implementation.
- When a user asks whether the package is release-ready, rely on the latest `make ci` result rather than editor diagnostics alone.