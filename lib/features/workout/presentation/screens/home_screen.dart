import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/app/router/app_router.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/providers/workout_providers.dart';
import 'package:ai_workout_tracker_app/features/stats/presentation/providers/stats_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_template.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider('stub-user-001'));
    final templatesAsync = ref.watch(workoutTemplatesProvider('stub-user-001'));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              _buildAppBar(context),
              _buildStatsSection(context, weeklyStatsAsync),
              _buildRecommendedCard(context, ref),
              _buildTemplatesSection(context, ref, templatesAsync),
              _buildStrengthTrendsSection(context),
              const SizedBox(height: 32),
            ]),
          ),
        ],
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

  Widget _buildRecommendedCard(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        color: AppColors.surfaceContainerLow,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECOMMENDED',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'PUSH HYPERTROPHY',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Targeting pectoral stability and tricep exhaustion with continuous eccentric loading.',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMiniStat(context, '24', ' MIN'),
                const SizedBox(width: 16),
                _buildMiniStat(context, '65', ' KG'),
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.activeWorkout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'START →',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String value, String unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
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
                onPressed: () {},
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

class _TemplateCard extends StatelessWidget {
  final WorkoutTemplate template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _NewTemplateCard extends StatelessWidget {
  const _NewTemplateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
