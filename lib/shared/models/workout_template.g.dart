// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateExercise _$TemplateExerciseFromJson(Map<String, dynamic> json) =>
    _TemplateExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      defaultSets: (json['defaultSets'] as num).toInt(),
      defaultReps: (json['defaultReps'] as num?)?.toInt(),
      defaultWeight: (json['defaultWeight'] as num?)?.toDouble(),
      trackingUnit: $enumDecode(_$TrackingUnitEnumMap, json['trackingUnit']),
    );

Map<String, dynamic> _$TemplateExerciseToJson(_TemplateExercise instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'defaultSets': instance.defaultSets,
      'defaultReps': instance.defaultReps,
      'defaultWeight': instance.defaultWeight,
      'trackingUnit': _$TrackingUnitEnumMap[instance.trackingUnit]!,
    };

const _$TrackingUnitEnumMap = {
  TrackingUnit.weightReps: 'weightReps',
  TrackingUnit.timeOnly: 'timeOnly',
  TrackingUnit.distanceTime: 'distanceTime',
  TrackingUnit.bodyweightReps: 'bodyweightReps',
};

_WorkoutTemplate _$WorkoutTemplateFromJson(Map<String, dynamic> json) =>
    _WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      exercises:
          (json['exercises'] as List<dynamic>)
              .map((e) => TemplateExercise.fromJson(e as Map<String, dynamic>))
              .toList(),
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
      lastUsed:
          json['lastUsed'] == null
              ? null
              : DateTime.parse(json['lastUsed'] as String),
    );

Map<String, dynamic> _$WorkoutTemplateToJson(_WorkoutTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'exercises': instance.exercises,
      'estimatedMinutes': instance.estimatedMinutes,
      'lastUsed': instance.lastUsed?.toIso8601String(),
    };
