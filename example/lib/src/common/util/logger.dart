import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Fine
final void Function(Object? message) fine = _logAll('FINE', 500);

/// Config
final void Function(Object? message) config = _logAll('CONF', 700);

/// Info
final void Function(Object? message) info = _logAll('INFO', 800);

/// Warning
final void Function(
  Object? exception, [
  StackTrace? stackTrace,
  String? reason,
]) warning = _logAll('WARN', 900);

/// Severe
final void Function(
  Object? error, [
  StackTrace? stackTrace,
  String? reason,
]) severe = _logAll('ERR!', 1000);

void Function(
  Object? message, [
  StackTrace? stackTrace,
  String? reason,
]) _logAll(String prefix, int level) => (message, [stackTrace, reason]) {
      if (kReleaseMode) return;
      developer.log(
        '[$prefix] ${reason ?? message}',
        level: level,
        name: 'isolation',
        error: message is Exception || message is Error ? message : null,
        stackTrace: stackTrace,
      );
    };
