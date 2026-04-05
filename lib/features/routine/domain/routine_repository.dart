import '../../../core/errors/failures.dart';
import '../../../shared/models/workout_routine.dart';

abstract class RoutineRepository {
  Stream<WorkoutRoutine?> watchRoutine(String userId);
  Future<(WorkoutRoutine?, Failure?)> getRoutine(String userId);
  Future<Failure?> saveRoutine(WorkoutRoutine routine);
  Future<Failure?> deleteRoutine(String userId);
}
