import '../../../core/network/api_service.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/models/donation.dart';
import './admin_repository.dart';
import './admin_stats_dto.dart';

class AdminRemoteDataSource {
  final ApiService _api;
  final SupabaseClientService _supabase = SupabaseClientService();
  final LoggerService _logger = LoggerService();

  AdminRemoteDataSource(this._api);

  Future<AdminStats> getStats() async {
    try {
      final users = await _api.query('profiles');
      final activeDonors = users
          .where((u) =>
              u['role'] == 'donor' && u['is_available'] == true)
          .toList();
      final hospitals = await _api.query('hospitals');
      final requests = await _api.query('blood_requests');
      final pendingRequests = requests
          .where((r) => r['status'] == 'pending')
          .toList();

      return AdminStatsDto(
        totalUsers: users.length,
        activeDonors: activeDonors.length,
        totalHospitals: hospitals.length,
        totalRequests: requests.length,
        pendingRequests: pendingRequests.length,
      ).toDomain();
    } catch (e, stack) {
      _logger.error('Failed to get admin stats', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<UserProfile>> getAllUsers({String? role}) async {
    try {
      final filters = <String, dynamic>{};
      if (role != null) filters['role'] = role;

      final data = await _api.query(
        'profiles',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((e) => UserProfile.fromJson(e)).toList();
    } catch (e, stack) {
      _logger.error('Failed to get all users', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> verifyHospital(String hospitalId) async {
    try {
      await _api.update(
        'hospitals',
        {'verified': true},
        'id',
        hospitalId,
      );
    } catch (e, stack) {
      _logger.error('Failed to verify hospital', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> suspendUser(String userId) async {
    try {
      await _api.update(
        'profiles',
        {'is_suspended': true, 'is_available': false},
        'id',
        userId,
      );
    } catch (e, stack) {
      _logger.error('Failed to suspend user', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<Donation>> getAllDonations() async {
    try {
      final data = await _api.query(
        'donations',
        orderBy: 'donation_date',
        ascending: false,
      );
      return data.map((e) => Donation.fromJson(e)).toList();
    } catch (e, stack) {
      _logger.error('Failed to get all donations', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<BloodRequest>> getPendingRequests() async {
    try {
      final data = await _api.query(
        'blood_requests',
        filters: {'status': 'pending'},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((e) => BloodRequest.fromJson(e)).toList();
    } catch (e, stack) {
      _logger.error('Failed to get pending requests', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<BloodRequest>> getAcceptedRequests() async {
    try {
      final data = await _api.query(
        'blood_requests',
        filters: {'status': 'accepted'},
        orderBy: 'updated_at',
        ascending: false,
      );
      return data.map((e) => BloodRequest.fromJson(e)).toList();
    } catch (e, stack) {
      _logger.error('Failed to get accepted requests', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<BloodRequest>> getAllRequests({String? status}) async {
    try {
      final filters = <String, dynamic>{};
      if (status != null) filters['status'] = status;

      final data = await _api.query(
        'blood_requests',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((e) => BloodRequest.fromJson(e)).toList();
    } catch (e, stack) {
      _logger.error('Failed to get all requests', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> removeRequest(String requestId) async {
    try {
      await _api.delete('blood_requests', 'id', requestId);
    } catch (e, stack) {
      _logger.error('Failed to remove request', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> createAnnouncement(String title, String body) async {
    try {
      // Insert the announcement record
      await _supabase.client.from('announcements').insert({
        'title': title,
        'description': body,
      });

      // Fetch all user IDs to notify
      final allUsers = await _api.query('profiles', filters: {});

      // Build notification rows for a batch insert
      final notifications = allUsers
          .map((user) => user['id'] as String?)
          .where((id) => id != null)
          .map((userId) => {
                'user_id': userId,
                'title': 'New Announcement: $title',
                'body': body,
                'type': 'announcement',
                'is_read': false,
                'created_at': DateTime.now().toIso8601String(),
              })
          .toList();

      if (notifications.isNotEmpty) {
        // Insert all notifications in one batch — no .select() so RLS SELECT
        // policy on other users' rows won't block this admin operation.
        await _supabase.client.from('notifications').insert(notifications);
      }
    } catch (e, stack) {
      _logger.error('Failed to create announcement', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getReports({String? status}) async {
    try {
      final filters = <String, dynamic>{};
      if (status != null) filters['status'] = status;

      // Fetch reports via the existing API (which uses .eq() filters)
      final data = await _api.query(
        'reports',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'created_at',
        ascending: false,
      );

      if (data.isEmpty) return data;

      // Collect unique user IDs referenced in the reports
      final userIds = <String>{};
      for (final report in data) {
        final reporterId = report['reporter_id'] as String?;
        final reportedId = report['reported_user_id'] as String?;
        if (reporterId != null) userIds.add(reporterId);
        if (reportedId != null) userIds.add(reportedId);
      }

      // Fetch all profiles in one query and build a name lookup map
      final allProfiles = await _api.query('profiles', limit: 100000);
      final nameMap = <String, String>{};
      for (final p in allProfiles) {
        final pid = p['id'] as String?;
        final name = p['name'] as String?;
        if (pid != null && name != null && userIds.contains(pid)) {
          nameMap[pid] = name;
        }
      }

      // Enrich each report with the resolved names
      return data.map((report) {
        final enriched = Map<String, dynamic>.from(report);
        final reporterId = report['reporter_id'] as String?;
        final reportedId = report['reported_user_id'] as String?;
        enriched['reporter_name'] =
            reporterId != null ? (nameMap[reporterId] ?? 'Unknown') : 'Unknown';
        enriched['reported_name'] =
            reportedId != null ? (nameMap[reportedId] ?? 'Unknown') : 'Unknown';
        return enriched;
      }).toList();
    } catch (e, stack) {
      _logger.error('Failed to get reports', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> dismissReport(String reportId) async {
    try {
      await _api.update('reports', {'status': 'resolved'}, 'id', reportId);
    } catch (e, stack) {
      _logger.error('Failed to dismiss report', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllHospitals() async {
    try {
      final data = await _api.query(
        'hospitals',
        orderBy: 'created_at',
        ascending: false,
      );
      return data;
    } catch (e, stack) {
      _logger.error('Failed to get all hospitals', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingHospitals() async {
    try {
      final data = await _api.query(
        'hospitals',
        filters: {'verified': false},
        orderBy: 'created_at',
        ascending: false,
      );
      return data;
    } catch (e, stack) {
      _logger.error('Failed to get pending hospitals', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllBloodBanks() async {
    try {
      final data = await _api.query(
        'blood_banks',
        orderBy: 'created_at',
        ascending: false,
      );
      return data;
    } catch (e, stack) {
      _logger.error('Failed to get all blood banks', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingBloodBanks() async {
    try {
      // Requires the `verified` column on blood_banks (added by fix_rls_policies.sql)
      final data = await _api.query(
        'blood_banks',
        filters: {'verified': false},
        orderBy: 'created_at',
        ascending: false,
      );
      return data;
    } catch (e, stack) {
      _logger.error('Failed to get pending blood banks', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> verifyBloodBank(String bloodBankId) async {
    try {
      await _api.update(
        'blood_banks',
        {'verified': true},
        'id',
        bloodBankId,
      );
    } catch (e, stack) {
      _logger.error('Failed to verify blood bank', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteHospital(String hospitalId) async {
    try {
      await _api.delete('hospitals', 'id', hospitalId);
    } catch (e, stack) {
      _logger.error('Failed to delete hospital', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteBloodBank(String bloodBankId) async {
    try {
      await _api.delete('blood_banks', 'id', bloodBankId);
    } catch (e, stack) {
      _logger.error('Failed to delete blood bank', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
