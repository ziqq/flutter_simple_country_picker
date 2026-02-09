import 'dart:async';
import 'dart:developer' as dev;

/// Catch all application errors and logs.
void appZone(
  Future<void> Function() fn, [
  Future<void> Function(Object error, StackTrace stackTrace)? onError,
]) => runZonedGuarded<void>(
  () => fn(),
  (e, s) => onError?.call(e, s) ?? dev.log(e.toString(), stackTrace: s),
);
