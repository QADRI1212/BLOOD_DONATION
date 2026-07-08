import '../../../core/network/api_service.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/models/donation.dart';
import './dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiService _api;

  DashboardRepositoryImpl(this._api);

  @override
  Future<DashboardStats> getStats(String userId) async {
    final activeRequests = await _api.query(
      'blood_requests',
      filters: {'status': 'pending'},
    );
    final donations = await _api.query(
      'donations',
      column: 'donor_id',
      value: userId,
    );
    final notifications = await _api.query(
      'notifications',
      filters: {'user_id': userId, 'is_read': false},
    );

    return DashboardStats(
      activeRequests: activeRequests.length,
      totalDonations: donations.length,
      totalUnits: donations.fold(0, (sum, d) => sum + (d['units'] as int? ?? 0)),
      unreadNotifications: notifications.length,
    );
  }

  @override
  Future<List<BloodRequest>> getRecentRequests(String userId) async {
    final data = await _api.query(
      'blood_requests',
      orderBy: 'created_at',
      ascending: false,
      limit: 5,
    );
    return data.map((e) => BloodRequest.fromJson(e)).toList();
  }

  @override
  Future<DonationStats> getDonationSummary(String userId) async {
    final data = await _api.query(
      'donations',
      column: 'donor_id',
      value: userId,
      orderBy: 'donation_date',
      ascending: false,
    );
    final donations = data.map((e) => Donation.fromJson(e)).toList();
    if (donations.isEmpty) return const DonationStats();
    return DonationStats(
      totalDonations: donations.length,
      totalUnits: donations.fold(0, (sum, d) => sum + d.units),
      lastDonationDate: donations.first.donationDate,
    );
  }
}
