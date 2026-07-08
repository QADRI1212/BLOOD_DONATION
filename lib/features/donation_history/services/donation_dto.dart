import '../../../shared/models/donation.dart';

class DonationDto {
  final String id;
  final String donorId;
  final String? donorName;
  final String? bloodGroup;
  final String? hospitalId;
  final String? hospitalName;
  final int units;
  final String donationDate;
  final String? remarks;
  final String createdAt;

  const DonationDto({
    required this.id,
    required this.donorId,
    this.donorName,
    this.bloodGroup,
    this.hospitalId,
    this.hospitalName,
    required this.units,
    required this.donationDate,
    this.remarks,
    required this.createdAt,
  });

  factory DonationDto.fromJson(Map<String, dynamic> map) {
    return DonationDto(
      id: map['id'] as String,
      donorId: map['donor_id'] as String,
      donorName: map['donor_name'] as String?,
      bloodGroup: map['blood_group'] as String?,
      hospitalId: map['hospital_id'] as String?,
      hospitalName: map['hospital_name'] as String?,
      units: map['units'] as int? ?? 1,
      donationDate: map['donation_date'] as String,
      remarks: map['remarks'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Donation toDomain() {
    return Donation(
      id: id,
      donorId: donorId,
      donorName: donorName,
      bloodGroup: bloodGroup,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      units: units,
      donationDate: DateTime.parse(donationDate),
      remarks: remarks,
      createdAt: DateTime.parse(createdAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donor_id': donorId,
      'donor_name': donorName,
      'blood_group': bloodGroup,
      'hospital_id': hospitalId,
      'hospital_name': hospitalName,
      'units': units,
      'donation_date': donationDate,
      'remarks': remarks,
      'created_at': createdAt,
    };
  }
}

class DonationStatsDto {
  final int totalDonations;
  final int totalUnits;
  final String? lastDonationDate;
  final String? lastHospitalName;

  const DonationStatsDto({
    this.totalDonations = 0,
    this.totalUnits = 0,
    this.lastDonationDate,
    this.lastHospitalName,
  });

  factory DonationStatsDto.fromJson(Map<String, dynamic> map) {
    return DonationStatsDto(
      totalDonations: (map['total_donations'] as num?)?.toInt() ?? 0,
      totalUnits: (map['total_units'] as num?)?.toInt() ?? 0,
      lastDonationDate: map['last_donation_date'] as String?,
      lastHospitalName: map['last_hospital_name'] as String?,
    );
  }

  DonationStats toDomain() {
    return DonationStats(
      totalDonations: totalDonations,
      totalUnits: totalUnits,
      lastDonationDate: lastDonationDate != null
          ? DateTime.tryParse(lastDonationDate!)
          : null,
      nextEligibleDate: lastDonationDate != null
          ? DateTime.tryParse(lastDonationDate!)?.add(const Duration(days: 90))
          : null,
      lastHospitalName: lastHospitalName,
    );
  }
}
