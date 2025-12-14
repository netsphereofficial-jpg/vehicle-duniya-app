import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging utility for the app
class AppLogger {
  AppLogger._();

  static const String _appTag = 'VehicleDuniya';

  /// Log info message
  static void info(String tag, String message) {
    if (kDebugMode) {
      developer.log(
        '[$_appTag][$tag] INFO: $message',
        name: tag,
        level: 800,
      );
    }
  }

  /// Log debug message
  static void debug(String tag, String message) {
    if (kDebugMode) {
      developer.log(
        '[$_appTag][$tag] DEBUG: $message',
        name: tag,
        level: 500,
      );
    }
  }

  /// Log warning message
  static void warning(String tag, String message) {
    if (kDebugMode) {
      developer.log(
        '[$_appTag][$tag] WARNING: $message',
        name: tag,
        level: 900,
      );
    }
  }

  /// Log error message
  static void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        '[$_appTag][$tag] ERROR: $message',
        name: tag,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log BLoC event
  static void blocEvent(String blocName, String eventName) {
    if (kDebugMode) {
      developer.log(
        '[$_appTag][BLoC][$blocName] Event: $eventName',
        name: 'BLoC',
      );
    }
  }

  /// Log BLoC state transition
  static void blocState(String blocName, String fromState, String toState) {
    if (kDebugMode) {
      developer.log(
        '[$_appTag][BLoC][$blocName] State: $fromState -> $toState',
        name: 'BLoC',
      );
    }
  }

  /// Log API call
  static void api(String method, String endpoint, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      final paramsStr = params != null ? ' Params: $params' : '';
      developer.log(
        '[$_appTag][API] $method $endpoint$paramsStr',
        name: 'API',
      );
    }
  }

  /// Log Firebase operation
  static void firebase(String operation, String collection, {String? docId}) {
    if (kDebugMode) {
      final docStr = docId != null ? '/$docId' : '';
      developer.log(
        '[$_appTag][Firebase] $operation: $collection$docStr',
        name: 'Firebase',
      );
    }
  }

  /// Log navigation
  static void navigation(String from, String to) {
    if (kDebugMode) {
      developer.log(
        '[$_appTag][Navigation] $from -> $to',
        name: 'Navigation',
      );
    }
  }
}
