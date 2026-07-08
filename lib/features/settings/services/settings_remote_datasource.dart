import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import './settings_repository.dart';
import './user_settings_dto.dart';

class SettingsRemoteDataSource {
  static const String _cacheBox = 'cached_settings';
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  SettingsRemoteDataSource(this._api);

  Future<UserSettings> getSettings(String userId) async {
    try {
      final data = await _api.querySingle('user_settings', 'user_id', userId,
        cacheBox: _cacheBox,
      );
      if (data == null) {
        return const UserSettings();
      }
      return UserSettingsDto.fromJson(data).toDomain();
    } catch (e, stack) {
      _logger.error('Failed to get settings', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> updateSettings(String userId, UserSettings settings) async {
    try {
      final dto = UserSettingsDto(
        darkMode: settings.darkMode,
        notificationsEnabled: settings.notificationsEnabled,
        emergencyAlertsEnabled: settings.emergencyAlertsEnabled,
        language: settings.language,
      );
      await _api.update('user_settings', dto.toJson(), 'user_id', userId);
    } catch (e, stack) {
      _logger.error('Failed to update settings', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> toggleDarkMode(String userId, bool enabled) async {
    try {
      await _api.update(
        'user_settings',
        {'dark_mode': enabled},
        'user_id',
        userId,
      );
    } catch (e, stack) {
      _logger.error('Failed to toggle dark mode', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> toggleNotifications(String userId, bool enabled) async {
    try {
      await _api.update(
        'user_settings',
        {'notification_enabled': enabled},
        'user_id',
        userId,
      );
    } catch (e, stack) {
      _logger.error('Failed to toggle notifications', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> toggleLanguage(String userId, String languageCode) async {
    try {
      await _api.update(
        'user_settings',
        {'language': languageCode},
        'user_id',
        userId,
      );
    } catch (e, stack) {
      _logger.error('Failed to update language', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
