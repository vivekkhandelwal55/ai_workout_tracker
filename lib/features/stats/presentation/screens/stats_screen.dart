import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/features/stats/presentation/providers/stats_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/personal_record.dart';
import 'package:ai_workout_tracker_app/shared/models/stats_data.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_session.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId =
        ref.watch(authNotifierProvider).valueOrNull?.id ?? '';

    if (userId.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final weeklyStatsAsync = ref.watch(weeklyStatsProvider(userId));
    final personalRecordsAsync = ref.watch(personalRecordsProvider(userId));
    final strengthProgressAsync = ref.watch(strengthProgressProvider(userId));
    final historyAsync = ref.watch(workoutHistoryProvider(userId));

    // Auto-select the top PR exercise for the chart once records load
    personalRecordsAsync.whenData((records) {
      if (records.isNotEmpty) {
        final current = ref.read(selectedExerciseForGraphProvider);
        if (current.isEmpty) {
          ref.read(selectedExerciseForGraphProvider.notifier).state =
              records.first.exerciseId;
        }
      }
    });

    final selectedExerciseId = ref.watch(selectedExerciseForGraphProvider);
    final selectedExerciseName = personalRecordsAsync.valueOrNull
        ?.firstWhere(
          (r) => r.exerciseId == selectedExerciseId,
          orElse: () => personalRecordsAsync.valueOrNull?.firstOrNull ??
              PersonalRecord(
                exerciseId: '',
                exerciseName: '',
                weight: 0,
                reps: 0,
                achievedAt: DateTime.now(),
                isNew: false,
              ),
        )
        .exerciseName;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.menu,
                            color: AppColors.onSurfaceVariant, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'TRAIN',
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.settings_outlined,
                            color: AppColors.onSurfaceVariant, size: 24),
                      ],
                    ),
                  ),

                  // Top Stats Grid
                  weeklyStatsAsync.when(
                    loading: () => const SizedBox(height: 160),
                    error: (err, st) => const SizedBox(height: 160),
                    data: (stats) => _StatsGrid(stats: stats),
                  ),

                  const SizedBox(height: 24),

                  // Strength Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'STRENGTH',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const Spacer(),
                            // Exercise picker for chart
                            personalRecordsAsync.when(
                              loading: () => const SizedBox.shrink(),
                              error: (e, s) => const SizedBox.shrink(),
                              data: (records) {
                                if (records.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return GestureDetector(
                                  onTap: () => _showExercisePicker(
                                    context,
                                    ref,
                                    records,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        (selectedExerciseName ?? records.first.exerciseName)
                                            .toUpperCase(),
                                        style: GoogleFonts.lexend(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.expand_more,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          color: AppColors.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        strengthProgressAsync.when(
                          loading: () => const SizedBox(height: 200),
                          error: (err, st) => const SizedBox(height: 200),
                          data: (dataPoints) {
                            if (dataPoints.isEmpty) {
                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    'No data yet — complete a workout to see your progress',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              );
                            }
                            return _StrengthChart(dataPoints: dataPoints);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Records Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RECORDS',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          color: AppColors.outlineVariant,
                        ),
                        personalRecordsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          ),
                          error: (err, st) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Unable to load records.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          data: (records) {
                            if (records.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'No records yet — log some sets to track your PRs',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: records
                                  .map((pr) => _PRRecordRow(
                                        pr: pr,
                                        isSelectedForGraph:
                                            pr.exerciseId == selectedExerciseId,
                                        onTap: () {
                                          ref
                                              .read(
                                                selectedExerciseForGraphProvider
                                                    .notifier,
                                              )
                                              .state = pr.exerciseId;
                                        },
                                      ))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // History Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _showFullHistory(context, historyAsync),
                          child: Row(
                            children: [
                              Text(
                                'HISTORY',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward,
                                color: AppColors.onSurface,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        historyAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                          error: (err, st) => Text(
                            'Unable to load history.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          data: (sessions) {
                            if (sessions.isEmpty) {
                              return Center(
                                child: Text(
                                  'No sessions recorded yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                ),
                              );
                            }
                            return Column(
                              children: sessions
                                  .map(
                                    (session) =>
                                        _WorkoutHistoryRow(session: session),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullHistory(
    BuildContext context,
    AsyncValue<List<WorkoutSession>> historyAsync,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (ctx2, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                color: AppColors.surfaceContainerHighest,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'WORKOUT HISTORY',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Container(height: 1, color: AppColors.outlineVariant),
            Expanded(
              child: historyAsync.when(
                loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, st) => Center(
                  child: Text('Unable to load history.',
                      style: GoogleFonts.lexend(
                          color: AppColors.onSurfaceVariant)),
                ),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Center(
                      child: Text(
                        'No sessions recorded yet',
                        style: GoogleFonts.lexend(
                            color: AppColors.onSurfaceVariant),
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: sessions.length,
                    separatorBuilder: (_, i) => Container(
                        height: 1, color: AppColors.outlineVariant),
                    itemBuilder: (_, i) =>
                        _WorkoutHistoryRow(session: sessions[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExercisePicker(
    BuildContext context,
    WidgetRef ref,
    List<PersonalRecord> records,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'SELECT EXERCISE',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              ...records.map(
                (pr) => ListTile(
                  title: Text(
                    pr.exerciseName.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '${pr.weight.toStringAsFixed(0)} KG × ${pr.reps} REPS',
                    style: Theme.of(ctx).textTheme.labelSmall,
                  ),
                  onTap: () {
                    ref
                        .read(selectedExerciseForGraphProvider.notifier)
                        .state = pr.exerciseId;
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final WeeklyStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row 1: Workouts this week + PR Count
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'THIS WEEK',
                  value: stats.workoutsThisWeek.toString(),
                  unit: 'WORKOUTS',
                  valueColor: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'PR COUNT',
                  value: stats.totalPRsThisWeek.toString(),
                  unit: 'WK',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Weekly Volume (full width with streak)
          _VolumeStatTile(stats: stats),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color valueColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VolumeStatTile extends StatelessWidget {
  final WeeklyStats stats;

  const _VolumeStatTile({required this.stats});

  String _formatVolume(double kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(1)}K';
    }
    return kg.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY VOLUME',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatVolume(stats.totalVolumeKg),
                      style: GoogleFonts.lexend(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'KG',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Streak badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'STREAK',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    stats.currentStreak.toString(),
                    style: GoogleFonts.lexend(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: stats.currentStreak > 0
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'DAYS',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StrengthChart extends StatelessWidget {
  final List<StrengthDataPoint> dataPoints;

  const _StrengthChart({required this.dataPoints});

  static const List<String> _monthLabels = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final spots = dataPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final currentMonthIndex = DateTime.now().month - 1;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.surfaceContainerHighest,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= dataPoints.length) {
                    return const SizedBox.shrink();
                  }
                  final monthIdx = dataPoints[idx].date.month - 1;
                  final isCurrentMonth = monthIdx == currentMonthIndex;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _monthLabels[monthIdx % 12],
                      style: GoogleFonts.lexend(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        color: isCurrentMonth
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: AppColors.primary,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final isLast = index == spots.length - 1;
                  return FlDotCirclePainter(
                    radius: isLast ? 6 : 0,
                    color: isLast ? AppColors.primary : Colors.transparent,
                    strokeColor: Colors.transparent,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _PRRecordRow extends StatelessWidget {
  final PersonalRecord pr;
  final bool isSelectedForGraph;
  final VoidCallback onTap;

  const _PRRecordRow({
    required this.pr,
    required this.isSelectedForGraph,
    required this.onTap,
  });

  Color _weightColor(PersonalRecord pr) {
    final name = pr.exerciseName.toLowerCase();
    if (name.contains('deadlift')) return AppColors.warning;
    if (pr.isNew) return AppColors.primary;
    return AppColors.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d').format(pr.achievedAt).toUpperCase();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            if (isSelectedForGraph)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 3,
                  height: 40,
                  color: AppColors.primary,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pr.exerciseName.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BEST SET: ${pr.reps} REPS',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      pr.weight.toStringAsFixed(0),
                      style: GoogleFonts.lexend(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _weightColor(pr),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'KG',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutHistoryRow extends StatelessWidget {
  final WorkoutSession session;

  const _WorkoutHistoryRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('EEE, MMM d').format(session.startTime).toUpperCase();
    final duration = session.durationMinutes;
    final volume = session.totalVolumeKg;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.templateName?.toUpperCase() ?? 'WORKOUT',
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                volume >= 1000
                    ? '${(volume / 1000).toStringAsFixed(1)}K KG'
                    : '${volume.toStringAsFixed(0)} KG',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$duration MIN',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
