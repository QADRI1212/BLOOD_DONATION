import '../../../shared/models/blood_request.dart';
import '../../../shared/models/donation.dart';

class DashboardStats {
  final int activeRequests;
  final int totalDonations;
  final int totalUnits;
  final int savedHospitals;
  final int unreadNotifications;

  const DashboardStats({
    this.activeRequests = 0,
    this.totalDonations = 0,
    this.totalUnits = 0,
    this.savedHospitals = 0,
    this.unreadNotifications = 0,
  });
}

abstract class DashboardRepository {
  Future<DashboardStats> getStats(String userId);

  Future<List<BloodRequest>> getRecentRequests(String userId);

  Future<DonationStats> getDonationSummary(String userId);
}
