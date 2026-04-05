// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_routine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutineDay {

 String get id; String get name; String? get templateId; String? get templateName;
/// Create a copy of RoutineDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineDayCopyWith<RoutineDay> get copyWith => _$RoutineDayCopyWithImpl<RoutineDay>(this as RoutineDay, _$identity);

  /// Serializes this RoutineDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineDay&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateName, templateName) || other.templateName == templateName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,templateId,templateName);

@override
String toString() {
  return 'RoutineDay(id: $id, name: $name, templateId: $templateId, templateName: $templateName)';
}


}

/// @nodoc
abstract mixin class $RoutineDayCopyWith<$Res>  {
  factory $RoutineDayCopyWith(RoutineDay value, $Res Function(RoutineDay) _then) = _$RoutineDayCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? templateId, String? templateName
});




}
/// @nodoc
class _$RoutineDayCopyWithImpl<$Res>
    implements $RoutineDayCopyWith<$Res> {
  _$RoutineDayCopyWithImpl(this._self, this._then);

  final RoutineDay _self;
  final $Res Function(RoutineDay) _then;

/// Create a copy of RoutineDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? templateId = freezed,Object? templateName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineDay].
extension RoutineDayPatterns on RoutineDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineDay value)  $default,){
final _that = this;
switch (_that) {
case _RoutineDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineDay value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? templateId,  String? templateName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineDay() when $default != null:
return $default(_that.id,_that.name,_that.templateId,_that.templateName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? templateId,  String? templateName)  $default,) {final _that = this;
switch (_that) {
case _RoutineDay():
return $default(_that.id,_that.name,_that.templateId,_that.templateName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? templateId,  String? templateName)?  $default,) {final _that = this;
switch (_that) {
case _RoutineDay() when $default != null:
return $default(_that.id,_that.name,_that.templateId,_that.templateName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineDay implements RoutineDay {
  const _RoutineDay({required this.id, required this.name, this.templateId, this.templateName});
  factory _RoutineDay.fromJson(Map<String, dynamic> json) => _$RoutineDayFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? templateId;
@override final  String? templateName;

/// Create a copy of RoutineDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineDayCopyWith<_RoutineDay> get copyWith => __$RoutineDayCopyWithImpl<_RoutineDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineDay&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateName, templateName) || other.templateName == templateName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,templateId,templateName);

@override
String toString() {
  return 'RoutineDay(id: $id, name: $name, templateId: $templateId, templateName: $templateName)';
}


}

/// @nodoc
abstract mixin class _$RoutineDayCopyWith<$Res> implements $RoutineDayCopyWith<$Res> {
  factory _$RoutineDayCopyWith(_RoutineDay value, $Res Function(_RoutineDay) _then) = __$RoutineDayCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? templateId, String? templateName
});




}
/// @nodoc
class __$RoutineDayCopyWithImpl<$Res>
    implements _$RoutineDayCopyWith<$Res> {
  __$RoutineDayCopyWithImpl(this._self, this._then);

  final _RoutineDay _self;
  final $Res Function(_RoutineDay) _then;

/// Create a copy of RoutineDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? templateId = freezed,Object? templateName = freezed,}) {
  return _then(_RoutineDay(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WorkoutRoutine {

 String get id; String get userId; List<RoutineDay> get days; DateTime get startDate; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of WorkoutRoutine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutRoutineCopyWith<WorkoutRoutine> get copyWith => _$WorkoutRoutineCopyWithImpl<WorkoutRoutine>(this as WorkoutRoutine, _$identity);

  /// Serializes this WorkoutRoutine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutRoutine&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,const DeepCollectionEquality().hash(days),startDate,createdAt,updatedAt);

@override
String toString() {
  return 'WorkoutRoutine(id: $id, userId: $userId, days: $days, startDate: $startDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WorkoutRoutineCopyWith<$Res>  {
  factory $WorkoutRoutineCopyWith(WorkoutRoutine value, $Res Function(WorkoutRoutine) _then) = _$WorkoutRoutineCopyWithImpl;
@useResult
$Res call({
 String id, String userId, List<RoutineDay> days, DateTime startDate, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$WorkoutRoutineCopyWithImpl<$Res>
    implements $WorkoutRoutineCopyWith<$Res> {
  _$WorkoutRoutineCopyWithImpl(this._self, this._then);

  final WorkoutRoutine _self;
  final $Res Function(WorkoutRoutine) _then;

/// Create a copy of WorkoutRoutine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? days = null,Object? startDate = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<RoutineDay>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutRoutine].
extension WorkoutRoutinePatterns on WorkoutRoutine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutRoutine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutRoutine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutRoutine value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutRoutine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutRoutine value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutRoutine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  List<RoutineDay> days,  DateTime startDate,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutRoutine() when $default != null:
return $default(_that.id,_that.userId,_that.days,_that.startDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  List<RoutineDay> days,  DateTime startDate,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkoutRoutine():
return $default(_that.id,_that.userId,_that.days,_that.startDate,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  List<RoutineDay> days,  DateTime startDate,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutRoutine() when $default != null:
return $default(_that.id,_that.userId,_that.days,_that.startDate,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutRoutine implements WorkoutRoutine {
  const _WorkoutRoutine({required this.id, required this.userId, required final  List<RoutineDay> days, required this.startDate, this.createdAt, this.updatedAt}): _days = days;
  factory _WorkoutRoutine.fromJson(Map<String, dynamic> json) => _$WorkoutRoutineFromJson(json);

@override final  String id;
@override final  String userId;
 final  List<RoutineDay> _days;
@override List<RoutineDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override final  DateTime startDate;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of WorkoutRoutine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutRoutineCopyWith<_WorkoutRoutine> get copyWith => __$WorkoutRoutineCopyWithImpl<_WorkoutRoutine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutRoutineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutRoutine&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,const DeepCollectionEquality().hash(_days),startDate,createdAt,updatedAt);

@override
String toString() {
  return 'WorkoutRoutine(id: $id, userId: $userId, days: $days, startDate: $startDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkoutRoutineCopyWith<$Res> implements $WorkoutRoutineCopyWith<$Res> {
  factory _$WorkoutRoutineCopyWith(_WorkoutRoutine value, $Res Function(_WorkoutRoutine) _then) = __$WorkoutRoutineCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, List<RoutineDay> days, DateTime startDate, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$WorkoutRoutineCopyWithImpl<$Res>
    implements _$WorkoutRoutineCopyWith<$Res> {
  __$WorkoutRoutineCopyWithImpl(this._self, this._then);

  final _WorkoutRoutine _self;
  final $Res Function(_WorkoutRoutine) _then;

/// Create a copy of WorkoutRoutine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? days = null,Object? startDate = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_WorkoutRoutine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<RoutineDay>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
