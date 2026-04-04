import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/stats/presentation/providers/stats_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/personal_record.dart';
import 'package:ai_workout_tracker_app/shared/models/stats_data.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  // Stub user id for now
  static const String _userId = 'stub-user';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider(_userId));
    final personalRecordsAsync = ref.watch(personalRecordsProvider(_userId));
    final strengthProgressAsync =
        ref.watch(strengthProgressProvider(_userId));

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
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
                            Text(
                              'SQUAT PR',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
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
                          loading: () =>
                              const SizedBox(height: 200),
                          error: (err, st) =>
                              const SizedBox(height: 200),
                          data: (dataPoints) =>
                              _StrengthChart(dataPoints: dataPoints),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Records Section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
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
                          data: (records) => Column(
                            children: records
                                .map((pr) => _PRRecordRow(pr: pr))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // History Section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'No sessions recorded yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
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
          // Row 1: Frequency + PR Count
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'FREQUENCY',
                  value: '24',
                  unit: 'DAYS/MO',
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

          // Row 2: Weekly Volume (full width with mini bar chart)
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
    // Stub bar values for the mini chart
    final barValues = [0.5, 0.7, 0.4, 0.9, 0.6, 0.8, 1.0];
    final maxHeight = 40.0;

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
          // Mini bar chart
          SizedBox(
            width: 70,
            height: maxHeight + 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: barValues.asMap().entries.map((entry) {
                final isLast = entry.key == barValues.length - 1;
                return Container(
                  width: 8,
                  height: maxHeight * entry.value,
                  color: isLast
                      ? AppColors.primary
                      : AppColors.surfaceContainerHighest,
                );
              }).toList(),
            ),
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
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  List<StrengthDataPoint> get _displayPoints {
    if (dataPoints.isNotEmpty) return dataPoints;
    // Stub data
    final now = DateTime.now();
    return List.generate(7, (i) {
      final month = now.month - 6 + i;
      final date = DateTime(now.year, month, 1);
      const weights = [100.0, 107.5, 112.5, 120.0, 127.5, 135.0, 145.0];
      return StrengthDataPoint(
        date: date,
        weight: weights[i],
        reps: 5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final points = _displayPoints;
    final spots = points.asMap().entries.map((e) {
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
                  if (idx < 0 || idx >= points.length) {
                    return const SizedBox.shrink();
                  }
                  final monthIdx = points[idx].date.month - 1;
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

  const _PRRecordRow({required this.pr});

  Color _weightColor(PersonalRecord pr) {
    final name = pr.exerciseName.toLowerCase();
    if (name.contains('deadlift')) return AppColors.warning;
    if (pr.isNew) return AppColors.primary;
    return AppColors.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d').format(pr.achievedAt).toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
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
                  'LAST SET: ${pr.reps} REPS',
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
    );
  }
}
