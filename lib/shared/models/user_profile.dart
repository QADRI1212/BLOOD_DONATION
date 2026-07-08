// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String id,
    @Default('') String name,
    @Default('') String email,
    String? phone,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    String? gender,
    int? age,
    double? weight,
    String? city,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'last_donation_date') DateTime? lastDonationDate,
    @JsonKey(name: 'is_available') @Default(false) bool isAvailable,
    @Default('donor') String role,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get isDonor => role == 'donor';
  bool get isPatient => role == 'patient';
  bool get isHospital => role == 'hospital';
  bool get isAdmin => role == 'admin';
}
