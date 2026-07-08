import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../services/maps_repository.dart';
import '../services/maps_remote_datasource.dart';

final mapsRemoteDataSourceProvider = Provider<MapsRemoteDataSource>((ref) {
  return MapsRemoteDataSource(ref.read(cachedApiServiceProvider));
});

final mapMarkersProvider = FutureProvider.family<List<MapMarker>, MapMarkerQueryParams>((ref, params) async {
  final dataSource = ref.read(mapsRemoteDataSourceProvider);
  return dataSource.getNearbyMarkers(
    latitude: params.latitude,
    longitude: params.longitude,
    radiusKm: params.radiusKm,
    types: params.types,
    bloodGroup: params.bloodGroup,
  );
});

class MapMarkerQueryParams {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final List<String>? types;
  final String? bloodGroup;

  const MapMarkerQueryParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 25,
    this.types,
    this.bloodGroup,
  });
}
