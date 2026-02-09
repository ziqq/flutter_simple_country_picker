import 'dart:async';
import 'dart:developer' as dev show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Ephemerally initializes the app and prepares it for use.
// Future<Dependencies>? _$initializeApp;
Future<void>? _$initializeApp;

/// Initializes the app and prepares it for use.
Future<void> $initializeApp({
  void Function(int progress, String message)? onProgress,
  Future<void> Function(void dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) => _$initializeApp ??= Future<void>(() async {
  late final WidgetsBinding binding;
  final stopwatch = Stopwatch()..start();
  try {
    binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
    await _catchExceptions();
    await onSuccess?.call(null);
    return;
  } on Object catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    dev.log('Failed to initialize app', stackTrace: stackTrace, level: 1000);
    rethrow;
  } finally {
    stopwatch.stop();
    binding.addPostFrameCallback((_) {
      // Closes splash screen, and show the app layout.
      binding.allowFirstFrame();
      //final context = binding.renderViewElement;
    });
    _$initializeApp = null;
  }
});

/// Resets the app's state to its initial state.
@visibleForTesting
Future<void> $resetApp(void dependencies) async {}

/// Disposes the app and releases all resources.
@visibleForTesting
Future<void> $disposeApp(void dependencies) async {}

Future<void> _catchExceptions() async {
  try {
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      dev.log(
        'Root error: ${Error.safeToString(error)}',
        stackTrace: stackTrace,
        level: 1000,
      );
      return true;
    };

    final sourceFlutterError = FlutterError.onError;
    FlutterError.onError = (final details) {
      dev.log(
        'Flutter error: ${details.exceptionAsString()}',
        stackTrace: details.stack,
        level: 1000,
      );
      // FlutterError.presentError(details);
      sourceFlutterError?.call(details);
    };
  } on Object catch (error, stackTrace) {
    dev.log(
      'Failed to set up error handling: ${Error.safeToString(error)}',
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
