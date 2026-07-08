import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../../../shared/models/user_profile.dart';
import '../services/nearby_donor_remote_datasource.dart';

final nearbyDonorRemoteDataSourceProvider = Provider<NearbyDonorRemoteDataSource>((ref) {
  return NearbyDonorRemoteDataSource(ref.read(cachedApiServiceProvider));
});

final findNearbyDonorsProvider = FutureProvider.family<List<UserProfile>, NearbyDonorSearchParams>((ref, params) async {
  final dataSource = ref.read(nearbyDonorRemoteDataSourceProvider);
  return dataSource.findNearbyDonors(
    latitude: params.latitude,
    longitude: params.longitude,
    radiusKm: params.radiusKm,
    bloodGroup: params.bloodGroup,
    sortBy: params.sortBy,
  );
});

class NearbyDonorSearchParams extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? bloodGroup;
  final String sortBy;

  const NearbyDonorSearchParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 25,
    this.bloodGroup,
    this.sortBy = 'nearest',
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm, bloodGroup, sortBy];
}
