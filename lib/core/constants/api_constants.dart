class ApiConstants {
  ApiConstants._();

  // Supabase Tables
  static const String profilesTable = 'profiles';
  static const String bloodRequestsTable = 'blood_requests';
  static const String donationsTable = 'donations';
  static const String hospitalsTable = 'hospitals';
  static const String bloodBanksTable = 'blood_banks';
  static const String notificationsTable = 'notifications';
  static const String userSettingsTable = 'user_settings';
  static const String announcementsTable = 'announcements';
  static const String reportsTable = 'reports';

  // Storage Buckets
  static const String profileImagesBucket = 'profile_images';
  static const String hospitalImagesBucket = 'hospital_images';
  static const String documentsBucket = 'documents';

  // Realtime Channels
  static const String emergencyChannel = 'emergency_requests';
  static const String donorChannel = 'donor_updates';
}
