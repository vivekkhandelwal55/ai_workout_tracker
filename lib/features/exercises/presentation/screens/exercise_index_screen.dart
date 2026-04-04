import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/exercises/presentation/providers/exercise_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/exercise.dart';

class ExerciseIndexScreen extends ConsumerWidget {
  const ExerciseIndexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesProvider);
    final selectedFilter = ref.watch(muscleGroupFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              _buildAppBar(context),
              _buildSearchBar(context, ref),
              _buildCategoryTabs(context, ref, selectedFilter),
            ]),
          ),
          exercisesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Failed to load exercises',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
            data: (exercises) => _ExerciseList(exercises: exercises),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Row(
                children: [
                  Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 16),
                  Icon(Icons.menu, color: AppColors.onSurfaceVariant),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'INDEX',
                style: GoogleFonts.lexend(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'NEW',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: TextField(
        onChanged: (value) {
          ref.read(exerciseSearchQueryProvider.notifier).state = value;
        },
        style: GoogleFonts.lexend(
          color: Colors.white,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        decoration: InputDecoration(
          hintText: 'SEARCH EXERCISES...',
          hintStyle: GoogleFonts.lexend(
            fontSize: 12,
            color: AppColors.surfaceContainerHighest,
            letterSpacing: 1.0,
          ),
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(
    BuildContext context,
    WidgetRef ref,
    MuscleGroup? selectedFilter,
  ) {
    final filters = <String, MuscleGroup?>{
      'ALL': null,
      'CHEST': MuscleGroup.chest,
      'BACK': MuscleGroup.back,
      'LEGS': MuscleGroup.legs,
      'SHOULDERS': MuscleGroup.shoulders,
      'ARMS': MuscleGroup.arms,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: filters.entries.map((entry) {
            final isSelected = selectedFilter == entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  ref.read(muscleGroupFilterProvider.notifier).state =
                      entry.value;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.key,
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  final List<Exercise> exercises;

  const _ExerciseList({required this.exercises});

  static const Map<MuscleGroup, String> _sectionHeaders = {
    MuscleGroup.chest: 'PUSH / CHEST',
    MuscleGroup.back: 'PULL / BACK',
    MuscleGroup.legs: 'LEGS',
    MuscleGroup.shoulders: 'SHOULDERS',
    MuscleGroup.arms: 'ARMS',
    MuscleGroup.core: 'CORE',
    MuscleGroup.fullBody: 'FULL BODY',
  };

  @override
  Widget build(BuildContext context) {
    // Group exercises by primaryMuscle
    final grouped = <MuscleGroup, List<Exercise>>{};
    for (final exercise in exercises) {
      grouped.putIfAbsent(exercise.primaryMuscle, () => []).add(exercise);
    }

    final items = <Widget>[];

    // Maintain consistent ordering
    final orderedGroups = MuscleGroup.values
        .where((g) => grouped.containsKey(g))
        .toList();

    for (final group in orderedGroups) {
      final groupExercises = grouped[group]!;
      items.add(
        _SectionHeader(title: _sectionHeaders[group] ?? group.name.toUpperCase()),
      );
      for (int i = 0; i < groupExercises.length; i++) {
        items.add(_ExerciseRow(exercise: groupExercises[i], index: i));
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => items[index],
        childCount: items.length,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final int index;

  const _ExerciseRow({required this.exercise, required this.index});

  @override
  Widget build(BuildContext context) {
    final isAlternate = index % 2 == 1;
    final equipment = exercise.equipmentName ?? '';
    final muscle = exercise.secondaryMuscleDescription ?? '';
    final subtitle = [equipment, muscle]
        .where((s) => s.isNotEmpty)
        .join(' • ');

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exercise.name),
          ),
        );
      },
      child: Container(
        color: isAlternate ? AppColors.surfaceContainerLow : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              color: AppColors.surfaceContainerHighest,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
