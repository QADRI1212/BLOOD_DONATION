import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/blood_request.dart';

class PatientRemoteDataSource {
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  PatientRemoteDataSource(this._api);

  Future<BloodRequest> createEmergencyRequest(BloodRequest request) async {
    try {
      final data = await _api.insert('blood_requests', request.toJson());
      return BloodRequest.fromJson(data);
    } catch (e, stack) {
      _logger.error('Failed to create emergency request', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<BloodRequest>> getMyRequests(String patientId) async {
    try {
      // Note: blood_requests is NOT cached — it's safety-critical real-time data.
      // CachedApiService has a built-in guard that rejects caching for this table.
      final data = await _api.query(
        'blood_requests',
        column: 'patient_id',
        value: patientId,
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((e) => BloodRequest.fromJson(e)).toList();
    } catch (e, stack) {
      _logger.error('Failed to get my requests', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _api.update(
        'blood_requests',
        {'status': 'cancelled'},
        'id',
        requestId,
      );
    } catch (e, stack) {
      _logger.error('Failed to cancel request', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
