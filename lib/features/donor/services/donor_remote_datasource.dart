import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/geometry_utils.dart';
import '../../../shared/models/user_profile.dart';

class DonorRemoteDataSource {
  static const String _cacheBox = 'cached_profiles';
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  DonorRemoteDataSource(this._api);

  Future<List<UserProfile>> getNearbyDonors({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? bloodGroup,
    bool? isAvailable,
  }) async {
    try {
      var filters = <String, dynamic>{'role': 'donor'};
      if (bloodGroup != null) filters['blood_group'] = bloodGroup;
      if (isAvailable != null) filters['is_available'] = isAvailable;

      final data = await _api.query(
        'profiles',
        cacheBox: _cacheBox,
        filters: filters,
        limit: 50,
      );

      // Filter by distance client-side
      final results = data
          .map((e) => UserProfile.fromJson(e))
          .where((donor) {
            if (donor.latitude == null || donor.longitude == null) return false;
            return GeometryUtils.isWithinRadius(
              latitude, longitude,
              donor.latitude!, donor.longitude!,
              radiusKm,
            );
          })
          .toList();

      return results;
    } catch (e, stack) {
      _logger.error('Failed to get nearby donors', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<UserProfile?> getDonorById(String id) async {
    try {
      final data = await _api.querySingle('profiles', 'id', id);
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e, stack) {
      _logger.error('Failed to get donor by id', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<UserProfile>> searchDonors(String query) async {
    try {
      final data = await _api.query(
        'profiles',
        filters: {'role': 'donor'},
        limit: 20,
      );
      // Client-side filter since Supabase REST doesn't support ILIKE easily via filters map
      final queryLower = query.toLowerCase();
      return data
          .map((e) => UserProfile.fromJson(e))
          .where((d) => d.name.toLowerCase().contains(queryLower))
          .toList();
    } catch (e, stack) {
      _logger.error('Failed to search donors', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<UserProfile> updateDonorProfile(UserProfile donor) async {
    try {
      await _api.update('profiles', donor.toJson(), 'id', donor.id);
      return donor;
    } catch (e, stack) {
      _logger.error('Failed to update donor profile', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> toggleAvailability(String donorId, bool isAvailable) async {
    try {
      await _api.update('profiles', {'is_available': isAvailable}, 'id', donorId);
    } catch (e, stack) {
      _logger.error('Failed to toggle availability', error: e, stackTrace: stack);
      rethrow;
    }
  }

}
