// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hospital.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Hospital {

 String get id; String get name; String? get address; double get latitude; double get longitude; String? get phone; String? get hours; bool get verified; double? get distance;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Hospital
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HospitalCopyWith<Hospital> get copyWith => _$HospitalCopyWithImpl<Hospital>(this as Hospital, _$identity);

  /// Serializes this Hospital to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hospital&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,latitude,longitude,phone,hours,verified,distance,createdAt);

@override
String toString() {
  return 'Hospital(id: $id, name: $name, address: $address, latitude: $latitude, longitude: $longitude, phone: $phone, hours: $hours, verified: $verified, distance: $distance, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $HospitalCopyWith<$Res>  {
  factory $HospitalCopyWith(Hospital value, $Res Function(Hospital) _then) = _$HospitalCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? address, double latitude, double longitude, String? phone, String? hours, bool verified, double? distance,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$HospitalCopyWithImpl<$Res>
    implements $HospitalCopyWith<$Res> {
  _$HospitalCopyWithImpl(this._self, this._then);

  final Hospital _self;
  final $Res Function(Hospital) _then;

/// Create a copy of Hospital
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = freezed,Object? latitude = null,Object? longitude = null,Object? phone = freezed,Object? hours = freezed,Object? verified = null,Object? distance = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,hours: freezed == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Hospital].
extension HospitalPatterns on Hospital {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Hospital value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Hospital() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Hospital value)  $default,){
final _that = this;
switch (_that) {
case _Hospital():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Hospital value)?  $default,){
final _that = this;
switch (_that) {
case _Hospital() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? address,  double latitude,  double longitude,  String? phone,  String? hours,  bool verified,  double? distance, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Hospital() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.latitude,_that.longitude,_that.phone,_that.hours,_that.verified,_that.distance,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? address,  double latitude,  double longitude,  String? phone,  String? hours,  bool verified,  double? distance, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Hospital():
return $default(_that.id,_that.name,_that.address,_that.latitude,_that.longitude,_that.phone,_that.hours,_that.verified,_that.distance,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? address,  double latitude,  double longitude,  String? phone,  String? hours,  bool verified,  double? distance, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Hospital() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.latitude,_that.longitude,_that.phone,_that.hours,_that.verified,_that.distance,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Hospital implements Hospital {
  const _Hospital({required this.id, this.name = '', this.address, this.latitude = 0.0, this.longitude = 0.0, this.phone, this.hours, this.verified = false, this.distance, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Hospital.fromJson(Map<String, dynamic> json) => _$HospitalFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override final  String? address;
@override@JsonKey() final  double latitude;
@override@JsonKey() final  double longitude;
@override final  String? phone;
@override final  String? hours;
@override@JsonKey() final  bool verified;
@override final  double? distance;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Hospital
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HospitalCopyWith<_Hospital> get copyWith => __$HospitalCopyWithImpl<_Hospital>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HospitalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hospital&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,latitude,longitude,phone,hours,verified,distance,createdAt);

@override
String toString() {
  return 'Hospital(id: $id, name: $name, address: $address, latitude: $latitude, longitude: $longitude, phone: $phone, hours: $hours, verified: $verified, distance: $distance, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$HospitalCopyWith<$Res> implements $HospitalCopyWith<$Res> {
  factory _$HospitalCopyWith(_Hospital value, $Res Function(_Hospital) _then) = __$HospitalCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? address, double latitude, double longitude, String? phone, String? hours, bool verified, double? distance,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$HospitalCopyWithImpl<$Res>
    implements _$HospitalCopyWith<$Res> {
  __$HospitalCopyWithImpl(this._self, this._then);

  final _Hospital _self;
  final $Res Function(_Hospital) _then;

/// Create a copy of Hospital
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = freezed,Object? latitude = null,Object? longitude = null,Object? phone = freezed,Object? hours = freezed,Object? verified = null,Object? distance = freezed,Object? createdAt = null,}) {
  return _then(_Hospital(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,hours: freezed == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$BloodBank {

 String get id; String get name; String? get address; double get latitude; double get longitude; String? get phone; bool get verified; double? get distance;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of BloodBank
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BloodBankCopyWith<BloodBank> get copyWith => _$BloodBankCopyWithImpl<BloodBank>(this as BloodBank, _$identity);

  /// Serializes this BloodBank to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BloodBank&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,latitude,longitude,phone,verified,distance,createdAt);

@override
String toString() {
  return 'BloodBank(id: $id, name: $name, address: $address, latitude: $latitude, longitude: $longitude, phone: $phone, verified: $verified, distance: $distance, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BloodBankCopyWith<$Res>  {
  factory $BloodBankCopyWith(BloodBank value, $Res Function(BloodBank) _then) = _$BloodBankCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? address, double latitude, double longitude, String? phone, bool verified, double? distance,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$BloodBankCopyWithImpl<$Res>
    implements $BloodBankCopyWith<$Res> {
  _$BloodBankCopyWithImpl(this._self, this._then);

  final BloodBank _self;
  final $Res Function(BloodBank) _then;

/// Create a copy of BloodBank
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = freezed,Object? latitude = null,Object? longitude = null,Object? phone = freezed,Object? verified = null,Object? distance = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BloodBank].
extension BloodBankPatterns on BloodBank {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BloodBank value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BloodBank() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BloodBank value)  $default,){
final _that = this;
switch (_that) {
case _BloodBank():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BloodBank value)?  $default,){
final _that = this;
switch (_that) {
case _BloodBank() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? address,  double latitude,  double longitude,  String? phone,  bool verified,  double? distance, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BloodBank() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.latitude,_that.longitude,_that.phone,_that.verified,_that.distance,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? address,  double latitude,  double longitude,  String? phone,  bool verified,  double? distance, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BloodBank():
return $default(_that.id,_that.name,_that.address,_that.latitude,_that.longitude,_that.phone,_that.verified,_that.distance,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? address,  double latitude,  double longitude,  String? phone,  bool verified,  double? distance, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BloodBank() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.latitude,_that.longitude,_that.phone,_that.verified,_that.distance,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BloodBank implements BloodBank {
  const _BloodBank({required this.id, this.name = '', this.address, this.latitude = 0.0, this.longitude = 0.0, this.phone, this.verified = false, this.distance, @JsonKey(name: 'created_at') required this.createdAt});
  factory _BloodBank.fromJson(Map<String, dynamic> json) => _$BloodBankFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override final  String? address;
@override@JsonKey() final  double latitude;
@override@JsonKey() final  double longitude;
@override final  String? phone;
@override@JsonKey() final  bool verified;
@override final  double? distance;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of BloodBank
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BloodBankCopyWith<_BloodBank> get copyWith => __$BloodBankCopyWithImpl<_BloodBank>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BloodBankToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BloodBank&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,latitude,longitude,phone,verified,distance,createdAt);

@override
String toString() {
  return 'BloodBank(id: $id, name: $name, address: $address, latitude: $latitude, longitude: $longitude, phone: $phone, verified: $verified, distance: $distance, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BloodBankCopyWith<$Res> implements $BloodBankCopyWith<$Res> {
  factory _$BloodBankCopyWith(_BloodBank value, $Res Function(_BloodBank) _then) = __$BloodBankCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? address, double latitude, double longitude, String? phone, bool verified, double? distance,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$BloodBankCopyWithImpl<$Res>
    implements _$BloodBankCopyWith<$Res> {
  __$BloodBankCopyWithImpl(this._self, this._then);

  final _BloodBank _self;
  final $Res Function(_BloodBank) _then;

/// Create a copy of BloodBank
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = freezed,Object? latitude = null,Object? longitude = null,Object? phone = freezed,Object? verified = null,Object? distance = freezed,Object? createdAt = null,}) {
  return _then(_BloodBank(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
