import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/services/logger_service.dart';

/// Provider to read the current theme mode without writing
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService _storage = LocalStorageService();
  final LoggerService _logger = LoggerService();

  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final isDark = _storage.getBool('dark_mode') ?? false;
      state = isDark ? ThemeMode.dark : ThemeMode.light;
      _logger.info('Loaded saved theme: ${isDark ? "dark" : "light"}');
    } catch (e) {
      _logger.warning('Failed to load saved theme, using light mode');
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;

    try {
      await _storage.setBool('dark_mode', newMode == ThemeMode.dark);
      _logger.info('Theme toggled to: ${newMode == ThemeMode.dark ? "dark" : "light"}');
    } catch (e) {
      _logger.error('Failed to save theme preference', error: e);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      await _storage.setBool('dark_mode', mode == ThemeMode.dark);
    } catch (e) {
      _logger.error('Failed to save theme preference', error: e);
    }
  }
}
