import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_routine.freezed.dart';
part 'workout_routine.g.dart';

@freezed
sealed class RoutineDay with _$RoutineDay {
  const factory RoutineDay({
    required String id,
    required String name,
    String? templateId,
    String? templateName,
  }) = _RoutineDay;

  factory RoutineDay.fromJson(Map<String, dynamic> json) =>
      _$RoutineDayFromJson(json);
}

@freezed
sealed class WorkoutRoutine with _$WorkoutRoutine {
  const factory WorkoutRoutine({
    required String id,
    required String userId,
    required List<RoutineDay> days,
    required DateTime startDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WorkoutRoutine;

  factory WorkoutRoutine.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRoutineFromJson(json);
}
