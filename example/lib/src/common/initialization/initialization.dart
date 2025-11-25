import 'dart:async';

import 'package:example/src/common/util/error_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Ephemerally initializes the app and prepares it for use.
// Future<Dependencies>? _$initializeApp;
Future<void>? _$initializeApp;

/// Initializes the app and prepares it for use.
Future<void> $initializeApp({
  void Function(int progress, String message)? onProgress,
  FutureOr<void> Function(void dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) => _$initializeApp ??= Future<void>(() async {
  late final WidgetsBinding binding;
  final stopwatch = Stopwatch()..start();
  try {
    binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
    /* await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]); */
    await _catchExceptions();
    /* final dependencies = await $initializeDependencies(
           onProgress: onProgress).timeout(const Duration(minutes: 7)); */
    await onSuccess?.call(null);
    return;
  } on Object catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    ErrorUtil.logError(
      error,
      stackTrace,
      hint: 'Failed to initialize app',
    ).ignore();
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
      ErrorUtil.logError(
        error,
        stackTrace,
        hint: 'ROOT ERROR\r\n${Error.safeToString(error)}',
      ).ignore();
      return true;
    };

    final sourceFlutterError = FlutterError.onError;
    FlutterError.onError = (final details) {
      ErrorUtil.logError(
        details.exception,
        details.stack ?? StackTrace.current,
        hint: 'FLUTTER ERROR\r\n$details',
      ).ignore();
      // FlutterError.presentError(details);
      sourceFlutterError?.call(details);
    };
  } on Object catch (error, stackTrace) {
    ErrorUtil.logError(error, stackTrace).ignore();
  }
}
