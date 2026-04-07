import '../domain/stats_repository.dart';
import '../../workout/data/workout_firestore_data_source.dart';
import '../../../shared/models/personal_record.dart';
import '../../../shared/models/stats_data.dart';
import '../../../shared/models/workout_session.dart';
import '../../../core/errors/failures.dart';

class FirebaseStatsRepository implements StatsRepository {
  FirebaseStatsRepository(this._dataSource);

  final WorkoutFirestoreDataSource _dataSource;

  @override
  Future<(WeeklyStats, Failure?)> getWeeklyStats(String userId) async {
    try {
      final sessions = await _dataSource.getWorkoutHistory(userId, limit: 100);
      final completed = sessions.where((s) => s.isCompleted).toList();

      final now = DateTime.now();
      final weekStart = DateTime(
        now.year,
        now.month,
        now.day - (now.weekday - 1),
      );
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weekSessions = completed
          .where(
            (s) =>
                !s.startTime.isBefore(weekStart) &&
                s.startTime.isBefore(weekEnd),
          )
          .toList();

      final totalVolumeKg =
          weekSessions.fold(0.0, (sum, s) => sum + s.totalVolumeKg);

      final totalPRsThisWeek = weekSessions.fold(0, (sum, s) {
        return sum +
            s.exercises.fold(0, (exSum, ex) {
              return exSum +
                  ex.sets.where((set) => set.isPR && set.isCompleted).length;
            });
      });

      final totalSets = weekSessions.fold(0, (sum, s) {
        return sum +
            s.exercises.fold(0, (exSum, ex) => exSum + ex.sets.length);
      });
      final completedSets =
          weekSessions.fold(0, (sum, s) => sum + s.totalSets);
      final averageIntensity =
          totalSets > 0 ? (completedSets / totalSets * 100) : 0.0;

      // Streak: consecutive days ending today (or yesterday) with a workout
      final workoutDays = completed
          .map(
            (s) =>
                DateTime(s.startTime.year, s.startTime.month, s.startTime.day),
          )
          .toSet();

      int streak = 0;
      var checkDay = DateTime(now.year, now.month, now.day);
      while (workoutDays.contains(checkDay)) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      }
      if (streak == 0) {
        // check from yesterday
        checkDay = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));
        while (workoutDays.contains(checkDay)) {
          streak++;
          checkDay = checkDay.subtract(const Duration(days: 1));
        }
      }

      return (
        WeeklyStats(
          workoutsThisWeek: weekSessions.length,
          totalVolumeKg: totalVolumeKg,
          averageIntensity: averageIntensity,
          currentStreak: streak,
          totalPRsThisWeek: totalPRsThisWeek,
        ),
        null,
      );
    } catch (e) {
      return (
        const WeeklyStats(
          workoutsThisWeek: 0,
          totalVolumeKg: 0,
          averageIntensity: 0,
          currentStreak: 0,
          totalPRsThisWeek: 0,
        ),
        UnknownFailure(e.toString()),
      );
    }
  }

  @override
  Future<(List<PersonalRecord>, Failure?)> getPersonalRecords(
    String userId,
  ) async {
    try {
      final sessions = await _dataSource.getWorkoutHistory(userId, limit: 200);
      final completed = sessions.where((s) => s.isCompleted).toList();

      final Map<String, PersonalRecord> bestByExercise = {};

      for (final session in completed) {
        for (final exercise in session.exercises) {
          for (final set in exercise.sets) {
            if (!set.isCompleted || set.weight == null || set.reps == null) {
              continue;
            }
            final existing = bestByExercise[exercise.exerciseId];
            if (existing == null || set.weight! > existing.weight) {
              bestByExercise[exercise.exerciseId] = PersonalRecord(
                exerciseId: exercise.exerciseId,
                exerciseName: exercise.exerciseName,
                weight: set.weight!,
                reps: set.reps!,
                achievedAt: session.startTime,
                isNew: false,
              );
            }
          }
        }
      }

      final records = bestByExercise.values.toList()
        ..sort((a, b) => b.weight.compareTo(a.weight));

      return (records, null);
    } catch (e) {
      return (<PersonalRecord>[], UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<StrengthDataPoint>, Failure?)> getStrengthProgress(
    String userId,
    String exerciseId,
  ) async {
    try {
      final sessions = await _dataSource.getWorkoutHistory(userId, limit: 200);
      final completed = sessions.where((s) => s.isCompleted).toList();

      // One point per calendar day — best set ranked by Epley e1RM.
      final Map<String, StrengthDataPoint> byDay = {};

      for (final session in completed) {
        for (final exercise in session.exercises) {
          if (exercise.exerciseId != exerciseId) continue;
          for (final set in exercise.sets) {
            if (!set.isCompleted || set.weight == null || set.reps == null) {
              continue;
            }
            // Epley estimated 1-rep max
            final e1rm = set.weight! * (1 + set.reps! / 30.0);
            final dayKey =
                '${session.startTime.year}-'
                '${session.startTime.month.toString().padLeft(2, '0')}-'
                '${session.startTime.day.toString().padLeft(2, '0')}';

            final existing = byDay[dayKey];

            if (existing == null || e1rm > existing.e1rm) {
              // New best set for this day; preserve any PR flag seen earlier today
              byDay[dayKey] = StrengthDataPoint(
                date: DateTime(
                  session.startTime.year,
                  session.startTime.month,
                  session.startTime.day,
                ),
                weight: set.weight!,
                reps: set.reps!,
                e1rm: e1rm,
                isPR: (existing?.isPR ?? false) || set.isPR,
              );
            } else if (set.isPR && !existing.isPR) {
              // Lower e1RM but flagged PR — preserve flag without replacing best-set data
              byDay[dayKey] = StrengthDataPoint(
                date: existing.date,
                weight: existing.weight,
                reps: existing.reps,
                e1rm: existing.e1rm,
                isPR: true,
              );
            }
          }
        }
      }

      final points = byDay.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      return (points, null);
    } catch (e) {
      return (<StrengthDataPoint>[], UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<WorkoutSession>, Failure?)> getWorkoutHistory(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final sessions =
          await _dataSource.getWorkoutHistory(userId, limit: limit);
      return (sessions, null);
    } catch (e) {
      return (<WorkoutSession>[], UnknownFailure(e.toString()));
    }
  }
}
