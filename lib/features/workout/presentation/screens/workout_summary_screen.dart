import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/router/app_router.dart';
import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/providers/workout_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_session.dart';

class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({super.key});

  String _formatVolume(double kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(1)}K';
    }
    return kg.toStringAsFixed(0);
  }

  String _buildSetsDescription(SessionExercise exercise) {
    final completedSets =
        exercise.sets.where((s) => s.isCompleted).toList();
    if (completedSets.isEmpty) {
      return '${exercise.sets.length} SETS';
    }
    final repsList = completedSets
        .where((s) => s.reps != null)
        .map((s) => s.reps!.toString())
        .toSet()
        .toList();
    final repsStr = repsList.join('+');
    return '${completedSets.length} SETS${repsStr.isNotEmpty ? ' • $repsStr REPS' : ''}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeWorkoutProvider);
    final session = state.session;

    // PR detection from session
    final prSets = <({String name, double weight, int reps, bool isVolume})>[];
    if (session != null) {
      for (final ex in session.exercises) {
        for (final set in ex.sets) {
          if (set.isPR && set.weight != null && set.reps != null) {
            prSets.add((
              name: ex.exerciseName,
              weight: set.weight!,
              reps: set.reps!,
              isVolume: false,
            ));
          }
        }
      }
    }

    // Use stub PRs if none found
    final displayPRs = prSets.isNotEmpty
        ? prSets
        : [
            (
              name: 'SQUAT (HIGH BAR)',
              weight: 145.0,
              reps: 5,
              isVolume: false,
            ),
            (
              name: 'BENCH PRESS',
              weight: 100.0,
              reps: 8,
              isVolume: true,
            ),
          ];

    final exercises = session?.exercises ?? [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
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
                      Icon(
                        Icons.settings_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SESSION SAVED',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Hero Section
                    Text(
                      'SUMMARY',
                      style: GoogleFonts.lexend(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Another step toward the goal. Your metrics are now synced.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Duration Block
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'DURATION',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                session != null
                                    ? session.durationMinutes.toString()
                                    : '74',
                                style: GoogleFonts.lexend(
                                  fontSize: 80,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -2.0,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'MIN',
                                style: GoogleFonts.lexend(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats Row
                    Container(
                      color: AppColors.surfaceContainerLow,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'VOLUME',
                                  style:
                                      Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session != null
                                      ? _formatVolume(session.totalVolumeKg)
                                      : '12.4K',
                                  style: GoogleFonts.lexend(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.surfaceContainerHighest,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'SETS',
                                  style:
                                      Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      session != null
                                          ? session.totalSets.toString()
                                          : '22',
                                      style: GoogleFonts.lexend(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Personal Best Section
                    Text(
                      'PERSONAL BEST',
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
                    const SizedBox(height: 8),
                    ...displayPRs.map((pr) => _PRRow(pr: pr)),

                    const SizedBox(height: 32),

                    // Exercises Section
                    Row(
                      children: [
                        Text(
                          'EXERCISES',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${exercises.isNotEmpty ? exercises.length : 3} TOTAL',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: AppColors.outlineVariant,
                    ),

                    // Exercise list
                    if (exercises.isNotEmpty)
                      ...exercises.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final ex = entry.value;
                        return _ExerciseRow(
                          index: idx + 1,
                          name: ex.exerciseName,
                          setsDescription: _buildSetsDescription(ex),
                        );
                      })
                    else ...[
                      _ExerciseRow(
                        index: 1,
                        name: 'SQUAT (HIGH BAR)',
                        setsDescription: '5 SETS • 5+8 REPS',
                      ),
                      _ExerciseRow(
                        index: 2,
                        name: 'BENCH PRESS',
                        setsDescription: '4 SETS • 8 REPS',
                      ),
                      _ExerciseRow(
                        index: 3,
                        name: 'DEADLIFT',
                        setsDescription: '3 SETS • 5 REPS',
                      ),
                    ],

                    const SizedBox(height: 32),

                    // CTA Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHighest,
                          foregroundColor: AppColors.onSurface,
                          side: const BorderSide(
                              color: AppColors.outlineVariant, width: 1),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () {
                          ref
                              .read(activeWorkoutProvider.notifier)
                              .reset();
                          context.go(AppRoutes.home);
                        },
                        child: Text(
                          'FINISH & SAVE',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () {},
                        child: Text(
                          '< SHARE SESSION',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PRRow extends StatelessWidget {
  final ({String name, double weight, int reps, bool isVolume}) pr;

  const _PRRow({required this.pr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.name.toUpperCase(),
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pr.weight.toStringAsFixed(0)} KG X ${pr.reps} REPS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (pr.isVolume)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: AppColors.primary,
              child: Text(
                'VOLUME PR',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.onPrimary,
                ),
              ),
            )
          else
            Text(
              '+5KG',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final int index;
  final String name;
  final String setsDescription;

  const _ExerciseRow({
    required this.index,
    required this.name,
    required this.setsDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              index.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  setsDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}
