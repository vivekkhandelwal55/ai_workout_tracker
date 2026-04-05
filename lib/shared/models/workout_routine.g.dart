// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoutineDay _$RoutineDayFromJson(Map<String, dynamic> json) => _RoutineDay(
  id: json['id'] as String,
  name: json['name'] as String,
  templateId: json['templateId'] as String?,
  templateName: json['templateName'] as String?,
);

Map<String, dynamic> _$RoutineDayToJson(_RoutineDay instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'templateId': instance.templateId,
      'templateName': instance.templateName,
    };

_WorkoutRoutine _$WorkoutRoutineFromJson(Map<String, dynamic> json) =>
    _WorkoutRoutine(
      id: json['id'] as String,
      userId: json['userId'] as String,
      days:
          (json['days'] as List<dynamic>)
              .map((e) => RoutineDay.fromJson(e as Map<String, dynamic>))
              .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WorkoutRoutineToJson(_WorkoutRoutine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'days': instance.days,
      'startDate': instance.startDate.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
