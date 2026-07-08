import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../../../shared/models/donation.dart';
import '../services/donation_remote_datasource.dart';

final donationRemoteDataSourceProvider = Provider<DonationRemoteDataSource>((ref) {
  return DonationRemoteDataSource(ref.read(cachedApiServiceProvider));
});

final donationHistoryProvider = FutureProvider.family<List<Donation>, String>((ref, donorId) async {
  final dataSource = ref.read(donationRemoteDataSourceProvider);
  return dataSource.getDonationHistory(donorId);
});

final donationStatsProvider = FutureProvider.autoDispose.family<DonationStats, String>((ref, donorId) async {
  final dataSource = ref.read(donationRemoteDataSourceProvider);
  return dataSource.getDonationStats(donorId);
});
