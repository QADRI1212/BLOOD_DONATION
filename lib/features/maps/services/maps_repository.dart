import 'dart:typed_data';

class MapMarker {
  final String id;
  final String type; // 'donor', 'hospital', 'blood_bank', 'request'
  final String label;
  final String? subtitle;
  final double latitude;
  final double longitude;
  final String? bloodGroup;

  const MapMarker({
    required this.id,
    required this.type,
    required this.label,
    this.subtitle,
    required this.latitude,
    required this.longitude,
    this.bloodGroup,
  });
}

abstract class MapsRepository {
  Future<List<MapMarker>> getNearbyMarkers({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    List<String>? types,
    String? bloodGroup,
  });

  Future<Uint8List?> getMarkerIcon(String type, {String? bloodGroup});
}
