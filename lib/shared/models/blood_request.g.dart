// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BloodRequest _$BloodRequestFromJson(Map<String, dynamic> json) =>
    _BloodRequest(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String?,
      bloodGroup: json['blood_group'] as String,
      units: (json['units'] as num?)?.toInt() ?? 1,
      hospitalId: json['hospital_id'] as String?,
      hospitalName: json['hospital_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'pending',
      priority: json['priority'] as String? ?? 'normal',
      notes: json['notes'] as String?,
      donorId: json['donor_id'] as String?,
      donorName: json['donor_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BloodRequestToJson(_BloodRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'patient_name': instance.patientName,
      'blood_group': instance.bloodGroup,
      'units': instance.units,
      'hospital_id': instance.hospitalId,
      'hospital_name': instance.hospitalName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'status': instance.status,
      'priority': instance.priority,
      'notes': instance.notes,
      'donor_id': instance.donorId,
      'donor_name': instance.donorName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
