import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

enum SetType { normal, warmup, dropSet, failureSet }

@freezed
sealed class WorkoutSet with _$WorkoutSet {
  const factory WorkoutSet({
    required String id,
    required int setNumber,
    @Default(SetType.normal) SetType type,
    double? weight,
    int? reps,
    int? durationSeconds,
    @Default(false) bool isCompleted,
    @Default(false) bool isPR,
  }) = _WorkoutSet;

  factory WorkoutSet.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetFromJson(json);
}

@freezed
sealed class SessionExercise with _$SessionExercise {
  const factory SessionExercise({
    required String exerciseId,
    required String exerciseName,
    required List<WorkoutSet> sets,
  }) = _SessionExercise;

  factory SessionExercise.fromJson(Map<String, dynamic> json) =>
      _$SessionExerciseFromJson(json);
}

@freezed
sealed class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required String id,
    required String userId,
    String? templateId,
    String? templateName,
    required DateTime startTime,
    DateTime? endTime,
    @Default([]) List<SessionExercise> exercises,
    @Default(false) bool isCompleted,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}

extension WorkoutSessionX on WorkoutSession {
  int get durationMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }

  double get totalVolumeKg {
    double total = 0;
    for (final ex in exercises) {
      for (final set in ex.sets) {
        if (set.isCompleted && set.weight != null && set.reps != null) {
          total += set.weight! * set.reps!;
        }
      }
    }
    return total;
  }

  int get totalSets {
    return exercises.fold(0, (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length);
  }
}
