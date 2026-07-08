import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../services/logger_service.dart';

class SupabaseClientService {
  static SupabaseClientService? _instance;
  final LoggerService _logger = LoggerService();

  SupabaseClientService._internal();

  factory SupabaseClientService() {
    _instance ??= SupabaseClientService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      _logger.info('Supabase initialized successfully');
    } catch (e, stack) {
      _logger.error('Failed to initialize Supabase', error: e, stackTrace: stack);
      rethrow;
    }
  }

  SupabaseClient get client => Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  SupabaseQueryBuilder get profiles => client.from('profiles');

  SupabaseQueryBuilder get bloodRequests => client.from('blood_requests');

  SupabaseQueryBuilder get donations => client.from('donations');

  SupabaseQueryBuilder get hospitals => client.from('hospitals');

  SupabaseQueryBuilder get bloodBanks => client.from('blood_banks');

  SupabaseQueryBuilder get notifications => client.from('notifications');

  SupabaseQueryBuilder get userSettings => client.from('user_settings');

  SupabaseQueryBuilder get announcements => client.from('announcements');

  SupabaseQueryBuilder get reports => client.from('reports');

  RealtimeClient get realtime => client.realtime;

  SupabaseStorageClient get storage => client.storage;

  User? get currentUser => auth.currentUser;

  bool get isAuthenticated => currentUser != null;
}
