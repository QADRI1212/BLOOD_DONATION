import './maps_repository.dart';

class MapMarkerDto {
  final String id;
  final String type;
  final String label;
  final String? subtitle;
  final double latitude;
  final double longitude;
  final String? bloodGroup;

  const MapMarkerDto({
    required this.id,
    required this.type,
    required this.label,
    this.subtitle,
    required this.latitude,
    required this.longitude,
    this.bloodGroup,
  });

  factory MapMarkerDto.fromJson(Map<String, dynamic> map, {required String type}) {
    final lat = (map['latitude'] as num?)?.toDouble() ?? 0.0;
    final lon = (map['longitude'] as num?)?.toDouble() ?? 0.0;

    String label;
    String? subtitle;
    String? bloodGroup;

    switch (type) {
      case 'donor':
        label = map['name'] as String? ?? 'Donor';
        bloodGroup = map['blood_group'] as String?;
        subtitle = bloodGroup;
        break;
      case 'hospital':
        label = map['name'] as String? ?? 'Hospital';
        subtitle = map['address'] as String?;
        break;
      case 'blood_bank':
        label = map['name'] as String? ?? 'Blood Bank';
        subtitle = map['address'] as String?;
        break;
      case 'request':
        bloodGroup = map['blood_group'] as String?;
        label = '${bloodGroup ?? '?'} Blood Needed';
        subtitle = map['patient_name'] as String?;
        break;
      default:
        label = map['name'] as String? ?? 'Location';
    }

    return MapMarkerDto(
      id: map['id'] as String,
      type: type,
      label: label,
      subtitle: subtitle,
      latitude: lat,
      longitude: lon,
      bloodGroup: bloodGroup,
    );
  }

  MapMarker toDomain() {
    return MapMarker(
      id: id,
      type: type,
      label: label,
      subtitle: subtitle,
      latitude: latitude,
      longitude: longitude,
      bloodGroup: bloodGroup,
    );
  }
}
