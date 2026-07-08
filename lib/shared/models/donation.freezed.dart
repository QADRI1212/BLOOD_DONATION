// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'donation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Donation {

 String get id;@JsonKey(name: 'donor_id') String get donorId;@JsonKey(name: 'donor_name') String? get donorName;@JsonKey(name: 'blood_group') String? get bloodGroup;@JsonKey(name: 'hospital_id') String? get hospitalId;@JsonKey(name: 'hospital_name') String? get hospitalName; int get units;@JsonKey(name: 'donation_date') DateTime get donationDate; String? get remarks;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Donation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DonationCopyWith<Donation> get copyWith => _$DonationCopyWithImpl<Donation>(this as Donation, _$identity);

  /// Serializes this Donation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Donation&&(identical(other.id, id) || other.id == id)&&(identical(other.donorId, donorId) || other.donorId == donorId)&&(identical(other.donorName, donorName) || other.donorName == donorName)&&(identical(other.bloodGroup, bloodGroup) || other.bloodGroup == bloodGroup)&&(identical(other.hospitalId, hospitalId) || other.hospitalId == hospitalId)&&(identical(other.hospitalName, hospitalName) || other.hospitalName == hospitalName)&&(identical(other.units, units) || other.units == units)&&(identical(other.donationDate, donationDate) || other.donationDate == donationDate)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,donorId,donorName,bloodGroup,hospitalId,hospitalName,units,donationDate,remarks,createdAt);

@override
String toString() {
  return 'Donation(id: $id, donorId: $donorId, donorName: $donorName, bloodGroup: $bloodGroup, hospitalId: $hospitalId, hospitalName: $hospitalName, units: $units, donationDate: $donationDate, remarks: $remarks, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DonationCopyWith<$Res>  {
  factory $DonationCopyWith(Donation value, $Res Function(Donation) _then) = _$DonationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'donor_id') String donorId,@JsonKey(name: 'donor_name') String? donorName,@JsonKey(name: 'blood_group') String? bloodGroup,@JsonKey(name: 'hospital_id') String? hospitalId,@JsonKey(name: 'hospital_name') String? hospitalName, int units,@JsonKey(name: 'donation_date') DateTime donationDate, String? remarks,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$DonationCopyWithImpl<$Res>
    implements $DonationCopyWith<$Res> {
  _$DonationCopyWithImpl(this._self, this._then);

  final Donation _self;
  final $Res Function(Donation) _then;

/// Create a copy of Donation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? donorId = null,Object? donorName = freezed,Object? bloodGroup = freezed,Object? hospitalId = freezed,Object? hospitalName = freezed,Object? units = null,Object? donationDate = null,Object? remarks = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,donorId: null == donorId ? _self.donorId : donorId // ignore: cast_nullable_to_non_nullable
as String,donorName: freezed == donorName ? _self.donorName : donorName // ignore: cast_nullable_to_non_nullable
as String?,bloodGroup: freezed == bloodGroup ? _self.bloodGroup : bloodGroup // ignore: cast_nullable_to_non_nullable
as String?,hospitalId: freezed == hospitalId ? _self.hospitalId : hospitalId // ignore: cast_nullable_to_non_nullable
as String?,hospitalName: freezed == hospitalName ? _self.hospitalName : hospitalName // ignore: cast_nullable_to_non_nullable
as String?,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as int,donationDate: null == donationDate ? _self.donationDate : donationDate // ignore: cast_nullable_to_non_nullable
as DateTime,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Donation].
extension DonationPatterns on Donation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Donation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Donation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Donation value)  $default,){
final _that = this;
switch (_that) {
case _Donation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Donation value)?  $default,){
final _that = this;
switch (_that) {
case _Donation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'donor_id')  String donorId, @JsonKey(name: 'donor_name')  String? donorName, @JsonKey(name: 'blood_group')  String? bloodGroup, @JsonKey(name: 'hospital_id')  String? hospitalId, @JsonKey(name: 'hospital_name')  String? hospitalName,  int units, @JsonKey(name: 'donation_date')  DateTime donationDate,  String? remarks, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Donation() when $default != null:
return $default(_that.id,_that.donorId,_that.donorName,_that.bloodGroup,_that.hospitalId,_that.hospitalName,_that.units,_that.donationDate,_that.remarks,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'donor_id')  String donorId, @JsonKey(name: 'donor_name')  String? donorName, @JsonKey(name: 'blood_group')  String? bloodGroup, @JsonKey(name: 'hospital_id')  String? hospitalId, @JsonKey(name: 'hospital_name')  String? hospitalName,  int units, @JsonKey(name: 'donation_date')  DateTime donationDate,  String? remarks, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Donation():
return $default(_that.id,_that.donorId,_that.donorName,_that.bloodGroup,_that.hospitalId,_that.hospitalName,_that.units,_that.donationDate,_that.remarks,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'donor_id')  String donorId, @JsonKey(name: 'donor_name')  String? donorName, @JsonKey(name: 'blood_group')  String? bloodGroup, @JsonKey(name: 'hospital_id')  String? hospitalId, @JsonKey(name: 'hospital_name')  String? hospitalName,  int units, @JsonKey(name: 'donation_date')  DateTime donationDate,  String? remarks, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Donation() when $default != null:
return $default(_that.id,_that.donorId,_that.donorName,_that.bloodGroup,_that.hospitalId,_that.hospitalName,_that.units,_that.donationDate,_that.remarks,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Donation implements Donation {
  const _Donation({required this.id, @JsonKey(name: 'donor_id') required this.donorId, @JsonKey(name: 'donor_name') this.donorName, @JsonKey(name: 'blood_group') this.bloodGroup, @JsonKey(name: 'hospital_id') this.hospitalId, @JsonKey(name: 'hospital_name') this.hospitalName, this.units = 1, @JsonKey(name: 'donation_date') required this.donationDate, this.remarks, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Donation.fromJson(Map<String, dynamic> json) => _$DonationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'donor_id') final  String donorId;
@override@JsonKey(name: 'donor_name') final  String? donorName;
@override@JsonKey(name: 'blood_group') final  String? bloodGroup;
@override@JsonKey(name: 'hospital_id') final  String? hospitalId;
@override@JsonKey(name: 'hospital_name') final  String? hospitalName;
@override@JsonKey() final  int units;
@override@JsonKey(name: 'donation_date') final  DateTime donationDate;
@override final  String? remarks;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Donation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DonationCopyWith<_Donation> get copyWith => __$DonationCopyWithImpl<_Donation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DonationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Donation&&(identical(other.id, id) || other.id == id)&&(identical(other.donorId, donorId) || other.donorId == donorId)&&(identical(other.donorName, donorName) || other.donorName == donorName)&&(identical(other.bloodGroup, bloodGroup) || other.bloodGroup == bloodGroup)&&(identical(other.hospitalId, hospitalId) || other.hospitalId == hospitalId)&&(identical(other.hospitalName, hospitalName) || other.hospitalName == hospitalName)&&(identical(other.units, units) || other.units == units)&&(identical(other.donationDate, donationDate) || other.donationDate == donationDate)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,donorId,donorName,bloodGroup,hospitalId,hospitalName,units,donationDate,remarks,createdAt);

@override
String toString() {
  return 'Donation(id: $id, donorId: $donorId, donorName: $donorName, bloodGroup: $bloodGroup, hospitalId: $hospitalId, hospitalName: $hospitalName, units: $units, donationDate: $donationDate, remarks: $remarks, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DonationCopyWith<$Res> implements $DonationCopyWith<$Res> {
  factory _$DonationCopyWith(_Donation value, $Res Function(_Donation) _then) = __$DonationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'donor_id') String donorId,@JsonKey(name: 'donor_name') String? donorName,@JsonKey(name: 'blood_group') String? bloodGroup,@JsonKey(name: 'hospital_id') String? hospitalId,@JsonKey(name: 'hospital_name') String? hospitalName, int units,@JsonKey(name: 'donation_date') DateTime donationDate, String? remarks,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$DonationCopyWithImpl<$Res>
    implements _$DonationCopyWith<$Res> {
  __$DonationCopyWithImpl(this._self, this._then);

  final _Donation _self;
  final $Res Function(_Donation) _then;

/// Create a copy of Donation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? donorId = null,Object? donorName = freezed,Object? bloodGroup = freezed,Object? hospitalId = freezed,Object? hospitalName = freezed,Object? units = null,Object? donationDate = null,Object? remarks = freezed,Object? createdAt = null,}) {
  return _then(_Donation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,donorId: null == donorId ? _self.donorId : donorId // ignore: cast_nullable_to_non_nullable
as String,donorName: freezed == donorName ? _self.donorName : donorName // ignore: cast_nullable_to_non_nullable
as String?,bloodGroup: freezed == bloodGroup ? _self.bloodGroup : bloodGroup // ignore: cast_nullable_to_non_nullable
as String?,hospitalId: freezed == hospitalId ? _self.hospitalId : hospitalId // ignore: cast_nullable_to_non_nullable
as String?,hospitalName: freezed == hospitalName ? _self.hospitalName : hospitalName // ignore: cast_nullable_to_non_nullable
as String?,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as int,donationDate: null == donationDate ? _self.donationDate : donationDate // ignore: cast_nullable_to_non_nullable
as DateTime,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$DonationStats {

 int get totalDonations; int get totalUnits; DateTime? get lastDonationDate; DateTime? get nextEligibleDate; String? get lastHospitalName;
/// Create a copy of DonationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DonationStatsCopyWith<DonationStats> get copyWith => _$DonationStatsCopyWithImpl<DonationStats>(this as DonationStats, _$identity);

  /// Serializes this DonationStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DonationStats&&(identical(other.totalDonations, totalDonations) || other.totalDonations == totalDonations)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.lastDonationDate, lastDonationDate) || other.lastDonationDate == lastDonationDate)&&(identical(other.nextEligibleDate, nextEligibleDate) || other.nextEligibleDate == nextEligibleDate)&&(identical(other.lastHospitalName, lastHospitalName) || other.lastHospitalName == lastHospitalName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalDonations,totalUnits,lastDonationDate,nextEligibleDate,lastHospitalName);

@override
String toString() {
  return 'DonationStats(totalDonations: $totalDonations, totalUnits: $totalUnits, lastDonationDate: $lastDonationDate, nextEligibleDate: $nextEligibleDate, lastHospitalName: $lastHospitalName)';
}


}

/// @nodoc
abstract mixin class $DonationStatsCopyWith<$Res>  {
  factory $DonationStatsCopyWith(DonationStats value, $Res Function(DonationStats) _then) = _$DonationStatsCopyWithImpl;
@useResult
$Res call({
 int totalDonations, int totalUnits, DateTime? lastDonationDate, DateTime? nextEligibleDate, String? lastHospitalName
});




}
/// @nodoc
class _$DonationStatsCopyWithImpl<$Res>
    implements $DonationStatsCopyWith<$Res> {
  _$DonationStatsCopyWithImpl(this._self, this._then);

  final DonationStats _self;
  final $Res Function(DonationStats) _then;

/// Create a copy of DonationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalDonations = null,Object? totalUnits = null,Object? lastDonationDate = freezed,Object? nextEligibleDate = freezed,Object? lastHospitalName = freezed,}) {
  return _then(_self.copyWith(
totalDonations: null == totalDonations ? _self.totalDonations : totalDonations // ignore: cast_nullable_to_non_nullable
as int,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,lastDonationDate: freezed == lastDonationDate ? _self.lastDonationDate : lastDonationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nextEligibleDate: freezed == nextEligibleDate ? _self.nextEligibleDate : nextEligibleDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastHospitalName: freezed == lastHospitalName ? _self.lastHospitalName : lastHospitalName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DonationStats].
extension DonationStatsPatterns on DonationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DonationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DonationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DonationStats value)  $default,){
final _that = this;
switch (_that) {
case _DonationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DonationStats value)?  $default,){
final _that = this;
switch (_that) {
case _DonationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalDonations,  int totalUnits,  DateTime? lastDonationDate,  DateTime? nextEligibleDate,  String? lastHospitalName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DonationStats() when $default != null:
return $default(_that.totalDonations,_that.totalUnits,_that.lastDonationDate,_that.nextEligibleDate,_that.lastHospitalName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalDonations,  int totalUnits,  DateTime? lastDonationDate,  DateTime? nextEligibleDate,  String? lastHospitalName)  $default,) {final _that = this;
switch (_that) {
case _DonationStats():
return $default(_that.totalDonations,_that.totalUnits,_that.lastDonationDate,_that.nextEligibleDate,_that.lastHospitalName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalDonations,  int totalUnits,  DateTime? lastDonationDate,  DateTime? nextEligibleDate,  String? lastHospitalName)?  $default,) {final _that = this;
switch (_that) {
case _DonationStats() when $default != null:
return $default(_that.totalDonations,_that.totalUnits,_that.lastDonationDate,_that.nextEligibleDate,_that.lastHospitalName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DonationStats extends DonationStats {
  const _DonationStats({this.totalDonations = 0, this.totalUnits = 0, this.lastDonationDate, this.nextEligibleDate, this.lastHospitalName}): super._();
  factory _DonationStats.fromJson(Map<String, dynamic> json) => _$DonationStatsFromJson(json);

@override@JsonKey() final  int totalDonations;
@override@JsonKey() final  int totalUnits;
@override final  DateTime? lastDonationDate;
@override final  DateTime? nextEligibleDate;
@override final  String? lastHospitalName;

/// Create a copy of DonationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DonationStatsCopyWith<_DonationStats> get copyWith => __$DonationStatsCopyWithImpl<_DonationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DonationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DonationStats&&(identical(other.totalDonations, totalDonations) || other.totalDonations == totalDonations)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.lastDonationDate, lastDonationDate) || other.lastDonationDate == lastDonationDate)&&(identical(other.nextEligibleDate, nextEligibleDate) || other.nextEligibleDate == nextEligibleDate)&&(identical(other.lastHospitalName, lastHospitalName) || other.lastHospitalName == lastHospitalName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalDonations,totalUnits,lastDonationDate,nextEligibleDate,lastHospitalName);

@override
String toString() {
  return 'DonationStats(totalDonations: $totalDonations, totalUnits: $totalUnits, lastDonationDate: $lastDonationDate, nextEligibleDate: $nextEligibleDate, lastHospitalName: $lastHospitalName)';
}


}

/// @nodoc
abstract mixin class _$DonationStatsCopyWith<$Res> implements $DonationStatsCopyWith<$Res> {
  factory _$DonationStatsCopyWith(_DonationStats value, $Res Function(_DonationStats) _then) = __$DonationStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalDonations, int totalUnits, DateTime? lastDonationDate, DateTime? nextEligibleDate, String? lastHospitalName
});




}
/// @nodoc
class __$DonationStatsCopyWithImpl<$Res>
    implements _$DonationStatsCopyWith<$Res> {
  __$DonationStatsCopyWithImpl(this._self, this._then);

  final _DonationStats _self;
  final $Res Function(_DonationStats) _then;

/// Create a copy of DonationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalDonations = null,Object? totalUnits = null,Object? lastDonationDate = freezed,Object? nextEligibleDate = freezed,Object? lastHospitalName = freezed,}) {
  return _then(_DonationStats(
totalDonations: null == totalDonations ? _self.totalDonations : totalDonations // ignore: cast_nullable_to_non_nullable
as int,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,lastDonationDate: freezed == lastDonationDate ? _self.lastDonationDate : lastDonationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nextEligibleDate: freezed == nextEligibleDate ? _self.nextEligibleDate : nextEligibleDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastHospitalName: freezed == lastHospitalName ? _self.lastHospitalName : lastHospitalName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
