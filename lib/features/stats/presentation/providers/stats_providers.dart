import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/stats_repository_impl.dart';
import '../../domain/stats_repository.dart';
import '../../../../features/workout/data/workout_firestore_data_source.dart';
import '../../../../shared/models/personal_record.dart';
import '../../../../shared/models/stats_data.dart';
import '../../../../shared/models/workout_session.dart';

enum StrengthRange { oneMonth, threeMonths, sixMonths, all }

final selectedStrengthRangeProvider =
    StateProvider<StrengthRange>((ref) => StrengthRange.threeMonths);

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return FirebaseStatsRepository(
    WorkoutFirestoreDataSource(FirebaseFirestore.instance),
  );
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

// exerciseId selected for the strength progress chart
final selectedExerciseForGraphProvider =
    StateProvider<String>((ref) => '');

final strengthProgressProvider =
    FutureProvider.family<List<StrengthDataPoint>, String>((ref, userId) async {
      final exerciseId = ref.watch(selectedExerciseForGraphProvider);
      if (exerciseId.isEmpty) return [];

      final range = ref.watch(selectedStrengthRangeProvider);
      final (data, _) = await ref
          .watch(statsRepositoryProvider)
          .getStrengthProgress(userId, exerciseId);

      if (data.isEmpty) return data;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final cutoff = switch (range) {
        StrengthRange.oneMonth => today.subtract(const Duration(days: 30)),
        StrengthRange.threeMonths => today.subtract(const Duration(days: 90)),
        StrengthRange.sixMonths => today.subtract(const Duration(days: 180)),
        StrengthRange.all => DateTime(2000),
      };

      return data.where((p) => !p.date.isBefore(cutoff)).toList();
    });

final workoutHistoryProvider =
    FutureProvider.family<List<WorkoutSession>, String>((ref, userId) async {
      final (history, _) =
          await ref.watch(statsRepositoryProvider).getWorkoutHistory(userId);
      return history;
    });

final lifetimeWorkoutStatsProvider =
    FutureProvider.family<LifetimeStats, String>((ref, userId) async {
      final (history, _) = await ref
          .watch(statsRepositoryProvider)
          .getWorkoutHistory(userId, limit: 500);
      final completed = history.where((s) => s.isCompleted).toList();
      return LifetimeStats(
        totalSessions: completed.length,
        totalVolumeKg: completed.fold(0.0, (acc, s) => acc + s.totalVolumeKg),
        totalSets: completed.fold(0, (acc, s) => acc + s.totalSets),
      );
    });
