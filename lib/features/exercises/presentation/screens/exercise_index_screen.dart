import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/features/exercises/presentation/providers/exercise_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/exercise.dart';

const _uuid = Uuid();

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
              _buildAppBar(context, ref),
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

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
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
                onPressed: () => _showAddExerciseSheet(context, ref),
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

  void _showAddExerciseSheet(BuildContext context, WidgetRef ref) {
    final userId = ref.read(authNotifierProvider).valueOrNull?.id;
    if (userId == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      builder: (ctx) => _AddExerciseSheet(userId: userId),
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

// ──────────────────────────────────────────────
// Add Custom Exercise Sheet
// ──────────────────────────────────────────────

class _AddExerciseSheet extends ConsumerStatefulWidget {
  final String userId;

  const _AddExerciseSheet({required this.userId});

  @override
  ConsumerState<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends ConsumerState<_AddExerciseSheet> {
  final _nameController = TextEditingController();
  final _equipmentController = TextEditingController();
  MuscleGroup _selectedMuscle = MuscleGroup.chest;
  ExerciseType _selectedType = ExerciseType.compound;
  TrackingUnit _selectedUnit = TrackingUnit.weightReps;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise name is required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final exercise = Exercise(
      id: _uuid.v4(),
      name: name,
      primaryMuscle: _selectedMuscle,
      type: _selectedType,
      trackingUnit: _selectedUnit,
      equipmentName: _equipmentController.text.trim().isEmpty
          ? null
          : _equipmentController.text.trim(),
      isCustom: true,
      userId: widget.userId,
    );

    final failure = await ref
        .read(exerciseRepositoryProvider)
        .createCustomExercise(exercise);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
      return;
    }

    ref.invalidate(exercisesProvider);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${exercise.name} added to your library')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                color: AppColors.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'NEW EXERCISE',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Name
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'EXERCISE NAME *',
                hintText: 'e.g. Incline Dumbbell Press',
                hintStyle: GoogleFonts.lexend(
                  fontSize: 14,
                  color: AppColors.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Equipment
            TextField(
              controller: _equipmentController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'EQUIPMENT (OPTIONAL)',
                hintText: 'e.g. Barbell, Dumbbell, Cable',
                hintStyle: GoogleFonts.lexend(
                  fontSize: 14,
                  color: AppColors.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Primary muscle
            Text('PRIMARY MUSCLE',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MuscleGroup.values.map((g) {
                final isSelected = _selectedMuscle == g;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMuscle = g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceContainerHighest,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      _muscleLabel(g),
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Exercise type
            Text('EXERCISE TYPE',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            Row(
              children: ExerciseType.values.map((t) {
                final isSelected = _selectedType == t;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: t == ExerciseType.cardio ? 0 : 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: isSelected
                            ? AppColors.surfaceContainerHigh
                            : AppColors.surfaceContainerHighest,
                        child: Center(
                          child: Text(
                            t.name.toUpperCase(),
                            style: GoogleFonts.lexend(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Tracking unit
            Text('TRACKING', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            Column(
              children: TrackingUnit.values.map((u) {
                final isSelected = _selectedUnit == u;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedUnit = u),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surfaceContainerHigh
                            : AppColors.surfaceContainerHighest,
                        border: Border(
                          left: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _unitLabel(u),
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceVariant,
                              letterSpacing: 0.6,
                            ),
                          ),
                          if (isSelected) ...[
                            const Spacer(),
                            const Icon(Icons.check,
                                color: AppColors.primary, size: 14),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: _isSaving
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    )
                  : ElevatedButton(
                      onPressed: _handleSave,
                      child: Text(
                        'ADD TO LIBRARY',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _muscleLabel(MuscleGroup g) => switch (g) {
        MuscleGroup.chest => 'CHEST',
        MuscleGroup.back => 'BACK',
        MuscleGroup.legs => 'LEGS',
        MuscleGroup.shoulders => 'SHOULDERS',
        MuscleGroup.arms => 'ARMS',
        MuscleGroup.core => 'CORE',
        MuscleGroup.fullBody => 'FULL BODY',
      };

  String _unitLabel(TrackingUnit u) => switch (u) {
        TrackingUnit.weightReps => 'WEIGHT + REPS  (e.g. 80 kg × 8)',
        TrackingUnit.timeOnly => 'TIME ONLY  (e.g. 60 seconds)',
        TrackingUnit.distanceTime => 'DISTANCE + TIME  (e.g. 5 km / 30 min)',
        TrackingUnit.bodyweightReps => 'BODYWEIGHT REPS  (e.g. 15 reps)',
      };
}
