// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  primaryMuscle: $enumDecode(_$MuscleGroupEnumMap, json['primaryMuscle']),
  secondaryMuscleDescription: json['secondaryMuscleDescription'] as String?,
  type: $enumDecode(_$ExerciseTypeEnumMap, json['type']),
  trackingUnit: $enumDecode(_$TrackingUnitEnumMap, json['trackingUnit']),
  equipmentName: json['equipmentName'] as String?,
  gifUrl: json['gifUrl'] as String?,
  tips:
      (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isCustom: json['isCustom'] as bool? ?? false,
  userId: json['userId'] as String?,
  bodyParts:
      (json['bodyParts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  targetMuscles:
      (json['targetMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  secondaryMuscles:
      (json['secondaryMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  mechanic: json['mechanic'] as String?,
  level: json['level'] as String?,
  force: json['force'] as String?,
  instructions:
      (json['instructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  thumbnailUrl: json['thumbnailUrl'] as String?,
  category: json['category'] as String?,
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'primaryMuscle': _$MuscleGroupEnumMap[instance.primaryMuscle]!,
  'secondaryMuscleDescription': instance.secondaryMuscleDescription,
  'type': _$ExerciseTypeEnumMap[instance.type]!,
  'trackingUnit': _$TrackingUnitEnumMap[instance.trackingUnit]!,
  'equipmentName': instance.equipmentName,
  'gifUrl': instance.gifUrl,
  'tips': instance.tips,
  'isCustom': instance.isCustom,
  'userId': instance.userId,
  'bodyParts': instance.bodyParts,
  'targetMuscles': instance.targetMuscles,
  'secondaryMuscles': instance.secondaryMuscles,
  'mechanic': instance.mechanic,
  'level': instance.level,
  'force': instance.force,
  'instructions': instance.instructions,
  'thumbnailUrl': instance.thumbnailUrl,
  'category': instance.category,
};

const _$MuscleGroupEnumMap = {
  MuscleGroup.chest: 'chest',
  MuscleGroup.back: 'back',
  MuscleGroup.legs: 'legs',
  MuscleGroup.shoulders: 'shoulders',
  MuscleGroup.arms: 'arms',
  MuscleGroup.core: 'core',
  MuscleGroup.fullBody: 'fullBody',
};

const _$ExerciseTypeEnumMap = {
  ExerciseType.compound: 'compound',
  ExerciseType.isolation: 'isolation',
  ExerciseType.cardio: 'cardio',
};

const _$TrackingUnitEnumMap = {
  TrackingUnit.weightReps: 'weightReps',
  TrackingUnit.timeOnly: 'timeOnly',
  TrackingUnit.distanceTime: 'distanceTime',
  TrackingUnit.bodyweightReps: 'bodyweightReps',
};
