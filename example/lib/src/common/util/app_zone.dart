import 'dart:async';
import 'dart:developer' as dev;

/// Runs the example in a guarded zone and logs uncaught errors.
///
/// Supply [onError] to handle those errors instead.
void appZone(
  Future<void> Function() fn, [
  Future<void> Function(Object error, StackTrace stackTrace)? onError,
]) => runZonedGuarded<void>(
  () => fn(),
  (e, s) => onError?.call(e, s) ?? dev.log(e.toString(), stackTrace: s),
);
