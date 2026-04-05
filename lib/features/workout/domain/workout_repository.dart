import '../../../shared/models/workout_template.dart';
import '../../../shared/models/workout_session.dart';
import '../../../core/errors/failures.dart';

abstract class WorkoutRepository {
  Future<(List<WorkoutTemplate>, Failure?)> getTemplates(String userId);
  Future<Failure?> saveTemplate(String userId, WorkoutTemplate template);
  Future<Failure?> deleteTemplate(String userId, String templateId);
  Future<Failure?> saveWorkoutSession(WorkoutSession session);
  Future<(List<WorkoutSession>, Failure?)> getWorkoutHistory(String userId, {int limit = 20});
  Future<(WorkoutSession?, Failure?)> getSession(String userId, String sessionId);
}
