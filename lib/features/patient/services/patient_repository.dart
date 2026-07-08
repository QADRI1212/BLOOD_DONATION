import '../../../shared/models/blood_request.dart';

abstract class PatientRepository {
  Future<BloodRequest> createEmergencyRequest(BloodRequest request);

  Future<List<BloodRequest>> getMyRequests(String patientId);

  Future<void> cancelRequest(String requestId);
}
