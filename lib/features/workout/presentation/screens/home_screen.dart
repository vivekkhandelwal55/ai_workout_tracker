import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/app/router/app_router.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/features/routine/presentation/providers/routine_providers.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/providers/workout_providers.dart';
import 'package:ai_workout_tracker_app/features/stats/presentation/providers/stats_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_template.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId =
        ref.watch(authNotifierProvider).valueOrNull?.id ?? 'stub-user-001';
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider(userId));
    final templatesAsync = ref.watch(workoutTemplatesProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: _buildStartWorkoutFAB(context, ref),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              _buildAppBar(context),
              _buildStatsSection(context, weeklyStatsAsync),
              const _RecommendedCard(),
              _buildTemplatesSection(context, ref, templatesAsync),
              _buildStrengthTrendsSection(context),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStartWorkoutFAB(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () {
        final userId = ref.read(authNotifierProvider).valueOrNull?.id ?? 'stub-user-001';
        ref.read(activeWorkoutProvider.notifier).startWorkout(userId: userId);
        context.push(AppRoutes.activeWorkout);
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 4,
      icon: const Icon(Icons.play_arrow, size: 28),
      label: Text(
        'QUICK START',
        style: GoogleFonts.lexend(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TRAIN',
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.0,
              color: Colors.white,
            ),
          ),
          Icon(
            Icons.menu,
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    AsyncValue weeklyStatsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 12),
          weeklyStatsAsync.when(
            loading: () => const _StatsPlaceholder(),
            error: (err, st) => const _StatsPlaceholder(),
            data: (stats) => _StatsData(stats: stats),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue templatesAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'YOUR TEMPLATES',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(AppRoutes.exercises),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'VIEW ALL',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          templatesAsync.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, st) => Text(
              'Failed to load templates',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            data: (templates) => _TemplatesGrid(templates: templates),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthTrendsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STRENGTH TRENDS',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTrendBox(context, '185 KG', 'BARBELL BACK SQUAT'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTrendBox(context, '115 LB', 'BENCH PRESS'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBox(BuildContext context, String value, String label) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _StatsPlaceholder extends StatelessWidget {
  const _StatsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '--',
              style: GoogleFonts.lexend(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'workouts this week',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _StatsRow(volume: '--', streak: '--', prs: '--'),
      ],
    );
  }
}

class _StatsData extends StatelessWidget {
  final dynamic stats;

  const _StatsData({required this.stats});

  @override
  Widget build(BuildContext context) {
    final workouts = stats.workoutsThisWeek.toString().padLeft(2, '0');
    final volume = stats.totalVolumeKg >= 1000
        ? '${(stats.totalVolumeKg / 1000).toStringAsFixed(1)}k'
        : stats.totalVolumeKg.toStringAsFixed(0);
    final streak = stats.currentStreak.toString();
    final prs = stats.totalPRsThisWeek.toString().padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              workouts,
              style: GoogleFonts.lexend(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'workouts this week',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _StatsRow(volume: volume, streak: streak, prs: prs),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String volume;
  final String streak;
  final String prs;

  const _StatsRow({
    required this.volume,
    required this.streak,
    required this.prs,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: _StatItem(label: 'VOLUME', value: volume)),
          VerticalDivider(
            color: AppColors.surfaceContainerHighest,
            width: 1,
            thickness: 1,
          ),
          Expanded(child: _StatItem(label: 'STREAK', value: streak)),
          VerticalDivider(
            color: AppColors.surfaceContainerHighest,
            width: 1,
            thickness: 1,
          ),
          Expanded(child: _StatItem(label: 'PRs', value: prs)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplatesGrid extends StatelessWidget {
  final List<WorkoutTemplate> templates;

  const _TemplatesGrid({required this.templates});

  @override
  Widget build(BuildContext context) {
    final displayTemplates = templates.take(3).toList();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: displayTemplates.length + 1,
      itemBuilder: (context, index) {
        if (index < displayTemplates.length) {
          return _TemplateCard(template: displayTemplates[index]);
        }
        return const _NewTemplateCard();
      },
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  final WorkoutTemplate template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(activeWorkoutProvider.notifier).startWorkout(
              userId: ref.read(authNotifierProvider).valueOrNull?.id ?? 'stub-user-001',
              template: template,
            );
        context.push(AppRoutes.activeWorkout);
      },
      onLongPress: () {
        _showTemplateOptions(context, ref, template);
      },
      child: Container(
        color: AppColors.surfaceContainerLow,
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${template.exercises.length} exercises',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Text(
                '→',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateOptions(BuildContext context, WidgetRef ref, WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.onSurface),
              title: Text(
                'EDIT TEMPLATE',
                style: GoogleFonts.lexend(color: AppColors.onSurface),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.push(AppRoutes.editTemplate, extra: template);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow, color: AppColors.primary),
              title: Text(
                'START WORKOUT',
                style: GoogleFonts.lexend(color: AppColors.primary),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(activeWorkoutProvider.notifier).startWorkout(
                  userId: ref.read(authNotifierProvider).valueOrNull?.id ?? 'stub-user-001',
                  template: template,
                );
                context.push(AppRoutes.activeWorkout);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NewTemplateCard extends StatelessWidget {
  const _NewTemplateCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.createTemplate),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '+',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NEW TEMPLATE',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recommended card — driven by routine + today's day data
// ---------------------------------------------------------------------------
class _RecommendedCard extends ConsumerWidget {
  const _RecommendedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authNotifierProvider).valueOrNull?.id ?? '';
    final routineAsync = ref.watch(currentRoutineProvider);
    final todayDay = ref.watch(todayRoutineDayProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: routineAsync.when(
        loading: () => const _RecommendedSkeleton(),
        error: (_, _s) => const _RecommendedSkeleton(),
        data: (routine) {
          // State 1 — no routine
          if (routine == null) {
            return const _RecommendedNoRoutine();
          }

          // State 2 — rest day (no template linked)
          if (todayDay == null || todayDay.routineDay.templateId == null) {
            return _RecommendedRestDay(
              routine: routine,
              todayDay: todayDay,
            );
          }

          // State 3 — workout day
          final templateId = todayDay.routineDay.templateId!;
          final templatesAsync = ref.watch(workoutTemplatesProvider(userId));
          final WorkoutTemplate? template =
              templatesAsync.valueOrNull?.cast<WorkoutTemplate?>().firstWhere(
                    (t) => t?.id == templateId,
                    orElse: () => null,
                  );

          return _RecommendedWorkoutDay(
            routine: routine,
            todayDay: todayDay,
            template: template,
            userId: userId,
          );
        },
      ),
    );
  }
}

// Skeleton placeholder
class _RecommendedSkeleton extends StatelessWidget {
  const _RecommendedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(20),
      height: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECOMMENDED', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: 180,
            color: AppColors.surfaceContainerHigh,
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 240,
            color: AppColors.surfaceContainerHigh,
          ),
        ],
      ),
    );
  }
}

// State 1 — no routine set
class _RecommendedNoRoutine extends StatelessWidget {
  const _RecommendedNoRoutine();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECOMMENDED', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 12),
          Text(
            'NO ROUTINE SET',
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set up your training schedule to get\npersonalised daily recommendations.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _CardButton(
              label: 'SET ROUTINE →',
              onPressed: () => context.push(AppRoutes.routine),
            ),
          ),
        ],
      ),
    );
  }
}

// State 2 — rest day
class _RecommendedRestDay extends StatelessWidget {
  final dynamic routine;
  final dynamic todayDay;

  const _RecommendedRestDay({required this.routine, required this.todayDay});

  @override
  Widget build(BuildContext context) {
    final totalDays = (routine.days as List).length;
    final dayNumber = todayDay != null ? todayDay.dayNumber as int : 0;

    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECOMMENDED',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              if (todayDay != null)
                Text(
                  'DAY $dayNumber OF $totalDays',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'REST',
            style: GoogleFonts.lexend(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Today is a recovery day. Stay hydrated\nand focus on mobility work.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _CardButton(
              label: 'PLAN: $totalDays DAYS',
              onPressed: () => context.push(AppRoutes.routine),
              isSecondary: true,
            ),
          ),
        ],
      ),
    );
  }
}

// State 3 — workout day
class _RecommendedWorkoutDay extends ConsumerWidget {
  final dynamic routine;
  final dynamic todayDay;
  final WorkoutTemplate? template;
  final String userId;

  const _RecommendedWorkoutDay({
    required this.routine,
    required this.todayDay,
    required this.template,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDays = (routine.days as List).length;
    final dayNumber = todayDay.dayNumber as int;
    final dayName =
        (todayDay.routineDay.templateName as String?)?.toUpperCase() ??
            todayDay.routineDay.name.toString().toUpperCase();

    // Exercise preview from template
    List<String> exerciseNames = [];
    int extraCount = 0;
    if (template != null) {
      final exercises = template!.exercises;
      exerciseNames = exercises.take(2).map((e) => e.exerciseName).toList();
      extraCount = (exercises.length - 2).clamp(0, 999);
    }

    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECOMMENDED',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                'DAY $dayNumber OF $totalDays',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dayName,
            style: GoogleFonts.lexend(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: AppColors.onSurface,
            ),
          ),
          if (exerciseNames.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              exerciseNames.join(' \u2022 '),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (extraCount > 0)
              Text(
                '+ $extraCount more exercise${extraCount == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _CardButton(
              label: 'START \u2192',
              onPressed: template == null
                  ? null
                  : () {
                      ref.read(activeWorkoutProvider.notifier).startWorkout(
                            userId: userId,
                            template: template,
                          );
                      context.push(AppRoutes.activeWorkout);
                    },
            ),
          ),
        ],
      ),
    );
  }
}

// Compact inline button used inside recommended card
class _CardButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;

  const _CardButton({
    required this.label,
    this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSecondary ? AppColors.surfaceContainerHigh : AppColors.primary,
          foregroundColor:
              isSecondary ? AppColors.onSurface : AppColors.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isSecondary ? AppColors.onSurface : AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

