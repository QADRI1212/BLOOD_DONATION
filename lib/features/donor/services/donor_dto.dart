import '../../../shared/models/user_profile.dart';

class DonorDto {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? bloodGroup;
  final String? gender;
  final int? age;
  final double? weight;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? lastDonationDate;
  final bool isAvailable;
  final String role;
  final String? avatarUrl;
  final String createdAt;
  final String updatedAt;

  const DonorDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.bloodGroup,
    this.gender,
    this.age,
    this.weight,
    this.city,
    this.latitude,
    this.longitude,
    this.lastDonationDate,
    this.isAvailable = false,
    this.role = 'donor',
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DonorDto.fromJson(Map<String, dynamic> map) {
    return DonorDto(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      bloodGroup: map['blood_group'] as String?,
      gender: map['gender'] as String?,
      age: map['age'] as int?,
      weight: (map['weight'] as num?)?.toDouble(),
      city: map['city'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      lastDonationDate: map['last_donation_date'] as String?,
      isAvailable: map['is_available'] as bool? ?? false,
      role: map['role'] as String? ?? 'donor',
      avatarUrl: map['avatar_url'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  UserProfile toDomain() {
    DateTime? parsedLastDonation;
    if (lastDonationDate != null) {
      parsedLastDonation = DateTime.tryParse(lastDonationDate!);
    }

    return UserProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      bloodGroup: bloodGroup,
      gender: gender,
      age: age,
      weight: weight,
      city: city,
      latitude: latitude,
      longitude: longitude,
      lastDonationDate: parsedLastDonation,
      isAvailable: isAvailable,
      role: role,
      avatarUrl: avatarUrl,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
