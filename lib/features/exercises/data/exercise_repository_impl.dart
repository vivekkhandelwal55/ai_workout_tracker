import '../domain/exercise_repository.dart';
import '../../../shared/models/exercise.dart';
import '../../../core/errors/failures.dart';
import 'exercise_firestore_data_source.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._dataSource);

  final ExerciseFirestoreDataSource _dataSource;

  @override
  Future<(List<Exercise>, Failure?)> getExercises({
    MuscleGroup? filterByMuscle,
    String? searchQuery,
    String? userId,
  }) async {
    try {
      final exercises = await _dataSource.getExercises(
        filterByMuscle: filterByMuscle,
        searchQuery: searchQuery,
        userId: userId,
      );
      return (exercises, null);
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
      await _dataSource.createCustomExercise(exercise.userId!, exercise);
      return null;
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
