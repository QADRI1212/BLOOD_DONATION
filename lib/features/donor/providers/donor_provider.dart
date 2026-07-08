import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../../../shared/models/user_profile.dart';
import '../services/donor_remote_datasource.dart';

final donorRemoteDataSourceProvider = Provider<DonorRemoteDataSource>((ref) {
  return DonorRemoteDataSource(ref.read(cachedApiServiceProvider));
});

final nearbyDonorsProvider = FutureProvider.family<List<UserProfile>, NearbyDonorsParams>((ref, params) async {
  final dataSource = ref.read(donorRemoteDataSourceProvider);
  return dataSource.getNearbyDonors(
    latitude: params.latitude,
    longitude: params.longitude,
    radiusKm: params.radiusKm,
    bloodGroup: params.bloodGroup,
    isAvailable: params.isAvailable,
  );
});

final donorByIdProvider = FutureProvider.family<UserProfile?, String>((ref, id) async {
  final dataSource = ref.read(donorRemoteDataSourceProvider);
  return dataSource.getDonorById(id);
});

final donorSearchProvider = FutureProvider.family<List<UserProfile>, String>((ref, query) async {
  final dataSource = ref.read(donorRemoteDataSourceProvider);
  return dataSource.searchDonors(query);
});

class NearbyDonorsParams {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? bloodGroup;
  final bool? isAvailable;

  const NearbyDonorsParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 25,
    this.bloodGroup,
    this.isAvailable,
  });
}
