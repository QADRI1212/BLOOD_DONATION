import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'logger_service.dart';

/// Service that wraps Firebase Analytics for tracking user engagement,
/// screen views, and custom events.
///
/// In debug mode, events are logged but not sent to Firebase.
/// In release mode, all events are sent to Firebase Analytics.
///
/// Usage:
/// ```dart
/// // Log a screen view
/// AnalyticsService().logScreenView('Dashboard', '/dashboard');
///
/// // Log a custom event
/// AnalyticsService().logEvent('blood_request_created', {
///   'blood_group': 'A+',
///   'units': 2,
///   'priority': 'urgent',
/// });
/// ```
class AnalyticsService {
  static AnalyticsService? _instance;
  final LoggerService _logger = LoggerService();
  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  AnalyticsService._internal();

  factory AnalyticsService() {
    _instance ??= AnalyticsService._internal();
    return _instance!;
  }

  /// Access the raw FirebaseAnalytics instance if needed for advanced usage
  /// (e.g., resetAnalyticsData, setUserProperties).
  /// Returns null if the service has not been initialized yet.
  FirebaseAnalytics? get instance => _analytics;

  /// Whether the service has been initialized.
  bool get isInitialized => _initialized;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize the analytics service.
  ///
  /// Must be called after Firebase Core is initialized.
  /// Sets analytics collection to enabled in release mode only.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Create the FirebaseAnalytics instance only after Firebase is initialized
      _analytics = FirebaseAnalytics.instance;

      // Disable analytics collection in debug mode to avoid polluting data
      await _analytics!.setAnalyticsCollectionEnabled(kReleaseMode);

      _initialized = true;
      _logger.info(
        'Analytics service initialized (release mode: $kReleaseMode)',
      );
    } catch (e) {
      _logger.warning('Failed to initialize Analytics: $e');
      // Don't crash the app if Analytics fails
    }
  }

  // ---------------------------------------------------------------------------
  // Screen Tracking
  // ---------------------------------------------------------------------------

  /// Log a screen view event.
  ///
  /// Call this when a new screen is shown to the user.
  /// [screenName] is the human-readable name (e.g. "Dashboard", "Login").
  /// [screenClass] is optional and defaults to [screenName].
  /// [path] is optional and typically is the route path.
  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
    String? path,
  }) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      _logger.info(
        'Analytics screen view: $screenName${path != null ? ' ($path)' : ''}',
      );
    } catch (e) {
      _logger.warning('Failed to log screen view: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // User Events
  // ---------------------------------------------------------------------------

  /// Log a custom analytics event.
  ///
  /// [name] should follow the format `feature_action` (e.g. `request_created`).
  /// [parameters] is an optional map of string-keyed string values (max 25 params,
  /// each name ≤ 40 chars, each value ≤ 100 chars).
  ///
  /// Predefined event names (use instead of raw strings when available):
  /// - login / sign_up / logout
  /// - donation_complete / donation_start
  /// - request_created / request_accepted / request_completed
  /// - notification_received / notification_opened
  /// - search (with params: search_term, result_count)
  /// - share / invite
  /// - error (with params: error_type, error_message)
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (!_initialized || _analytics == null) return;

    try {
      // Firebase Analytics only accepts String parameter values in some SDK versions.
      // We convert all values to String to be safe.
      final safeParams = <String, dynamic>{};
      if (parameters != null) {
        for (final entry in parameters.entries) {
          safeParams[entry.key] = entry.value.toString();
        }
      }

      await _analytics!.logEvent(
        name: name,
        parameters: safeParams.isNotEmpty
            ? safeParams.cast<String, Object>()
            : null,
      );
      _logger.info('Analytics event: $name');
    } catch (e) {
      _logger.warning('Failed to log analytics event: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // User Properties
  // ---------------------------------------------------------------------------

  /// Set a user property for analytics segmentation.
  ///
  /// Useful for grouping users by:
  /// - `role` (donor, patient, hospital, admin)
  /// - `blood_group` (A+, O-, etc.)
  /// - `donation_tier` (new, bronze, silver, gold)
  /// - `is_available` (true, false)
  Future<void> setUserProperty(String name, String? value) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.setUserProperty(name: name, value: value);
      _logger.info('Analytics user property: $name = $value');
    } catch (e) {
      _logger.warning('Failed to set user property: $e');
    }
  }

  /// Convenience: set multiple user properties at once.
  Future<void> setUserProperties(Map<String, String?> properties) async {
    for (final entry in properties.entries) {
      await setUserProperty(entry.key, entry.value);
    }
  }

  /// Set the user's ID for analytics (pseudonymized).
  Future<void> setUserId(String? userId) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: userId);
      _logger.info('Analytics user ID: ${userId ?? "cleared"}');
    } catch (e) {
      _logger.warning('Failed to set user ID: $e');
    }
  }

  /// Clear all analytics user data (call on logout).
  Future<void> clearUserData() async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: null);
      _logger.info('Analytics user data cleared');
    } catch (e) {
      _logger.warning('Failed to clear analytics user data: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience Events
  // ---------------------------------------------------------------------------

  /// Log that a blood request was created.
  Future<void> logRequestCreated({
    required String bloodGroup,
    required int units,
    required String priority,
  }) async {
    await logEvent(
      'request_created',
      parameters: {
        'blood_group': bloodGroup,
        'units': units.toString(),
        'priority': priority,
      },
    );
  }

  /// Log that a blood request was accepted by a donor.
  Future<void> logRequestAccepted(String requestId) async {
    await logEvent('request_accepted', parameters: {'request_id': requestId});
  }

  /// Log that a donation was completed.
  Future<void> logDonationComplete({
    required int units,
    required String bloodGroup,
    String? hospitalName,
  }) async {
    final params = <String, dynamic>{
      'units': units.toString(),
      'blood_group': bloodGroup,
    };
    if (hospitalName != null) {
      params['hospital'] = hospitalName;
    }
    await logEvent('donation_complete', parameters: params);
  }

  /// Log a user registration/sign-up.
  Future<void> logSignUp({required String method}) async {
    await logEvent('sign_up', parameters: {'method': method});
  }

  /// Log a login event.
  Future<void> logLogin({required String method}) async {
    await logEvent('login', parameters: {'method': method});
  }

  /// Log a search action (e.g. donors, hospitals).
  Future<void> logSearch({
    required String searchTerm,
    required int resultCount,
    String? category,
  }) async {
    final params = <String, dynamic>{
      'search_term': searchTerm,
      'result_count': resultCount.toString(),
    };
    if (category != null) {
      params['category'] = category;
    }
    await logEvent('search', parameters: params);
  }

  /// Log that a push notification was received.
  Future<void> logNotificationReceived(String type) async {
    await logEvent('notification_received', parameters: {'type': type});
  }

  /// Log a generic error event.
  Future<void> logError({
    required String errorType,
    String? errorMessage,
  }) async {
    final params = <String, dynamic>{
      'error_type': errorType,
    };
    if (errorMessage != null) {
      params['error_message'] = errorMessage;
    }
    await logEvent('error', parameters: params);
  }
}

/// A GoRouter observer that automatically logs screen views to Analytics.
///
/// Attach this to your GoRouter to automatically track route changes:
/// ```dart
/// GoRouter(
///   observers: [AnalyticsScreenObserver()],
///   ...
/// )
/// ```
class AnalyticsScreenObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route.settings);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRoute(newRoute.settings);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackRoute(previousRoute.settings);
    }
  }

  void _trackRoute(RouteSettings settings) {
    final name = settings.name ?? settings.toString();
    final path = settings.name;

    AnalyticsService().logScreenView(
      _humanizeRouteName(name),
      screenClass: name,
      path: path,
    );
  }

  /// Convert a route path like `/auth/login` to a human name `Login`.
  String _humanizeRouteName(String name) {
    final segments = name.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return 'Unknown';

    final last = segments.last;

    // Convert kebab-case to Title Case
    return last
        .split(RegExp(r'[-_ ]'))
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }
}
