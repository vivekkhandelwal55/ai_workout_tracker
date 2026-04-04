import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/workout_repository_impl.dart';
import '../../domain/workout_repository.dart';
import '../../../../shared/models/workout_template.dart';
import '../../../../shared/models/workout_session.dart';

const _uuid = Uuid();

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return StubWorkoutRepository();
});

// Templates
final workoutTemplatesProvider =
    FutureProvider.family<List<WorkoutTemplate>, String>((ref, userId) async {
      final (templates, _) =
          await ref.watch(workoutRepositoryProvider).getTemplates(userId);
      return templates;
    });

// Active workout state
class ActiveWorkoutState {
  final WorkoutSession? session;
  final bool isRunning;
  final DateTime? startTime;
  final int elapsedSeconds;

  const ActiveWorkoutState({
    this.session,
    this.isRunning = false,
    this.startTime,
    this.elapsedSeconds = 0,
  });

  ActiveWorkoutState copyWith({
    WorkoutSession? session,
    bool? isRunning,
    DateTime? startTime,
    int? elapsedSeconds,
  }) {
    return ActiveWorkoutState(
      session: session ?? this.session,
      isRunning: isRunning ?? this.isRunning,
      startTime: startTime ?? this.startTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  ActiveWorkoutNotifier() : super(const ActiveWorkoutState());

  void startWorkout({WorkoutTemplate? template}) {
    final now = DateTime.now();
    final exercises =
        template?.exercises.map((te) {
          return SessionExercise(
            exerciseId: te.exerciseId,
            exerciseName: te.exerciseName,
            sets: List.generate(
              te.defaultSets,
              (i) => WorkoutSet(
                id: _uuid.v4(),
                setNumber: i + 1,
                type: SetType.normal,
                weight: te.defaultWeight,
                reps: te.defaultReps,
                isCompleted: false,
                isPR: false,
              ),
            ),
          );
        }).toList() ??
        [];

    state = ActiveWorkoutState(
      session: WorkoutSession(
        id: _uuid.v4(),
        templateId: template?.id,
        templateName: template?.name,
        startTime: now,
        exercises: exercises,
        isCompleted: false,
      ),
      isRunning: true,
      startTime: now,
      elapsedSeconds: 0,
    );
  }

  void tickTimer() {
    if (state.isRunning && state.startTime != null) {
      final elapsed =
          DateTime.now().difference(state.startTime!).inSeconds;
      state = state.copyWith(elapsedSeconds: elapsed);
    }
  }

  void updateSet(String exerciseId, int setIndex, WorkoutSet updatedSet) {
    if (state.session == null) return;
    final updatedExercises =
        state.session!.exercises.map((ex) {
          if (ex.exerciseId != exerciseId) return ex;
          final sets = List<WorkoutSet>.from(ex.sets);
          sets[setIndex] = updatedSet;
          return ex.copyWith(sets: sets);
        }).toList();
    state = state.copyWith(
      session: state.session!.copyWith(exercises: updatedExercises),
    );
  }

  void addSet(String exerciseId) {
    if (state.session == null) return;
    final updatedExercises =
        state.session!.exercises.map((ex) {
          if (ex.exerciseId != exerciseId) return ex;
          final newSet = WorkoutSet(
            id: _uuid.v4(),
            setNumber: ex.sets.length + 1,
            type: SetType.normal,
            isCompleted: false,
            isPR: false,
          );
          return ex.copyWith(sets: [...ex.sets, newSet]);
        }).toList();
    state = state.copyWith(
      session: state.session!.copyWith(exercises: updatedExercises),
    );
  }

  void addExercise(String exerciseId, String exerciseName) {
    if (state.session == null) return;
    final newExercise = SessionExercise(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: [
        WorkoutSet(
          id: _uuid.v4(),
          setNumber: 1,
          type: SetType.normal,
          isCompleted: false,
          isPR: false,
        ),
      ],
    );
    state = state.copyWith(
      session: state.session!.copyWith(
        exercises: [...state.session!.exercises, newExercise],
      ),
    );
  }

  WorkoutSession? finishWorkout() {
    if (state.session == null) return null;
    final finished = state.session!.copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
    );
    state = ActiveWorkoutState(
      session: finished,
      isRunning: false,
    );
    return finished;
  }

  void reset() {
    state = const ActiveWorkoutState();
  }
}

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>((ref) {
      return ActiveWorkoutNotifier();
    });
