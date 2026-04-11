import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/shared/models/exercise.dart';

/// A reusable widget that displays an exercise thumbnail (48x48) or GIF.
///
/// Used everywhere an exercise thumbnail or animated preview is needed:
/// - Exercise index list rows
/// - Active workout exercise picker
/// - Any place exercise visuals appear
class ExerciseThumbnail extends StatelessWidget {
  final Exercise? exercise;
  final String? thumbnailUrl;
  final String? gifUrl;
  final double size;
  final BoxFit fit;

  const ExerciseThumbnail({
    super.key,
    this.exercise,
    this.thumbnailUrl,
    this.gifUrl,
    this.size = 48,
    this.fit = BoxFit.cover,
  });

  String? get resolvedThumbnailUrl =>
      exercise?.thumbnailUrl ?? thumbnailUrl;

  String? get resolvedGifUrl =>
      exercise?.gifUrl ?? gifUrl;

  @override
  Widget build(BuildContext context) {
    final thumb = resolvedThumbnailUrl;
    final gif = resolvedGifUrl;

    // Prefer GIF if available (animated), fall back to thumbnail
    if (gif != null && gif.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRect(
          child: GifView.asset(
            'assets/$gif',
            fit: fit,
            width: size,
            height: size,
            filterQuality: FilterQuality.high,
            progressBuilder: (context) => const _Placeholder(),
            errorBuilder: (context, error, tryAgain) => const _Placeholder(),
          ),
        ),
      );
    }

    if (thumb != null && thumb.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRect(
          child: Image.asset(
            'assets/$thumb',
            fit: fit,
            cacheWidth: (size * 2).toInt(),
            errorBuilder: (context, error, stack) => const _Placeholder(),
          ),
        ),
      );
    }

    return const _Placeholder();
  }
}

/// A small (48x48) thumbnail placeholder with a fitness icon.
/// Matches the placeholder used in ExerciseIndexScreen.
class ExerciseThumbnailPlaceholder extends StatelessWidget {
  final double size;

  const ExerciseThumbnailPlaceholder({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: size * 0.4,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// A large GIF placeholder used in exercise detail screens.
/// Uses a darker background and a larger fitness icon.
class ExerciseGifPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const ExerciseGifPlaceholder({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceContainerLow,
      child: const Center(
        child: Icon(
          Icons.fitness_center,
          size: 56,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─── Private placeholder widget ───────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHighest,
      child: const Center(
        child: Icon(
          Icons.fitness_center,
          size: 20,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}