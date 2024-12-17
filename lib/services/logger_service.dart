import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class LoggerService {
  static final Logger _logger = Logger('CleverRealtor');

  static void init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      }
      // TODO: Add production logging service integration here
      // e.g., Firebase Crashlytics, Sentry, etc.
    });
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  static void info(String message) {
    _logger.info(message);
  }
}
