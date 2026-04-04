import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/exercise_repository_impl.dart';
import '../../domain/exercise_repository.dart';
import '../../../../shared/models/exercise.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return StubExerciseRepository();
});

final muscleGroupFilterProvider = StateProvider<MuscleGroup?>((ref) => null);
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final filter = ref.watch(muscleGroupFilterProvider);
  final query = ref.watch(exerciseSearchQueryProvider);
  final (exercises, _) = await ref
      .watch(exerciseRepositoryProvider)
      .getExercises(
        filterByMuscle: filter,
        searchQuery: query.isEmpty ? null : query,
      );
  return exercises;
});
