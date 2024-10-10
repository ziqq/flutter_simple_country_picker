/*
 * Simplified navigator that allows to change the pages declaratively.
 * https://gist.github.com/PlugFox/053d267fe59bc65da0d6fb9e9dd7e374
 * https://dartpad.dev?id=053d267fe59bc65da0d6fb9e9dd7e374
 * Mike Matiunin <plugfox@gmail.com>, 01 April 2024
 */

import 'dart:collection';

import 'package:flutter/material.dart';

/// {@template example_navigator}
/// Simplified navigator that allows to change the pages declaratively.
/// You can add a custom controller with interceptors and other features.
/// You can pass controller down the widget tree to change the pages
///  from anywhere with InheritedWidget.
/// {@endtemplate}
class ExampleNavigator extends StatefulWidget {
  /// {@macro example_navigator}
  const ExampleNavigator({
    required this.home,
    this.controller,
    super.key,
  });

  /// Fallback page when the pages list is empty.
  final Page<Object?> home;

  /// Custom controller to change the pages declaratively.
  final ValueNotifier<List<Page<Object?>>>? controller;

  /// Change the pages declaratively.
  static void change(BuildContext context,
          List<Page<Object?>> Function(List<Page<Object?>>) fn) =>
      context.findAncestorStateOfType<_ExampleNavigatorState>()?.change(fn);

  @override
  State<ExampleNavigator> createState() => _ExampleNavigatorState();
}

class _ExampleNavigatorState extends State<ExampleNavigator> {
  late ValueNotifier<List<Page<Object?>>> _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        ValueNotifier<List<Page<Object?>>>(<Page<Object?>>[widget.home]);
    if (_controller.value.isEmpty)
      _controller.value = <Page<Object?>>[widget.home];
    _controller.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(covariant ExampleNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(_controller, widget.controller)) {
      _controller.removeListener(_onStateChanged);
      _controller = widget.controller ??
          ValueNotifier<List<Page<Object?>>>(<Page<Object?>>[widget.home]);
      if (_controller.value.isEmpty)
        _controller.value = <Page<Object?>>[widget.home];
      _controller.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    super.dispose();
  }

  /// Change the pages declaratively.
  void change(List<Page<Object?>> Function(List<Page<Object?>>) fn) {
    final pages = fn(_controller.value);
    if (identical(pages, _controller.value)) return; // No changes
    // Remove duplicates and null keys
    final set = <LocalKey>{};
    final newPages = <Page<Object?>>[];
    for (var i = pages.length - 1; i >= 0; i--) {
      final page = pages[i];
      final key = page.key;
      if (set.contains(page.key) || key == null) continue;
      set.add(key);
      newPages.insert(0, page);
    }
    if (newPages.isEmpty) newPages.add(widget.home);
    _controller.value = UnmodifiableListView<Page<Object?>>(newPages);
  }

  @protected
  void _onStateChanged() => setState(() {});

  @protected
  bool _onPopPage(Page<Object?> route) {
    if (!route.canPop) return false;
    final pages = _controller.value;
    if (pages.length <= 1) return false;
    // You can implement custom logic here
    _controller.value =
        UnmodifiableListView<Page<Object?>>(pages.sublist(0, pages.length - 1));
    return true;
  }

  @override
  Widget build(BuildContext context) => Navigator(
        pages: _controller.value.toList(growable: false),
        onDidRemovePage: _onPopPage,
      );
}

// void main() => runZonedGuarded<void>(
//   () => runApp(App(controller: ValueNotifier<List<Page<Object?>>>([]))),
//   (error, stackTrace) => l.e('Top level exception: error\nstackTrace'),
// );

/// {@template example_navigator}
/// Example app with a custom navigator.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro example_navigator}
  const App({required this.controller, super.key});

  /// Custom controller to change the pages declaratively.
  final ValueNotifier<List<Page<Object?>>> controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Declarative Navigator Example',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        builder: (context, _) => ExampleNavigator(
          home: AppPages.pickerPreview.page,
          controller: controller,
        ),
      );
}

/// {@template example_navigator}
/// Pages and screens of the example app.
/// {@endtemplate}
enum AppPages {
  /// Input preview
  inputPreview('County Phone Input Preview'),

  /// Picker preview
  pickerPreview('Country Picker Preview');

  const AppPages(this.title);

  /// Page title
  final String title;

  /// Create a new page
  Page<Object?> get page => MaterialPage<Object?>(
        key: ValueKey<AppPages>(this),
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: <Widget>[
                // Show modal dialog
                IconButton(
                  icon: const Icon(Icons.warning),
                  tooltip: 'Show modal dialog',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Warning'),
                      content: const Text('This is a warning message.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Go to input preview page
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Drop routes and go to input preview',
                  onPressed: () => ExampleNavigator.change(
                    context,
                    (pages) => [
                      AppPages.inputPreview.page,
                      AppPages.pickerPreview.page,
                    ],
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: ListView(
                shrinkWrap: true,
                // Show list of new routes
                children: AppPages.values
                    .where((e) => e != this)
                    .map<Widget>(
                      (e) => ListTile(
                        title: Text(e.title),
                        onTap: () => ExampleNavigator.change(
                          context,
                          (pages) => [...pages, e.page],
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      );
}
