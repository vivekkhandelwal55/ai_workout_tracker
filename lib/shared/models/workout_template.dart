import 'exercise.dart';

class WorkoutTemplate {
  final String id;
  final String name; // e.g. "PUSH A", "LEGS B"
  final String? description;
  final List<TemplateExercise> exercises;
  final int estimatedMinutes;
  final DateTime? lastUsed;

  const WorkoutTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    required this.estimatedMinutes,
    this.lastUsed,
  });

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<TemplateExercise>? exercises,
    int? estimatedMinutes,
    DateTime? lastUsed,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

class TemplateExercise {
  final String exerciseId;
  final String exerciseName;
  final int defaultSets;
  final int? defaultReps;
  final double? defaultWeight;
  final TrackingUnit trackingUnit;

  const TemplateExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.defaultSets,
    this.defaultReps,
    this.defaultWeight,
    required this.trackingUnit,
  });

  TemplateExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    int? defaultSets,
    int? defaultReps,
    double? defaultWeight,
    TrackingUnit? trackingUnit,
  }) {
    return TemplateExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      trackingUnit: trackingUnit ?? this.trackingUnit,
    );
  }
}
