import '../../../shared/models/personal_record.dart';
import '../../../shared/models/stats_data.dart';
import '../../../shared/models/workout_session.dart';
import '../../../core/errors/failures.dart';

abstract class StatsRepository {
  Future<(WeeklyStats, Failure?)> getWeeklyStats(String userId);
  Future<(List<PersonalRecord>, Failure?)> getPersonalRecords(String userId);
  Future<(List<StrengthDataPoint>, Failure?)> getStrengthProgress(
    String userId,
    String exerciseId,
  );
  Future<(List<WorkoutSession>, Failure?)> getWorkoutHistory(
    String userId, {
    int limit = 20,
  });
}
