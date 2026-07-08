class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Blood Donor Network';
  static const String appTagline = 'Save Lives, Donate Blood';

  // Donation Eligibility
  static const int minimumDonationAge = 18;
  static const int maximumDonationAge = 65;
  static const double minimumWeightKg = 50.0;
  static const int donationIntervalDays = 56; // 8 weeks for whole blood
  static const int donationIntervalMaleDays = 90; // 3 months
  static const int donationIntervalFemaleDays = 120; // 4 months

  // Distance
  static const double defaultSearchRadiusKm = 25.0;
  static const double maxSearchRadiusKm = 100.0;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Location
  static const String defaultLatLng = '28.6139,77.2090'; // New Delhi

  // Timeouts
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;

  // Debounce
  static const int searchDebounceMs = 500;

  // OAuth
  static const String oauthRedirectUrl = 'com.example.blood_donation://auth/callback';

  // Cache Keys
  static const String cachedDonorsKey = 'cached_donors';
  static const String cachedHospitalsKey = 'cached_hospitals';
  static const String cachedBloodBanksKey = 'cached_blood_banks';
  static const String cachedNotificationsKey = 'cached_notifications';
  static const String cachedRequestsKey = 'cached_requests';

  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String introCompletedKey = 'intro_completed';
}
