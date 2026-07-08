import './settings_repository.dart';

class UserSettingsDto {
  final bool darkMode;
  final bool notificationsEnabled;
  final bool emergencyAlertsEnabled;
  final String language;

  const UserSettingsDto({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.emergencyAlertsEnabled = true,
    this.language = 'en',
  });

  factory UserSettingsDto.fromJson(Map<String, dynamic> map) {
    return UserSettingsDto(
      darkMode: map['dark_mode'] as bool? ?? false,
      notificationsEnabled: map['notification_enabled'] as bool? ?? true,
      emergencyAlertsEnabled: map['emergency_alerts_enabled'] as bool? ?? true,
      language: map['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dark_mode': darkMode,
      'notification_enabled': notificationsEnabled,
      'emergency_alerts_enabled': emergencyAlertsEnabled,
      'language': language,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  UserSettings toDomain() {
    return UserSettings(
      darkMode: darkMode,
      notificationsEnabled: notificationsEnabled,
      emergencyAlertsEnabled: emergencyAlertsEnabled,
      language: language,
    );
  }
}
