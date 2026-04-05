import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_theme.dart';
import '../../features/exercises/presentation/providers/exercise_providers.dart';
import '../models/exercise.dart';

/// Muscle group filter labels for the picker UI.
const muscleGroupLabels = <MuscleGroup?, String>{
  null: 'ALL',
  MuscleGroup.chest: 'CHEST',
  MuscleGroup.back: 'BACK',
  MuscleGroup.legs: 'LEGS',
  MuscleGroup.shoulders: 'SHOULDERS',
  MuscleGroup.arms: 'ARMS',
  MuscleGroup.core: 'CORE',
};

/// A reusable bottom sheet for selecting an exercise from the library.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => ExercisePicker(
///     onExerciseSelected: (exercise) { ... },
///   ),
/// );
/// ```
class ExercisePicker extends ConsumerStatefulWidget {
  final void Function(Exercise exercise) onExerciseSelected;

  const ExercisePicker({super.key, required this.onExerciseSelected});

  @override
  ConsumerState<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends ConsumerState<ExercisePicker> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedMuscle;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Exercise> _filter(List<Exercise> all) {
    return all.where((e) {
      final matchesMuscle =
          _selectedMuscle == null || e.primaryMuscle == _selectedMuscle;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          (e.equipmentName?.toLowerCase().contains(q) ?? false);
      return matchesMuscle && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allExercisesAsync = ref.watch(exercisesProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          color: AppColors.surfaceContainerLow,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'SELECT EXERCISE',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: AppColors.onSurface,
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'SEARCH EXERCISES...',
                  hintStyle: GoogleFonts.lexend(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHighest,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Muscle group filter chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: muscleGroupLabels.entries.map((entry) {
                  final isSelected = _selectedMuscle == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMuscle = entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceContainerHighest,
                        ),
                        child: Text(
                          entry.value,
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

            const Divider(color: AppColors.outlineVariant, height: 1),

            // Exercise list
            Expanded(
              child: allExercisesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Failed to load exercises',
                    style: GoogleFonts.lexend(color: AppColors.onSurfaceVariant),
                  ),
                ),
                data: (all) {
                  final exercises = _filter(all);
                  if (exercises.isEmpty) {
                    return Center(
                      child: Text(
                        'NO EXERCISES FOUND',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          letterSpacing: 1.2,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: exercises.length,
                    itemBuilder: (_, i) {
                      final ex = exercises[i];
                      final isEven = i.isEven;
                      return GestureDetector(
                        onTap: () => widget.onExerciseSelected(ex),
                        child: Container(
                          color: isEven
                              ? AppColors.surfaceContainerLow
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              // Placeholder for gif
                              Container(
                                width: 44,
                                height: 44,
                                color: AppColors.surfaceContainerHighest,
                                child: Icon(
                                  Icons.fitness_center,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name.toUpperCase(),
                                      style: GoogleFonts.lexend(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurface,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        if (ex.equipmentName != null)
                                          ex.equipmentName!,
                                        ex.primaryMuscle.name.toUpperCase(),
                                      ].join(' • '),
                                      style: GoogleFonts.lexend(
                                        fontSize: 10,
                                        color: AppColors.onSurfaceVariant,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.add,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
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
