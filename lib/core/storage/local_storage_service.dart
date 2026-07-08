import 'package:shared_preferences/shared_preferences.dart';
import '../services/logger_service.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  final LoggerService _logger = LoggerService();
  SharedPreferences? _prefs;

  LocalStorageService._internal();

  factory LocalStorageService() {
    _instance ??= LocalStorageService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.info('SharedPreferences initialized');
    } catch (e, stack) {
      _logger.error('Failed to initialize SharedPreferences', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<bool> setString(String key, String value) async {
    return (await _ensurePrefs()).setString(key, value);
  }

  String? getString(String key) => _prefs?.getString(key);

  Future<bool> setBool(String key, bool value) async {
    return (await _ensurePrefs()).setBool(key, value);
  }

  bool? getBool(String key) => _prefs?.getBool(key);

  Future<bool> setInt(String key, int value) async {
    return (await _ensurePrefs()).setInt(key, value);
  }

  int? getInt(String key) => _prefs?.getInt(key);

  Future<bool> setDouble(String key, double value) async {
    return (await _ensurePrefs()).setDouble(key, value);
  }

  double? getDouble(String key) => _prefs?.getDouble(key);

  Future<bool> remove(String key) async {
    return (await _ensurePrefs()).remove(key);
  }

  Future<bool> clear() async {
    return (await _ensurePrefs()).clear();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
