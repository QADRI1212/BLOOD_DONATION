import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/geometry_utils.dart';
import '../../../shared/models/hospital.dart';

class HospitalRemoteDataSource {
  static const String _cacheBox = 'cached_hospitals';
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  HospitalRemoteDataSource(this._api);

  Future<List<Hospital>> getHospitals({
    String? query,
    double? latitude,
    double? longitude,
    double radiusKm = 25,
    bool? verified,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (verified != null) filters['verified'] = verified;

      final data = await _api.query(
        'hospitals',
        cacheBox: _cacheBox,
        filters: filters.isNotEmpty ? filters : null,
      );

      var hospitals = data.map((e) => Hospital.fromJson(e)).toList();

      // Client-side search filter
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        hospitals = hospitals
            .where((h) => h.name.toLowerCase().contains(q))
            .toList();
      }

      // Client-side distance filter
      if (latitude != null && longitude != null) {
        hospitals = hospitals.where((h) {
          final dist = GeometryUtils.calculateDistanceInKm(
            latitude, longitude,
            h.latitude, h.longitude,
          );
          return dist <= radiusKm;
        }).toList();
      }

      return hospitals;
    } catch (e, stack) {
      _logger.error('Failed to get hospitals', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<Hospital?> getHospitalById(String id) async {
    try {
      final data = await _api.querySingle('hospitals', 'id', id);
      if (data == null) return null;
      return Hospital.fromJson(data);
    } catch (e, stack) {
      _logger.error('Failed to get hospital by id', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<Hospital>> getSavedHospitals(String userId) async {
    try {
      final saved = await _api.query(
        'saved_locations',
        filters: {'user_id': userId},
      );
      final hospitalIds = saved
          .map((e) => e['hospital_id'] as String?)
          .where((id) => id != null)
          .toList();

      if (hospitalIds.isEmpty) return [];

      // Fetch each hospital individually (Supabase doesn't support array contains easily)
      final hospitals = <Hospital>[];
      for (final id in hospitalIds) {
        final data = await _api.querySingle('hospitals', 'id', id);
        if (data != null) hospitals.add(Hospital.fromJson(data));
      }
      return hospitals;
    } catch (e, stack) {
      _logger.error('Failed to get saved hospitals', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> saveHospital(String userId, String hospitalId) async {
    try {
      await _api.insert('saved_locations', {
        'user_id': userId,
        'hospital_id': hospitalId,
      });
    } catch (e, stack) {
      _logger.error('Failed to save hospital', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> removeSavedHospital(String userId, String hospitalId) async {
    try {
      await _api.delete('saved_locations', 'user_id', userId);
    } catch (e, stack) {
      _logger.error('Failed to remove saved hospital', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Insert a new hospital record (used by hospital managers on registration).
  Future<Map<String, dynamic>> insertHospital(Map<String, dynamic> data) async {
    try {
      final result = await _api.insert('hospitals', data);
      return result;
    } catch (e, stack) {
      _logger.error('Failed to insert hospital', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
