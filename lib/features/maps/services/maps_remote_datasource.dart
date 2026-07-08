import 'dart:typed_data';
import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/geometry_utils.dart';
import './maps_repository.dart';

class MapsRemoteDataSource {
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  MapsRemoteDataSource(this._api);

  Future<List<MapMarker>> getNearbyMarkers({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    List<String>? types,
    String? bloodGroup,
  }) async {
    try {
      final markers = <MapMarker>[];

      // Donor markers (profiles table — cacheable)
      if (types == null || types.contains('donor')) {
        final donorFilters = <String, dynamic>{
          'role': 'donor',
          'is_available': true,
        };
        if (bloodGroup != null) donorFilters['blood_group'] = bloodGroup;

        final donors = await _api.query(
          'profiles',
          cacheBox: 'cached_profiles',
          filters: donorFilters,
          limit: 100,
        );

        for (final d in donors) {
          final lat = (d['latitude'] as num?)?.toDouble();
          final lon = (d['longitude'] as num?)?.toDouble();
          if (lat == null || lon == null) continue;

          if (GeometryUtils.isWithinRadius(latitude, longitude, lat, lon, radiusKm)) {
            markers.add(MapMarker(
              id: d['id'] as String,
              type: 'donor',
              label: d['name'] as String? ?? 'Donor',
              subtitle: d['blood_group'] as String?,
              latitude: lat,
              longitude: lon,
              bloodGroup: d['blood_group'] as String?,
            ));
          }
        }
      }

      // Hospital markers (cacheable)
      if (types == null || types.contains('hospital')) {
        final hospitals = await _api.query('hospitals',
          cacheBox: 'cached_hospitals',
        );
        for (final h in hospitals) {
          final lat = (h['latitude'] as num?)?.toDouble();
          final lon = (h['longitude'] as num?)?.toDouble();
          if (lat == null || lon == null) continue;

          if (GeometryUtils.isWithinRadius(latitude, longitude, lat, lon, radiusKm)) {
            markers.add(MapMarker(
              id: h['id'] as String,
              type: 'hospital',
              label: h['name'] as String? ?? 'Hospital',
              subtitle: h['address'] as String?,
              latitude: lat,
              longitude: lon,
            ));
          }
        }
      }

      // Blood bank markers (cacheable)
      if (types == null || types.contains('blood_bank')) {
        final banks = await _api.query('blood_banks',
          cacheBox: 'cached_blood_banks',
        );
        for (final b in banks) {
          final lat = (b['latitude'] as num?)?.toDouble();
          final lon = (b['longitude'] as num?)?.toDouble();
          if (lat == null || lon == null) continue;

          if (GeometryUtils.isWithinRadius(latitude, longitude, lat, lon, radiusKm)) {
            markers.add(MapMarker(
              id: b['id'] as String,
              type: 'blood_bank',
              label: b['name'] as String? ?? 'Blood Bank',
              subtitle: b['address'] as String?,
              latitude: lat,
              longitude: lon,
            ));
          }
        }
      }

      // Active request markers
      if (types == null || types.contains('request')) {
        final requests = await _api.query(
          'blood_requests',
          filters: {'status': 'pending'},
          limit: 50,
        );
        for (final r in requests) {
          final lat = (r['latitude'] as num?)?.toDouble();
          final lon = (r['longitude'] as num?)?.toDouble();
          if (lat == null || lon == null) continue;

          if (GeometryUtils.isWithinRadius(latitude, longitude, lat, lon, radiusKm)) {
            markers.add(MapMarker(
              id: r['id'] as String,
              type: 'request',
              label: '${r['blood_group'] ?? '?'} Blood Needed',
              subtitle: r['patient_name'] as String?,
              latitude: lat,
              longitude: lon,
              bloodGroup: r['blood_group'] as String?,
            ));
          }
        }
      }

      return markers;
    } catch (e, stack) {
      _logger.error('Failed to get nearby markers', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<Uint8List?> getMarkerIcon(String type, {String? bloodGroup}) async {
    // Return null to use default icons - actual icon generation
    // would be handled in the presentation layer
    return null;
  }

}
