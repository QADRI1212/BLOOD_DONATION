import '../../../core/network/api_service.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/blood_request.dart';
import './admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final ApiService _api;

  AdminRepositoryImpl(this._api);

  @override
  Future<AdminStats> getStats() async {
    final users = await _api.query('profiles');
    final donors = users.where((u) => u['role'] == 'donor').toList();
    final requests = await _api.query('blood_requests');
    final hospitals = await _api.query('hospitals');

    return AdminStats(
      totalUsers: users.length,
      activeDonors: donors.where((d) => d['is_available'] == true).length,
      totalHospitals: hospitals.length,
      totalRequests: requests.length,
      pendingRequests: requests.where((r) => r['status'] == 'pending').length,
    );
  }

  @override
  Future<List<UserProfile>> getAllUsers({String? role}) async {
    final data = await _api.query(
      'profiles',
      column: role != null ? 'role' : null,
      value: role,
      orderBy: 'created_at',
      ascending: false,
    );
    return data.map((e) => UserProfile.fromJson(e)).toList();
  }

  @override
  Future<void> verifyHospital(String hospitalId) async {
    await _api.update('hospitals', {'verified': true}, 'id', hospitalId);
  }

  @override
  Future<void> suspendUser(String userId) async {
    await _api.update(
      'profiles',
      {'is_available': false},
      'id',
      userId,
    );
  }

  @override
  Future<List<BloodRequest>> getAllRequests({String? status}) async {
    final data = await _api.query(
      'blood_requests',
      column: status != null ? 'status' : null,
      value: status,
      orderBy: 'created_at',
      ascending: false,
    );
    return data.map((e) => BloodRequest.fromJson(e)).toList();
  }

  @override
  Future<void> removeRequest(String requestId) async {
    await _api.delete('blood_requests', 'id', requestId);
  }

  @override
  Future<void> createAnnouncement(String title, String body) async {
    await _api.insert('announcements', {
      'title': title,
      'description': body,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
