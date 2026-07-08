import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../services/settings_repository.dart';
import '../services/settings_remote_datasource.dart';

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSource(ref.read(cachedApiServiceProvider));
});

class SettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  final SettingsRemoteDataSource _dataSource;
  final String _userId;

  SettingsNotifier(this._dataSource, this._userId)
      : super(const AsyncValue.data(UserSettings())) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _dataSource.getSettings(_userId);
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleDarkMode(bool enabled) async {
    try {
      await _dataSource.toggleDarkMode(_userId, enabled);
      final current = state.valueOrNull ?? const UserSettings();
      state = AsyncValue.data(current.copyWith(darkMode: enabled));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    try {
      await _dataSource.toggleNotifications(_userId, enabled);
      final current = state.valueOrNull ?? const UserSettings();
      state = AsyncValue.data(current.copyWith(notificationsEnabled: enabled));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleLanguage(String languageCode) async {
    try {
      await _dataSource.toggleLanguage(_userId, languageCode);
      final current = state.valueOrNull ?? const UserSettings();
      state = AsyncValue.data(current.copyWith(language: languageCode));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings(UserSettings settings) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.updateSettings(_userId, settings);
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final settingsProvider = StateNotifierProvider.family<SettingsNotifier, AsyncValue<UserSettings>, String>((ref, userId) {
  return SettingsNotifier(ref.read(settingsRemoteDataSourceProvider), userId);
});
