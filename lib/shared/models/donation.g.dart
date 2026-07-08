// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Donation _$DonationFromJson(Map<String, dynamic> json) => _Donation(
  id: json['id'] as String,
  donorId: json['donor_id'] as String,
  donorName: json['donor_name'] as String?,
  bloodGroup: json['blood_group'] as String?,
  hospitalId: json['hospital_id'] as String?,
  hospitalName: json['hospital_name'] as String?,
  units: (json['units'] as num?)?.toInt() ?? 1,
  donationDate: DateTime.parse(json['donation_date'] as String),
  remarks: json['remarks'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$DonationToJson(_Donation instance) => <String, dynamic>{
  'id': instance.id,
  'donor_id': instance.donorId,
  'donor_name': instance.donorName,
  'blood_group': instance.bloodGroup,
  'hospital_id': instance.hospitalId,
  'hospital_name': instance.hospitalName,
  'units': instance.units,
  'donation_date': instance.donationDate.toIso8601String(),
  'remarks': instance.remarks,
  'created_at': instance.createdAt.toIso8601String(),
};

_DonationStats _$DonationStatsFromJson(Map<String, dynamic> json) =>
    _DonationStats(
      totalDonations: (json['totalDonations'] as num?)?.toInt() ?? 0,
      totalUnits: (json['totalUnits'] as num?)?.toInt() ?? 0,
      lastDonationDate: json['lastDonationDate'] == null
          ? null
          : DateTime.parse(json['lastDonationDate'] as String),
      nextEligibleDate: json['nextEligibleDate'] == null
          ? null
          : DateTime.parse(json['nextEligibleDate'] as String),
      lastHospitalName: json['lastHospitalName'] as String?,
    );

Map<String, dynamic> _$DonationStatsToJson(_DonationStats instance) =>
    <String, dynamic>{
      'totalDonations': instance.totalDonations,
      'totalUnits': instance.totalUnits,
      'lastDonationDate': instance.lastDonationDate?.toIso8601String(),
      'nextEligibleDate': instance.nextEligibleDate?.toIso8601String(),
      'lastHospitalName': instance.lastHospitalName,
    };
