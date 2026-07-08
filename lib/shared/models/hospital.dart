// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hospital.freezed.dart';
part 'hospital.g.dart';

@freezed
abstract class Hospital with _$Hospital {
  const factory Hospital({
    required String id,
    @Default('') String name,
    String? address,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    String? phone,
    String? hours,
    @Default(false) bool verified,
    double? distance,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Hospital;

  factory Hospital.fromJson(Map<String, dynamic> json) => _$HospitalFromJson(json);
}

@freezed
abstract class BloodBank with _$BloodBank {
  const factory BloodBank({
    required String id,
    @Default('') String name,
    String? address,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    String? phone,
    @Default(false) bool verified,
    double? distance,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BloodBank;

  factory BloodBank.fromJson(Map<String, dynamic> json) => _$BloodBankFromJson(json);
}
