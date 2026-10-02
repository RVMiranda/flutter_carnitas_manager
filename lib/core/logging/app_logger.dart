import 'package:flutter/foundation.dart';

/// Niveles de log disponibles en la aplicación.
enum LogLevel { debug, info, warning, error }

/// Logger centralizado de la aplicación.
///
/// Nunca registra contraseñas, tokens, service role keys ni información sensible.
/// En producción, los logs de debug se suprimen automáticamente.
class AppLogger {
  AppLogger._();

  static const String _prefix = '[ExquisssitaMgr]';

  static void debug(String message, {String? tag}) {
    if (!kDebugMode) return;
    _log(LogLevel.debug, message, tag: tag);
  }

  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  static void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final tagStr = tag != null ? '[$tag]' : '';
    final errorStr = error != null ? ' | Error: $error' : '';

    // ignore: avoid_print
    print('$_prefix $timestamp $levelStr$tagStr $message$errorStr');

    if (stackTrace != null && kDebugMode) {
      // ignore: avoid_print
      print(stackTrace);
    }
  }
}
