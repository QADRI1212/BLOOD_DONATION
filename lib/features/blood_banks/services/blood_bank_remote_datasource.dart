import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/geometry_utils.dart';
import '../../../shared/models/hospital.dart';

class BloodBankRemoteDataSource {
  static const String _cacheBox = 'cached_blood_banks';
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  BloodBankRemoteDataSource(this._api);

  Future<List<BloodBank>> getBloodBanks({
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
        'blood_banks',
        cacheBox: _cacheBox,
        filters: filters.isNotEmpty ? filters : null,
      );

      var banks = data.map((e) => BloodBank.fromJson(e)).toList();

      // Client-side search filter
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        banks = banks
            .where((b) => b.name.toLowerCase().contains(q))
            .toList();
      }

      // Client-side distance filter
      if (latitude != null && longitude != null) {
        banks = banks.where((b) {
          final dist = GeometryUtils.calculateDistanceInKm(
            latitude, longitude,
            b.latitude, b.longitude,
          );
          return dist <= radiusKm;
        }).toList();
      }

      return banks;
    } catch (e, stack) {
      _logger.error('Failed to get blood banks', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<BloodBank?> getBloodBankById(String id) async {
    try {
      final data = await _api.querySingle('blood_banks', 'id', id);
      if (data == null) return null;
      return BloodBank.fromJson(data);
    } catch (e, stack) {
      _logger.error('Failed to get blood bank by id', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Insert a new blood bank record (used by managers on registration).
  Future<Map<String, dynamic>> insertBloodBank(Map<String, dynamic> data) async {
    try {
      final result = await _api.insert('blood_banks', data);
      return result;
    } catch (e, stack) {
      _logger.error('Failed to insert blood bank', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
