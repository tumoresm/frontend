import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fieldforce/core/logger.dart';

/// Performance monitoring utilities
class PerformanceUtils {
  static final Map<String, DateTime> _timers = {};

  /// Start timing an operation
  static void startTimer(String name) {
    if (kDebugMode) {
      _timers[name] = DateTime.now();
      Loggers.config.debug('Started timer: $name');
    }
  }

  /// End timing and log duration
  static void endTimer(String name) {
    if (kDebugMode && _timers.containsKey(name)) {
      final duration = DateTime.now().difference(_timers[name]!);
      Loggers.config.debug('$name took: ${duration.inMilliseconds}ms');
      _timers.remove(name);

      // Warn if operation took too long
      if (duration.inMilliseconds > 100) {
        Loggers.config
            .warning('Slow operation: $name (${duration.inMilliseconds}ms)');
      }
    }
  }

  /// Measure execution time of a function
  static T measureSync<T>(String name, T Function() function) {
    startTimer(name);
    try {
      return function();
    } finally {
      endTimer(name);
    }
  }

  /// Measure execution time of an async function
  static Future<T> measureAsync<T>(
      String name, Future<T> Function() function) async {
    startTimer(name);
    try {
      return await function();
    } finally {
      endTimer(name);
    }
  }

  /// Clear all timers (useful for testing)
  static void clearTimers() {
    _timers.clear();
  }
}

/// Throttle function calls to prevent excessive rebuilds
class Throttler {
  static final Map<String, DateTime> _lastThrottleTime = {};

  /// Throttle a function call
  static void throttle(String key, Duration interval, VoidCallback callback) {
    final now = DateTime.now();
    if (!_lastThrottleTime.containsKey(key) ||
        now.difference(_lastThrottleTime[key]!) >= interval) {
      _lastThrottleTime[key] = now;
      callback();
    }
  }

  /// Clear throttle history
  static void clear() {
    _lastThrottleTime.clear();
  }
}

/// Debounce function calls
class Debouncer {
  static final Map<String, Timer?> _timers = {};

  /// Debounce a function call
  static void debounce(String key, Duration delay, VoidCallback callback) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, callback);
  }

  /// Cancel a debounced function
  static void cancel(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// Cancel all debounced functions
  static void cancelAll() {
    for (final timer in _timers.values) {
      timer?.cancel();
    }
    _timers.clear();
  }
}

/// Widget performance monitoring mixin
mixin PerformanceMixin {
  /// Log build time for a widget
  Widget logBuildTime(String widgetName, Widget Function() buildFunction) {
    if (kDebugMode) {
      return PerformanceUtils.measureSync('$widgetName.build', buildFunction);
    } else {
      return buildFunction();
    }
  }

  /// Log async operation time
  Future<T> logAsyncOperation<T>(
      String operationName, Future<T> Function() operation) {
    return PerformanceUtils.measureAsync(operationName, operation);
  }
}
