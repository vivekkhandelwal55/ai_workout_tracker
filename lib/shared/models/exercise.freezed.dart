// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exercise {

 String get id; String get name; MuscleGroup get primaryMuscle; String? get secondaryMuscleDescription; ExerciseType get type; TrackingUnit get trackingUnit; String? get equipmentName; String? get gifUrl; List<String> get tips; bool get isCustom; String? get userId;
/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseCopyWith<Exercise> get copyWith => _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.primaryMuscle, primaryMuscle) || other.primaryMuscle == primaryMuscle)&&(identical(other.secondaryMuscleDescription, secondaryMuscleDescription) || other.secondaryMuscleDescription == secondaryMuscleDescription)&&(identical(other.type, type) || other.type == type)&&(identical(other.trackingUnit, trackingUnit) || other.trackingUnit == trackingUnit)&&(identical(other.equipmentName, equipmentName) || other.equipmentName == equipmentName)&&(identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl)&&const DeepCollectionEquality().equals(other.tips, tips)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,primaryMuscle,secondaryMuscleDescription,type,trackingUnit,equipmentName,gifUrl,const DeepCollectionEquality().hash(tips),isCustom,userId);

@override
String toString() {
  return 'Exercise(id: $id, name: $name, primaryMuscle: $primaryMuscle, secondaryMuscleDescription: $secondaryMuscleDescription, type: $type, trackingUnit: $trackingUnit, equipmentName: $equipmentName, gifUrl: $gifUrl, tips: $tips, isCustom: $isCustom, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res>  {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) = _$ExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String name, MuscleGroup primaryMuscle, String? secondaryMuscleDescription, ExerciseType type, TrackingUnit trackingUnit, String? equipmentName, String? gifUrl, List<String> tips, bool isCustom, String? userId
});




}
/// @nodoc
class _$ExerciseCopyWithImpl<$Res>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? primaryMuscle = null,Object? secondaryMuscleDescription = freezed,Object? type = null,Object? trackingUnit = null,Object? equipmentName = freezed,Object? gifUrl = freezed,Object? tips = null,Object? isCustom = null,Object? userId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,primaryMuscle: null == primaryMuscle ? _self.primaryMuscle : primaryMuscle // ignore: cast_nullable_to_non_nullable
as MuscleGroup,secondaryMuscleDescription: freezed == secondaryMuscleDescription ? _self.secondaryMuscleDescription : secondaryMuscleDescription // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExerciseType,trackingUnit: null == trackingUnit ? _self.trackingUnit : trackingUnit // ignore: cast_nullable_to_non_nullable
as TrackingUnit,equipmentName: freezed == equipmentName ? _self.equipmentName : equipmentName // ignore: cast_nullable_to_non_nullable
as String?,gifUrl: freezed == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String?,tips: null == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as List<String>,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Exercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Exercise value)  $default,){
final _that = this;
switch (_that) {
case _Exercise():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Exercise value)?  $default,){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  MuscleGroup primaryMuscle,  String? secondaryMuscleDescription,  ExerciseType type,  TrackingUnit trackingUnit,  String? equipmentName,  String? gifUrl,  List<String> tips,  bool isCustom,  String? userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.primaryMuscle,_that.secondaryMuscleDescription,_that.type,_that.trackingUnit,_that.equipmentName,_that.gifUrl,_that.tips,_that.isCustom,_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  MuscleGroup primaryMuscle,  String? secondaryMuscleDescription,  ExerciseType type,  TrackingUnit trackingUnit,  String? equipmentName,  String? gifUrl,  List<String> tips,  bool isCustom,  String? userId)  $default,) {final _that = this;
switch (_that) {
case _Exercise():
return $default(_that.id,_that.name,_that.primaryMuscle,_that.secondaryMuscleDescription,_that.type,_that.trackingUnit,_that.equipmentName,_that.gifUrl,_that.tips,_that.isCustom,_that.userId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  MuscleGroup primaryMuscle,  String? secondaryMuscleDescription,  ExerciseType type,  TrackingUnit trackingUnit,  String? equipmentName,  String? gifUrl,  List<String> tips,  bool isCustom,  String? userId)?  $default,) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.primaryMuscle,_that.secondaryMuscleDescription,_that.type,_that.trackingUnit,_that.equipmentName,_that.gifUrl,_that.tips,_that.isCustom,_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Exercise implements Exercise {
  const _Exercise({required this.id, required this.name, required this.primaryMuscle, this.secondaryMuscleDescription, required this.type, required this.trackingUnit, this.equipmentName, this.gifUrl, final  List<String> tips = const [], this.isCustom = false, this.userId}): _tips = tips;
  factory _Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

@override final  String id;
@override final  String name;
@override final  MuscleGroup primaryMuscle;
@override final  String? secondaryMuscleDescription;
@override final  ExerciseType type;
@override final  TrackingUnit trackingUnit;
@override final  String? equipmentName;
@override final  String? gifUrl;
 final  List<String> _tips;
@override@JsonKey() List<String> get tips {
  if (_tips is EqualUnmodifiableListView) return _tips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tips);
}

@override@JsonKey() final  bool isCustom;
@override final  String? userId;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseCopyWith<_Exercise> get copyWith => __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.primaryMuscle, primaryMuscle) || other.primaryMuscle == primaryMuscle)&&(identical(other.secondaryMuscleDescription, secondaryMuscleDescription) || other.secondaryMuscleDescription == secondaryMuscleDescription)&&(identical(other.type, type) || other.type == type)&&(identical(other.trackingUnit, trackingUnit) || other.trackingUnit == trackingUnit)&&(identical(other.equipmentName, equipmentName) || other.equipmentName == equipmentName)&&(identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl)&&const DeepCollectionEquality().equals(other._tips, _tips)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,primaryMuscle,secondaryMuscleDescription,type,trackingUnit,equipmentName,gifUrl,const DeepCollectionEquality().hash(_tips),isCustom,userId);

@override
String toString() {
  return 'Exercise(id: $id, name: $name, primaryMuscle: $primaryMuscle, secondaryMuscleDescription: $secondaryMuscleDescription, type: $type, trackingUnit: $trackingUnit, equipmentName: $equipmentName, gifUrl: $gifUrl, tips: $tips, isCustom: $isCustom, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res> implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(_Exercise value, $Res Function(_Exercise) _then) = __$ExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, MuscleGroup primaryMuscle, String? secondaryMuscleDescription, ExerciseType type, TrackingUnit trackingUnit, String? equipmentName, String? gifUrl, List<String> tips, bool isCustom, String? userId
});




}
/// @nodoc
class __$ExerciseCopyWithImpl<$Res>
    implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? primaryMuscle = null,Object? secondaryMuscleDescription = freezed,Object? type = null,Object? trackingUnit = null,Object? equipmentName = freezed,Object? gifUrl = freezed,Object? tips = null,Object? isCustom = null,Object? userId = freezed,}) {
  return _then(_Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,primaryMuscle: null == primaryMuscle ? _self.primaryMuscle : primaryMuscle // ignore: cast_nullable_to_non_nullable
as MuscleGroup,secondaryMuscleDescription: freezed == secondaryMuscleDescription ? _self.secondaryMuscleDescription : secondaryMuscleDescription // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExerciseType,trackingUnit: null == trackingUnit ? _self.trackingUnit : trackingUnit // ignore: cast_nullable_to_non_nullable
as TrackingUnit,equipmentName: freezed == equipmentName ? _self.equipmentName : equipmentName // ignore: cast_nullable_to_non_nullable
as String?,gifUrl: freezed == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String?,tips: null == tips ? _self._tips : tips // ignore: cast_nullable_to_non_nullable
as List<String>,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
