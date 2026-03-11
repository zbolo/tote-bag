import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Log levels ordered by severity.
enum LogLevel { debug, info, warn, error }

/// Structured logger that outputs formatted logs to the debug console.
///
/// Logs are only emitted in debug mode (kDebugMode). Each entry includes
/// a timestamp, level tag, module name, and message.
class Log {
  static LogLevel _minLevel = LogLevel.debug;

  /// Set the minimum log level (messages below this level are ignored).
  static void setLevel(LogLevel level) => _minLevel = level;

  // ── Public API ──────────────────────────────────────────────

  static void debug(String module, String message, [Object? data]) =>
      _log(LogLevel.debug, module, message, data);

  static void info(String module, String message, [Object? data]) =>
      _log(LogLevel.info, module, message, data);

  static void warn(String module, String message, [Object? data]) =>
      _log(LogLevel.warn, module, message, data);

  static void error(String module, String message,
          [Object? error, StackTrace? stack]) =>
      _log(LogLevel.error, module, message, error, stack);

  // ── Internals ───────────────────────────────────────────────

  static void _log(LogLevel level, String module, String message,
      [Object? data, StackTrace? stack]) {
    if (!kDebugMode) return;
    if (level.index < _minLevel.index) return;

    final tag = _tag(level);
    final time = _timestamp();
    final buf = StringBuffer('$tag $time [$module] $message');

    if (data != null) {
      buf.write(' | $data');
    }

    dev.log(buf.toString(), name: 'ToteBag', stackTrace: stack);
  }

  static String _tag(LogLevel level) => switch (level) {
        LogLevel.debug => '🔍 DEBUG',
        LogLevel.info => 'ℹ️  INFO',
        LogLevel.warn => '⚠️  WARN',
        LogLevel.error => '❌ ERROR',
      };

  static String _timestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }
}
