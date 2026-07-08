import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/services/logger_service.dart';

/// Current locale code (e.g. 'en', 'hi').
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  final LocalStorageService _storage = LocalStorageService();
  final LoggerService _logger = LoggerService();

  LocaleNotifier() : super('en') {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final saved = _storage.getString('language_code');
      if (saved != null && ['en', 'hi', 'ur'].contains(saved)) {
        state = saved;
        _logger.info('Loaded saved locale: $saved');
      }
    } catch (e) {
      _logger.warning('Failed to load saved locale, using English');
      state = 'en';
    }
  }

  Future<void> setLocale(String code) async {
    state = code;
    try {
      await _storage.setString('language_code', code);
      _logger.info('Locale set to: $code');
    } catch (e) {
      _logger.error('Failed to save locale preference', error: e);
    }
  }
}
