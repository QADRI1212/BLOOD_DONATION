import '../../../shared/models/user_profile.dart';
import '../../../shared/models/blood_request.dart';
import './admin_repository.dart';

class AdminUseCases {
  final AdminRepository _repository;

  AdminUseCases(this._repository);

  Future<AdminStats> getStats() => _repository.getStats();

  Future<List<UserProfile>> getAllUsers({String? role}) {
    return _repository.getAllUsers(role: role);
  }

  Future<void> verifyHospital(String hospitalId) {
    return _repository.verifyHospital(hospitalId);
  }

  Future<void> suspendUser(String userId) {
    return _repository.suspendUser(userId);
  }

  Future<List<BloodRequest>> getAllRequests({String? status}) {
    return _repository.getAllRequests(status: status);
  }

  Future<void> removeRequest(String requestId) {
    return _repository.removeRequest(requestId);
  }

  Future<void> createAnnouncement(String title, String body) {
    return _repository.createAnnouncement(title, body);
  }
}
