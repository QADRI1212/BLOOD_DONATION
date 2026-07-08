class UserSettings {
  final bool darkMode;
  final bool notificationsEnabled;
  final bool emergencyAlertsEnabled;
  final String language;

  const UserSettings({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.emergencyAlertsEnabled = true,
    this.language = 'en',
  });

  UserSettings copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? emergencyAlertsEnabled,
    String? language,
  }) {
    return UserSettings(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emergencyAlertsEnabled: emergencyAlertsEnabled ?? this.emergencyAlertsEnabled,
      language: language ?? this.language,
    );
  }
}

abstract class SettingsRepository {
  Future<UserSettings> getSettings(String userId);

  Future<void> updateSettings(String userId, UserSettings settings);

  Future<void> toggleDarkMode(String userId, bool enabled);

  Future<void> toggleNotifications(String userId, bool enabled);
}
