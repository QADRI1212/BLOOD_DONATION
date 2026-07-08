import 'dart:convert';
import '../services/logger_service.dart';
import 'local_database_service.dart';

/// Manages offline caching of API data using Hive.
///
/// Stores data as JSON strings in named Hive boxes.
/// Each box represents a table/collection (e.g. 'profiles', 'hospitals').
/// Keys are the record IDs, values are JSON-encoded maps.
class CacheManager {
  static CacheManager? _instance;
  final LoggerService _logger = LoggerService();
  final LocalDatabaseService _db = LocalDatabaseService();

  static const String _profilesBox = 'cached_profiles';
  static const String _hospitalsBox = 'cached_hospitals';
  static const String _bloodBanksBox = 'cached_blood_banks';
  static const String _requestsBox = 'cached_requests';
  static const String _notificationsBox = 'cached_notifications';
  static const String _settingsBox = 'cached_settings';
  static const String _donationsBox = 'cached_donations';
  static const String _metaBox = 'cache_meta';

  CacheManager._internal();

  factory CacheManager() {
    _instance ??= CacheManager._internal();
    return _instance!;
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    try {
      // Open all boxes so they're ready for use
      await Future.wait([
        _db.openBox<String>(_profilesBox),
        _db.openBox<String>(_hospitalsBox),
        _db.openBox<String>(_bloodBanksBox),
        _db.openBox<String>(_requestsBox),
        _db.openBox<String>(_notificationsBox),
        _db.openBox<String>(_settingsBox),
        _db.openBox<String>(_donationsBox),
        _db.openBox<String>(_metaBox),
      ]);
      _logger.info('CacheManager initialized with all boxes');
    } catch (e, stack) {
      _logger.error('Failed to initialize CacheManager', error: e, stackTrace: stack);
    }
  }

  // ---------------------------------------------------------------------------
  // Generic cache helpers
  // ---------------------------------------------------------------------------

  /// Cache a single record as JSON.
  Future<void> putRecord(String boxName, String id, Map<String, dynamic> record) async {
    try {
      await _db.put(boxName, id, jsonEncode(record));
    } catch (e) {
      _logger.warning('Failed to cache record $id in $boxName: $e');
    }
  }

  /// Retrieve a single cached record.
  Future<Map<String, dynamic>?> getRecord(String boxName, String id) async {
    try {
      final raw = await _db.get<String>(boxName, id);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      _logger.warning('Failed to read cached record $id from $boxName: $e');
      return null;
    }
  }

  /// Cache a list of records, keyed by their 'id' field.
  Future<void> putRecords(String boxName, List<Map<String, dynamic>> records) async {
    try {
      for (final record in records) {
        final id = record['id'] as String?;
        if (id != null) {
          await _db.put(boxName, id, jsonEncode(record));
        }
      }
    } catch (e) {
      _logger.warning('Failed to cache records in $boxName: $e');
    }
  }

  /// Retrieve all cached records from a box.
  Future<List<Map<String, dynamic>>> getAllRecords(String boxName) async {
    try {
      final rawItems = await _db.getAll<String>(boxName);
      return rawItems
          .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _logger.warning('Failed to read all records from $boxName: $e');
      return [];
    }
  }

  /// Remove a record from cache.
  Future<void> removeRecord(String boxName, String id) async {
    try {
      await _db.delete(boxName, id);
    } catch (e) {
      _logger.warning('Failed to remove cached record $id from $boxName: $e');
    }
  }

  /// Clear an entire cache box.
  Future<void> clearBox(String boxName) async {
    try {
      await _db.clear(boxName);
    } catch (e) {
      _logger.warning('Failed to clear box $boxName: $e');
    }
  }

  /// Clear all cached data (e.g. on logout).
  Future<void> clearAll() async {
    try {
      await Future.wait([
        clearBox(_profilesBox),
        clearBox(_hospitalsBox),
        clearBox(_bloodBanksBox),
        clearBox(_requestsBox),
        clearBox(_notificationsBox),
        clearBox(_settingsBox),
        clearBox(_donationsBox),
        clearBox(_metaBox),
      ]);
      _logger.info('All cache boxes cleared');
    } catch (e) {
      _logger.error('Failed to clear all cache boxes', error: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Profiles
  // ---------------------------------------------------------------------------

  Future<void> cacheProfile(Map<String, dynamic> profile) =>
      putRecord(_profilesBox, profile['id'] as String, profile);

  Future<void> cacheProfiles(List<Map<String, dynamic>> profiles) =>
      putRecords(_profilesBox, profiles);

  Future<Map<String, dynamic>?> getCachedProfile(String id) =>
      getRecord(_profilesBox, id);

  Future<List<Map<String, dynamic>>> getCachedProfiles() =>
      getAllRecords(_profilesBox);

  // ---------------------------------------------------------------------------
  // Hospitals
  // ---------------------------------------------------------------------------

  Future<void> cacheHospital(Map<String, dynamic> hospital) =>
      putRecord(_hospitalsBox, hospital['id'] as String, hospital);

  Future<void> cacheHospitals(List<Map<String, dynamic>> hospitals) =>
      putRecords(_hospitalsBox, hospitals);

  Future<Map<String, dynamic>?> getCachedHospital(String id) =>
      getRecord(_hospitalsBox, id);

  Future<List<Map<String, dynamic>>> getCachedHospitals() =>
      getAllRecords(_hospitalsBox);

  // ---------------------------------------------------------------------------
  // Blood Banks
  // ---------------------------------------------------------------------------

  Future<void> cacheBloodBanks(List<Map<String, dynamic>> banks) =>
      putRecords(_bloodBanksBox, banks);

  Future<List<Map<String, dynamic>>> getCachedBloodBanks() =>
      getAllRecords(_bloodBanksBox);

  // ---------------------------------------------------------------------------
  // Blood Requests
  // ---------------------------------------------------------------------------

  Future<void> cacheRequests(List<Map<String, dynamic>> requests) =>
      putRecords(_requestsBox, requests);

  Future<List<Map<String, dynamic>>> getCachedRequests() =>
      getAllRecords(_requestsBox);

  Future<void> removeCachedRequest(String id) =>
      removeRecord(_requestsBox, id);

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  Future<void> cacheNotifications(List<Map<String, dynamic>> notifications) =>
      putRecords(_notificationsBox, notifications);

  Future<List<Map<String, dynamic>>> getCachedNotifications() =>
      getAllRecords(_notificationsBox);

  Future<void> removeCachedNotification(String id) =>
      removeRecord(_notificationsBox, id);

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<void> cacheSettings(Map<String, dynamic> settings) =>
      putRecord(_settingsBox, 'my_settings', settings);

  Future<Map<String, dynamic>?> getCachedSettings() =>
      getRecord(_settingsBox, 'my_settings');

  // ---------------------------------------------------------------------------
  // Donations
  // ---------------------------------------------------------------------------

  Future<void> cacheDonations(List<Map<String, dynamic>> donations) =>
      putRecords(_donationsBox, donations);

  Future<List<Map<String, dynamic>>> getCachedDonations() =>
      getAllRecords(_donationsBox);

  Future<void> removeCachedDonation(String id) =>
      removeRecord(_donationsBox, id);

  // ---------------------------------------------------------------------------
  // Cache invalidation / TTL
  // ---------------------------------------------------------------------------

  /// Set the timestamp for when a box was last refreshed from the server.
  Future<void> setLastRefresh(String boxName) async {
    try {
      await _db.put(_metaBox, '${boxName}_refreshed_at',
          DateTime.now().toIso8601String());
    } catch (e) {
      _logger.warning('Failed to set refresh timestamp for $boxName: $e');
    }
  }

  /// Get the timestamp of the last refresh.
  Future<DateTime?> getLastRefresh(String boxName) async {
    try {
      final raw = await _db.get<String>(_metaBox, '${boxName}_refreshed_at');
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    } catch (e) {
      return null;
    }
  }

  /// Check whether a cache box is stale (older than [ttlMinutes]).
  Future<bool> isStale(String boxName, {int ttlMinutes = 30}) async {
    try {
      final raw = await _db.get<String>(_metaBox, '${boxName}_refreshed_at');
      if (raw == null) return true;
      final lastRefresh = DateTime.tryParse(raw);
      if (lastRefresh == null) return true;
      return DateTime.now().difference(lastRefresh).inMinutes > ttlMinutes;
    } catch (e) {
      return true;
    }
  }

  /// Get the total size estimate of all cached data.
  Future<int> getCacheSizeBytes() async {
    try {
      final allBoxes = [
        _profilesBox,
        _hospitalsBox,
        _bloodBanksBox,
        _requestsBox,
        _notificationsBox,
        _settingsBox,
        _donationsBox,
      ];
      int total = 0;
      for (final boxName in allBoxes) {
        final items = await _db.getAll<String>(boxName);
        for (final item in items) {
          total += item.length;
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }
}
