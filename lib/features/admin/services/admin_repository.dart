import '../../../shared/models/user_profile.dart';
import '../../../shared/models/blood_request.dart';

class AdminStats {
  final int totalUsers;
  final int activeDonors;
  final int totalHospitals;
  final int totalRequests;
  final int pendingRequests;

  const AdminStats({
    this.totalUsers = 0,
    this.activeDonors = 0,
    this.totalHospitals = 0,
    this.totalRequests = 0,
    this.pendingRequests = 0,
  });
}

abstract class AdminRepository {
  Future<AdminStats> getStats();

  Future<List<UserProfile>> getAllUsers({String? role});

  Future<void> verifyHospital(String hospitalId);

  Future<void> suspendUser(String userId);

  Future<List<BloodRequest>> getAllRequests({String? status});

  Future<void> removeRequest(String requestId);

  Future<void> createAnnouncement(String title, String body);
}
