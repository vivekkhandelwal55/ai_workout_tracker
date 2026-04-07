import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_session.dart';

class WorkoutHistoryDetailScreen extends ConsumerWidget {
  const WorkoutHistoryDetailScreen({super.key, required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStr =
        session.templateName?.toUpperCase() ?? 'WORKOUT';
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(session.startTime);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleStr,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  dateStr,
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            titleSpacing: 0,
            toolbarHeight: 64,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.outlineVariant),
            ),
          ),

          // ── Summary stat row ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SummaryRow(session: session),
          ),

          // ── Divider ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(height: 1, color: AppColors.outlineVariant),
          ),

          // ── Empty state ──────────────────────────────────────────────────
          if (session.exercises.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No exercises recorded for this session.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          // ── Exercise cards ───────────────────────────────────────────────
          if (session.exercises.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              sliver: SliverList.separated(
                itemCount: session.exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => RepaintBoundary(
                  child: _ExerciseCard(
                    exercise: session.exercises[index],
                    index: index,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.session});

  final WorkoutSession session;

  String _formatVolume(double kg) {
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)}K KG';
    return '${kg.toStringAsFixed(0)} KG';
  }

  @override
  Widget build(BuildContext context) {
    final duration = session.durationMinutes;
    final volume = session.totalVolumeKg;
    final sets = session.totalSets;
    final exercises = session.exercises.length;

    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryStat(value: '$duration', unit: 'MIN'),
          _SummaryDivider(),
          _SummaryStat(value: _formatVolume(volume), unit: 'VOLUME'),
          _SummaryDivider(),
          _SummaryStat(value: '$sets', unit: 'SETS'),
          _SummaryDivider(),
          _SummaryStat(value: '$exercises', unit: 'EXERCISES'),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lexendMega(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          unit,
          style: GoogleFonts.lexend(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.outlineVariant,
    );
  }
}

// ── Exercise card ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.index});

  final SessionExercise exercise;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                // Exercise number badge
                Container(
                  width: 24,
                  height: 24,
                  color: AppColors.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exercise.exerciseName.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Text(
                  '${exercise.sets.where((s) => s.isCompleted).length} SETS',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Divider between header and table
          Container(height: 1, color: AppColors.surfaceContainerHighest),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    'SET',
                    style: GoogleFonts.lexend(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    'TYPE',
                    style: GoogleFonts.lexend(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'WEIGHT',
                    style: GoogleFonts.lexend(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    'REPS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
              ],
            ),
          ),

          // Set rows
          ...exercise.sets.map(
            (set) => _SetRow(workoutSet: set),
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Set row ───────────────────────────────────────────────────────────────────

class _SetRow extends StatelessWidget {
  const _SetRow({required this.workoutSet});

  final WorkoutSet workoutSet;

  Color _rowBackground(SetType type) {
    return switch (type) {
      SetType.warmup => AppColors.warning.withValues(alpha: 0.06),
      SetType.dropSet => const Color(0xFFFF6600).withValues(alpha: 0.06),
      _ => Colors.transparent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final weightStr = workoutSet.weight != null
        ? '${workoutSet.weight!.toStringAsFixed(workoutSet.weight! % 1 == 0 ? 0 : 1)} KG'
        : '—';
    final repsStr =
        workoutSet.reps != null ? workoutSet.reps.toString() : '—';

    return Container(
      color: _rowBackground(workoutSet.type),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 32,
            child: Text(
              '${workoutSet.setNumber}',
              style: GoogleFonts.lexendMega(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: workoutSet.isCompleted
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),

          // Type badge
          SizedBox(
            width: 56,
            child: _SetTypeBadge(type: workoutSet.type),
          ),

          // Weight
          Expanded(
            child: Text(
              weightStr,
              style: GoogleFonts.lexendMega(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: workoutSet.isCompleted
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),

          // Reps
          SizedBox(
            width: 48,
            child: Text(
              repsStr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexendMega(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: workoutSet.isCompleted
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),

          // Status icon / PR badge
          SizedBox(
            width: 32,
            child: Align(
              alignment: Alignment.centerRight,
              child: workoutSet.isPR
                  ? _PRBadge()
                  : workoutSet.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.primary,
                        )
                      : const Icon(
                          Icons.remove,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Set type badge ────────────────────────────────────────────────────────────

class _SetTypeBadge extends StatelessWidget {
  const _SetTypeBadge({required this.type});

  final SetType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      SetType.warmup => ('W', AppColors.warning),
      SetType.dropSet => ('D', const Color(0xFFFF6600)),
      SetType.failureSet => ('F', AppColors.error),
      SetType.normal => ('', AppColors.onSurfaceVariant),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: color.withValues(alpha: 0.15),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

// ── PR badge ──────────────────────────────────────────────────────────────────

class _PRBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
      child: Text(
        'PR',
        style: GoogleFonts.lexend(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: const Color(0xFFFFD700),
        ),
      ),
    );
  }
}
