import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'logger_service.dart';

/// Service that wraps Firebase Crashlytics for crash and error reporting.
///
/// In debug mode, errors are only logged, not sent to Crashlytics.
/// In release mode, all unhandled errors are automatically recorded.
class CrashlyticsService {
  static CrashlyticsService? _instance;
  final LoggerService _logger = LoggerService();
  bool _initialized = false;

  CrashlyticsService._internal();

  factory CrashlyticsService() {
    _instance ??= CrashlyticsService._internal();
    return _instance!;
  }

  /// Whether the service has been initialized.
  bool get isInitialized => _initialized;

  /// Initialize Crashlytics.
  ///
  /// Must be called after Firebase Core is initialized.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // In debug mode, don't send crashes to Firebase
      if (kReleaseMode) {
        // Pass all unhandled errors to Crashlytics
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };

        // Pass all platform errors to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }

      // Set Crashlytics collection to enabled in release mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);

      _initialized = true;
      _logger.info('Crashlytics service initialized');
    } catch (e) {
      _logger.warning('Failed to initialize Crashlytics: $e');
      // Don't crash the app if Crashlytics fails
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Log a non-fatal error to Crashlytics.
  Future<void> recordError(dynamic error, StackTrace? stack, {String? context}) async {
    if (!_initialized) return;

    try {
      if (context != null) {
        await FirebaseCrashlytics.instance.recordError(error, stack,
            reason: context, fatal: false);
      } else {
        await FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
      }
      _logger.error('Error recorded to Crashlytics: $error');
    } catch (e) {
      _logger.warning('Failed to record error to Crashlytics: $e');
    }
  }

  /// Log a custom message to Crashlytics (breadcrumb).
  Future<void> log(String message) async {
    if (!_initialized) return;

    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      // Silently fail
    }
  }

  /// Set a custom key for crash reports (e.g. userId, role).
  Future<void> setCustomKey(String key, String value) async {
    if (!_initialized) return;

    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (e) {
      // Silently fail
    }
  }

  /// Set the current user identifier for crash reports.
  Future<void> setUserId(String userId) async {
    if (!_initialized) return;

    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e) {
      // Silently fail
    }
  }

  /// Simulate a crash for testing purposes.
  void testCrash() {
    if (!_initialized) return;
    FirebaseCrashlytics.instance.crash();
  }
}
