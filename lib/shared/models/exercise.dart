import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

enum MuscleGroup { chest, back, legs, shoulders, arms, core, fullBody }

enum TrackingUnit { weightReps, timeOnly, distanceTime, bodyweightReps }

enum ExerciseType { compound, isolation, cardio }

@freezed
sealed class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    required MuscleGroup primaryMuscle,
    String? secondaryMuscleDescription,
    required ExerciseType type,
    required TrackingUnit trackingUnit,
    String? equipmentName,
    String? gifUrl,
    @Default([]) List<String> tips,
    @Default(false) bool isCustom,
    String? userId,
    // Rich fields from the exercises_data.json asset
    @Default([]) List<String> bodyParts,
    @Default([]) List<String> targetMuscles,
    @Default([]) List<String> secondaryMuscles,
    String? mechanic,
    String? level,
    String? force,
    @Default([]) List<String> instructions,
    String? thumbnailUrl,
    String? category,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}
