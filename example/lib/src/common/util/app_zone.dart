import 'dart:async';
import 'dart:developer' as dev;

/// Catch all application errors and logs.
void appZone(
  Future<void> Function() fn, [
  Future<void> Function(Object, StackTrace)? onError,
]) =>
    runZonedGuarded<void>(
      () => fn(),
      (error, stackTrace) =>
          onError?.call(error, stackTrace) ??
          dev.log(error.toString(), stackTrace: stackTrace),
    );
