import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key';

  static String get appName => 'Blood Donor Network';

  static String get appVersion => '1.0.0';

  static bool get isProduction =>
      dotenv.env['APP_ENV'] == 'production';

  static bool get isStaging => dotenv.env['APP_ENV'] == 'staging';

  static bool get isDevelopment => !isProduction && !isStaging;
}
