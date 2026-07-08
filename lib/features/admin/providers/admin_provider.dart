import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/blood_request.dart';
import '../services/admin_repository.dart';
import '../services/admin_remote_datasource.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource(ApiService());
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final dataSource = ref.read(adminRemoteDataSourceProvider);
  return dataSource.getStats();
});

final adminUsersProvider = FutureProvider.family<List<UserProfile>, String?>((ref, role) async {
  final dataSource = ref.read(adminRemoteDataSourceProvider);
  return dataSource.getAllUsers(role: role);
});

final adminRequestsProvider = FutureProvider.family<List<BloodRequest>, String?>((ref, status) async {
  final dataSource = ref.read(adminRemoteDataSourceProvider);
  return dataSource.getAllRequests(status: status);
});

final adminReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dataSource = ref.read(adminRemoteDataSourceProvider);
  return dataSource.getReports(status: 'pending');
});

final adminPendingHospitalsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dataSource = ref.read(adminRemoteDataSourceProvider);
  return dataSource.getPendingHospitals();
});

final adminPendingBloodBanksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dataSource = ref.read(adminRemoteDataSourceProvider);
  return dataSource.getPendingBloodBanks();
});

class AdminNotifier extends StateNotifier<AsyncValue<void>> {
  final AdminRemoteDataSource _dataSource;

  AdminNotifier(this._dataSource) : super(const AsyncValue.data(null));

  Future<void> suspendUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.suspendUser(userId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeRequest(String requestId) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.removeRequest(requestId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createAnnouncement(String title, String body) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.createAnnouncement(title, body);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> dismissReport(String reportId) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.dismissReport(reportId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> verifyHospital(String hospitalId) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.verifyHospital(hospitalId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> verifyBloodBank(String bloodBankId) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.verifyBloodBank(bloodBankId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> rejectHospital(String hospitalId) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.deleteHospital(hospitalId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> rejectBloodBank(String bloodBankId) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.deleteBloodBank(bloodBankId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final adminNotifierProvider = StateNotifierProvider<AdminNotifier, AsyncValue<void>>((ref) {
  return AdminNotifier(ref.read(adminRemoteDataSourceProvider));
});
