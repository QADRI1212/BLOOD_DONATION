import '../../../core/utils/geometry_utils.dart';
import '../../../shared/models/user_profile.dart';

class NearbyDonorDto {
  final String id;
  final String name;
  final String? bloodGroup;
  final double? latitude;
  final double? longitude;
  final bool isAvailable;
  final double distanceKm;

  const NearbyDonorDto({
    required this.id,
    required this.name,
    this.bloodGroup,
    this.latitude,
    this.longitude,
    this.isAvailable = false,
    this.distanceKm = 0,
  });

  factory NearbyDonorDto.fromJson(Map<String, dynamic> map, {double? refLat, double? refLon}) {
    final lat = (map['latitude'] as num?)?.toDouble();
    final lon = (map['longitude'] as num?)?.toDouble();

    double distance = 0;
    if (lat != null && lon != null && refLat != null && refLon != null) {
      distance = GeometryUtils.calculateDistanceInKm(refLat, refLon, lat, lon);
    }

    return NearbyDonorDto(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      bloodGroup: map['blood_group'] as String?,
      latitude: lat,
      longitude: lon,
      isAvailable: map['is_available'] as bool? ?? false,
      distanceKm: distance,
    );
  }

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      name: name,
      email: '',
      bloodGroup: bloodGroup,
      latitude: latitude,
      longitude: longitude,
      isAvailable: isAvailable,
      role: 'donor',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
