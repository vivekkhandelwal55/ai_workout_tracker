import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/router/app_router.dart';
import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/features/exercises/presentation/providers/exercise_providers.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/providers/workout_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/exercise.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_session.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Ensure a workout session exists before allowing exercise additions.
    // This handles the case where navigation to this screen was done without
    // a template (e.g., "START →" button on home screen).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(activeWorkoutProvider);
      if (currentState.session == null) {
        final userId = ref.read(authNotifierProvider).valueOrNull?.id ?? 'stub-user-001';
        ref.read(activeWorkoutProvider.notifier).startWorkout(userId: userId);
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(activeWorkoutProvider.notifier).tickTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatElapsed(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatVolume(double kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(1)}K KG';
    }
    return '${kg.toStringAsFixed(0)} KG';
  }

  /// Shows the discard/resume dialog and returns true if user wants to finish.
  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'DISCARD WORKOUT?',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: Colors.white,
          ),
        ),
        content: Text(
          'This session is short or has no exercises. Do you want to discard it?',
          style: GoogleFonts.lexend(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'RESUME WORKOUT',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'DISCARD',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onFinishWorkout() async {
    final state = ref.read(activeWorkoutProvider);
    if (state.shouldWarnOnFinish) {
      final discard = await _showDiscardDialog();
      if (!mounted) return;
      if (!discard) return;
      // User chose to discard — cancel and go home
      _timer?.cancel();
      ref.read(activeWorkoutProvider.notifier).reset();
      context.go(AppRoutes.home);
      return;
    }
    _timer?.cancel();
    ref.read(activeWorkoutProvider.notifier).finishWorkout();
    if (mounted) context.go(AppRoutes.workoutSummary);
  }

  Future<bool> _onPopInvoked() async {
    final state = ref.read(activeWorkoutProvider);
    if (!state.isRunning) return true;
    if (state.shouldWarnOnFinish) {
      final discard = await _showDiscardDialog();
      if (!mounted) return false;
      if (discard) {
        _timer?.cancel();
        ref.read(activeWorkoutProvider.notifier).reset();
        return true;
      }
      return false;
    }
    // Workout has exercises and is long enough — ask if they want to leave
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'LEAVE WORKOUT?',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Your workout progress will be lost.',
          style: GoogleFonts.lexend(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'STAY',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'LEAVE',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      _timer?.cancel();
      ref.read(activeWorkoutProvider.notifier).reset();
      return true;
    }
    return false;
  }

  void _showExercisePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => _ExercisePicker(
        onExerciseSelected: (exercise) {
          ref
              .read(activeWorkoutProvider.notifier)
              .addExercise(exercise.id, exercise.name);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _showWeightPicker(
    BuildContext context,
    String exerciseId,
    int setIndex,
    WorkoutSet set,
  ) {
    final controller =
        TextEditingController(text: set.weight?.toStringAsFixed(1) ?? '');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WEIGHT (KG)',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.6,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: GoogleFonts.lexend(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '0.0',
                  hintStyle: GoogleFonts.lexend(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final value = double.tryParse(controller.text);
                    if (value != null) {
                      ref
                          .read(activeWorkoutProvider.notifier)
                          .updateSet(exerciseId, setIndex,
                              set.copyWith(weight: value));
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    'CONFIRM',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRepsPicker(
    BuildContext context,
    String exerciseId,
    int setIndex,
    WorkoutSet set,
  ) {
    final controller =
        TextEditingController(text: set.reps?.toString() ?? '');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REPS',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.6,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.lexend(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: GoogleFonts.lexend(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final value = int.tryParse(controller.text);
                    if (value != null) {
                      ref
                          .read(activeWorkoutProvider.notifier)
                          .updateSet(exerciseId, setIndex,
                              set.copyWith(reps: value));
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    'CONFIRM',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeWorkoutProvider);
    final session = state.session;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final canPop = await _onPopInvoked();
        if (!mounted) return;
        if (canPop) router.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final router = GoRouter.of(context);
                        final canPop = await _onPopInvoked();
                        if (!mounted) return;
                        if (canPop) router.pop();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'TRAINING',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.0,
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
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Session Timer
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Text(
                              'SESSION DURATION',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatElapsed(state.elapsedSeconds),
                              style: GoogleFonts.lexend(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Stats Row
                      Container(
                        color: AppColors.surfaceContainerLow,
                        padding: const EdgeInsets.symmetric(vertical: 20),
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
                                        : '0 KG',
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
                                  Text(
                                    state.completedSetsCount.toString(),
                                    style: GoogleFonts.lexend(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Exercise Cards
                      if (session != null)
                        ...session.exercises.map((exercise) {
                          return _ExerciseCard(
                            exercise: exercise,
                            onWeightTap: (setIndex, set) =>
                                _showWeightPicker(
                                    context, exercise.exerciseId, setIndex, set),
                            onRepsTap: (setIndex, set) =>
                                _showRepsPicker(
                                    context, exercise.exerciseId, setIndex, set),
                            onToggleSet: (setIndex, set) {
                              ref
                                  .read(activeWorkoutProvider.notifier)
                                  .updateSet(
                                    exercise.exerciseId,
                                    setIndex,
                                    set.copyWith(
                                        isCompleted: !set.isCompleted),
                                  );
                            },
                            onAddSet: () => ref
                                .read(activeWorkoutProvider.notifier)
                                .addSet(exercise.exerciseId),
                          );
                        }),

                      // Add Exercise
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showExercisePicker(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: AppColors.onSurfaceVariant,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ADD EXERCISE',
                                style: GoogleFonts.lexend(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.6,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Finish Workout CTA
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                ),
                                onPressed: _onFinishWorkout,
                                child: Text(
                                  'FINISH WORKOUT',
                                  style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'INTENSITY IS THE ONLY REQUIREMENT',
                              style: Theme.of(context).textTheme.labelSmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise Picker Bottom Sheet
// ---------------------------------------------------------------------------

class _ExercisePicker extends ConsumerStatefulWidget {
  final void Function(Exercise exercise) onExerciseSelected;

  const _ExercisePicker({required this.onExerciseSelected});

  @override
  ConsumerState<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends ConsumerState<_ExercisePicker> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedMuscle;
  String _searchQuery = '';

  static const _muscleLabels = <MuscleGroup?, String>{
    null: 'ALL',
    MuscleGroup.chest: 'CHEST',
    MuscleGroup.back: 'BACK',
    MuscleGroup.legs: 'LEGS',
    MuscleGroup.shoulders: 'SHOULDERS',
    MuscleGroup.arms: 'ARMS',
    MuscleGroup.core: 'CORE',
  };

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
        return Column(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Muscle group filter chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: _muscleLabels.entries.map((entry) {
                  final isSelected = _selectedMuscle == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedMuscle = entry.key),
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
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise Card
// ---------------------------------------------------------------------------

class _ExerciseCard extends ConsumerWidget {
  final SessionExercise exercise;
  final void Function(int setIndex, WorkoutSet set) onWeightTap;
  final void Function(int setIndex, WorkoutSet set) onRepsTap;
  final void Function(int setIndex, WorkoutSet set) onToggleSet;
  final VoidCallback onAddSet;

  const _ExerciseCard({
    required this.exercise,
    required this.onWeightTap,
    required this.onRepsTap,
    required this.onToggleSet,
    required this.onAddSet,
  });

  Color _setNumberColor(SetType type) {
    switch (type) {
      case SetType.warmup:
        return AppColors.warning;
      case SetType.dropSet:
        return const Color(0xFFAA88FF);
      case SetType.normal:
      case SetType.failureSet:
        return AppColors.onSurface;
    }
  }

  String _metadataLabel(Exercise? meta) {
    if (meta == null) return '';
    final type = meta.type.name.toUpperCase();
    final muscle = meta.primaryMuscle.name.toUpperCase();
    return '$type • $muscle';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaAsync = ref.watch(exerciseMetadataProvider(exercise.exerciseId));
    final meta = metaAsync.valueOrNull;

    // Find first uncompleted set index
    final firstUncompletedIndex =
        exercise.sets.indexWhere((s) => !s.isCompleted);

    return Container(
      color: AppColors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseName.toUpperCase(),
                        style: GoogleFonts.lexend(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _metadataLabel(meta),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),

          // Set table header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    'SET',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  child: Text(
                    'WEIGHT (KG)',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    'REPS',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    'STATUS',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Set rows
          ...exercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            final isActiveSet =
                setIndex == firstUncompletedIndex && firstUncompletedIndex >= 0;
            final isCompleted = set.isCompleted;

            return Container(
              height: 52,
              decoration: BoxDecoration(
                color: isActiveSet
                    ? AppColors.surfaceContainerHigh
                    : Colors.transparent,
                border: isActiveSet
                    ? const Border(
                        left: BorderSide(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Set number
                  SizedBox(
                    width: 36,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        set.setNumber.toString(),
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppColors.onSurfaceVariant
                              : _setNumberColor(set.type),
                        ),
                      ),
                    ),
                  ),

                  // Weight
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onWeightTap(setIndex, set),
                      child: Center(
                        child: Text(
                          set.weight != null
                              ? set.weight!.toStringAsFixed(1)
                              : '—',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Reps
                  SizedBox(
                    width: 64,
                    child: GestureDetector(
                      onTap: () => onRepsTap(setIndex, set),
                      child: Center(
                        child: Text(
                          set.reps != null ? set.reps.toString() : '—',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Status
                  SizedBox(
                    width: 48,
                    child: GestureDetector(
                      onTap: () => onToggleSet(setIndex, set),
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isCompleted
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerHighest,
                              width: 1.5,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.onPrimary,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Add Set button
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onAddSet,
            child: Container(
              width: double.infinity,
              height: 44,
              color: AppColors.surfaceContainerHighest,
              alignment: Alignment.center,
              child: Text(
                '+ ADD SET',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
