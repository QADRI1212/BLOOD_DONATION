import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../network/supabase_client.dart';
import '../services/logger_service.dart';

// ──────────────────────────────────────────────────────────────
// Top-level helper functions for notification channels
// These are extracted so the background handler can use them
// without depending on the NotificationService class.
// ──────────────────────────────────────────────────────────────

String channelIdForType(String type) {
  switch (type) {
    case 'emergency':
      return 'emergency_alerts';
    case 'reminder':
      return 'reminders';
    case 'announcement':
      return 'announcements';
    default:
      return 'general';
  }
}

String channelNameForType(String type) {
  switch (type) {
    case 'emergency':
      return 'Emergency Alerts';
    case 'reminder':
      return 'Reminders';
    case 'announcement':
      return 'Announcements';
    default:
      return 'General';
  }
}

String channelDescriptionForType(String type) {
  switch (type) {
    case 'emergency':
      return 'Time-sensitive emergency blood request alerts';
    case 'reminder':
      return 'Donation eligibility reminders and check-ins';
    case 'announcement':
      return 'Platform announcements and updates';
    default:
      return 'General notifications about your activity';
  }
}

int colorForNotificationType(String type) {
  switch (type) {
    case 'emergency':
      return 0xFFDC2626; // Red
    case 'reminder':
      return 0xFFF59E0B; // Amber
    case 'announcement':
      return 0xFF3B82F6; // Blue
    default:
      return 0xFFDC2626; // Primary red
  }
}

String iconForType(String type) {
  switch (type) {
    case 'emergency':
      return 'ic_emergency';
    case 'reminder':
      return 'ic_reminder';
    case 'announcement':
      return 'ic_announcement';
    default:
      return 'ic_notification';
  }
}

/// Background message handler — called when a push notification arrives
/// while the app is in the background or terminated.
///
/// This creates a local notification via [flutter_local_notifications]
/// so that push notifications are displayed even when the app is closed.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = LoggerService();
  logger.info('Background message received: ${message.messageId}');

  try {
    // Initialize flutter_local_notifications to show the notification
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Extract notification details from the message
    final notification = message.notification;
    final data = message.data;

    if (notification == null) {
      logger.warning('Background message has no notification payload');
      return;
    }

    final type = data['type'] ?? 'general';
    final channelId = channelIdForType(type);
    final channelName = channelNameForType(type);
    final channelDescription = channelDescriptionForType(type);
    final importance = type == 'emergency' ? Importance.max : Importance.high;
    final priority = type == 'emergency' ? Priority.max : Priority.high;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      color: Color(colorForNotificationType(type)),
      icon: iconForType(type),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title ?? 'Blood Donor Network',
      notification.body ?? '',
      details,
      payload: data['route'],
    );

    logger.info('Background notification displayed: ${notification.title}');
  } catch (e, stack) {
    logger.error('Failed to show background notification', error: e, stackTrace: stack);
  }
}

/// Callback type for when a notification is tapped with a route
typedef NotificationTapCallback = void Function(String? route, Map<String, String> data);

class NotificationService {
  static NotificationService? _instance;
  final LoggerService _logger = LoggerService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging? _messaging;
  bool _initialized = false;
  String? _fcmToken;

  /// Callback to handle navigation when notification is tapped
  NotificationTapCallback? onNotificationTap;

  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();

  /// Stream of notification routes from taps (for deep linking)
  final StreamController<String?> _routeController =
      StreamController<String?>.broadcast();

  NotificationService._internal();

  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  /// Stream of incoming push messages (foreground)
  Stream<RemoteMessage> get messageStream => _messageController.stream;

  /// Stream of routes from notification taps (for navigation after background/terminated)
  Stream<String?> get routeStream => _routeController.stream;

  /// The current FCM device token
  String? get fcmToken => _fcmToken;

  /// Whether the service has been initialized
  bool get isInitialized => _initialized;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _logger.info('Initializing notification service...');

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Create notification channels first
      await createNotificationChannels();

      // Request notification permissions (iOS)
      await _requestPermissions();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Get FCM token
      await _refreshToken();

      // Listen for token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _logger.info('FCM token refreshed');
        _uploadTokenToSupabase(newToken);
      });

      // Initialize local notifications
      await _initLocalNotifications();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Handle notification taps when app was in background
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      // Check if app was opened from a terminated notification
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _logger.info('App opened from terminated notification');
        final route = initialMessage.data['route'];
        _routeController.add(route);
        _onMessageOpened(initialMessage);
      }

      _initialized = true;
      _logger.info('Notification service initialized');
    } catch (e, stack) {
      _logger.error('Failed to initialize notification service',
          error: e, stackTrace: stack);
      // Don't throw - notifications are non-critical
    }
  }

  /// Refresh the FCM token
  Future<void> _refreshToken() async {
    try {
      _fcmToken = await _messaging!.getToken();
      if (_fcmToken != null) {
        _logger.info('FCM token obtained');
      }
    } catch (e) {
      _logger.warning('Failed to get FCM token: $e');
    }
  }

  /// Upload the FCM token to user's profile in Supabase
  Future<void> _uploadTokenToSupabase(String token) async {
    try {
      final supabase = SupabaseClientService();
      final user = supabase.currentUser;
      if (user != null) {
        await supabase.client
            .from('profiles')
            .update({'fcm_token': token, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', user.id);
        _logger.info('FCM token uploaded to Supabase');
      }
    } catch (e) {
      _logger.warning('Failed to upload FCM token: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      _logger.info(
          'Notification permissions: ${settings.authorizationStatus.name}');
    } catch (e) {
      _logger.warning('Failed to request notification permissions: $e');
    }
  }

  /// Initialize local notifications for displaying in-app notifications
  Future<void> _initLocalNotifications() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          _logger.info('Local notification tapped: ${response.payload}');
          _routeController.add(response.payload);
        },
      );

      _logger.info('Local notifications initialized');
    } catch (e) {
      _logger.warning('Failed to initialize local notifications: $e');
    }
  }

  /// Handle foreground message - show local notification
  void _onForegroundMessage(RemoteMessage message) {
    _logger.info('Foreground message received: ${message.messageId}');
    _showLocalNotification(message);
    _messageController.add(message);
  }

  /// Handle notification tap when app was in background
  void _onMessageOpened(RemoteMessage message) {
    _logger.info('Message opened from background: ${message.messageId}');
    final route = message.data['route'];
    final data = Map<String, String>.from(message.data);
    _routeController.add(route);
    _messageController.add(message);

    // Also call the navigation callback if set
    onNotificationTap?.call(route, data);
  }

  /// Show a local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      if (notification == null) return;

      // Determine the correct channel based on notification type
      final type = data['type'] ?? 'general';
      final channelId = _getChannelId(type);
      final channelName = _getChannelName(type);
      final importance = type == 'emergency' ? Importance.max : Importance.high;
      final priority = type == 'emergency' ? Priority.max : Priority.high;

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: _getChannelDescription(type),
        importance: importance,
        priority: priority,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        color: Color(_getColorForType(type)),
        icon: _getIconForType(type),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notification.title ?? 'Blood Donor Network',
        notification.body ?? '',
        details,
        payload: data['route'],
      );
    } catch (e) {
      _logger.warning('Failed to show local notification: $e');
    }
  }

  /// Get the channel ID for a notification type
  String _getChannelId(String type) => channelIdForType(type);

  /// Get the channel display name for a notification type
  String _getChannelName(String type) => channelNameForType(type);

  /// Get the channel description for a notification type
  String _getChannelDescription(String type) => channelDescriptionForType(type);

  /// Get the notification color for a type (Android color value)
  int _getColorForType(String type) => colorForNotificationType(type);

  /// Get the small icon for a notification type
  String _getIconForType(String type) => iconForType(type);

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging!.subscribeToTopic(topic);
      _logger.info('Subscribed to topic: $topic');
    } catch (e, stack) {
      _logger.error('Failed to subscribe to topic: $topic',
          error: e, stackTrace: stack);
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging!.unsubscribeFromTopic(topic);
      _logger.info('Unsubscribed from topic: $topic');
    } catch (e, stack) {
      _logger.error('Failed to unsubscribe from topic: $topic',
          error: e, stackTrace: stack);
    }
  }

  /// Subscribe to emergency alerts based on user's blood group and location
  Future<void> subscribeToEmergencyAlerts(String bloodGroup) async {
    await subscribeToTopic('emergency');
    await subscribeToTopic('blood_group_${bloodGroup.replaceAll('+', 'p').replaceAll('-', 'n')}');
  }

  /// Create notification channels for Android O+
  Future<void> createNotificationChannels() async {
    try {
      final plugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (plugin == null) return; // not Android

      // Emergency alert channel (highest priority, bypasses DND)
      const emergencyChannel = AndroidNotificationChannel(
        'emergency_alerts',
        'Emergency Alerts',
        description: 'Time-sensitive emergency blood request alerts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await plugin.createNotificationChannel(emergencyChannel);

      // Reminders channel
      const remindersChannel = AndroidNotificationChannel(
        'reminders',
        'Reminders',
        description: 'Donation eligibility reminders and check-ins',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await plugin.createNotificationChannel(remindersChannel);

      // Announcements channel
      const announcementsChannel = AndroidNotificationChannel(
        'announcements',
        'Announcements',
        description: 'Platform announcements and updates',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: false,
      );
      await plugin.createNotificationChannel(announcementsChannel);

      // General channel
      const generalChannel = AndroidNotificationChannel(
        'general',
        'General',
        description: 'General notifications about your activity',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: false,
      );
      await plugin.createNotificationChannel(generalChannel);

      _logger.info('Android notification channels created');
    } catch (e) {
      _logger.warning('Failed to create notification channels: $e');
    }
  }

  /// Handle a navigation route string (e.g., from notification tap)
  void handleNavigationRoute(String? route, BuildContext context) {
    if (route == null || route.isEmpty) return;
    try {
      context.go(route);
    } catch (e) {
      _logger.warning('Failed to navigate to route: $route, error: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _messageController.close();
    _routeController.close();
  }
}
