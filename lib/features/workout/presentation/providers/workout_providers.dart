import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/workout_repository_impl.dart';
import '../../data/workout_firestore_data_source.dart';
import '../../domain/workout_repository.dart';
import '../../../../shared/models/workout_template.dart';
import '../../../../shared/models/workout_session.dart';

const _uuid = Uuid();

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(
    WorkoutFirestoreDataSource(FirebaseFirestore.instance),
  );
});

// Templates
final workoutTemplatesProvider =
    FutureProvider.family<List<WorkoutTemplate>, String>((ref, userId) async {
      final (templates, _) = await ref
          .watch(workoutRepositoryProvider)
          .getTemplates(userId);
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

  /// Returns true if the user should be warned before finishing/discarding:
  /// less than 5 minutes elapsed OR no exercises added yet.
  bool get shouldWarnOnFinish =>
      elapsedSeconds < 30 || session == null || session!.exercises.isEmpty;

  /// Total completed sets across all exercises in the current session.
  int get completedSetsCount {
    if (session == null) return 0;
    return session!.exercises.fold(
      0,
      (total, ex) => total + ex.sets.where((s) => s.isCompleted).length,
    );
  }

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

class ActiveWorkoutNotifier extends Notifier<ActiveWorkoutState> {
  @override
  ActiveWorkoutState build() {
    return const ActiveWorkoutState();
  }

  void startWorkout({required String userId, WorkoutTemplate? template}) {
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
        userId: userId,
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

    // Persist lastUsed on the template so the home screen card reflects it.
    if (template != null) {
      final updatedTemplate = template.copyWith(lastUsed: now);
      ref.read(workoutRepositoryProvider).saveTemplate(userId, updatedTemplate);
    }
  }

  void tickTimer() {
    if (state.isRunning && state.startTime != null) {
      final elapsed = DateTime.now().difference(state.startTime!).inSeconds;
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

  void removeExercise(String exerciseId) {
    if (state.session == null) return;
    final updatedExercises = state.session!.exercises
        .where((ex) => ex.exerciseId != exerciseId)
        .toList();
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
    state = ActiveWorkoutState(session: finished, isRunning: false);
    return finished;
  }

  /// Reorder exercises in the current session.
  /// Call with the [oldIndex] and [newIndex] produced by [ReorderableListView].
  /// Flutter's ReorderableListView passes newIndex *after* removal, so this
  /// method adjusts the index before inserting.
  void reorderExercises(int oldIndex, int newIndex) {
    if (state.session == null) return;
    final exercises = List<SessionExercise>.from(state.session!.exercises);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);
    state = state.copyWith(
      session: state.session!.copyWith(exercises: exercises),
    );
  }

  void reset() {
    state = const ActiveWorkoutState();
  }
}

final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>(
  ActiveWorkoutNotifier.new,
);

/// Persistent ticker that auto-starts/stops based on [activeWorkoutProvider].
/// Runs at the Riverpod provider level so the timer keeps ticking even when
/// the user navigates away from [ActiveWorkoutScreen].
final workoutTickerProvider = StreamProvider<void>((ref) {
  final workoutState = ref.watch(activeWorkoutProvider);

  if (!workoutState.isRunning || workoutState.startTime == null) {
    return const Stream.empty();
  }

  return Stream.periodic(const Duration(seconds: 1), (_) {
    ref.read(activeWorkoutProvider.notifier).tickTimer();
  });
});
