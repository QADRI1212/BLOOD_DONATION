// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hospital.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Hospital _$HospitalFromJson(Map<String, dynamic> json) => _Hospital(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
  phone: json['phone'] as String?,
  hours: json['hours'] as String?,
  verified: json['verified'] as bool? ?? false,
  distance: (json['distance'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$HospitalToJson(_Hospital instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phone': instance.phone,
  'hours': instance.hours,
  'verified': instance.verified,
  'distance': instance.distance,
  'created_at': instance.createdAt.toIso8601String(),
};

_BloodBank _$BloodBankFromJson(Map<String, dynamic> json) => _BloodBank(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
  phone: json['phone'] as String?,
  verified: json['verified'] as bool? ?? false,
  distance: (json['distance'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BloodBankToJson(_BloodBank instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'verified': instance.verified,
      'distance': instance.distance,
      'created_at': instance.createdAt.toIso8601String(),
    };
