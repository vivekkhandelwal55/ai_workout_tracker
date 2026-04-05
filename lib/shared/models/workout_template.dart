import 'package:freezed_annotation/freezed_annotation.dart';

import 'exercise.dart';

part 'workout_template.freezed.dart';
part 'workout_template.g.dart';

@freezed
sealed class TemplateExercise with _$TemplateExercise {
  const factory TemplateExercise({
    required String exerciseId,
    required String exerciseName,
    required int defaultSets,
    int? defaultReps,
    double? defaultWeight,
    required TrackingUnit trackingUnit,
  }) = _TemplateExercise;

  factory TemplateExercise.fromJson(Map<String, dynamic> json) =>
      _$TemplateExerciseFromJson(json);
}

@freezed
sealed class WorkoutTemplate with _$WorkoutTemplate {
  const factory WorkoutTemplate({
    required String id,
    required String name,
    String? description,
    required List<TemplateExercise> exercises,
    required int estimatedMinutes,
    DateTime? lastUsed,
  }) = _WorkoutTemplate;

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateFromJson(json);
}
