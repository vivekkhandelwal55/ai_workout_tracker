// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateExercise {

 String get exerciseId; String get exerciseName; int get defaultSets; int? get defaultReps; double? get defaultWeight; TrackingUnit get trackingUnit;
/// Create a copy of TemplateExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateExerciseCopyWith<TemplateExercise> get copyWith => _$TemplateExerciseCopyWithImpl<TemplateExercise>(this as TemplateExercise, _$identity);

  /// Serializes this TemplateExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateExercise&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.defaultSets, defaultSets) || other.defaultSets == defaultSets)&&(identical(other.defaultReps, defaultReps) || other.defaultReps == defaultReps)&&(identical(other.defaultWeight, defaultWeight) || other.defaultWeight == defaultWeight)&&(identical(other.trackingUnit, trackingUnit) || other.trackingUnit == trackingUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,defaultSets,defaultReps,defaultWeight,trackingUnit);

@override
String toString() {
  return 'TemplateExercise(exerciseId: $exerciseId, exerciseName: $exerciseName, defaultSets: $defaultSets, defaultReps: $defaultReps, defaultWeight: $defaultWeight, trackingUnit: $trackingUnit)';
}


}

/// @nodoc
abstract mixin class $TemplateExerciseCopyWith<$Res>  {
  factory $TemplateExerciseCopyWith(TemplateExercise value, $Res Function(TemplateExercise) _then) = _$TemplateExerciseCopyWithImpl;
@useResult
$Res call({
 String exerciseId, String exerciseName, int defaultSets, int? defaultReps, double? defaultWeight, TrackingUnit trackingUnit
});




}
/// @nodoc
class _$TemplateExerciseCopyWithImpl<$Res>
    implements $TemplateExerciseCopyWith<$Res> {
  _$TemplateExerciseCopyWithImpl(this._self, this._then);

  final TemplateExercise _self;
  final $Res Function(TemplateExercise) _then;

/// Create a copy of TemplateExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? defaultSets = null,Object? defaultReps = freezed,Object? defaultWeight = freezed,Object? trackingUnit = null,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,defaultSets: null == defaultSets ? _self.defaultSets : defaultSets // ignore: cast_nullable_to_non_nullable
as int,defaultReps: freezed == defaultReps ? _self.defaultReps : defaultReps // ignore: cast_nullable_to_non_nullable
as int?,defaultWeight: freezed == defaultWeight ? _self.defaultWeight : defaultWeight // ignore: cast_nullable_to_non_nullable
as double?,trackingUnit: null == trackingUnit ? _self.trackingUnit : trackingUnit // ignore: cast_nullable_to_non_nullable
as TrackingUnit,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateExercise].
extension TemplateExercisePatterns on TemplateExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateExercise value)  $default,){
final _that = this;
switch (_that) {
case _TemplateExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateExercise value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  String exerciseName,  int defaultSets,  int? defaultReps,  double? defaultWeight,  TrackingUnit trackingUnit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateExercise() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.defaultSets,_that.defaultReps,_that.defaultWeight,_that.trackingUnit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  String exerciseName,  int defaultSets,  int? defaultReps,  double? defaultWeight,  TrackingUnit trackingUnit)  $default,) {final _that = this;
switch (_that) {
case _TemplateExercise():
return $default(_that.exerciseId,_that.exerciseName,_that.defaultSets,_that.defaultReps,_that.defaultWeight,_that.trackingUnit);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  String exerciseName,  int defaultSets,  int? defaultReps,  double? defaultWeight,  TrackingUnit trackingUnit)?  $default,) {final _that = this;
switch (_that) {
case _TemplateExercise() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.defaultSets,_that.defaultReps,_that.defaultWeight,_that.trackingUnit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateExercise implements TemplateExercise {
  const _TemplateExercise({required this.exerciseId, required this.exerciseName, required this.defaultSets, this.defaultReps, this.defaultWeight, required this.trackingUnit});
  factory _TemplateExercise.fromJson(Map<String, dynamic> json) => _$TemplateExerciseFromJson(json);

@override final  String exerciseId;
@override final  String exerciseName;
@override final  int defaultSets;
@override final  int? defaultReps;
@override final  double? defaultWeight;
@override final  TrackingUnit trackingUnit;

/// Create a copy of TemplateExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateExerciseCopyWith<_TemplateExercise> get copyWith => __$TemplateExerciseCopyWithImpl<_TemplateExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateExercise&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.defaultSets, defaultSets) || other.defaultSets == defaultSets)&&(identical(other.defaultReps, defaultReps) || other.defaultReps == defaultReps)&&(identical(other.defaultWeight, defaultWeight) || other.defaultWeight == defaultWeight)&&(identical(other.trackingUnit, trackingUnit) || other.trackingUnit == trackingUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,defaultSets,defaultReps,defaultWeight,trackingUnit);

@override
String toString() {
  return 'TemplateExercise(exerciseId: $exerciseId, exerciseName: $exerciseName, defaultSets: $defaultSets, defaultReps: $defaultReps, defaultWeight: $defaultWeight, trackingUnit: $trackingUnit)';
}


}

/// @nodoc
abstract mixin class _$TemplateExerciseCopyWith<$Res> implements $TemplateExerciseCopyWith<$Res> {
  factory _$TemplateExerciseCopyWith(_TemplateExercise value, $Res Function(_TemplateExercise) _then) = __$TemplateExerciseCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, String exerciseName, int defaultSets, int? defaultReps, double? defaultWeight, TrackingUnit trackingUnit
});




}
/// @nodoc
class __$TemplateExerciseCopyWithImpl<$Res>
    implements _$TemplateExerciseCopyWith<$Res> {
  __$TemplateExerciseCopyWithImpl(this._self, this._then);

  final _TemplateExercise _self;
  final $Res Function(_TemplateExercise) _then;

/// Create a copy of TemplateExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? defaultSets = null,Object? defaultReps = freezed,Object? defaultWeight = freezed,Object? trackingUnit = null,}) {
  return _then(_TemplateExercise(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,defaultSets: null == defaultSets ? _self.defaultSets : defaultSets // ignore: cast_nullable_to_non_nullable
as int,defaultReps: freezed == defaultReps ? _self.defaultReps : defaultReps // ignore: cast_nullable_to_non_nullable
as int?,defaultWeight: freezed == defaultWeight ? _self.defaultWeight : defaultWeight // ignore: cast_nullable_to_non_nullable
as double?,trackingUnit: null == trackingUnit ? _self.trackingUnit : trackingUnit // ignore: cast_nullable_to_non_nullable
as TrackingUnit,
  ));
}


}


/// @nodoc
mixin _$WorkoutTemplate {

 String get id; String get name; String? get description; List<TemplateExercise> get exercises; int get estimatedMinutes; DateTime? get lastUsed;
/// Create a copy of WorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutTemplateCopyWith<WorkoutTemplate> get copyWith => _$WorkoutTemplateCopyWithImpl<WorkoutTemplate>(this as WorkoutTemplate, _$identity);

  /// Serializes this WorkoutTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.estimatedMinutes, estimatedMinutes) || other.estimatedMinutes == estimatedMinutes)&&(identical(other.lastUsed, lastUsed) || other.lastUsed == lastUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(exercises),estimatedMinutes,lastUsed);

@override
String toString() {
  return 'WorkoutTemplate(id: $id, name: $name, description: $description, exercises: $exercises, estimatedMinutes: $estimatedMinutes, lastUsed: $lastUsed)';
}


}

/// @nodoc
abstract mixin class $WorkoutTemplateCopyWith<$Res>  {
  factory $WorkoutTemplateCopyWith(WorkoutTemplate value, $Res Function(WorkoutTemplate) _then) = _$WorkoutTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, List<TemplateExercise> exercises, int estimatedMinutes, DateTime? lastUsed
});




}
/// @nodoc
class _$WorkoutTemplateCopyWithImpl<$Res>
    implements $WorkoutTemplateCopyWith<$Res> {
  _$WorkoutTemplateCopyWithImpl(this._self, this._then);

  final WorkoutTemplate _self;
  final $Res Function(WorkoutTemplate) _then;

/// Create a copy of WorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? exercises = null,Object? estimatedMinutes = null,Object? lastUsed = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<TemplateExercise>,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,lastUsed: freezed == lastUsed ? _self.lastUsed : lastUsed // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutTemplate].
extension WorkoutTemplatePatterns on WorkoutTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutTemplate value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  List<TemplateExercise> exercises,  int estimatedMinutes,  DateTime? lastUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.exercises,_that.estimatedMinutes,_that.lastUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  List<TemplateExercise> exercises,  int estimatedMinutes,  DateTime? lastUsed)  $default,) {final _that = this;
switch (_that) {
case _WorkoutTemplate():
return $default(_that.id,_that.name,_that.description,_that.exercises,_that.estimatedMinutes,_that.lastUsed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  List<TemplateExercise> exercises,  int estimatedMinutes,  DateTime? lastUsed)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.exercises,_that.estimatedMinutes,_that.lastUsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutTemplate implements WorkoutTemplate {
  const _WorkoutTemplate({required this.id, required this.name, this.description, required final  List<TemplateExercise> exercises, required this.estimatedMinutes, this.lastUsed}): _exercises = exercises;
  factory _WorkoutTemplate.fromJson(Map<String, dynamic> json) => _$WorkoutTemplateFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
 final  List<TemplateExercise> _exercises;
@override List<TemplateExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override final  int estimatedMinutes;
@override final  DateTime? lastUsed;

/// Create a copy of WorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutTemplateCopyWith<_WorkoutTemplate> get copyWith => __$WorkoutTemplateCopyWithImpl<_WorkoutTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.estimatedMinutes, estimatedMinutes) || other.estimatedMinutes == estimatedMinutes)&&(identical(other.lastUsed, lastUsed) || other.lastUsed == lastUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_exercises),estimatedMinutes,lastUsed);

@override
String toString() {
  return 'WorkoutTemplate(id: $id, name: $name, description: $description, exercises: $exercises, estimatedMinutes: $estimatedMinutes, lastUsed: $lastUsed)';
}


}

/// @nodoc
abstract mixin class _$WorkoutTemplateCopyWith<$Res> implements $WorkoutTemplateCopyWith<$Res> {
  factory _$WorkoutTemplateCopyWith(_WorkoutTemplate value, $Res Function(_WorkoutTemplate) _then) = __$WorkoutTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, List<TemplateExercise> exercises, int estimatedMinutes, DateTime? lastUsed
});




}
/// @nodoc
class __$WorkoutTemplateCopyWithImpl<$Res>
    implements _$WorkoutTemplateCopyWith<$Res> {
  __$WorkoutTemplateCopyWithImpl(this._self, this._then);

  final _WorkoutTemplate _self;
  final $Res Function(_WorkoutTemplate) _then;

/// Create a copy of WorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? exercises = null,Object? estimatedMinutes = null,Object? lastUsed = freezed,}) {
  return _then(_WorkoutTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<TemplateExercise>,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,lastUsed: freezed == lastUsed ? _self.lastUsed : lastUsed // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
