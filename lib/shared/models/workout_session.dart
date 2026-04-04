enum SetType { normal, warmup, dropSet, failureSet }

class WorkoutSet {
  final String id;
  final int setNumber;
  final SetType type;
  final double? weight; // kg or null for bodyweight
  final int? reps;
  final int? durationSeconds; // for time-based
  final bool isCompleted;
  final bool isPR; // personal record

  const WorkoutSet({
    required this.id,
    required this.setNumber,
    required this.type,
    this.weight,
    this.reps,
    this.durationSeconds,
    required this.isCompleted,
    required this.isPR,
  });

  WorkoutSet copyWith({
    String? id,
    int? setNumber,
    SetType? type,
    double? weight,
    int? reps,
    int? durationSeconds,
    bool? isCompleted,
    bool? isPR,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      isPR: isPR ?? this.isPR,
    );
  }
}

class SessionExercise {
  final String exerciseId;
  final String exerciseName;
  final List<WorkoutSet> sets;

  const SessionExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  SessionExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    List<WorkoutSet>? sets,
  }) {
    return SessionExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
    );
  }
}

class WorkoutSession {
  final String id;
  final String? templateId;
  final String? templateName;
  final DateTime startTime;
  final DateTime? endTime;
  final List<SessionExercise> exercises;
  final bool isCompleted;

  const WorkoutSession({
    required this.id,
    this.templateId,
    this.templateName,
    required this.startTime,
    this.endTime,
    required this.exercises,
    required this.isCompleted,
  });

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

  WorkoutSession copyWith({
    String? id,
    String? templateId,
    String? templateName,
    DateTime? startTime,
    DateTime? endTime,
    List<SessionExercise>? exercises,
    bool? isCompleted,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exercises: exercises ?? this.exercises,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
