import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../../../shared/models/hospital.dart';
import '../services/hospital_remote_datasource.dart';

final hospitalRemoteDataSourceProvider = Provider<HospitalRemoteDataSource>((ref) {
  return HospitalRemoteDataSource(ref.read(cachedApiServiceProvider));
});

final hospitalsProvider = FutureProvider.family<List<Hospital>, HospitalQueryParams>((ref, params) async {
  final dataSource = ref.read(hospitalRemoteDataSourceProvider);
  return dataSource.getHospitals(
    query: params.query,
    latitude: params.latitude,
    longitude: params.longitude,
    radiusKm: params.radiusKm,
    verified: params.verified,
  );
});

final hospitalByIdProvider = FutureProvider.family<Hospital?, String>((ref, id) async {
  final dataSource = ref.read(hospitalRemoteDataSourceProvider);
  return dataSource.getHospitalById(id);
});

final savedHospitalsProvider = FutureProvider.family<List<Hospital>, String>((ref, userId) async {
  final dataSource = ref.read(hospitalRemoteDataSourceProvider);
  return dataSource.getSavedHospitals(userId);
});

class HospitalQueryParams {
  final String? query;
  final double? latitude;
  final double? longitude;
  final double radiusKm;
  final bool? verified;

  const HospitalQueryParams({
    this.query,
    this.latitude,
    this.longitude,
    this.radiusKm = 25,
    this.verified,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalQueryParams &&
          query == other.query &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radiusKm == other.radiusKm &&
          verified == other.verified;

  @override
  int get hashCode => Object.hash(query, latitude, longitude, radiusKm, verified);
}
