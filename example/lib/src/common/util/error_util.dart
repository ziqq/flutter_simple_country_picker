// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';
import 'dart:developer' as dev;

import 'package:example/src/common/util/platform/error_util_vm.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'platform/error_util_js.dart';

/// Error util.
abstract final class ErrorUtil {
  /// Log the error to the console and to Crashlytics.
  static Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {
    try {
      if (exception is String) {
        return await logMessage(
          exception,
          stackTrace: stackTrace,
          hint: hint,
          warning: true,
        );
      }
      $captureException(exception, stackTrace, hint, fatal).ignore();
      dev.log(exception.toString(), stackTrace: stackTrace);
    } on Object catch (error, stackTrace) {
      dev.log(
        'Error while logging error "$error" inside ErrorUtil.logError',
        stackTrace: stackTrace,
      );
    }
  }

  /// Logs a message to the console and to Crashlytics.
  static Future<void> logMessage(
    String message, {
    StackTrace? stackTrace,
    String? hint,
    bool warning = false,
  }) async {
    try {
      dev.log(message, stackTrace: stackTrace ?? StackTrace.current);
      $captureMessage(message, stackTrace, hint, warning).ignore();
    } on Object catch (error, stackTrace) {
      dev.log(
        'Error while logging error "$error" inside ErrorUtil.logMessage',
        stackTrace: stackTrace,
      );
    }
  }

  /// Rethrows the error with the stack trace.
  static Never throwWithStackTrace(Object error, StackTrace stackTrace) =>
      Error.throwWithStackTrace(error, stackTrace);
}
