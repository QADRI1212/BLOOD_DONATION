// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blood_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BloodRequest {

 String get id;@JsonKey(name: 'patient_id') String get patientId;@JsonKey(name: 'patient_name') String? get patientName;@JsonKey(name: 'blood_group') String get bloodGroup; int get units;@JsonKey(name: 'hospital_id') String? get hospitalId;@JsonKey(name: 'hospital_name') String? get hospitalName; double get latitude; double get longitude; String? get address; String get status; String get priority; String? get notes;@JsonKey(name: 'donor_id') String? get donorId;@JsonKey(name: 'donor_name') String? get donorName;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of BloodRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BloodRequestCopyWith<BloodRequest> get copyWith => _$BloodRequestCopyWithImpl<BloodRequest>(this as BloodRequest, _$identity);

  /// Serializes this BloodRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BloodRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.bloodGroup, bloodGroup) || other.bloodGroup == bloodGroup)&&(identical(other.units, units) || other.units == units)&&(identical(other.hospitalId, hospitalId) || other.hospitalId == hospitalId)&&(identical(other.hospitalName, hospitalName) || other.hospitalName == hospitalName)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.donorId, donorId) || other.donorId == donorId)&&(identical(other.donorName, donorName) || other.donorName == donorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,patientId,patientName,bloodGroup,units,hospitalId,hospitalName,latitude,longitude,address,status,priority,notes,donorId,donorName,createdAt,updatedAt);

@override
String toString() {
  return 'BloodRequest(id: $id, patientId: $patientId, patientName: $patientName, bloodGroup: $bloodGroup, units: $units, hospitalId: $hospitalId, hospitalName: $hospitalName, latitude: $latitude, longitude: $longitude, address: $address, status: $status, priority: $priority, notes: $notes, donorId: $donorId, donorName: $donorName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BloodRequestCopyWith<$Res>  {
  factory $BloodRequestCopyWith(BloodRequest value, $Res Function(BloodRequest) _then) = _$BloodRequestCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'patient_id') String patientId,@JsonKey(name: 'patient_name') String? patientName,@JsonKey(name: 'blood_group') String bloodGroup, int units,@JsonKey(name: 'hospital_id') String? hospitalId,@JsonKey(name: 'hospital_name') String? hospitalName, double latitude, double longitude, String? address, String status, String priority, String? notes,@JsonKey(name: 'donor_id') String? donorId,@JsonKey(name: 'donor_name') String? donorName,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$BloodRequestCopyWithImpl<$Res>
    implements $BloodRequestCopyWith<$Res> {
  _$BloodRequestCopyWithImpl(this._self, this._then);

  final BloodRequest _self;
  final $Res Function(BloodRequest) _then;

/// Create a copy of BloodRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? patientId = null,Object? patientName = freezed,Object? bloodGroup = null,Object? units = null,Object? hospitalId = freezed,Object? hospitalName = freezed,Object? latitude = null,Object? longitude = null,Object? address = freezed,Object? status = null,Object? priority = null,Object? notes = freezed,Object? donorId = freezed,Object? donorName = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientName: freezed == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String?,bloodGroup: null == bloodGroup ? _self.bloodGroup : bloodGroup // ignore: cast_nullable_to_non_nullable
as String,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as int,hospitalId: freezed == hospitalId ? _self.hospitalId : hospitalId // ignore: cast_nullable_to_non_nullable
as String?,hospitalName: freezed == hospitalName ? _self.hospitalName : hospitalName // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,donorId: freezed == donorId ? _self.donorId : donorId // ignore: cast_nullable_to_non_nullable
as String?,donorName: freezed == donorName ? _self.donorName : donorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BloodRequest].
extension BloodRequestPatterns on BloodRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BloodRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BloodRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BloodRequest value)  $default,){
final _that = this;
switch (_that) {
case _BloodRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BloodRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BloodRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'patient_id')  String patientId, @JsonKey(name: 'patient_name')  String? patientName, @JsonKey(name: 'blood_group')  String bloodGroup,  int units, @JsonKey(name: 'hospital_id')  String? hospitalId, @JsonKey(name: 'hospital_name')  String? hospitalName,  double latitude,  double longitude,  String? address,  String status,  String priority,  String? notes, @JsonKey(name: 'donor_id')  String? donorId, @JsonKey(name: 'donor_name')  String? donorName, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BloodRequest() when $default != null:
return $default(_that.id,_that.patientId,_that.patientName,_that.bloodGroup,_that.units,_that.hospitalId,_that.hospitalName,_that.latitude,_that.longitude,_that.address,_that.status,_that.priority,_that.notes,_that.donorId,_that.donorName,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'patient_id')  String patientId, @JsonKey(name: 'patient_name')  String? patientName, @JsonKey(name: 'blood_group')  String bloodGroup,  int units, @JsonKey(name: 'hospital_id')  String? hospitalId, @JsonKey(name: 'hospital_name')  String? hospitalName,  double latitude,  double longitude,  String? address,  String status,  String priority,  String? notes, @JsonKey(name: 'donor_id')  String? donorId, @JsonKey(name: 'donor_name')  String? donorName, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BloodRequest():
return $default(_that.id,_that.patientId,_that.patientName,_that.bloodGroup,_that.units,_that.hospitalId,_that.hospitalName,_that.latitude,_that.longitude,_that.address,_that.status,_that.priority,_that.notes,_that.donorId,_that.donorName,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'patient_id')  String patientId, @JsonKey(name: 'patient_name')  String? patientName, @JsonKey(name: 'blood_group')  String bloodGroup,  int units, @JsonKey(name: 'hospital_id')  String? hospitalId, @JsonKey(name: 'hospital_name')  String? hospitalName,  double latitude,  double longitude,  String? address,  String status,  String priority,  String? notes, @JsonKey(name: 'donor_id')  String? donorId, @JsonKey(name: 'donor_name')  String? donorName, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BloodRequest() when $default != null:
return $default(_that.id,_that.patientId,_that.patientName,_that.bloodGroup,_that.units,_that.hospitalId,_that.hospitalName,_that.latitude,_that.longitude,_that.address,_that.status,_that.priority,_that.notes,_that.donorId,_that.donorName,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BloodRequest extends BloodRequest {
  const _BloodRequest({required this.id, @JsonKey(name: 'patient_id') required this.patientId, @JsonKey(name: 'patient_name') this.patientName, @JsonKey(name: 'blood_group') required this.bloodGroup, this.units = 1, @JsonKey(name: 'hospital_id') this.hospitalId, @JsonKey(name: 'hospital_name') this.hospitalName, this.latitude = 0.0, this.longitude = 0.0, this.address, this.status = 'pending', this.priority = 'normal', this.notes, @JsonKey(name: 'donor_id') this.donorId, @JsonKey(name: 'donor_name') this.donorName, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): super._();
  factory _BloodRequest.fromJson(Map<String, dynamic> json) => _$BloodRequestFromJson(json);

@override final  String id;
@override@JsonKey(name: 'patient_id') final  String patientId;
@override@JsonKey(name: 'patient_name') final  String? patientName;
@override@JsonKey(name: 'blood_group') final  String bloodGroup;
@override@JsonKey() final  int units;
@override@JsonKey(name: 'hospital_id') final  String? hospitalId;
@override@JsonKey(name: 'hospital_name') final  String? hospitalName;
@override@JsonKey() final  double latitude;
@override@JsonKey() final  double longitude;
@override final  String? address;
@override@JsonKey() final  String status;
@override@JsonKey() final  String priority;
@override final  String? notes;
@override@JsonKey(name: 'donor_id') final  String? donorId;
@override@JsonKey(name: 'donor_name') final  String? donorName;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of BloodRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BloodRequestCopyWith<_BloodRequest> get copyWith => __$BloodRequestCopyWithImpl<_BloodRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BloodRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BloodRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.bloodGroup, bloodGroup) || other.bloodGroup == bloodGroup)&&(identical(other.units, units) || other.units == units)&&(identical(other.hospitalId, hospitalId) || other.hospitalId == hospitalId)&&(identical(other.hospitalName, hospitalName) || other.hospitalName == hospitalName)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.donorId, donorId) || other.donorId == donorId)&&(identical(other.donorName, donorName) || other.donorName == donorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,patientId,patientName,bloodGroup,units,hospitalId,hospitalName,latitude,longitude,address,status,priority,notes,donorId,donorName,createdAt,updatedAt);

@override
String toString() {
  return 'BloodRequest(id: $id, patientId: $patientId, patientName: $patientName, bloodGroup: $bloodGroup, units: $units, hospitalId: $hospitalId, hospitalName: $hospitalName, latitude: $latitude, longitude: $longitude, address: $address, status: $status, priority: $priority, notes: $notes, donorId: $donorId, donorName: $donorName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BloodRequestCopyWith<$Res> implements $BloodRequestCopyWith<$Res> {
  factory _$BloodRequestCopyWith(_BloodRequest value, $Res Function(_BloodRequest) _then) = __$BloodRequestCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'patient_id') String patientId,@JsonKey(name: 'patient_name') String? patientName,@JsonKey(name: 'blood_group') String bloodGroup, int units,@JsonKey(name: 'hospital_id') String? hospitalId,@JsonKey(name: 'hospital_name') String? hospitalName, double latitude, double longitude, String? address, String status, String priority, String? notes,@JsonKey(name: 'donor_id') String? donorId,@JsonKey(name: 'donor_name') String? donorName,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$BloodRequestCopyWithImpl<$Res>
    implements _$BloodRequestCopyWith<$Res> {
  __$BloodRequestCopyWithImpl(this._self, this._then);

  final _BloodRequest _self;
  final $Res Function(_BloodRequest) _then;

/// Create a copy of BloodRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? patientId = null,Object? patientName = freezed,Object? bloodGroup = null,Object? units = null,Object? hospitalId = freezed,Object? hospitalName = freezed,Object? latitude = null,Object? longitude = null,Object? address = freezed,Object? status = null,Object? priority = null,Object? notes = freezed,Object? donorId = freezed,Object? donorName = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_BloodRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientName: freezed == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String?,bloodGroup: null == bloodGroup ? _self.bloodGroup : bloodGroup // ignore: cast_nullable_to_non_nullable
as String,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as int,hospitalId: freezed == hospitalId ? _self.hospitalId : hospitalId // ignore: cast_nullable_to_non_nullable
as String?,hospitalName: freezed == hospitalName ? _self.hospitalName : hospitalName // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,donorId: freezed == donorId ? _self.donorId : donorId // ignore: cast_nullable_to_non_nullable
as String?,donorName: freezed == donorName ? _self.donorName : donorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
