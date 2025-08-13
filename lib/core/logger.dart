import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging utility for FieldForce app
class AppLogger {
  static const String _appName = 'FieldForce';
  
  /// Log levels
  static const int _debugLevel = 0;
  static const int _infoLevel = 1;
  static const int _warningLevel = 2;
  static const int _errorLevel = 3;
  
  /// Debug log - for development debugging
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(_debugLevel, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Info log - for general information
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(_infoLevel, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Warning log - for warnings that don't break functionality
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(_warningLevel, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Error log - for errors that need attention
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(_errorLevel, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Internal logging method
  static void _log(int level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final String levelName = _getLevelName(level);
      final String tagPrefix = tag != null ? '[$tag] ' : '';
      final String logMessage = '[$_appName] $levelName: $tagPrefix$message';
      
      // Use developer.log for better debugging experience
      developer.log(
        logMessage,
        name: _appName,
        level: _getDeveloperLogLevel(level),
        error: error,
        stackTrace: stackTrace,
      );
      
      // Also print to console for immediate visibility during development
      if (kDebugMode) {
        print(logMessage);
        if (error != null) {
          print('Error: $error');
        }
        if (stackTrace != null) {
          print('Stack trace: $stackTrace');
        }
      }
    }
  }
  
  /// Get level name for display
  static String _getLevelName(int level) {
    switch (level) {
      case _debugLevel:
        return 'DEBUG';
      case _infoLevel:
        return 'INFO';
      case _warningLevel:
        return 'WARNING';
      case _errorLevel:
        return 'ERROR';
      default:
        return 'UNKNOWN';
    }
  }
  
  /// Convert our log levels to developer.log levels
  static int _getDeveloperLogLevel(int level) {
    switch (level) {
      case _debugLevel:
        return 500; // Fine
      case _infoLevel:
        return 800; // Info
      case _warningLevel:
        return 900; // Warning
      case _errorLevel:
        return 1000; // Severe
      default:
        return 800;
    }
  }
}

/// Convenience class for specific module logging
class ModuleLogger {
  final String _moduleName;
  
  const ModuleLogger(this._moduleName);
  
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.debug(message, tag: _moduleName, error: error, stackTrace: stackTrace);
  }
  
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.info(message, tag: _moduleName, error: error, stackTrace: stackTrace);
  }
  
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.warning(message, tag: _moduleName, error: error, stackTrace: stackTrace);
  }
  
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.error(message, tag: _moduleName, error: error, stackTrace: stackTrace);
  }
}

/// Pre-defined loggers for common modules
class Loggers {
  static const ModuleLogger auth = ModuleLogger('AUTH');
  static const ModuleLogger api = ModuleLogger('API');
  static const ModuleLogger navigation = ModuleLogger('NAVIGATION');
  static const ModuleLogger database = ModuleLogger('DATABASE');
  static const ModuleLogger ui = ModuleLogger('UI');
  static const ModuleLogger network = ModuleLogger('NETWORK');
  static const ModuleLogger config = ModuleLogger('CONFIG');
}