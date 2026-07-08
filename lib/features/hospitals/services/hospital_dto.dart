import '../../../shared/models/hospital.dart';

class HospitalDto {
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? hours;
  final bool verified;
  final String createdAt;

  const HospitalDto({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.hours,
    this.verified = false,
    required this.createdAt,
  });

  factory HospitalDto.fromJson(Map<String, dynamic> map) {
    return HospitalDto(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      address: map['address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: map['phone'] as String?,
      hours: map['hours'] as String?,
      verified: map['verified'] as bool? ?? false,
      createdAt: map['created_at'] as String,
    );
  }

  Hospital toDomain() {
    return Hospital(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      hours: hours,
      verified: verified,
      createdAt: DateTime.parse(createdAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'hours': hours,
      'verified': verified,
      'created_at': createdAt,
    };
  }
}
