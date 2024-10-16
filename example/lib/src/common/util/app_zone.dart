import 'dart:async';

import 'package:l/l.dart';
import 'package:platform_info/platform_info.dart';

/// Catch all application errors and logs.
void appZone(
  Future<void> Function() fn, [
  Future<void> Function(Object, StackTrace)? onError,
]) =>
    l.capture<void>(
      () => runZonedGuarded<void>(
        () => fn(),
        (err, st) => onError?.call(err, st) ?? l.e(err, st),
      ),
      LogOptions(
        handlePrint: true,
        messageFormatting: _messageFormatting,
        outputInRelease: false,
        printColors: !platform.iOS,
      ),
    );

/// Formats the log message.
Object _messageFormatting(Object message, LogLevel logLevel, DateTime now) =>
    '${_timeFormat(now)} | $message';

/// Formats the time.
String _timeFormat(DateTime time) =>
    '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
