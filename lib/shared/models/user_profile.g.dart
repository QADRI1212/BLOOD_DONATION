// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  phone: json['phone'] as String?,
  bloodGroup: json['blood_group'] as String?,
  gender: json['gender'] as String?,
  age: (json['age'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  city: json['city'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  lastDonationDate: json['last_donation_date'] == null
      ? null
      : DateTime.parse(json['last_donation_date'] as String),
  isAvailable: json['is_available'] as bool? ?? false,
  role: json['role'] as String? ?? 'donor',
  avatarUrl: json['avatar_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'blood_group': instance.bloodGroup,
      'gender': instance.gender,
      'age': instance.age,
      'weight': instance.weight,
      'city': instance.city,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'last_donation_date': instance.lastDonationDate?.toIso8601String(),
      'is_available': instance.isAvailable,
      'role': instance.role,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
