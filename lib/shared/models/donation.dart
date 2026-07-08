// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'donation.freezed.dart';
part 'donation.g.dart';

@freezed
abstract class Donation with _$Donation {
  const factory Donation({
    required String id,
    @JsonKey(name: 'donor_id') required String donorId,
    @JsonKey(name: 'donor_name') String? donorName,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'hospital_id') String? hospitalId,
    @JsonKey(name: 'hospital_name') String? hospitalName,
    @Default(1) int units,
    @JsonKey(name: 'donation_date') required DateTime donationDate,
    String? remarks,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Donation;

  factory Donation.fromJson(Map<String, dynamic> json) => _$DonationFromJson(json);
}

@freezed
abstract class DonationStats with _$DonationStats {
  const DonationStats._();

  const factory DonationStats({
    @Default(0) int totalDonations,
    @Default(0) int totalUnits,
    DateTime? lastDonationDate,
    DateTime? nextEligibleDate,
    String? lastHospitalName,
  }) = _DonationStats;

  factory DonationStats.fromJson(Map<String, dynamic> json) => _$DonationStatsFromJson(json);

  bool get hasDonated => totalDonations > 0;

  String get achievementLevel {
    if (totalDonations >= 10) return 'Platinum Donor';
    if (totalDonations >= 5) return 'Gold Donor';
    if (totalDonations >= 3) return 'Silver Donor';
    if (totalDonations >= 1) return 'First Donor';
    return 'New Donor';
  }
}
