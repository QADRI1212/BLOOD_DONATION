import '../../../core/network/api_service.dart';
import '../../../shared/models/blood_request.dart';
import './patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  final ApiService _api;

  PatientRepositoryImpl(this._api);

  @override
  Future<BloodRequest> createEmergencyRequest(BloodRequest request) async {
    final data = await _api.insert('blood_requests', request.toJson());
    return BloodRequest.fromJson(data);
  }

  @override
  Future<List<BloodRequest>> getMyRequests(String patientId) async {
    final data = await _api.query(
      'blood_requests',
      column: 'patient_id',
      value: patientId,
      orderBy: 'created_at',
      ascending: false,
    );
    return data.map((e) => BloodRequest.fromJson(e)).toList();
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    await _api.update(
      'blood_requests',
      {'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()},
      'id',
      requestId,
    );
  }
}
