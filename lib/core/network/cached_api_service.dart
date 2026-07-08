import '../database/cache_manager.dart';
import '../network/connectivity_service.dart';
import '../services/logger_service.dart';
import 'api_service.dart';

/// A service that wraps [ApiService] with automatic offline-first caching.
///
/// On success: data is cached to Hive via [CacheManager].
/// On failure (network error): cached data is returned as fallback.
/// On failure (no cache): the original exception is rethrown.
class CachedApiService {
  final ApiService _api;
  final CacheManager _cache;
  final ConnectivityService _connectivity;
  final LoggerService _logger = LoggerService();

  CachedApiService({
    required ApiService apiService,
    required CacheManager cacheManager,
    required ConnectivityService connectivityService,
  })  : _api = apiService,
        _cache = cacheManager,
        _connectivity = connectivityService;

  /// Query a table with offline caching support.
  ///
  /// [cacheBox] - the Hive box name to cache in (e.g. 'cached_hospitals').
  /// If null, caching is skipped and the raw API is used.
  ///
  /// **SAFETY NOTE:** Real-time / safety-critical tables (e.g. `blood_requests`)
  /// must NEVER pass a [cacheBox] — stale emergency data can cost lives.
  static const _noCacheTables = {'blood_requests'};

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? cacheBox,
    String? column,
    dynamic value,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    // Safety guard: never allow caching of real-time emergency data.
    assert(
      cacheBox == null || !_noCacheTables.contains(table),
      'CachedApiService: table "$table" must not be cached (real-time safety-critical data).',
    );
    if (_noCacheTables.contains(table)) {
      return _api.query(
        table,
        column: column,
        value: value,
        filters: filters,
        orderBy: orderBy,
        ascending: ascending,
        limit: limit,
        offset: offset,
      );
    }

    try {
      final data = await _api.query(
        table,
        column: column,
        value: value,
        filters: filters,
        orderBy: orderBy,
        ascending: ascending,
        limit: limit,
        offset: offset,
      );

      // Cache on success
      if (cacheBox != null) {
        await _cache.putRecords(cacheBox, data);
        await _cache.setLastRefresh(cacheBox);
      }

      return data;
    } catch (e) {
      // On failure, try to return cached data if offline
      final isOnline = await _connectivity.checkConnectivity();
      if (!isOnline && cacheBox != null) {
        final cached = await _cache.getAllRecords(cacheBox);
        if (cached.isNotEmpty) {
          _logger.info('Returning ${cached.length} cached records from $cacheBox (offline)');
          return cached;
        }
      }
      rethrow;
    }
  }


  /// Query a single record with offline caching.
  Future<Map<String, dynamic>?> querySingle(
    String table,
    String column,
    dynamic value, {
    String? cacheBox,
  }) async {
    try {
      final data = await _api.querySingle(table, column, value);

      // Cache single record
      if (cacheBox != null && data != null) {
        await _cache.putRecord(cacheBox, value.toString(), data);
      }

      return data;
    } catch (e) {
      // Fall back to cached single record
      if (cacheBox != null) {
        final cached = await _cache.getRecord(cacheBox, value.toString());
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Passthrough methods (no caching needed for writes)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) =>
      _api.insert(table, data);

  Future<List<Map<String, dynamic>>> insertAll(
          String table, List<Map<String, dynamic>> data) =>
      _api.insertAll(table, data);

  Future<void> update(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) =>
      _api.update(table, data, column, value);

  Future<void> delete(String table, String column, dynamic value) =>
      _api.delete(table, column, value);
}
