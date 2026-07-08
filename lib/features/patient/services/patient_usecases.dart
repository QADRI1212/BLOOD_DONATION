import '../../../shared/models/blood_request.dart';
import './patient_repository.dart';

class PatientUseCases {
  final PatientRepository _repository;

  PatientUseCases(this._repository);

  Future<BloodRequest> createEmergencyRequest(BloodRequest request) {
    return _repository.createEmergencyRequest(request);
  }

  Future<List<BloodRequest>> getMyRequests(String patientId) {
    return _repository.getMyRequests(patientId);
  }

  Future<void> cancelRequest(String requestId) {
    return _repository.cancelRequest(requestId);
  }
}
