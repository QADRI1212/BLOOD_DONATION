import '../../../shared/models/blood_request.dart';
import '../../../shared/models/donation.dart';
import './dashboard_repository.dart';

class DashboardUseCases {
  final DashboardRepository _repository;

  DashboardUseCases(this._repository);

  Future<DashboardStats> getStats(String userId) {
    return _repository.getStats(userId);
  }

  Future<List<BloodRequest>> getRecentRequests(String userId) {
    return _repository.getRecentRequests(userId);
  }

  Future<DonationStats> getDonationSummary(String userId) {
    return _repository.getDonationSummary(userId);
  }
}
