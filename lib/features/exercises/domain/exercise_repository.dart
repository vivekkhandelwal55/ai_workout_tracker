import '../../../shared/models/exercise.dart';
import '../../../core/errors/failures.dart';

abstract class ExerciseRepository {
  Future<(List<Exercise>, Failure?)> getExercises({
    MuscleGroup? filterByMuscle,
    String? searchQuery,
    String? userId,
  });
  Future<Failure?> createCustomExercise(Exercise exercise);
}
