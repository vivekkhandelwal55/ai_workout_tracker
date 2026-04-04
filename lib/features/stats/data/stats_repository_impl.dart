import '../domain/stats_repository.dart';
import '../../../shared/models/personal_record.dart';
import '../../../shared/models/stats_data.dart';
import '../../../shared/models/workout_session.dart';
import '../../../core/errors/failures.dart';

class StubStatsRepository implements StatsRepository {
  @override
  Future<(WeeklyStats, Failure?)> getWeeklyStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return (
      const WeeklyStats(
        workoutsThisWeek: 3,
        totalVolumeKg: 42500,
        averageIntensity: 88,
        currentStreak: 4,
        totalPRsThisWeek: 8,
      ),
      null,
    );
  }

  @override
  Future<(List<PersonalRecord>, Failure?)> getPersonalRecords(
    String userId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return (
      [
        PersonalRecord(
          exerciseId: 'ex-009',
          exerciseName: 'Back Squat',
          weight: 185,
          reps: 5,
          achievedAt: DateTime(2024, 7, 12),
          isNew: false,
        ),
        PersonalRecord(
          exerciseId: 'ex-001',
          exerciseName: 'Bench Press',
          weight: 110,
          reps: 1,
          achievedAt: DateTime(2024, 7, 8),
          isNew: true,
        ),
        PersonalRecord(
          exerciseId: 'ex-017',
          exerciseName: 'Deadlift',
          weight: 220,
          reps: 3,
          achievedAt: DateTime(2024, 6, 29),
          isNew: false,
        ),
      ],
      null,
    );
  }

  @override
  Future<(List<StrengthDataPoint>, Failure?)> getStrengthProgress(
    String userId,
    String exerciseId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return (
      [
        StrengthDataPoint(date: DateTime(now.year, 1), weight: 120, reps: 5),
        StrengthDataPoint(date: DateTime(now.year, 2), weight: 130, reps: 5),
        StrengthDataPoint(date: DateTime(now.year, 3), weight: 140, reps: 5),
        StrengthDataPoint(date: DateTime(now.year, 4), weight: 145, reps: 5),
        StrengthDataPoint(date: DateTime(now.year, 5), weight: 155, reps: 5),
        StrengthDataPoint(date: DateTime(now.year, 6), weight: 165, reps: 5),
        StrengthDataPoint(date: DateTime(now.year, 7), weight: 185, reps: 5),
      ],
      null,
    );
  }

  @override
  Future<(List<WorkoutSession>, Failure?)> getWorkoutHistory(
    String userId, {
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return (<WorkoutSession>[], null);
  }
}
