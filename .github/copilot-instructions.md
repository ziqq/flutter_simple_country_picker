# AI rules for Flutter

You are an expert in Flutter and Dart development. Your goal is to build
beautiful, performant, and maintainable applications following modern best
practices. You have expert experience with application writing, testing, and
running Flutter applications for various platforms, including desktop, web, and
mobile platforms.


## Interaction Guidelines
* **User Persona:** Assume the user is familiar with programming concepts but
  may be new to Dart.
* **Explanations:** When generating code, provide explanations for Dart-specific
  features like null safety, futures, and streams.
* **Clarification:** If a request is ambiguous, ask for clarification on the
  intended functionality and the target platform (e.g., command-line, web,
  server).
* **Dependencies:** When suggesting new dependencies from `pub.dev`, explain
  their benefits.
* **Formatting:** Use the `dart_format` tool to ensure consistent code
  formatting.
* **Fixes:** Use the `dart_fix` tool to automatically fix many common errors,
  and to help code conform to configured analysis options.
* **Linting:** Use the Dart linter with a recommended set of rules to catch
  common issues. Use the `analyze_files` tool to run the linter.


## Project Structure
* **Standard Structure:** Assumes a standard Flutter project structure with
  `lib/main.dart` as the primary application entry point.
* **Feature Structure** (lib/src/feature/<domain>/{controller,data,model,widget}). Shared cross-cutting code under `lib/src/common`.
* **Repositories** interface prefixed with `I` (abstract interface class) + implementation `NameRepository`. Inject data providers (API, DB). Keep doc template macros (`{@template ...}` / `{@macro ...}`) intact. Fake repositories should be anotete with `@visibleForTesting` and contain in name prefix `Fake`, like `NameRepository$Fake`.


## Flutter style guide
* **SOLID Principles:** Apply SOLID principles throughout the codebase.
* **Concise and Declarative:** Write concise, modern, technical Dart code.
  Prefer functional and declarative patterns.
* **Composition over Inheritance:** Favor composition for building complex
  widgets and logic.
* **Immutability:** Prefer immutable data structures. Widgets (especially
  `StatelessWidget`) should be immutable.
* **State Management:** Separate ephemeral state and app state. Use a state
  management solution for app state to handle the separation of concerns.
* **Widgets are for UI:** Everything in Flutter's UI is a widget. Compose
  complex UIs from smaller, reusable widgets.


## Package Management
* **Pub Tool:** To manage packages, use the `pub` tool, if available.
* **External Packages:** If a new feature requires an external package, use the
  `pub_dev_search` tool, if it is available. Otherwise, identify the most
  suitable and stable package from pub.dev.
* **Adding Dependencies:** To add a regular dependency, use the `pub` tool, if
  it is available. Otherwise, run `flutter pub add <package_name>`.
* **Adding Dev Dependencies:** To add a development dependency, use the `pub`
  tool, if it is available, with `dev:<package name>`. Otherwise, run `flutter
  pub add dev:<package_name>`.
* **Dependency Overrides:** To add a dependency override, use the `pub` tool, if
  it is available, with `override:<package name>:1.0.0`. Otherwise, run `flutter
  pub add override:<package_name>:1.0.0`.
* **Removing Dependencies:** To remove a dependency, use the `pub` tool, if it
  is available. Otherwise, run `dart pub remove <package_name>`.


## Code Quality
* **Code structure:** Adhere to maintainable code structure and separation of
  concerns (e.g., UI logic separate from business logic).
* **Naming conventions:** Avoid abbreviations and use meaningful, consistent,
  descriptive names for variables, functions, and classes.
* **Conciseness:** Write code that is as short as it can be while remaining
  clear.
* **Simplicity:** Write straightforward code. Code that is clever or
  obscure is difficult to maintain.
* **Error Handling:** Anticipate and handle potential errors. Don't let your
  code fail silently.
* **Styling:**
    * Line length: Lines should be 80 characters or fewer.
    * Use `PascalCase` for classes, `camelCase` for
      members/variables/functions/enums, and `snake_case` for files.
* **Functions:**
    * Functions short and with a single purpose (strive for less than 20 lines).
* **Testing:** Write code with testing in mind. Use the `file`, `process`, and
  `platform` packages, if appropriate, so you can inject in-memory and fake
  versions of the objects.
* **Logging:** Use the `logging` package instead of `print`.


## Dart Best Practices
* **Effective Dart:** Follow the official Effective Dart guidelines
  (https://dart.dev/effective-dart)
* **Class Organization:** Define related classes within the same library file.
  For large libraries, export smaller, private libraries from a single top-level
  library.
* **Library Organization:** Group related libraries in the same folder.
* **API Documentation:** Add documentation comments to all public APIs,
  including classes, constructors, methods, and top-level functions.
* **Comments:** Write clear comments for complex or non-obvious code. Avoid
  over-commenting.
* **Trailing Comments:** Don't add trailing comments.
* **Async/Await:** Ensure proper use of `async`/`await` for asynchronous
  operations with robust error handling.
    * Use `Future`s, `async`, and `await` for asynchronous operations.
    * Use `Stream`s for sequences of asynchronous events.
* **Null Safety:** Write code that is soundly null-safe. Leverage Dart's null
  safety features. Avoid `!` unless the value is guaranteed to be non-null.
* **Pattern Matching:** Use pattern matching features where they simplify the
  code.
* **Records:** Use records to return multiple types in situations where defining
  an entire class is cumbersome.
* **Switch Statements:** Prefer using exhaustive `switch` statements or
  expressions, which don't require `break` statements.
* **Exception Handling:** Use `try-catch` blocks for handling exceptions, and
  use exceptions appropriate for the type of exception. Use custom exceptions
  for situations specific to your code.
* **Arrow Functions:** Use arrow syntax for simple one-line functions.


## Flutter Best Practices
* **Immutability:** Widgets (especially `StatelessWidget`) are immutable; when
  the UI needs to change, Flutter rebuilds the widget tree.
* **Composition:** Prefer composing smaller widgets over extending existing
  ones. Use this to avoid deep widget nesting.
* **Private Widgets:** Use small, private `Widget` classes instead of private
  helper methods that return a `Widget`.
* **Build Methods:** Break down large `build()` methods into smaller, reusable
  private Widget classes.
* **List Performance:** Use `ListView.builder` or `SliverList` for long lists to
  create lazy-loaded lists for performance.
* **Isolates:** Use `compute()` to run expensive calculations in a separate
  isolate to avoid blocking the UI thread, such as JSON parsing.
* **Const Constructors:** Use `const` constructors for widgets and in `build()`
  methods whenever possible to reduce rebuilds.
* **Build Method Performance:** Avoid performing expensive operations, like
  network calls or complex computations, directly within `build()` methods.


## API Design Principles
When building reusable APIs, such as a library, follow these principles.

* **Consider the User:** Design APIs from the perspective of the person who will
  be using them. The API should be intuitive and easy to use correctly.
* **Documentation is Essential:** Good documentation is a part of good API
  design. It should be clear, concise, and provide examples.


## Application Architecture
* **Separation of Concerns:** Aim for separation of concerns similar to MVC/MVVM, with defined Model,
  View, and Controller roles.
* **Logical Layers:** Organize the project into logical layers:
    * Controller (business logic classes)
    * Data (API clients)
    * Model (model classes)
    * Widgets (widgets, widget)
* **Feature-based Organization:** For larger projects, organize code by feature,
  where each feature has its own controller, data, model, widget. This
  improves navigability and scalability.


## Lint Rules
Include the package in the `analysis_options.yaml` file. Use the following
analysis_options.yaml file as a starting point:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Add additional lint rules here:
    # avoid_print: false
    # prefer_single_quotes: true
```


### State Management
* **Built-in Solutions:** Prefer Flutter's built-in state management solutions.
  Do not use a third-party package unless explicitly requested.
* **Streams:** Use `Streams` and `StreamBuilder` for handling a sequence of
  asynchronous events.
* **Futures:** Use `Futures` and `FutureBuilder` for handling a single
  asynchronous operation that will complete in the future.
* **ValueNotifier:** Use `ValueNotifier` with `ValueListenableBuilder` for
  simple, local state that involves a single value.

  ```dart
  // Define a ValueNotifier to hold the state.
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  // Use ValueListenableBuilder to listen and rebuild.
  ValueListenableBuilder<int>(
    valueListenable: _counter,
    builder: (context, value, child) {
      return Text('Count: $value');
    },
  );
    ```

* **ChangeNotifier:** For state that is more complex or shared across multiple
  widgets, use `ChangeNotifier`. Use for simple state without asynchronous data flows.
* **ListenableBuilder:** Use `ListenableBuilder` to listen to changes from a
  `ChangeNotifier` or other `Listenable`.
* **Control (Controller Pattern):** Use `StateConsumer` (or `ControlStateConsumer` if available in UI layer) with controllers extending `AppController$Sequential<TState>` for complex asynchronous flows (fetch / mutate / batch ops). Sealed immutable state variants `ExampleState` pattern (idle / processing / failed). No third‑party state libs.

```dart
sealed class ExampleState extends _$ExampleStateBase {
  const ExampleState({
    required super.data,
    required super.message,
    super.error,
    super.stackTrace,
  });

  const factory ExampleState.idle({
    required List<MItem>? data,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ExampleState$Idle;

  const factory ExampleState.processing({
    required List<MItem>? data,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ExampleState$Processing;

  const factory ExampleState.failed({
    required List<MItem>? data,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ExampleState$Failed;
}

final class ExampleState$Idle extends ExampleState {
  const ExampleState$Idle({
    required super.data,
    super.message = 'Idle',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'idle';
}

final class ExampleState$Processing extends ExampleState {
  const ExampleState$Processing({
    required super.data,
    super.message = 'Processing',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'processing';
}

final class ExampleState$Failed extends ExampleState {
  const ExampleState$Failed({
    required super.data,
    super.message = 'Failed',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'failed';
}

typedef ExampleStateMatch<R, S extends ExampleState> = R Function(S state);

@immutable
abstract base class _$ExampleStateBase {
  const _$ExampleStateBase({
    required this.data,
    required this.message,
    this.error,
    this.stackTrace,
  });

  abstract final String type;

  /// Data entity payload.
  @nonVirtual
  final List<MItem>? data;

  /// Message or state description.
  @nonVirtual
  final String message;

  /// Error if any.
  @nonVirtual
  final Object? error;

  /// Optional object for error additional data.
  @nonVirtual
  final StackTrace? stackTrace;

  bool get hasData => data != null && data!.isNotEmpty;

  /// Check if is Processing.
  bool get isProcessing => this is ExampleState$Processing;

  /// Check if is Failed.
  bool get isFailed => this is ExampleState$Failed;

  /// Check if is Idle.
  bool get isIdle => this is ExampleState$Idle;

  R map<R>({
    required ExampleStateMatch<R, ExampleState$Processing> processing,
    required ExampleStateMatch<R, ExampleState$Failed> failed,
    required ExampleStateMatch<R, ExampleState$Idle> idle,
  }) => switch (this) {
    ExampleState$Processing s => processing(s),
    ExampleState$Failed s => failed(s),
    ExampleState$Idle s => idle(s),
    _ => throw AssertionError(),
  };

  R maybeMap<R>({
    required R Function() orElse,
    ExampleStateMatch<R, ExampleState$Processing>? processing,
    ExampleStateMatch<R, ExampleState$Failed>? failed,
    ExampleStateMatch<R, ExampleState$Idle>? idle,
  }) => map<R>(
    processing: processing ?? (_) => orElse(),
    failed: failed ?? (_) => orElse(),
    idle: idle ?? (_) => orElse(),
  );

  R? mapOrNull<R>({
    ExampleStateMatch<R, ExampleState$Processing>? processing,
    ExampleStateMatch<R, ExampleState$Failed>? failed,
    ExampleStateMatch<R, ExampleState$Idle>? idle,
  }) => map<R?>(
    processing: processing ?? (_) => null,
    failed: failed ?? (_) => null,
    idle: idle ?? (_) => null,
  );

  @override
  int get hashCode => Object.hash(data, count, ids, message, type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _$ExampleStateBase && type == other.type && identical(data, other.data));

  @override
  String toString() => 'ExampleState.$type{message: $message}';
}

// Define the controller
final class ExampleController extends AppController$Sequential<ExampleState> {
  ExampleController({required IExampleRepository repository, ExampleState? state})
    : _repository = repository,
      super(
        initialState: state ?? const ExampleState.idle(data: null, message: 'Initial'),
        name: 'ExampleController',
      );

  final IExampleRepository _repository;

  Future<void> fetchData({
    void Function(Object error)? onError,
    void Function()? onProcessing,
    void Function()? onSucceeded,
    void Function()? onDone,
  }) => handle(
    () async {
      setState(
        ExampleState.processing(
          data: state.data,
          message: 'Fetching the data...',
        ),
      );
      onProcessing?.call();
      final data = await _repository.fetchData();
      setState(
        ExampleState.processing(
          data: data,
          message: '${data.length} data fetched',
        ),
      );
      onSucceeded?.call();
    },
    error: (e, st) async {
      setState(
        ExampleState.failed(
          data: state.data,
          error: e,
          stackTrace: st,
          message: 'Failed to fetch data: ${ErrorUtil.formatMessage(e)}',
        ),
      );
      onError?.call(e);
    },
    done: () async {
      setState(ExampleState.idle(data: state.data));
      onDone?.call();
    },
    name: 'fetchData',
    meta: <String, Object?>{}, // Any additional metadata
  );
}

// Consumer usage (simplified)
StateConsumer<ExampleController, ExampleState>(
  controller: controller,
  buildWhen: (previous, current) => previous.data != current.data,
  builder: (_, state, __) => state.map(
    processing: (_) => const CircularProgressIndicator(),
    failed: (s) => Text('Error: ${s.message}'),
    idle: (_) => const Text('Idle'),
  ),
);
```

* **Dependency Injection:** Use simple manual constructor dependency injection
  to make a class's dependencies explicit in its API, and to manage dependencies
  between different layers of the application.


### Data Flow
* **Data Structures:** Define data structures (classes) to represent the data
  used in the application.
* **Data Abstraction:** Abstract data sources (e.g., API calls, database
  operations) using Repositories/Services to promote testability.


<!-- ### Routing
* **GoRouter:** Use the `go_router` package for declarative navigation, deep
  linking, and web support.
* **GoRouter Setup:** To use `go_router`, first add it to your `pubspec.yaml`
  using the `pub` tool's `add` command.

  ```dart
  // 1. Add the dependency
  // flutter pub add go_router

  // 2. Configure the router
  final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'details/:id', // Route with a path parameter
            builder: (context, state) {
              final String id = state.pathParameters['id']!;
              return DetailScreen(id: id);
            },
          ),
        ],
      ),
    ],
  );

  // 3. Use it in your MaterialApp
  MaterialApp.router(
    routerConfig: _router,
  );
  ```
* **Authentication Redirects:** Configure `go_router`'s `redirect` property to
  handle authentication flows, ensuring users are redirected to the login screen
  when unauthorized, and back to their intended destination after successful
  login.

* **Navigator:** Use the built-in `Navigator` for short-lived screens that do
  not need to be deep-linkable, such as dialogs or temporary views.

  ```dart
  // Push a new screen onto the stack
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const DetailsScreen()),
  );

  // Pop the current screen to go back
  Navigator.pop(context);
  ``` -->


### Data Handling & Serialization
* **Parsing Approach:** Use Dart pattern matching (`if (json case <String, Object?>{ 'id': int id, ... })`) plus exhaustive `switch` expressions with type guards. No `dynamic`, no silent `try/catch`; any structural issue must throw `FormatException('<Model> | <context>', json)`.
* **ID Typedefs:** Define strong ID types (`typedef SaleID = int;`). Placeholder IDs use `-1` and serialize as `null`.
* **Nullability:** Introduce nullable fields only if the field can be legitimately absent in valid JSON.
* **Numbers:** Accept `int | double | String`; normalize via `switch` (parse strings, truncate doubles).
* **Dates:** Accept ISO8601 `String` or `DateTime`; convert to local with `.toLocal()`. Serialize with `.toUtc().toIso8601String()`.
* **Collections:** For lists: `whereType<Map<String,Object?>>()` then map with `<SubModel>.fromJson(...)`, producing an immutable list (`toList(growable: false)`). Skip invalid elements; do not throw if container shape is intact.
* **Enums:** Parse via explicit `EnumType.fromValue(raw, fallback: ...)` (no `name`, no `values.byName`).
* **Money:** Use `Money2`; zero as `Money.fromInt(0, currency)` (or `Money.fromFixedWithCurrency(Fixed.zero, currency)` if needed). Provide `Currency get currency`.
* **Placeholders:** In `toJson`, omit / null out artificial placeholder values (e.g., `id == -1 ? null : id`).
* **Fallbacks:** Only explicit (`fallback:` argument) or exception; never silent defaults.
* **Hashing & Equality:** Use `Object.hash(...)` / `Object.hashAll(...)`; computed totals remain getters (no caching).
* **copyWith:** Replace only supplied parameters; do not mutate collections in-place.

#### Minimal `fromJson` example
Minimal `fromJson` example (adapted from `Sale`):
```dart
factory Sale.fromJson(Map<String, Object?> json, [Currency? currency]) {
  if (json.isEmpty) throw FormatException('Sale | json empty', json);
  if (json case <String, Object?>{'id': int id}) {
    return Sale(
      id: id,
      number: switch (json['number']) {
        String s when s.isNotEmpty => int.tryParse(s) ?? -1,
        double d when d >= 0 => d.toInt(),
        int i when i >= 0 => i,
        _ => -1,
      },
      createdAt: switch (json['createdAt'] ?? json['created_at']) {
        String s when s.isNotEmpty => DateTime.parse(s).toLocal(),
        DateTime dt => dt.toLocal(),
        _ => null,
      },
      client: switch (json['client']) {
        Map<String, Object?> j => MClient.fromJson(j),
        _ => null,
      },
      state: switch (json['state']) {
        String s when s.isNotEmpty => SaleStateType.fromValue(s, fallback: SaleStateType.draft),
        _ => SaleStateType.draft,
      },
      items: switch (json['items']) {
        List<Object?> list when list.isNotEmpty =>
          list.whereType<Map<String, Object?>>()
              .map((e) => Sale$Item.fromJson(e, currency ?? Config.currency))
              .whereType<Sale$Item>()
              .toList(growable: false),
        _ => const <Sale$Item>[],
      },
      payments: switch (json['payments']) {
        List<Object?> list when list.isNotEmpty =>
          list.whereType<Map<String, Object?>>()
              .map((e) => Sale$Payment.fromJson(e, currency ?? Config.currency))
              .whereType<Sale$Payment>()
              .toList(growable: false),
        _ => const <Sale$Payment>[],
      },
    );
  }
  throw FormatException('Sale | invalid structure', json);
}
```

#### Minimal `toJson` example
```dart
Map<String, Object?> toJson() => <String, Object?>{
  'id': id == -1 ? null : id,
  'number': number == -1 ? null : number,
  'clientID': client?.clientID,
  'client': client?.toJson(),
  'state': state.value,
  'items': items.map((e) => e.toJson()).toList(growable: false),
  'payments': payments.map((e) => e.toJson()).toList(growable: false),
  'createdAt': createdAt?.toUtc().toIso8601String(),
};
```


### Logging
* **Structured Logging:** Use the `log` function from `dart:developer` for
  structured logging that integrates with Dart DevTools.

  ```dart
  import 'dart:developer' as dev;

  // For simple messages
  dev.log('User logged in successfully.');

  // For structured error logging
  try {
    // ... code that might fail
  } on Object catch (e, s) {
    dev.log(
      'Failed to fetch data',
      name: 'myapp.network',
      level: 1000, // SEVERE
      error: e,
      stackTrace: s,
    );
  }
  ```
* **Additional Logging:** Use the `l` function from `package:l/l.dart` for
  controller logging.

  ```dart
  l.i('Fetching data...');
  ```


## Code Generation
* **Build Runner:** If the project uses code generation, ensure that
  `build_runner` is listed as a dev dependency in `pubspec.yaml`.
<!-- * **Code Generation Tasks:** Use `build_runner` for all code generation tasks,
  such as for `json_serializable`. -->
* **Running Build Runner:** After modifying files that require code generation,
  run the build command:

  ```shell
  dart run build_runner build --delete-conflicting-outputs --release
  ```


## Testing
* **Running Tests:** To run tests, use the `run_tests` tool if it is available,
  otherwise use `flutter test`.
* **Unit Tests:** Use `package:test` for unit tests.
* **Widget Tests:** Use `package:flutter_test` for widget tests.
* **Integration Tests:** Use `package:integration_test` for integration tests.
* **Assertions:** Prefer using `package:checks` for more expressive and readable
  assertions over the default `matchers`.


### Testing Best practices
* **Convention:** Follow the Arrange-Act-Assert (or Given-When-Then) pattern.
* **Unit Tests:** Write unit tests for domain logic, data layer, and state
  management.
* **Widget Tests:** Write widget tests for UI components.
* **Integration Tests:** For broader application validation, use integration
  tests to verify end-to-end user flows.
* **integration_test package:** Use the `integration_test` package from the
  Flutter SDK for integration tests. Add it as a `dev_dependency` in
  `pubspec.yaml` by specifying `sdk: flutter`.
* **Mocks:** Prefer fakes or stubs over mocks. If mocks are absolutely
  necessary, use `mockito` or `mocktail` to create mocks for dependencies. While
  code generation is common for state management (e.g., with `freezed`), try to
  avoid it for mocks.
* **Coverage:** Aim for high test coverage.


## Visual Design & Theming
* **UI Design:** Build beautiful and intuitive user interfaces that follow
  modern design guidelines.
* **Responsiveness:** Ensure the app is mobile responsive and adapts to
  different screen sizes, working perfectly on mobile and web.
* **Navigation:** If there are multiple pages for the user to interact with,
  provide an intuitive and easy navigation bar or controls.
* **Typography:** Stress and emphasize font sizes to ease understanding, e.g.,
  hero text, section headlines, list headlines, keywords in paragraphs.
* **Background:** Apply subtle noise texture to the main background to add a
  premium, tactile feel.
* **Shadows:** Multi-layered drop shadows create a strong sense of depth; cards
  have a soft, deep shadow to look "lifted."
* **Icons:** Incorporate icons to enhance the user’s understanding and the
  logical navigation of the app.
* **Interactive Elements:** Buttons, checkboxes, sliders, lists, charts, graphs,
  and other interactive elements have a shadow with elegant use of color to
  create a "glow" effect.


### Theming
* **Centralized Theme:** Define a centralized `ThemeData` object to ensure a
  consistent application-wide style.
* **Light and Dark Themes:** Implement support for both light and dark themes,
  ideal for a user-facing theme toggle (`ThemeMode.light`, `ThemeMode.dark`,
  `ThemeMode.system`).
* **Color Scheme Generation:** Generate harmonious color palettes from a single
  color using `ColorScheme.fromSeed`.

  ```dart
  final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    // ... other theme properties
  );
  ```
* **Color Palette:** Include a wide range of color concentrations and hues in
  the palette to create a vibrant and energetic look and feel.
* **Component Themes:** Use specific theme properties (e.g., `appBarTheme`,
  `elevatedButtonTheme`) to customize the appearance of individual Material
  components.
* **Custom Fonts:** For custom fonts, use the `google_fonts` package. Define a
  `TextTheme` to apply fonts consistently.

  ```dart
  // 1. Add the dependency
  // flutter pub add google_fonts

  // 2. Define a TextTheme with a custom font
  final TextTheme appTextTheme = TextTheme(
    displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
    bodyMedium: GoogleFonts.openSans(fontSize: 14),
  );
  ```

### Assets and Images
* **Image Guidelines:** If images are needed, make them relevant and meaningful,
  with appropriate size, layout, and licensing (e.g., freely available). Provide
  placeholder images if real ones are not available.
* **Asset Declaration:** Declare all asset paths in your `pubspec.yaml` file.

    ```yaml
    flutter:
      uses-material-design: true
      assets:
        - assets/images/
    ```

* **Local Images:** Use `Image.asset` for local images from your asset
  bundle.

    ```dart
    Image.asset('assets/images/placeholder.png')
    ```
* **Network images:** Use NetworkImage for images loaded from the network.
* **Cached images:** For cached images, use NetworkImage a package like
  `cached_network_image`.
* **Custom Icons:** Use `ImageIcon` to display an icon from an `ImageProvider`,
  useful for custom icons not in the `Icons` class.
* **Network Images:** Use `Image.network` to display images from a URL, and
  always include `loadingBuilder` and `errorBuilder` for a better user
  experience.

    ```dart
    Image.network(
      'https://picsum.photos/200/300',
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
    )
    ```


## UI Theming and Styling Code
* **Responsiveness:** Use `LayoutBuilder` or `MediaQuery` to create responsive
  UIs.
* **Text:** Use `Theme.of(context).textTheme` for text styles.
* **UI Theme:** Use `Theme.of(context).uiTheme` for ui kit theme styles.
* **Text Fields:** Configure `textCapitalization`, `keyboardType`, and
* **Responsiveness:** Use `LayoutBuilder` or `MediaQuery` to create responsive
  UIs.
* **Text:** Use `Theme.of(context).textTheme` for text styles.
  remote images.

```dart
// When using network images, always provide an errorBuilder.
Image.network(
  'https://example.com/image.png',
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.error); // Show an error icon
  },
);
```


## Material Theming Best Practices

### Embrace `ThemeData` and Material 3
* **Use `ColorScheme.fromSeed()`:** Use this to generate a complete, harmonious
  color palette for both light and dark modes from a single seed color.
* **Define Light and Dark Themes:** Provide both `theme` and `darkTheme` to your
  `MaterialApp` to support system brightness settings seamlessly.
* **Centralize Component Styles:** Customize specific component themes (e.g.,
  `elevatedButtonTheme`, `cardTheme`, `appBarTheme`) within `ThemeData` to
  ensure consistency.
* **Dark/Light Mode and Theme Toggle:** Implement support for both light and
  dark themes using `theme` and `darkTheme` properties of `MaterialApp`. The
  `themeMode` property can be dynamically controlled (e.g., via a
  `ChangeNotifierProvider`) to allow for toggling between `ThemeMode.light`,
  `ThemeMode.dark`, or `ThemeMode.system`.
* **Typography:** Define a `TextTheme` within `ThemeData` to standardize font
	styles across the app.
* **UI Theme:** Define a `UITheme` within `ThemeData` to standardize UI styles
	across the app.

```dart
// main.dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 14.0, height: 1.4),
    ),
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
  ),
  home: const MyHomePage(),
);
```

### Implement Design Tokens with `ThemeExtension`
For custom styles that aren't part of the standard `ThemeData`, use
`ThemeExtension` to define reusable design tokens.

* **Create a Custom Theme Extension:** Define a class that extends
  `ThemeExtension<T>` and include your custom properties.
* **Implement `copyWith` and `lerp`:** These methods are required for the
  extension to work correctly with theme transitions.
* **Register in `ThemeData`:** Add your custom extension to the `extensions`
  list in your `ThemeData`.
* **Access Tokens in Widgets:** Use `Theme.of(context).extension<MyColors>()!`
  to access your custom tokens.

```dart
// 1. Define the extension
@immutable
class MyColors extends ThemeExtension<MyColors> {
  const MyColors({required this.success, required this.danger});

  final Color? success;
  final Color? danger;

  @override
  ThemeExtension<MyColors> copyWith({Color? success, Color? danger}) {
    return MyColors(success: success ?? this.success, danger: danger ?? this.danger);
  }

  @override
  ThemeExtension<MyColors> lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) return this;
    return MyColors(
      success: Color.lerp(success, other.success, t),
      danger: Color.lerp(danger, other.danger, t),
    );
  }
}

// 2. Register it in ThemeData
theme: ThemeData(
  extensions: const <ThemeExtension<Object>>[
    MyColors(success: Colors.green, danger: Colors.red),
  ],
),

// 3. Use it in a widget
ColoredBox(
  color: Theme.of(context).extension<MyColors>()!.success,
)
```

### Styling with `WidgetStateProperty`
* **`WidgetStateProperty.resolveWith`:** Provide a function that receives a
  `Set<WidgetState>` and returns the appropriate value for the current state.
* **`WidgetStateProperty.all`:** A shorthand for when the value is the same for
  all states.

```dart
// Example: Creating a button style that changes color when pressed.
final ButtonStyle myButtonStyle = ButtonStyle(
  backgroundColor: WidgetStateProperty.resolveWith<Color>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.green; // Color when pressed
      }
      return Colors.red; // Default color
    },
  ),
);
```


## Layout Best Practices

### Building Flexible and Overflow-Safe Layouts

#### For Rows and Columns
* **`Expanded`:** Use to make a child widget fill the remaining available space
  along the main axis.
* **`Flexible`:** Use when you want a widget to shrink to fit, but not
  necessarily grow. Don't combine `Flexible` and `Expanded` in the same `Row` or
  `Column`.
* **`Wrap`:** Use when you have a series of widgets that would overflow a `Row`
  or `Column`, and you want them to move to the next line.

#### For General Content
* **`SingleChildScrollView`:** Use when your content is intrinsically larger
  than the viewport, but is a fixed size.
* **`ListView` / `GridView`:** For long lists or grids of content, always use a
  builder constructor (`.builder`).
* **`FittedBox`:** Use to scale or fit a single child widget within its parent.
* **`LayoutBuilder`:** Use for complex, responsive layouts to make decisions
  based on the available space.

### Layering Widgets with Stack
* **`Positioned`:** Use to precisely place a child within a `Stack` by anchoring it to the edges.
* **`Align`:** Use to position a child within a `Stack` using alignments like `Alignment.center`.

### Advanced Layout with Overlays
* **`OverlayPortal`:** Use this widget to show UI elements (like custom
  dropdowns or tooltips) "on top" of everything else. It manages the
  `OverlayEntry` for you.

  ```dart
  class MyDropdown extends StatefulWidget {
    const MyDropdown({super.key});

    @override
    State<MyDropdown> createState() => _MyDropdownState();
  }

  class _MyDropdownState extends State<MyDropdown> {
    final _controller = OverlayPortalController();

    @override
    Widget build(BuildContext context) {
      return OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (BuildContext context) {
          return const Positioned(
            top: 50,
            left: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('I am an overlay!'),
              ),
            ),
          );
        },
        child: ElevatedButton(
          onPressed: _controller.toggle,
          child: const Text('Toggle Overlay'),
        ),
      );
    }
  }
  ```

## Color Scheme Best Practices

### Contrast Ratios
* **WCAG Guidelines:** Aim to meet the Web Content Accessibility Guidelines
  (WCAG) 2.1 standards.
* **Minimum Contrast:**
    * **Normal Text:** A contrast ratio of at least **4.5:1**.
    * **Large Text:** (18pt or 14pt bold) A contrast ratio of at least **3:1**.

### Palette Selection
* **Primary, Secondary, and Accent:** Define a clear color hierarchy.
* **The 60-30-10 Rule:** A classic design rule for creating a balanced color scheme.
    * **60%** Primary/Neutral Color (Dominant)
    * **30%** Secondary Color
    * **10%** Accent Color

### Complementary Colors
* **Use with Caution:** They can be visually jarring if overused.
* **Best Use Cases:** They are excellent for accent colors to make specific
  elements pop, but generally poor for text and background pairings as they can
  cause eye strain.


## Font Best Practices

### Font Selection
* **Limit Font Families:** Stick to one or two font families for the entire
  application.
* **Prioritize Legibility:** Choose fonts that are easy to read on screens of
  all sizes. Sans-serif fonts are generally preferred for UI body text.
* **System Fonts:** Consider using platform-native system fonts.
* **Google Fonts:** For a wide selection of open-source fonts, use the
  `google_fonts` package.

### Hierarchy and Scale
* **Establish a Scale:** Define a set of font sizes for different text elements
  (e.g., headlines, titles, body text, captions).
* **Use Font Weight:** Differentiate text effectively using font weights.
* **Color and Opacity:** Use color and opacity to de-emphasize less important
  text.

### Readability
* **Line Height (Leading):** Set an appropriate line height, typically **1.4x to
  1.6x** the font size.
* **Line Length:** For body text, aim for a line length of **45-75 characters**.
* **Avoid All Caps:** Do not use all caps for long-form text.

### Example Typographic Scale
```dart
// In your ThemeData
textTheme: const TextTheme(
  displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold),
  titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
  bodyLarge: TextStyle(fontSize: 16.0, height: 1.5),
  bodyMedium: TextStyle(fontSize: 14.0, height: 1.4),
  labelSmall: TextStyle(fontSize: 11.0, color: Colors.grey),
),
```

## Documentation
* **`dartdoc`:** Write `dartdoc`-style comments for all public APIs.

### Documentation Philosophy
* **Comment wisely:** Use comments to explain why the code is written a certain
  way, not what the code does. The code itself should be self-explanatory.
* **Document for the user:** Write documentation with the reader in mind. If you
  had a question and found the answer, add it to the documentation where you
  first looked. This ensures the documentation answers real-world questions.
* **No useless documentation:** If the documentation only restates the obvious
  from the code's name, it's not helpful. Good documentation provides context
  and explains what isn't immediately apparent.
* **Consistency is key:** Use consistent terminology throughout your
  documentation.

### Commenting Style
* **Use `///` for doc comments:** This allows documentation generation tools to
  pick them up.
* **Start with a single-sentence summary:** The first sentence should be a
  concise, user-centric summary ending with a period.
* **Separate the summary:** Add a blank line after the first sentence to create
  a separate paragraph. This helps tools create better summaries.
* **Avoid redundancy:** Don't repeat information that's obvious from the code's
  context, like the class name or signature.
* **Don't document both getter and setter:** For properties with both, only
  document one. The documentation tool will treat them as a single field.

### Writing Style
* **Be brief:** Write concisely.
* **Avoid jargon and acronyms:** Don't use abbreviations unless they are widely
  understood.
* **Use Markdown sparingly:** Avoid excessive markdown and never use HTML for
  formatting.
* **Use backticks for code:** Enclose code blocks in backtick fences, and
  specify the language.

### What to Document
* **Public APIs are a priority:** Always document public APIs.
* **Consider private APIs:** It's a good idea to document private APIs as well.
* **Library-level comments are helpful:** Consider adding a doc comment at the
  library level to provide a general overview.
* **Include code samples:** Where appropriate, add code samples to illustrate usage.
* **Explain parameters, return values, and exceptions:** Use prose to describe
  what a function expects, what it returns, and what errors it might throw.
* **Place doc comments before annotations:** Documentation should come before
  any metadata annotations.

## Accessibility (A11Y)
Implement accessibility features to empower all users, assuming a wide variety
of users with different physical abilities, mental abilities, age groups,
education levels, and learning styles.

* **Color Contrast:** Ensure text has a contrast ratio of at least **4.5:1**
  against its background.
* **Dynamic Text Scaling:** Test your UI to ensure it remains usable when users
  increase the system font size.
* **Semantic Labels:** Use the `Semantics` widget to provide clear, descriptive
  labels for UI elements.
* **Screen Reader Testing:** Regularly test your app with TalkBack (Android) and
  VoiceOver (iOS).


## SVG → Flutter LeafRenderObject Icons
Icons from SVG are implemented uniformly for predictability, simple diffs, and absence of hidden optimizations.

* **Widget Structure:** One public widget: LeafRenderObjectWidget + PreferredSizeWidget (parameters: size, Color? color, double opacity).
* **RenderObject State:** Stores only _targetSize, _scale, _color, _opacity. Update via setters with `markNeedsLayout` / `markNeedsPaint` when needed.
* **Layout:** computeDryLayout -> `constraints.constrain(_targetSize)`; in performLayout compute `_scale = min(size.width/24, size.height/24)`.
* **Painting Sequence:** Center (translate to middle), then scale, then build picture inside `paint` via `ui.PictureRecorder`; immediately obtain `picture` and `canvas.drawPicture(picture)`.
* **Path Definitions:** All paths static: `static final Path path_0`, `path_1`, ... no intermediate local paths.
* **Picture Naming:** Picture builder function by icon name: `UIIcon$Example -> _$examplePicture(Canvas canvas, Color color, double opacity)`.
* **Multiple Layers:** If multiple layers/opacities — draw sequentially inside the build function.
* **Parameters Only:** ONLY size, color, opacity supported. No alignment/fit/contentScale.
* **No Caching:** Do not cache picture / dynamic path calculations; static paths allowed, picture recreated every paint.
* **Prohibited:** imports inside snippet, comments, fixed viewBox, extra state fields, external optimizations.

### LeafRenderObject Icon Template
```dart
import 'dart:math' as math;
import 'dart:ui' as ui hide Size;

import 'package:flutter/material.dart';
import 'package:ui/src/theme/theme.dart';

/// {@template icon_example}
/// Example icon widget.
/// {@endtemplate}
class UIIcon$Example extends LeafRenderObjectWidget implements PreferredSizeWidget {
  /// {@macro icon_example}
  const UIIcon$Example({this.color, this.size = 24, this.opacity = 1.0, super.key});

	/// The size of the icon.
  final double size;

	/// The opacity of the icon.
  final double opacity;

	/// The color of the icon.
	final Color? color;

  @override
  Size get preferredSize => Size.square(size);

  @override
  RenderObject createRenderObject(BuildContext context) => _UIIcon$Example$RenderObject()
    .._isDark = Theme.of(context).brightness == Brightness.dark
    .._targetSize = Size.square(size)
    .._opacity = opacity;

  @override
  void updateRenderObject(BuildContext context, covariant _UIIcon$Example$RenderObject renderObject) {
		final newSize = Size.square(size);
    if (renderObject case _UIIcon$Example$RenderObject object when object._targetSize != newSize) {
      object
        .._targetSize = newSize
        ..markNeedsLayout();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (renderObject case _UIIcon$Example$RenderObject object when object._isDark != isDark) {
      object
        .._isDark = isDark
        ..markNeedsPaint();
    }
    if (renderObject case _UIIcon$Example$RenderObject object when object.color != color) {
      object
        .._color = color
        ..markNeedsPaint();
    }
    if (renderObject case _UIIcon$Example$RenderObject object when object._opacity != opacity) {
      object
        .._opacity = opacity
        ..markNeedsPaint();
    }
  }
}

class _UIIcon$Example$RenderObject extends RenderBox {
  Size _targetSize = Size.zero;
  Color _color = kAccentColor;
  double _opacity = 1.0;
  bool _isDark = false;
  double _scale = .0;

  @override
  bool get alwaysNeedsCompositing => false;

  @override
  bool get isRepaintBoundary => false;

  @override
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(_targetSize);

  @override
  void performLayout() {
    final size = super.size = computeDryLayout(constraints);
    _scale = math.min(size.width / 24.0, size.height / 24.0);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_scale < .01) return;
    final canvas = context.canvas..save();
    final sideScaled = 24.0 * _scale;
    canvas
      ..translate(offset.dx + (size.width - sideScaled) / 2, offset.dy + (size.height - sideScaled) / 2)
      ..scale(_scale, _scale);
    final pic = _$examplePicture(_opacity);
    canvas
      ..drawPicture(pic)
      ..restore();
    pic.dispose();
  }

  static ui.Picture _$examplePicture(Color color, double opacity) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    canvas
      ..drawPath(path_1, paint..color = color.withValues(alpha: 1 * opacity))
      ..drawPath(path_0, paint..color = color.withValues(alpha: 0.5 * opacity));
    return recorder.endRecording();
  }

  static final Path path_1 = Path()
    ..moveTo(20.25, 7.35156)
    ..lineTo(17.5, 7.35156)
    ..cubicTo(17.5, 5.89287, 16.9205, 4.49393, 15.8891, 3.46248)
    ..cubicTo(14.8576, 2.43103, 13.4587, 1.85156, 12, 1.85156)
    ..cubicTo(10.5413, 1.85156, 9.14236, 2.43103, 8.11091, 3.46248)
    ..cubicTo(7.07946, 4.49393, 6.5, 5.89287, 6.5, 7.35156)
    ..lineTo(3.75, 7.35156)
    ..cubicTo(3.02065, 7.35156, 2.32118, 7.64129, 1.80546, 8.15702)
    ..cubicTo(1.28973, 8.67274, 1, 9.37222, 1, 10.1016)
    ..lineTo(1, 19.2682)
    ..cubicTo(1.00146, 20.4834, 1.48481, 21.6483, 2.34403, 22.5075)
    ..cubicTo(3.20326, 23.3668, 4.3682, 23.8501, 5.58333, 23.8516)
    ..lineTo(16.2955, 23.8516)
    ..cubicTo(15.6582, 23.4373, 15.1137, 22.8955, 14.6964, 22.2603)
    ..cubicTo(14.279, 21.6251, 13.9979, 20.9103, 13.8706, 20.1609)
    ..cubicTo(13.7434, 19.4116, 13.7728, 18.644, 13.9571, 17.9066)
    ..cubicTo(14.1414, 17.1693, 14.4765, 16.4781, 14.9413, 15.8767)
    ..cubicTo(15.4061, 15.2753, 15.9905, 14.7768, 16.6576, 14.4126)
    ..cubicTo(17.3247, 14.0485, 18.0601, 13.8265, 18.8173, 13.7608)
    ..cubicTo(19.5745, 13.695, 20.3372, 13.787, 21.0571, 14.0307)
    ..cubicTo(21.777, 14.2745, 22.4385, 14.6649, 23, 15.1771)
    ..lineTo(23, 10.1016)
    ..cubicTo(23, 9.37222, 22.7103, 8.67274, 22.1945, 8.15702)
    ..cubicTo(21.6788, 7.64129, 20.9793, 7.35156, 20.25, 7.35156)
    ..close()
    ..moveTo(8.33333, 7.35156)
    ..cubicTo(8.33333, 6.3791, 8.71964, 5.44647, 9.40728, 4.75884)
    ..cubicTo(10.0949, 4.0712, 11.0275, 3.6849, 12, 3.6849)
    ..cubicTo(12.9725, 3.6849, 13.9051, 4.0712, 14.5927, 4.75884)
    ..cubicTo(15.2804, 5.44647, 15.6667, 6.3791, 15.6667, 7.35156)
    ..lineTo(8.33333, 7.35156)
    ..close();

  static final Path path_0 = Path()
    ..moveTo(22.0827, 18.3516)
    ..lineTo(20.2493, 18.3516)
    ..lineTo(20.2493, 16.5182)
    ..cubicTo(20.2493, 16.2751, 20.1528, 16.042, 19.9809, 15.87)
    ..cubicTo(19.8089, 15.6981, 19.5758, 15.6016, 19.3327, 15.6016)
    ..cubicTo(19.0896, 15.6016, 18.8564, 15.6981, 18.6845, 15.87)
    ..cubicTo(18.5126, 16.042, 18.416, 16.2751, 18.416, 16.5182)
    ..lineTo(18.416, 18.3516)
    ..lineTo(16.5827, 18.3516)
    ..cubicTo(16.3396, 18.3516, 16.1064, 18.4481, 15.9345, 18.62)
    ..cubicTo(15.7626, 18.7919, 15.666, 19.0251, 15.666, 19.2682)
    ..cubicTo(15.666, 19.5113, 15.7626, 19.7445, 15.9345, 19.9164)
    ..cubicTo(16.1064, 20.0883, 16.3396, 20.1849, 16.5827, 20.1849)
    ..lineTo(18.416, 20.1849)
    ..lineTo(18.416, 22.0182)
    ..cubicTo(18.416, 22.2613, 18.5126, 22.4945, 18.6845, 22.6664)
    ..cubicTo(18.8564, 22.8383, 19.0896, 22.9349, 19.3327, 22.9349)
    ..cubicTo(19.5758, 22.9349, 19.8089, 22.8383, 19.9809, 22.6664)
    ..cubicTo(20.1528, 22.4945, 20.2493, 22.2613, 20.2493, 22.0182)
    ..lineTo(20.2493, 20.1849)
    ..lineTo(22.0827, 20.1849)
    ..cubicTo(22.3258, 20.1849, 22.5589, 20.0883, 22.7309, 19.9164)
    ..cubicTo(22.9028, 19.7445, 22.9993, 19.5113, 22.9993, 19.2682)
    ..cubicTo(22.9993, 19.0251, 22.9028, 18.7919, 22.7309, 18.62)
    ..cubicTo(22.5589, 18.4481, 22.3258, 18.3516, 22.0827, 18.3516)
    ..close();
}
```


## Enums
Enums are defined with the following conventions to ensure consistency, type safety, and ease of use across the codebase.

* **Signature**: `enum <ExampleType> implements Comparable<ExampleType> { ... }`
* **Value storage**: each case declares a canonical string via `const <ExampleType>(this.value);`
* **Parsing**: use explicit static `fromValue` with `switch`:
```dart
/// Creates a new instance of [ExampleType] from a given string.
static <ExampleType> fromValue(String? value, {ExampleType? fallback}) =>
  switch (value?.trim().toLowerCase()) {
    'examplevalue' => exampleValue,
    _ => fallback ?? (throw ArgumentError.value(value)),
  };
```
* **Field**: `final String value;`
* **Helpers**:
  * `map` (exhaustive; all cases required)
  * `maybeMap` (fallback via `orElse`)
  * `maybeMapOrNull` (delegates to `maybeMap` with `orElse: () => null`)
* **compareTo**: `@override int compareTo(<ExampleType> other) => index.compareTo(other.index);`
* **toString**: return `value`
* **Ordering**: rely solely on declaration order and `index` (no extra ordering fields)
* **Naming**:
  * **Case identifiers**: lowerCamelCase
  * **Stored `value`**: matches API/server contract (normalized in `fromValue` via `toLowerCase()`)
* **No reflection**: never use `name` or `values.byName`; only explicit `switch`
* **Changes**: adding/removing cases REQUIRES updating `map`, `maybeMap`, `maybeMapOrNull` and related tests (CI/analyzer should fail if incomplete)
* **No extra extensions**: unless cross-cutting (place extensions under `lib/src/common/`)
* **No mutable state or side effects**: enums should be pure value types

### Example Enum Template
```dart
/// {@template example_type}
/// ExampleType enumeration.
/// {@endtemplate}
enum ExampleType implements Comparable<ExampleType> {
	/// foo
  foo('foo'),

	/// bar
  bar('bar');

	/// {@macro example_type}
  const ExampleType(this.value);

	/// Creates an ExampleType from a string value.
  static ExampleType fromValue(String? value, {ExampleType? fallback}) => switch (value?.trim().toLowerCase()) {
    'foo' => foo,
    'bar' => bar,
    _ => fallback ?? (throw ArgumentError.value(value)),
  };

	/// The string value of the ExampleType.
  final String value;

	/// Pattern matching helper.
  T map<T>({required T Function() foo, required T Function() bar}) => switch (this) {
    ExampleType.foo => foo(),
    ExampleType.bar => bar(),
  };


	/// Pattern matching helper with fallback.
  T maybeMap<T>({required T Function() orElse, T Function()? foo, T Function()? bar}) =>
      map<T>(foo: foo ?? orElse, bar: bar ?? orElse);

	/// Pattern matching helper with nullable return.
  T? maybeMapOrNull<T>({T Function()? foo, T Function()? bar}) =>
      maybeMap<T?>(orElse: () => null, foo: foo, bar: bar);

  @override
  int compareTo(ExampleType other) => index.compareTo(other.index);

  @override
  String toString() => value;

	/// Optional: Additional methods or properties can be added here.
	@override
	String toLocalizedString(BuildContext context) => map<String>(
		foo: () => 'Foo Localized',
		bar: () => 'Bar Localized',
	);
}
```
