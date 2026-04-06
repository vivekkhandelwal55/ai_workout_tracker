import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_theme.dart';
import '../../features/workout/presentation/providers/workout_providers.dart';

/// A floating banner that appears above the bottom navigation bar when a
/// workout is in progress. Shows the workout name and elapsed time, and
/// tapping it navigates back to the active workout screen.
class ActiveWorkoutIndicator extends ConsumerWidget {
  const ActiveWorkoutIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(activeWorkoutProvider);

    // Only show when a workout is actively running
    if (!workoutState.isRunning || workoutState.session == null) {
      return const SizedBox.shrink();
    }

    final templateName = workoutState.session!.templateName ?? 'Workout';
    final elapsed = workoutState.elapsedSeconds;
    final formattedElapsed = _formatElapsed(elapsed);

    return GestureDetector(
      onTap: () => context.go('/workout'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          border: Border(
            top: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      templateName.toUpperCase(),
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedElapsed,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatElapsed(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
