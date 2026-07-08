import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../core/services/logger_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/crashlytics_service.dart';
import '../core/database/local_database_service.dart';
import '../core/database/cache_manager.dart';
import '../core/network/supabase_client.dart';
import '../core/network/connectivity_service.dart';

class AppInitializer {
  final LoggerService _logger = LoggerService();
  final SupabaseClientService _supabase = SupabaseClientService();
  final ConnectivityService _connectivity = ConnectivityService();
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final CacheManager _cacheManager = CacheManager();
  final AnalyticsService _analytics = AnalyticsService();
  final CrashlyticsService _crashlytics = CrashlyticsService();

  Future<void> initialize() async {
    try {
      _logger.info('Starting app initialization...');

      // Load environment variables
      await _loadEnvironment();

      // Set preferred orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // Initialize Firebase core (must be before any Firebase service)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Crashlytics (before other services to catch init errors)
      await _crashlytics.initialize();

      // Initialize Analytics
      await _analytics.initialize();

      // Initialize local database (Hive)
      await _localDb.initialize();

      // Initialize cache manager
      await _cacheManager.initialize();

      // Initialize Supabase
      await _supabase.initialize();

      // Initialize connectivity monitoring
      await _connectivity.initialize();

      // Initialize push notifications
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Set user IDs for crash reporting + analytics if already authenticated
      final user = _supabase.currentUser;
      if (user != null) {
        await _crashlytics.setUserId(user.id);
        await _analytics.setUserId(user.id);
      }

      _logger.info('App initialization completed successfully');
      await _crashlytics.log('App initialized successfully');
    } catch (e, stack) {
      _logger.error('App initialization failed', error: e, stackTrace: stack);
      await _crashlytics.recordError(e, stack, context: 'App initialization');
      rethrow;
    }
  }

  Future<void> _loadEnvironment() async {
    try {
      await dotenv.load(fileName: '.env');
      _logger.info('Environment variables loaded');
    } catch (e) {
      _logger.warning('Failed to load .env file, using defaults');
    }
  }

  ConnectivityService get connectivityService => _connectivity;
  CacheManager get cacheManager => _cacheManager;
  CrashlyticsService get crashlytics => _crashlytics;

  void dispose() {
    _connectivity.dispose();
  }
}
