import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/models/donation.dart';
import './dashboard_repository.dart';

class DashboardRemoteDataSource {
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  DashboardRemoteDataSource(this._api);

  Future<DashboardStats> getStats(String userId) async {
    try {
      final activeRequests = await _api.query(
        'blood_requests',
        filters: {'patient_id': userId, 'status': 'pending'},
      );
      final donations = await _api.query(
        'donations',
        column: 'donor_id',
        value: userId,
      );
      final saved = await _api.query(
        'saved_locations',
        column: 'user_id',
        value: userId,
      );
      final unread = await _api.query(
        'notifications',
        filters: {'user_id': userId, 'is_read': false},
      );

      final totalUnits = donations.fold<int>(
        0,
        (sum, d) => sum + ((d['units'] as num?)?.toInt() ?? 0),
      );

      return DashboardStats(
        activeRequests: activeRequests.length,
        totalDonations: donations.length,
        totalUnits: totalUnits,
        savedHospitals: saved.length,
        unreadNotifications: unread.length,
      );
    } catch (e, stack) {
      _logger.error('Failed to get dashboard stats', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<BloodRequest>> getRecentRequests({required String userId, required bool forDonor}) async {
    try {
      late final List<Map<String, dynamic>> data;
      if (forDonor) {
        // Donors see all pending requests
        data = await _api.query(
          'blood_requests',
          filters: {'status': 'pending'},
          orderBy: 'created_at',
          ascending: false,
          limit: 5,
        );
      } else {
        // Patients see their own requests
        data = await _api.query(
          'blood_requests',
          filters: {'patient_id': userId},
          orderBy: 'created_at',
          ascending: false,
          limit: 5,
        );
      }
      return data.map((e) => BloodRequest.fromJson(e)).toList();
    } catch (e, stack) {
      _logger.error('Failed to get recent requests', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<DonationStats> getDonationSummary(String userId) async {
    try {
      final donations = await _api.query(
        'donations',
        column: 'donor_id',
        value: userId,
        orderBy: 'donation_date',
        ascending: false,
      );

      if (donations.isEmpty) {
        return const DonationStats();
      }

      final lastDonation = donations.first;
      final totalUnits = donations.fold<int>(
        0,
        (sum, d) => sum + ((d['units'] as num?)?.toInt() ?? 0),
      );

      return DonationStats(
        totalDonations: donations.length,
        totalUnits: totalUnits,
        lastDonationDate: DateTime.tryParse(lastDonation['donation_date'] as String? ?? ''),
        nextEligibleDate: _calculateNextEligible(lastDonation['donation_date'] as String?),
        lastHospitalName: lastDonation['hospital_name'] as String?,
      );
    } catch (e, stack) {
      _logger.error('Failed to get donation summary', error: e, stackTrace: stack);
      rethrow;
    }
  }

  DateTime? _calculateNextEligible(String? donationDate) {
    if (donationDate == null) return null;
    final date = DateTime.tryParse(donationDate);
    if (date == null) return null;
    return date.add(const Duration(days: 90));
  }
}
