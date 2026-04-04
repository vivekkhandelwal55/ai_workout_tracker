import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/router/app_router.dart';
import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/providers/workout_providers.dart';
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

  void _onFinishWorkout() {
    _timer?.cancel();
    ref.read(activeWorkoutProvider.notifier).finishWorkout();
    if (mounted) {
      context.go(AppRoutes.workoutSummary);
    }
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

    return Scaffold(
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
                  Icon(Icons.menu, color: AppColors.onSurfaceVariant, size: 24),
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
                  Icon(Icons.settings_outlined,
                      color: AppColors.onSurfaceVariant, size: 24),
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
                                  'INTENSITY',
                                  style:
                                      Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '88 %',
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
                          onWeightTap: (setIndex, set) => _showWeightPicker(
                              context, exercise.exerciseId, setIndex, set),
                          onRepsTap: (setIndex, set) => _showRepsPicker(
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
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming soon: exercise picker'),
                          ),
                        );
                      },
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
    );
  }
}

class _ExerciseCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
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
                        'COMPOUND • LOWER BODY',
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
