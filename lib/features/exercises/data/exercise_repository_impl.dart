import '../domain/exercise_repository.dart';
import '../../../shared/models/exercise.dart';
import '../../../core/errors/failures.dart';
import 'exercise_firestore_data_source.dart';
import 'exercise_local_data_source.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._localDataSource, this._firestoreDataSource);

  final ExerciseLocalDataSource _localDataSource;
  final ExerciseFirestoreDataSource _firestoreDataSource;

  @override
  Future<(List<Exercise>, Failure?)> getExercises({
    MuscleGroup? filterByMuscle,
    String? searchQuery,
    String? userId,
  }) async {
    try {
      final localExercises = await _localDataSource.getExercises(
        filterByMuscle: filterByMuscle,
        searchQuery: searchQuery,
      );

      var customExercises = <Exercise>[];
      if (userId != null) {
        customExercises = await _firestoreDataSource.getCustomExercises(userId);
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          customExercises = customExercises
              .where((e) => e.name.toLowerCase().contains(q))
              .toList();
        }
        if (filterByMuscle != null) {
          customExercises = customExercises
              .where((e) => e.primaryMuscle == filterByMuscle)
              .toList();
        }
      }

      return ([...localExercises, ...customExercises], null);
    } catch (e) {
      return (<Exercise>[], UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> createCustomExercise(Exercise exercise) async {
    if (exercise.userId == null) {
      return const ValidationFailure('Custom exercises require a userId');
    }
    try {
      await _firestoreDataSource.createCustomExercise(exercise.userId!, exercise);
      return null;
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
