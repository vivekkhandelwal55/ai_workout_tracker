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
import 'package:ai_workout_tracker_app/features/stats/presentation/providers/stats_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/exercise.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_session.dart';
import 'package:ai_workout_tracker_app/shared/widgets/exercise_thumbnail_widget.dart';

// NOTE: The workout ticker is now driven by [workoutTickerProvider] at the
// provider level so the clock keeps running even when navigating away.

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure a workout session exists before allowing exercise additions.
    // This handles the case where navigation to this screen was done without
    // a template (e.g., "START →" button on home screen).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(activeWorkoutProvider);
      if (currentState.session == null) {
        final userId =
            ref.read(authNotifierProvider).valueOrNull?.id ?? 'stub-user-001';
        ref.read(activeWorkoutProvider.notifier).startWorkout(userId: userId);
      }
    });
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
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
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
      // User chose to discard — reset and go home
      ref.read(activeWorkoutProvider.notifier).reset();
      context.go(AppRoutes.home);
      return;
    }
    final session = ref.read(activeWorkoutProvider.notifier).finishWorkout();

    if (session != null) {
      final userId =
          ref.read(authNotifierProvider).valueOrNull?.id ?? 'stub-user-001';
      final failure = await ref
          .read(workoutRepositoryProvider)
          .saveWorkoutSession(session);
      if (!mounted) return;
      if (failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save workout: ${failure.message}')),
        );
        return;
      }
      ref.invalidate(weeklyStatsProvider(userId));
      ref.invalidate(workoutHistoryProvider(userId));
      ref.invalidate(lifetimeWorkoutStatsProvider(userId));
    }

    if (mounted) context.go(AppRoutes.workoutSummary);
  }

  Future<bool> _onPopInvoked() async {
    final state = ref.read(activeWorkoutProvider);
    if (!state.isRunning) return true;
    if (state.shouldWarnOnFinish) {
      final discard = await _showDiscardDialog();
      if (!mounted) return false;
      if (discard) {
        ref.read(activeWorkoutProvider.notifier).reset();
        return true;
      }
      return false;
    }
    // Workout has exercises and is long enough — ask if they want to leave
    final leave = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
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
      ref.read(activeWorkoutProvider.notifier).reset();
      return true;
    }
    return false;
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Text(
                    'WORKOUT SETTINGS',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const Divider(color: AppColors.outlineVariant, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.timer_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(
                    'REST TIMER',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: AppColors.onSurface,
                    ),
                  ),
                  trailing: Text(
                    'COMING SOON',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  onTap: null,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.swap_horiz,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(
                    'UNIT SYSTEM',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: AppColors.onSurface,
                    ),
                  ),
                  trailing: Text(
                    'KG',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: null,
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text(
                    'DISCARD WORKOUT',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final discard = await _showDiscardDialog();
                    if (!mounted) return;
                    if (discard) {
                      ref.read(activeWorkoutProvider.notifier).reset();
                      if (mounted) context.go(AppRoutes.home);
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  void _showExercisePicker(BuildContext context) {
    final alreadyAdded =
        ref
            .read(activeWorkoutProvider)
            .session
            ?.exercises
            .map((e) => e.exerciseId)
            .toSet() ??
        {};
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder:
          (ctx) => _ExercisePicker(
            excludedIds: alreadyAdded,
            onExerciseSelected: (exercise) {
              ref
                  .read(activeWorkoutProvider.notifier)
                  .addExercise(exercise.id, exercise.name);
              Navigator.of(ctx).pop();
            },
          ),
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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
                    GestureDetector(
                      onTap: () => _showSettingsSheet(context),
                      child: Icon(
                        Icons.settings_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content — GestureDetector dismisses keyboard when
              // user taps outside a text input field.
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: CustomScrollView(
                    slivers: [
                      // -------------------------------------------------------
                      // Static header: timer + stats
                      // -------------------------------------------------------
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Session Timer
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'SESSION DURATION',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
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
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                color: AppColors.surfaceContainerLow,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            'VOLUME',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.labelSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            session != null
                                                ? _formatVolume(
                                                  session.totalVolumeKg,
                                                )
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
                                                Theme.of(
                                                  context,
                                                ).textTheme.labelSmall,
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
                            ],
                          ),
                        ),
                      ),

                      // -------------------------------------------------------
                      // Reorderable exercise cards
                      // -------------------------------------------------------
                      if (session != null)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverReorderableList(
                            itemCount: session.exercises.length,
                            onReorder: (oldIndex, newIndex) {
                              ref
                                  .read(activeWorkoutProvider.notifier)
                                  .reorderExercises(oldIndex, newIndex);
                            },
                            proxyDecorator: (child, index, animation) {
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (ctx, builtChild) {
                                  final elevation =
                                      Tween<double>(
                                        begin: 0,
                                        end: 8,
                                      ).animate(animation).value;
                                  return Material(
                                    elevation: elevation,
                                    color: AppColors.surfaceContainerHigh,
                                    shadowColor: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    child: builtChild,
                                  );
                                },
                                child: child,
                              );
                            },
                            itemBuilder: (ctx, index) {
                              final exercise = session.exercises[index];
                              return ReorderableDelayedDragStartListener(
                                key: ValueKey(exercise.exerciseId),
                                index: index,
                                child: _ExerciseCard(
                                  // key: ValueKey(
                                  //   '${exercise.exerciseId}_card',
                                  // ),
                                  exercise: exercise,
                                  onWeightTap:
                                      (setIndex, set) => ref
                                          .read(activeWorkoutProvider.notifier)
                                          .updateSet(
                                            exercise.exerciseId,
                                            setIndex,
                                            set,
                                          ),
                                  onRepsTap:
                                      (setIndex, set) => ref
                                          .read(activeWorkoutProvider.notifier)
                                          .updateSet(
                                            exercise.exerciseId,
                                            setIndex,
                                            set,
                                          ),
                                  onToggleSet: (setIndex, set) {
                                    ref
                                        .read(activeWorkoutProvider.notifier)
                                        .updateSet(
                                          exercise.exerciseId,
                                          setIndex,
                                          set.copyWith(
                                            isCompleted: !set.isCompleted,
                                          ),
                                        );
                                  },
                                  onAddSet:
                                      () => ref
                                          .read(activeWorkoutProvider.notifier)
                                          .addSet(exercise.exerciseId),
                                  onRemove:
                                      () => ref
                                          .read(activeWorkoutProvider.notifier)
                                          .removeExercise(exercise.exerciseId),
                                ),
                              );
                            },
                          ),
                        ),

                      // -------------------------------------------------------
                      // Add Exercise + Finish Workout footer
                      // -------------------------------------------------------
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // Add Exercise
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showExercisePicker(context),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      const Icon(
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
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.onPrimary,
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
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
                      ),
                    ],
                  ),
                ), // GestureDetector (unfocus)
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
  final Set<String> excludedIds;

  const _ExercisePicker({
    required this.onExerciseSelected,
    this.excludedIds = const {},
  });

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
      if (widget.excludedIds.contains(e.id)) return false;
      final matchesMuscle =
          _selectedMuscle == null || e.primaryMuscle == _selectedMuscle;
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                children:
                    _muscleLabels.entries.map((entry) {
                      final isSelected = _selectedMuscle == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap:
                              () => setState(() => _selectedMuscle = entry.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceContainerHighest,
                            ),
                            child: Text(
                              entry.value,
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color:
                                    isSelected
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
                loading:
                    () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                error:
                    (e, _) => Center(
                      child: Text(
                        'Failed to load exercises',
                        style: GoogleFonts.lexend(
                          color: AppColors.onSurfaceVariant,
                        ),
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
                          color:
                              isEven
                                  ? AppColors.surfaceContainerLow
                                  : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              // Thumbnail or GIF
                              ExerciseThumbnail(exercise: ex, size: 44),
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
// Exercise Card (Inline Editable)
// ---------------------------------------------------------------------------

class _ExerciseCard extends ConsumerStatefulWidget {
  final SessionExercise exercise;
  final void Function(int setIndex, WorkoutSet set) onWeightTap;
  final void Function(int setIndex, WorkoutSet set) onRepsTap;
  final void Function(int setIndex, WorkoutSet set) onToggleSet;
  final VoidCallback onAddSet;
  final VoidCallback onRemove;

  /// Emitted when the drag handle is long-pressed — consumed by
  /// [ReorderableListView] via its [proxyDecorator].
  final VoidCallback? onReorderStart;

  const _ExerciseCard({
    required this.exercise,
    required this.onWeightTap,
    required this.onRepsTap,
    required this.onToggleSet,
    required this.onAddSet,
    required this.onRemove,
    this.onReorderStart,
  });

  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  // Inline editing state for weight/reps
  int? _editingWeightSetIndex;
  int? _editingRepsSetIndex;
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late FocusNode _weightFocusNode;
  late FocusNode _repsFocusNode;

  static const _cardPadding = 16.0;
  static const _sectionSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _repsController = TextEditingController();
    _weightFocusNode = FocusNode();
    _repsFocusNode = FocusNode();

    _weightFocusNode.addListener(_onWeightFocusChange);
    _repsFocusNode.addListener(_onRepsFocusChange);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightFocusNode.removeListener(_onWeightFocusChange);
    _repsFocusNode.removeListener(_onRepsFocusChange);
    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    super.dispose();
  }

  void _onWeightFocusChange() {
    if (!_weightFocusNode.hasFocus && _editingWeightSetIndex != null) {
      _saveWeightEdit();
    }
  }

  void _onRepsFocusChange() {
    if (!_repsFocusNode.hasFocus && _editingRepsSetIndex != null) {
      _saveRepsEdit();
    }
  }

  void _startWeightEdit(int setIndex, WorkoutSet set) {
    setState(() {
      _editingWeightSetIndex = setIndex;
      _weightController.text = set.weight?.toStringAsFixed(1) ?? '';
    });
    _weightFocusNode.requestFocus();
  }

  void _startRepsEdit(int setIndex, WorkoutSet set) {
    setState(() {
      _editingRepsSetIndex = setIndex;
      _repsController.text = set.reps?.toString() ?? '';
    });
    _repsFocusNode.requestFocus();
  }

  void _saveWeightEdit() {
    if (_editingWeightSetIndex == null) return;
    final value = double.tryParse(_weightController.text);
    if (value != null) {
      widget.onWeightTap(
        _editingWeightSetIndex!,
        widget.exercise.sets[_editingWeightSetIndex!].copyWith(weight: value),
      );
    }
    setState(() {
      _editingWeightSetIndex = null;
      _weightController.clear();
    });
  }

  void _saveRepsEdit() {
    if (_editingRepsSetIndex == null) return;
    final value = int.tryParse(_repsController.text);
    if (value != null) {
      widget.onRepsTap(
        _editingRepsSetIndex!,
        widget.exercise.sets[_editingRepsSetIndex!].copyWith(reps: value),
      );
    }
    setState(() {
      _editingRepsSetIndex = null;
      _repsController.clear();
    });
  }

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

  // ---------------------------------------------------------------------------
  // "Show Description" bottom sheet
  // ---------------------------------------------------------------------------

  void _showDescriptionSheet(BuildContext context, Exercise? meta) {
    final exercise = widget.exercise;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    exercise.exerciseName.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),

                // Muscle chips row
                if (meta != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MuscleChip(
                          label: meta.primaryMuscle.name.toUpperCase(),
                          isPrimary: true,
                        ),
                        ...meta.targetMuscles.map(
                          (m) => _MuscleChip(
                            label: m.toUpperCase(),
                            isPrimary: false,
                          ),
                        ),
                        ...meta.secondaryMuscles.map(
                          (m) => _MuscleChip(
                            label: m.toUpperCase(),
                            isPrimary: false,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Metadata pills
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        if (meta.level != null)
                          _InfoPill(
                            icon: Icons.signal_cellular_alt,
                            label: meta.level!.toUpperCase(),
                          ),
                        if (meta.mechanic != null) ...[
                          const SizedBox(width: 8),
                          _InfoPill(
                            icon: Icons.settings_outlined,
                            label: meta.mechanic!.toUpperCase(),
                          ),
                        ],
                        if (meta.force != null) ...[
                          const SizedBox(width: 8),
                          _InfoPill(
                            icon: Icons.bolt_outlined,
                            label: meta.force!.toUpperCase(),
                          ),
                        ],
                        if (meta.equipmentName != null) ...[
                          const SizedBox(width: 8),
                          _InfoPill(
                            icon: Icons.fitness_center,
                            label: meta.equipmentName!.toUpperCase(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const Divider(
                  color: AppColors.outlineVariant,
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                ),

                // Instructions / tips
                if (meta != null && meta.instructions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'HOW TO PERFORM',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ...meta.instructions.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1, right: 12),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${e.key + 1}',
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.value,
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ] else if (meta != null && meta.tips.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'TIPS',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ...meta.tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Text(
                      'No description available for this exercise.',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // "Show Trend" bottom sheet
  // ---------------------------------------------------------------------------

  void _showTrendSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return _TrendSheet(
          exerciseName: widget.exercise.exerciseName,
          currentSets: widget.exercise.sets,
        );
      },
    );
  }

  Widget _buildWeightCell(int setIndex, WorkoutSet set, bool isCompleted) {
    if (_editingWeightSetIndex == setIndex) {
      return SizedBox(
        height: 36,
        child: TextField(
          controller: _weightController,
          focusNode: _weightFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onSubmitted: (_) => _saveWeightEdit(),
        ),
      );
    }

    return GestureDetector(
      onTap: isCompleted ? null : () => _startWeightEdit(setIndex, set),
      child: Center(
        child: Text(
          set.weight != null ? set.weight!.toStringAsFixed(1) : '—',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildRepsCell(int setIndex, WorkoutSet set, bool isCompleted) {
    if (_editingRepsSetIndex == setIndex) {
      return SizedBox(
        height: 36,
        child: TextField(
          controller: _repsController,
          focusNode: _repsFocusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onSubmitted: (_) => _saveRepsEdit(),
        ),
      );
    }

    return GestureDetector(
      onTap: isCompleted ? null : () => _startRepsEdit(setIndex, set),
      child: Center(
        child: Text(
          set.reps != null ? set.reps.toString() : '—',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(
      exerciseMetadataProvider(widget.exercise.exerciseId),
    );
    final meta = metaAsync.valueOrNull;

    // Fallback: if the ID-based lookup returned null (e.g. template exercise IDs
    // differ from library IDs), try a case-insensitive name lookup so that the
    // description sheet always shows full metadata when available.
    final metaByNameAsync = meta == null
        ? ref.watch(
            exerciseMetadataByNameProvider(widget.exercise.exerciseName),
          )
        : const AsyncData<Exercise?>(null);
    final effectiveMeta = meta ?? metaByNameAsync.valueOrNull;

    // Find first uncompleted set index
    final firstUncompletedIndex = widget.exercise.sets.indexWhere(
      (s) => !s.isCompleted,
    );

    return Container(
      color: AppColors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _cardPadding,
              vertical: _cardPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.exerciseName.toUpperCase(),
                        style: GoogleFonts.lexend(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _metadataLabel(effectiveMeta),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                // Drag handle — long-press is picked up by ReorderableListView
                Semantics(
                  label: 'Drag to reorder',
                  child: const Icon(
                    Icons.drag_handle,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  color: AppColors.surfaceContainerHighest,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  onSelected: (value) {
                    if (value == 'remove') {
                      widget.onRemove();
                    } else if (value == 'description') {
                      _showDescriptionSheet(context, effectiveMeta);
                    } else if (value == 'trend') {
                      _showTrendSheet(context);
                    }
                  },
                  itemBuilder:
                      (ctx) => [
                        PopupMenuItem<String>(
                          value: 'description',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.onSurfaceVariant,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'SHOW DESCRIPTION',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.8,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'trend',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bar_chart_outlined,
                                color: AppColors.onSurfaceVariant,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'SHOW TREND',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.8,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'REMOVE EXERCISE',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.8,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),

          // Set table header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _cardPadding,
              vertical: _sectionSpacing,
            ),
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
                  width: 72,
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
          ...widget.exercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            final isActiveSet =
                setIndex == firstUncompletedIndex && firstUncompletedIndex >= 0;
            final isCompleted = set.isCompleted;

            return Container(
              height: 52,
              decoration: BoxDecoration(
                color:
                    isActiveSet
                        ? AppColors.surfaceContainerHigh
                        : Colors.transparent,
                border:
                    isActiveSet
                        ? const Border(
                          left: BorderSide(color: AppColors.primary, width: 3),
                        )
                        : null,
              ),
              child: Row(
                children: [
                  // Set number
                  SizedBox(
                    width: 36,
                    child: Padding(
                      padding: const EdgeInsets.only(left: _cardPadding),
                      child: Text(
                        set.setNumber.toString(),
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isCompleted
                                  ? AppColors.onSurfaceVariant
                                  : _setNumberColor(set.type),
                        ),
                      ),
                    ),
                  ),

                  // Weight - inline editable
                  Expanded(child: _buildWeightCell(setIndex, set, isCompleted)),

                  // Reps - inline editable
                  SizedBox(
                    width: 72,
                    child: _buildRepsCell(setIndex, set, isCompleted),
                  ),

                  // Status
                  SizedBox(
                    width: 48,
                    child: GestureDetector(
                      onTap: () {
                        // Flush any pending inline edits before toggling
                        // so weight/reps are persisted before completion
                        // and totalVolumeKg is computed correctly.
                        if (_editingWeightSetIndex == setIndex) {
                          _saveWeightEdit();
                        }
                        if (_editingRepsSetIndex == setIndex) {
                          _saveRepsEdit();
                        }
                        // Re-read the set from the provider after any saves
                        // to avoid toggling stale data without weight/reps.
                        final latestState = ref.read(activeWorkoutProvider);
                        final latestExercise =
                            latestState.session?.exercises
                                .where(
                                  (e) =>
                                      e.exerciseId ==
                                      widget.exercise.exerciseId,
                                )
                                .firstOrNull;
                        final latestSet =
                            latestExercise != null &&
                                    setIndex < latestExercise.sets.length
                                ? latestExercise.sets[setIndex]
                                : set;
                        widget.onToggleSet(setIndex, latestSet);
                      },
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                isCompleted
                                    ? AppColors.primary
                                    : Colors.transparent,
                            border: Border.all(
                              color:
                                  isCompleted
                                      ? AppColors.primary
                                      : AppColors.surfaceContainerHighest,
                              width: 1.5,
                            ),
                          ),
                          child:
                              isCompleted
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
          const SizedBox(height: _sectionSpacing),
          GestureDetector(
            onTap: widget.onAddSet,
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

// ---------------------------------------------------------------------------
// Description sheet helpers
// ---------------------------------------------------------------------------

/// A small coloured chip used to display muscle group labels in the
/// description bottom sheet.
class _MuscleChip extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _MuscleChip({required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            isPrimary
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceContainerHighest,
        border:
            isPrimary ? Border.all(color: AppColors.primary, width: 1) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isPrimary ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// A compact icon + text pill used to show exercise metadata (level, mechanic,
/// force, equipment) in the description bottom sheet.
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Trend sheet helpers
// ---------------------------------------------------------------------------

/// A labelled numeric stat used in the trend sheet summary row.
class _TrendStat extends StatelessWidget {
  final String label;
  final String value;

  const _TrendStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Trend sheet — ConsumerWidget so it can access workout history providers
// ---------------------------------------------------------------------------

/// The full trend bottom-sheet content.
///
/// Shows a "THIS SESSION" summary at the top (identical to the old inline
/// implementation) followed by a "HISTORY" section that pulls the last 10
/// sessions for this exercise from [workoutHistoryProvider].
class _TrendSheet extends ConsumerWidget {
  final String exerciseName;
  final List<WorkoutSet> currentSets;

  const _TrendSheet({
    required this.exerciseName,
    required this.currentSets,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId =
        ref.watch(authNotifierProvider).valueOrNull?.id ?? '';

    // Only completed sets that have both weight and reps contribute to stats.
    final sessionSets = currentSets
        .where((s) => s.isCompleted && s.weight != null && s.reps != null)
        .toList();

    // Historical data — gracefully degrade when loading or on error.
    final historyAsync = userId.isNotEmpty
        ? ref.watch(workoutHistoryProvider(userId))
        : const AsyncData<List<WorkoutSession>>([]);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
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

            // Title + sub-label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                exerciseName.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'THIS SESSION',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.6,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),

            const Divider(
              color: AppColors.outlineVariant,
              height: 1,
              indent: 20,
              endIndent: 20,
            ),

            // ---- Current-session body ----
            if (sessionSets.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.bar_chart_outlined,
                      color: AppColors.onSurfaceVariant,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'NO COMPLETED SETS YET',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete sets to see your volume trend.',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Summary stats row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    _TrendStat(
                      label: 'SETS DONE',
                      value: sessionSets.length.toString(),
                    ),
                    const SizedBox(width: 24),
                    _TrendStat(
                      label: 'MAX WEIGHT',
                      value:
                          '${sessionSets.map((s) => s.weight!).reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} KG',
                    ),
                    const SizedBox(width: 24),
                    _TrendStat(
                      label: 'VOLUME',
                      value:
                          '${sessionSets.fold<double>(0, (t, s) => t + s.weight! * s.reps!).toStringAsFixed(0)} KG',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'VOLUME PER SET (KG)',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.4,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _VolumeBarChart(sets: sessionSets),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'SET BREAKDOWN',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.4,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              ...sessionSets.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                final vol = s.weight! * s.reps!;
                return Container(
                  color: i.isEven
                      ? AppColors.surfaceContainerHigh
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'SET ${i + 1}',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${s.weight!.toStringAsFixed(1)} KG × ${s.reps} reps',
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '= ${vol.toStringAsFixed(0)} KG',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // ---- History section ----
            const SizedBox(height: 12),
            const Divider(
              color: AppColors.outlineVariant,
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'HISTORY',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),

            historyAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Text(
                  'Could not load history.',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              data: (sessions) {
                // Collect sessions that contain this exercise (name match,
                // case-insensitive), limited to the 10 most recent.
                final matchedSessions = sessions
                    .where(
                      (session) => session.exercises.any(
                        (ex) =>
                            ex.exerciseName.toLowerCase() ==
                            exerciseName.toLowerCase(),
                      ),
                    )
                    .take(10)
                    .toList();

                if (matchedSessions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Text(
                      'No previous sessions found for this exercise.',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return Column(
                  children: matchedSessions.asMap().entries.map((entry) {
                    final i = entry.key;
                    final session = entry.value;
                    // Find the matching exercise in this session.
                    final ex = session.exercises.firstWhere(
                      (e) =>
                          e.exerciseName.toLowerCase() ==
                          exerciseName.toLowerCase(),
                    );
                    final completedSets = ex.sets
                        .where(
                          (s) =>
                              s.isCompleted &&
                              s.weight != null &&
                              s.reps != null,
                        )
                        .toList();

                    return _HistorySessionRow(
                      index: i,
                      date: session.startTime,
                      sets: completedSets,
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

/// One row in the history section — shows date, max weight, sets, and volume
/// for a single past workout session.
class _HistorySessionRow extends StatelessWidget {
  final int index;
  final DateTime date;
  final List<WorkoutSet> sets;

  const _HistorySessionRow({
    required this.index,
    required this.date,
    required this.sets,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final maxWeight = sets.isEmpty
        ? 0.0
        : sets.map((s) => s.weight!).reduce((a, b) => a > b ? a : b);
    final volume = sets.fold<double>(0, (t, s) => t + s.weight! * s.reps!);
    final totalReps = sets.fold<int>(0, (t, s) => t + s.reps!);

    return Container(
      color: index.isEven
          ? AppColors.surfaceContainerHigh
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date column
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(date),
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${sets.length} SET${sets.length == 1 ? '' : 'S'} · $totalReps REPS',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          // Stats column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${maxWeight.toStringAsFixed(1)} KG',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'VOL ${volume.toStringAsFixed(0)} KG',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A simple horizontal bar chart that renders one bar per completed set.
/// Each bar's width is proportional to that set's volume relative to the max.
class _VolumeBarChart extends StatelessWidget {
  final List<WorkoutSet> sets;

  const _VolumeBarChart({required this.sets});

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) return const SizedBox.shrink();

    final volumes = sets.map((s) => s.weight! * s.reps!.toDouble()).toList();
    final maxVol = volumes.reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final availableWidth = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              volumes.asMap().entries.map((entry) {
                final i = entry.key;
                final vol = entry.value;
                final fraction = maxVol > 0 ? vol / maxVol : 0.0;
                final barWidth = availableWidth * fraction;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      // Set label
                      SizedBox(
                        width: 36,
                        child: Text(
                          'S${i + 1}',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // Bar
                      Expanded(
                        child: Stack(
                          children: [
                            // Track
                            Container(
                              height: 16,
                              color: AppColors.surfaceContainerHighest,
                            ),
                            // Fill
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                              height: 16,
                              width: barWidth,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Value label
                      SizedBox(
                        width: 52,
                        child: Text(
                          '${vol.toStringAsFixed(0)} kg',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
