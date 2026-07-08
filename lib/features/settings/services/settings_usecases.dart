import './settings_repository.dart';

class SettingsUseCases {
  final SettingsRepository _repository;

  SettingsUseCases(this._repository);

  Future<UserSettings> getSettings(String userId) {
    return _repository.getSettings(userId);
  }

  Future<void> updateSettings(String userId, UserSettings settings) {
    return _repository.updateSettings(userId, settings);
  }

  Future<void> toggleDarkMode(String userId, bool enabled) {
    return _repository.toggleDarkMode(userId, enabled);
  }

  Future<void> toggleNotifications(String userId, bool enabled) {
    return _repository.toggleNotifications(userId, enabled);
  }
}
