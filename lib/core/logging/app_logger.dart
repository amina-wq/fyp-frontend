// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Debug-only logging helper wrapping dart:developer log.
// First Written on: Sunday, 12-Jul-2026
// Edited on: Sunday, 12-Jul-2026
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void info(
    String message, {
    String name = 'FoodTrack',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    developer.log(
      message,
      name: name,
      level: 800,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(
    String message, {
    String name = 'FoodTrack',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    developer.log(
      message,
      name: name,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(
    String message, {
    String name = 'FoodTrack',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
