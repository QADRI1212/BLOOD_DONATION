import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../../../shared/models/blood_request.dart';
import '../services/patient_remote_datasource.dart';

final patientRemoteDataSourceProvider = Provider<PatientRemoteDataSource>((ref) {
  return PatientRemoteDataSource(ref.read(cachedApiServiceProvider));
});

final myRequestsProvider = FutureProvider.family<List<BloodRequest>, String>((ref, patientId) async {
  final dataSource = ref.read(patientRemoteDataSourceProvider);
  return dataSource.getMyRequests(patientId);
});

class PatientNotifier extends StateNotifier<AsyncValue<void>> {
  final PatientRemoteDataSource _dataSource;

  PatientNotifier(this._dataSource) : super(const AsyncValue.data(null));

  Future<void> createRequest(BloodRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.createEmergencyRequest(request);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelRequest(String requestId) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.cancelRequest(requestId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final patientNotifierProvider = StateNotifierProvider<PatientNotifier, AsyncValue<void>>((ref) {
  return PatientNotifier(ref.read(patientRemoteDataSourceProvider));
});
