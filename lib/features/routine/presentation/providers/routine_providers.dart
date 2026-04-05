import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/routine/data/routine_firestore_data_source.dart';
import '../../../../features/routine/data/routine_repository_impl.dart';
import '../../../../features/routine/domain/routine_day_calculator.dart';
import '../../../../features/routine/domain/routine_repository.dart';
import '../../../../shared/models/workout_routine.dart';

part 'routine_providers.g.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

@riverpod
RoutineRepository routineRepository(Ref ref) {
  return RoutineRepositoryImpl(
    RoutineFirestoreDataSource(FirebaseFirestore.instance),
  );
}

// ---------------------------------------------------------------------------
// Current routine stream
//
// State flow: authNotifierProvider → userId → watchRoutine → WorkoutRoutine?
// Emits null when no routine document exists (not an error).
// ---------------------------------------------------------------------------

@riverpod
Stream<WorkoutRoutine?> currentRoutine(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.valueOrNull?.id;

  if (userId == null) {
    // No authenticated user — emit a single null and stay idle.
    return Stream.value(null);
  }

  return ref.watch(routineRepositoryProvider).watchRoutine(userId);
}

// ---------------------------------------------------------------------------
// Today's routine day — pure derived state
// ---------------------------------------------------------------------------

@riverpod
TodayRoutineDay? todayRoutineDay(Ref ref) {
  final routineAsync = ref.watch(currentRoutineProvider);
  final routine = routineAsync.valueOrNull;
  if (routine == null) return null;
  return computeTodayRoutineDay(routine, DateTime.now());
}

// ---------------------------------------------------------------------------
// RoutineNotifier — handles save / delete mutations
//
// Initial state: AsyncData(null) — idle, no in-flight operation.
// Callers check state for AsyncLoading / AsyncError after mutations.
// ---------------------------------------------------------------------------

@riverpod
class RoutineNotifier extends _$RoutineNotifier {
  @override
  Future<void> build() async {}

  Future<void> saveRoutine(WorkoutRoutine routine) async {
    state = const AsyncLoading();
    final failure =
        await ref.read(routineRepositoryProvider).saveRoutine(routine);
    if (failure != null) {
      state = AsyncError(failure.message, StackTrace.current);
      return;
    }
    state = const AsyncData(null);
  }

  Future<void> deleteRoutine() async {
    final userId = ref.read(authNotifierProvider).valueOrNull?.id;
    if (userId == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    final failure =
        await ref.read(routineRepositoryProvider).deleteRoutine(userId);
    if (failure != null) {
      state = AsyncError(failure.message, StackTrace.current);
      return;
    }
    state = const AsyncData(null);
  }
}
