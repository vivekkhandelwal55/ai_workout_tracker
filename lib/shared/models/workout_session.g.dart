// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => _WorkoutSet(
  id: json['id'] as String,
  setNumber: (json['setNumber'] as num).toInt(),
  type: $enumDecodeNullable(_$SetTypeEnumMap, json['type']) ?? SetType.normal,
  weight: (json['weight'] as num?)?.toDouble(),
  reps: (json['reps'] as num?)?.toInt(),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
  isCompleted: json['isCompleted'] as bool? ?? false,
  isPR: json['isPR'] as bool? ?? false,
);

Map<String, dynamic> _$WorkoutSetToJson(_WorkoutSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'setNumber': instance.setNumber,
      'type': _$SetTypeEnumMap[instance.type]!,
      'weight': instance.weight,
      'reps': instance.reps,
      'durationSeconds': instance.durationSeconds,
      'isCompleted': instance.isCompleted,
      'isPR': instance.isPR,
    };

const _$SetTypeEnumMap = {
  SetType.normal: 'normal',
  SetType.warmup: 'warmup',
  SetType.dropSet: 'dropSet',
  SetType.failureSet: 'failureSet',
};

_SessionExercise _$SessionExerciseFromJson(Map<String, dynamic> json) =>
    _SessionExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sets:
          (json['sets'] as List<dynamic>)
              .map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$SessionExerciseToJson(_SessionExercise instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'sets': instance.sets,
    };

_WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    _WorkoutSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      templateId: json['templateId'] as String?,
      templateName: json['templateName'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime:
          json['endTime'] == null
              ? null
              : DateTime.parse(json['endTime'] as String),
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => SessionExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkoutSessionToJson(_WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'templateId': instance.templateId,
      'templateName': instance.templateName,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'exercises': instance.exercises,
      'isCompleted': instance.isCompleted,
    };
