import '../../../core/network/api_service.dart';
import './settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final ApiService _api;

  SettingsRepositoryImpl(this._api);

  @override
  Future<UserSettings> getSettings(String userId) async {
    final data = await _api.querySingle('user_settings', 'user_id', userId);
    if (data == null) return const UserSettings();
    return UserSettings(
      darkMode: data['dark_mode'] as bool? ?? false,
      notificationsEnabled: data['notifications_enabled'] as bool? ?? true,
      emergencyAlertsEnabled: data['emergency_alerts_enabled'] as bool? ?? true,
      language: data['language'] as String? ?? 'en',
    );
  }

  @override
  Future<void> updateSettings(String userId, UserSettings settings) async {
    await _api.update('user_settings', {
      'dark_mode': settings.darkMode,
      'notifications_enabled': settings.notificationsEnabled,
      'emergency_alerts_enabled': settings.emergencyAlertsEnabled,
      'language': settings.language,
    }, 'user_id', userId);
  }

  @override
  Future<void> toggleDarkMode(String userId, bool enabled) async {
    await _api.update(
      'user_settings',
      {'dark_mode': enabled},
      'user_id',
      userId,
    );
  }

  @override
  Future<void> toggleNotifications(String userId, bool enabled) async {
    await _api.update(
      'user_settings',
      {'notifications_enabled': enabled},
      'user_id',
      userId,
    );
  }
}
