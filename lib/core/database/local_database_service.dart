import 'package:hive_flutter/hive_flutter.dart';
import '../services/logger_service.dart';

class LocalDatabaseService {
  static LocalDatabaseService? _instance;
  final LoggerService _logger = LoggerService();

  LocalDatabaseService._internal();

  factory LocalDatabaseService() {
    _instance ??= LocalDatabaseService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _logger.info('Hive initialized successfully');
    } catch (e, stack) {
      _logger.error('Failed to initialize Hive', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<Box<T>> openBox<T>(String name) async {
    try {
      return await Hive.openBox<T>(name);
    } catch (e, stack) {
      _logger.error('Failed to open Hive box: $name', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> put<T>(String boxName, String key, T value) async {
    final box = await openBox<T>(boxName);
    await box.put(key, value);
  }

  Future<T?> get<T>(String boxName, String key) async {
    final box = await openBox<T>(boxName);
    return box.get(key);
  }

  Future<List<T>> getAll<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    return box.values.toList();
  }

  Future<void> delete(String boxName, String key) async {
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }

  Future<void> clear(String boxName) async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }

  Future<void> close() async {
    await Hive.close();
  }
}
