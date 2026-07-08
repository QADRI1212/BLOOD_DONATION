import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/models/donation.dart';
import '../services/dashboard_repository.dart';
import '../services/dashboard_remote_datasource.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(ref.read(cachedApiServiceProvider));
});

final dashboardProvider = FutureProvider.family<DashboardStats, String>((ref, userId) async {
  final dataSource = ref.read(dashboardRemoteDataSourceProvider);
  return dataSource.getStats(userId);
});

final recentRequestsProvider = FutureProvider.family<List<BloodRequest>, RecentRequestsParams>((ref, params) async {
  final dataSource = ref.read(dashboardRemoteDataSourceProvider);
  return dataSource.getRecentRequests(userId: params.userId, forDonor: params.forDonor);
});

class RecentRequestsParams {
  final String userId;
  final bool forDonor;

  const RecentRequestsParams({required this.userId, required this.forDonor});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentRequestsParams &&
          userId == other.userId &&
          forDonor == other.forDonor;

  @override
  int get hashCode => Object.hash(userId, forDonor);
}

final donationSummaryProvider = FutureProvider.family<DonationStats, String>((ref, userId) async {
  final dataSource = ref.read(dashboardRemoteDataSourceProvider);
  return dataSource.getDonationSummary(userId);
});
