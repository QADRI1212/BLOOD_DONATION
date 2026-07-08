import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/models/donation.dart';
import '../../donation_history/providers/donation_history_provider.dart';
import '../../donation_history/services/donation_remote_datasource.dart';
import '../services/blood_request_repository_impl.dart';

final bloodRequestRemoteDataSourceProvider =
    Provider<BloodRequestRepositoryImpl>((ref) {
      return BloodRequestRepositoryImpl(ApiService(), SupabaseClientService());
    });

final bloodRequestsProvider =
    FutureProvider.family<List<BloodRequest>, BloodRequestFilter?>((
      ref,
      filter,
    ) async {
      final dataSource = ref.read(bloodRequestRemoteDataSourceProvider);
      return dataSource.getRequests(
        status: filter?.status,
        patientId: filter?.patientId,
        donorId: filter?.donorId,
      );
    });

final bloodRequestByIdProvider = FutureProvider.family<BloodRequest?, String>((
  ref,
  id,
) async {
  final dataSource = ref.read(bloodRequestRemoteDataSourceProvider);
  return dataSource.getRequestById(id);
});

class BloodRequestFilter {
  final String? status;
  final String? patientId;
  final String? donorId;

  const BloodRequestFilter({this.status, this.patientId, this.donorId});
}

class BloodRequestNotifier extends StateNotifier<AsyncValue<void>> {
  final BloodRequestRepositoryImpl _dataSource;
  final DonationRemoteDataSource _donationDataSource;

  BloodRequestNotifier(this._dataSource, this._donationDataSource)
    : super(const AsyncValue.data(null));

  Future<BloodRequest> createRequest(BloodRequest request) async {
    state = const AsyncValue.loading();
    try {
      final created = await _dataSource.createRequest(request);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> acceptRequest(
    String requestId,
    String donorId,
    String donorName,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.updateRequestStatus(
        requestId,
        'accepted',
        donorId: donorId,
        donorName: donorName,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeRequest(
    String requestId, {
    String? hospitalId,
    String? hospitalName,
    DateTime? donationDate,
    String? remarks,
  }) async {
    state = const AsyncValue.loading();
    try {
      final completed = await _dataSource.updateRequestStatus(
        requestId,
        'completed',
      );

      // Auto-record a donation entry so the dashboard stats update correctly.
      // The donor_id on the completed request is the logged-in donor.
      if (completed.donorId != null) {
        try {
          final donation = Donation(
            id: '', // DB generates via gen_random_uuid()
            donorId: completed.donorId!,
            donorName: completed.donorName,
            bloodGroup: completed.bloodGroup,
            hospitalId: hospitalId,
            hospitalName: hospitalName,
            units: completed.units,
            donationDate: donationDate ?? DateTime.now(),
            remarks: remarks,
            createdAt: DateTime.now(),
          );
          await _donationDataSource.recordDonation(donation);
        } catch (e) {
          // Donation recording is non-critical — don't fail the whole completion,
          // but log it so we can diagnose why donations aren't persisting.
          LoggerService().error('Failed to record donation after completing request', error: e);
        }
      }

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

final bloodRequestNotifierProvider =
    StateNotifierProvider<BloodRequestNotifier, AsyncValue<void>>((ref) {
      return BloodRequestNotifier(
        ref.read(bloodRequestRemoteDataSourceProvider),
        ref.read(donationRemoteDataSourceProvider),
      );
    });

final realtimeRequestsProvider = StreamProvider<List<BloodRequest>>((ref) {
  final dataSource = ref.read(bloodRequestRemoteDataSourceProvider);
  return dataSource.subscribeToNewRequests();
});
