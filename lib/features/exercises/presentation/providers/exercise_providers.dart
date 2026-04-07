import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/exercise_repository_impl.dart';
import '../../data/exercise_firestore_data_source.dart';
import '../../data/exercise_local_data_source.dart';
import '../../domain/exercise_repository.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/models/exercise.dart';

final exerciseLocalDataSourceProvider = Provider<ExerciseLocalDataSource>((ref) {
  return ExerciseLocalDataSource();
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(
    ref.read(exerciseLocalDataSourceProvider),
    ExerciseFirestoreDataSource(FirebaseFirestore.instance),
  );
});

final muscleGroupFilterProvider = StateProvider<MuscleGroup?>((ref) => null);
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final filter = ref.watch(muscleGroupFilterProvider);
  final query = ref.watch(exerciseSearchQueryProvider);
  final authState = ref.watch(authNotifierProvider).valueOrNull;
  final userId = authState?.id;
  final (exercises, _) = await ref
      .watch(exerciseRepositoryProvider)
      .getExercises(
        filterByMuscle: filter,
        searchQuery: query.isEmpty ? null : query,
        userId: userId,
      );
  return exercises;
});

/// Fetches metadata for a single exercise by ID.
/// Used by the active workout screen to display exercise type and muscle group.
final exerciseMetadataProvider =
    FutureProvider.family<Exercise?, String>((ref, exerciseId) async {
  final (exercises, _) = await ref
      .read(exerciseRepositoryProvider)
      .getExercises();
  try {
    return exercises.firstWhere((e) => e.id == exerciseId);
  } catch (_) {
    return null;
  }
});

/// Fallback metadata lookup by exercise name (case-insensitive).
/// Used when the ID-based lookup in [exerciseMetadataProvider] returns null
/// due to an ID format mismatch between templates and the exercise library.
final exerciseMetadataByNameProvider =
    FutureProvider.family<Exercise?, String>((ref, exerciseName) async {
  final (exercises, _) = await ref
      .read(exerciseRepositoryProvider)
      .getExercises();
  try {
    return exercises.firstWhere(
      (e) => e.name.toLowerCase() == exerciseName.toLowerCase(),
    );
  } catch (_) {
    return null;
  }
});
