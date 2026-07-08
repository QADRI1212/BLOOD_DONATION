// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'blood_request.freezed.dart';
part 'blood_request.g.dart';

@freezed
abstract class BloodRequest with _$BloodRequest {
  const BloodRequest._();

  const factory BloodRequest({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'patient_name') String? patientName,
    @JsonKey(name: 'blood_group') required String bloodGroup,
    @Default(1) int units,
    @JsonKey(name: 'hospital_id') String? hospitalId,
    @JsonKey(name: 'hospital_name') String? hospitalName,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    String? address,
    @Default('pending') String status,
    @Default('normal') String priority,
    String? notes,
    @JsonKey(name: 'donor_id') String? donorId,
    @JsonKey(name: 'donor_name') String? donorName,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BloodRequest;

  factory BloodRequest.fromJson(Map<String, dynamic> json) => _$BloodRequestFromJson(json);

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isCritical => priority == 'critical';
  bool get isUrgent => priority == 'urgent';
}
