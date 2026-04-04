import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/stats_repository_impl.dart';
import '../../domain/stats_repository.dart';
import '../../../../shared/models/personal_record.dart';
import '../../../../shared/models/stats_data.dart';
import '../../../../shared/models/workout_session.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StubStatsRepository();
});

final weeklyStatsProvider =
    FutureProvider.family<WeeklyStats, String>((ref, userId) async {
      final (stats, _) =
          await ref.watch(statsRepositoryProvider).getWeeklyStats(userId);
      return stats;
    });

final personalRecordsProvider =
    FutureProvider.family<List<PersonalRecord>, String>((ref, userId) async {
      final (records, _) =
          await ref.watch(statsRepositoryProvider).getPersonalRecords(userId);
      return records;
    });

final selectedExerciseForGraphProvider =
    StateProvider<String>((ref) => 'ex-009');

final strengthProgressProvider =
    FutureProvider.family<List<StrengthDataPoint>, String>((ref, userId) async {
      final exerciseId = ref.watch(selectedExerciseForGraphProvider);
      final (data, _) = await ref
          .watch(statsRepositoryProvider)
          .getStrengthProgress(userId, exerciseId);
      return data;
    });

final workoutHistoryProvider =
    FutureProvider.family<List<WorkoutSession>, String>((ref, userId) async {
      final (history, _) =
          await ref.watch(statsRepositoryProvider).getWorkoutHistory(userId);
      return history;
    });
