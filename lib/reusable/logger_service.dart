import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sermon/main.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void d(String message) {
    if (isDebugMode() || kDebugMode) _logger.d('🐛 ${message}\n');
  }

  static void i(String message) {
    if (isDebugMode() || kDebugMode) _logger.i('🐛 ${message}\n');
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    if (isDebugMode() || kDebugMode) {
      _logger.w('🐛 ${message}\n', error: error, stackTrace: stackTrace);
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (isDebugMode() || kDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }
}
