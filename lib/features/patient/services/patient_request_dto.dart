import '../../../shared/models/blood_request.dart';

class PatientRequestDto {
  final String id;
  final String patientId;
  final String? patientName;
  final String bloodGroup;
  final int units;
  final String? hospitalId;
  final String? hospitalName;
  final double latitude;
  final double longitude;
  final String? address;
  final String status;
  final String priority;
  final String? notes;
  final String? donorId;
  final String? donorName;
  final String createdAt;
  final String? updatedAt;

  const PatientRequestDto({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.bloodGroup,
    required this.units,
    this.hospitalId,
    this.hospitalName,
    required this.latitude,
    required this.longitude,
    this.address,
    this.status = 'pending',
    this.priority = 'normal',
    this.notes,
    this.donorId,
    this.donorName,
    required this.createdAt,
    this.updatedAt,
  });

  factory PatientRequestDto.fromJson(Map<String, dynamic> map) {
    return PatientRequestDto(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      patientName: map['patient_name'] as String?,
      bloodGroup: map['blood_group'] as String,
      units: map['units'] as int? ?? 1,
      hospitalId: map['hospital_id'] as String?,
      hospitalName: map['hospital_name'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String?,
      status: map['status'] as String? ?? 'pending',
      priority: map['priority'] as String? ?? 'normal',
      notes: map['notes'] as String?,
      donorId: map['donor_id'] as String?,
      donorName: map['donor_name'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String?,
    );
  }

  BloodRequest toDomain() {
    return BloodRequest(
      id: id,
      patientId: patientId,
      patientName: patientName,
      bloodGroup: bloodGroup,
      units: units,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      latitude: latitude,
      longitude: longitude,
      address: address,
      status: status,
      priority: priority,
      notes: notes,
      donorId: donorId,
      donorName: donorName,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'blood_group': bloodGroup,
      'units': units,
      'hospital_id': hospitalId,
      'hospital_name': hospitalName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': status,
      'priority': priority,
      'notes': notes,
      'donor_id': donorId,
      'donor_name': donorName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
