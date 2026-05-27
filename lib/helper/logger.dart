import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _tag = 'HisabBox';

  // Info level logging
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      print('ℹ️ ${tag ?? _tag}: $message');
    }
  }

  // Error level logging
  static void error(String message, [dynamic error, String? tag]) {
    if (kDebugMode) {
      print('❌ ${tag ?? _tag}: $message');
      if (error != null) {
        print('   Error details: $error');
      }
    }
  }

  // Warning level logging
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      print('⚠️ ${tag ?? _tag}: $message');
    }
  }

  // Debug level logging
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      print('🐛 ${tag ?? _tag}: $message');
    }
  }

  // Success level logging
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      print('✅ ${tag ?? _tag}: $message');
    }
  }
}
