import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gif_view/gif_view.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/shared/models/exercise.dart';
import 'package:ai_workout_tracker_app/shared/widgets/exercise_thumbnail_widget.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            backgroundColor: AppColors.surfaceContainerLow,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _GifSection(gifUrl: exercise.gifUrl),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Name + Category badge row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name.toUpperCase(),
                          style: GoogleFonts.lexend(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (exercise.category != null)
                        Container(
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          color: AppColors.surfaceContainerHighest,
                          child: Text(
                            exercise.category!.toUpperCase(),
                            style: GoogleFonts.lexend(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // 2. Attribute pills row
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (exercise.mechanic != null)
                        _AttributePill(exercise.mechanic!),
                      if (exercise.level != null)
                        _AttributePill(exercise.level!),
                      if (exercise.force != null)
                        _AttributePill(exercise.force!),
                      if (exercise.equipmentName != null &&
                          exercise.equipmentName!.isNotEmpty)
                        _AttributePill(exercise.equipmentName!),
                    ],
                  ),

                  // 3. Divider
                  const SizedBox(height: 24),
                  Container(height: 1, color: AppColors.outlineVariant),

                  // 4. Target Muscles section
                  if (exercise.targetMuscles.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionLabel('TARGET MUSCLES'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exercise.targetMuscles
                          .map((m) => _MuscleChip(m))
                          .toList(),
                    ),
                  ],

                  // 5. Secondary Muscles section
                  if (exercise.secondaryMuscles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const _SectionLabel('SECONDARY'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exercise.secondaryMuscles
                          .map((m) => _SecondaryMuscleChip(m))
                          .toList(),
                    ),
                  ],

                  // 6. Divider
                  const SizedBox(height: 24),
                  Container(height: 1, color: AppColors.outlineVariant),

                  // 7. Instructions section
                  if (exercise.instructions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionLabel('HOW TO'),
                    const SizedBox(height: 16),
                    Column(
                      children: exercise.instructions
                          .asMap()
                          .entries
                          .map((entry) => _InstructionStep(
                                number: entry.key + 1,
                                text: entry.value,
                              ))
                          .toList(),
                    ),
                  ],

                  // 8. Tips section
                  if (exercise.tips.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(height: 1, color: AppColors.outlineVariant),
                    const SizedBox(height: 20),
                    const _SectionLabel('COACHING TIPS'),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        for (int i = 0; i < exercise.tips.length; i++) ...[
                          _TipRow(exercise.tips[i]),
                          if (i < exercise.tips.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ],

                  // 9. Bottom spacer
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _GifSection extends StatelessWidget {
  final String? gifUrl;

  const _GifSection({required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (gifUrl != null && gifUrl!.isNotEmpty)
          GifView.asset(
            'assets/$gifUrl',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.high,
            progressBuilder: (context) => const _GifPlaceholder(),
            errorBuilder: (context, error, tryAgain) => const _GifPlaceholder(),
          )
        else
          const _GifPlaceholder(),
        // Bottom gradient overlay for seamless content flow
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.surface],
                stops: [0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GifPlaceholder extends StatelessWidget {
  const _GifPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ExerciseGifPlaceholder();
  }
}

class _AttributePill extends StatelessWidget {
  final String label;

  const _AttributePill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  final String muscle;

  const _MuscleChip(this.muscle);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        muscle.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}

class _SecondaryMuscleChip extends StatelessWidget {
  final String muscle;

  const _SecondaryMuscleChip(this.muscle);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        muscle.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              number.toString().padLeft(2, '0'),
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String tip;

  const _TipRow(this.tip);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 12),
          color: AppColors.primary,
        ),
        Expanded(
          child: Text(
            tip,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
