import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../../../shared/models/hospital.dart';
import '../services/blood_bank_remote_datasource.dart';

final bloodBankRemoteDataSourceProvider = Provider<BloodBankRemoteDataSource>((ref) {
  return BloodBankRemoteDataSource(ref.read(cachedApiServiceProvider));
});

final bloodBanksProvider = FutureProvider.family<List<BloodBank>, BloodBankQueryParams>((ref, params) async {
  final dataSource = ref.read(bloodBankRemoteDataSourceProvider);
  return dataSource.getBloodBanks(
    query: params.query,
    latitude: params.latitude,
    longitude: params.longitude,
    radiusKm: params.radiusKm,
    verified: params.verified,
  );
});

final bloodBankByIdProvider = FutureProvider.family<BloodBank?, String>((ref, id) async {
  final dataSource = ref.read(bloodBankRemoteDataSourceProvider);
  return dataSource.getBloodBankById(id);
});

class BloodBankQueryParams {
  final String? query;
  final double? latitude;
  final double? longitude;
  final double radiusKm;
  final bool? verified;

  const BloodBankQueryParams({
    this.query,
    this.latitude,
    this.longitude,
    this.radiusKm = 25,
    this.verified,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodBankQueryParams &&
          query == other.query &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radiusKm == other.radiusKm &&
          verified == other.verified;

  @override
  int get hashCode => Object.hash(query, latitude, longitude, radiusKm, verified);
}
