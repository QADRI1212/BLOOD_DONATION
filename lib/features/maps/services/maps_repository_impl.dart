import 'dart:typed_data';
import '../../../core/network/api_service.dart';
import '../../../core/utils/geometry_utils.dart';
import './maps_repository.dart';

class MapsRepositoryImpl implements MapsRepository {
  final ApiService _api;

  MapsRepositoryImpl(this._api);

  @override
  Future<List<MapMarker>> getNearbyMarkers({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    List<String>? types,
    String? bloodGroup,
  }) async {
    final markers = <MapMarker>[];

    if (types == null || types.contains('donor')) {
      final donors = await _api.query('profiles',
        filters: {'role': 'donor', 'is_available': true},
      );
      for (final d in donors) {
        final lat = (d['latitude'] as num?)?.toDouble();
        final lon = (d['longitude'] as num?)?.toDouble();
        if (lat == null || lon == null) continue;
        if (!GeometryUtils.isWithinRadius(latitude, longitude, lat, lon, radiusKm)) continue;
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

    if (types == null || types.contains('hospital')) {
      final hospitals = await _api.query('hospitals');
      for (final h in hospitals) {
        final lat = (h['latitude'] as num?)?.toDouble();
        final lon = (h['longitude'] as num?)?.toDouble();
        if (lat == null || lon == null) continue;
        markers.add(MapMarker(
          id: h['id'] as String,
          type: 'hospital',
          label: h['name'] as String? ?? 'Hospital',
          latitude: lat,
          longitude: lon,
        ));
      }
    }

    if (types == null || types.contains('blood_bank')) {
      final banks = await _api.query('blood_banks');
      for (final b in banks) {
        final lat = (b['latitude'] as num?)?.toDouble();
        final lon = (b['longitude'] as num?)?.toDouble();
        if (lat == null || lon == null) continue;
        markers.add(MapMarker(
          id: b['id'] as String,
          type: 'blood_bank',
          label: b['name'] as String? ?? 'Blood Bank',
          latitude: lat,
          longitude: lon,
        ));
      }
    }

    return markers;
  }

  @override
  Future<Uint8List?> getMarkerIcon(String type, {String? bloodGroup}) async {
    return null;
  }
}
