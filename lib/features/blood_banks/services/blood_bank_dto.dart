import '../../../shared/models/hospital.dart';

class BloodBankDto {
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String createdAt;

  const BloodBankDto({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    required this.createdAt,
  });

  factory BloodBankDto.fromJson(Map<String, dynamic> map) {
    return BloodBankDto(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      address: map['address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: map['phone'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  BloodBank toDomain() {
    return BloodBank(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
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
      'created_at': createdAt,
    };
  }
}
