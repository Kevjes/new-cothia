import 'dart:developer';

class AppLogger {
  static void info(String message) {
    log('ℹ️ INFO: $message', name: 'CothiaApp');
  }

  static void success(String message) {
    log('✅ SUCCESS: $message', name: 'CothiaApp');
  }

  static void warning(String message) {
    log('⚠️ WARNING: $message', name: 'CothiaApp');
  }

  static void error(String message) {
    log('❌ ERROR: $message', name: 'CothiaApp');
  }

  static void debug(String message) {
    log('🐛 DEBUG: $message', name: 'CothiaApp');
  }
}