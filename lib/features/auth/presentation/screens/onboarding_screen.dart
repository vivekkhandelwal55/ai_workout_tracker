import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/router/app_router.dart';
import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Version badge chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Text(
                  'HYPERTROPHY ENGINE 2.0',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: 32),
              // Hero display text
              Text(
                'TRACK YOUR\nGAINS,\nREACH YOUR\nGOALS.',
                style: GoogleFonts.lexend(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Subtitle paragraph
              Text(
                'The mechanical edge for elite performance. Precision logging meets high-fidelity design.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              // Feature bullet 1
              _FeatureBullet(
                title: 'INSTANT METRICS',
                subtitle: 'REAL-TIME VOLUME TRACKING & 1RM ESTIMATION',
              ),
              const SizedBox(height: 16),
              // Feature bullet 2
              _FeatureBullet(
                title: 'PROGRESS MAPS',
                subtitle: 'VISUALIZE YOUR EVOLUTION WITH HIGH-FIDELITY CHARTS',
              ),
              const SizedBox(height: 48),
              // GET STARTED button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.userDetails),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'GET STARTED →',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // SIGN IN text button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                  ),
                  child: Text(
                    'SIGN IN',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Footer row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SYSTEM FORCE • SYSTEM READY',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    'ENGINEERED FOR THE TOP 1%',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FeatureBullet({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.bolt, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
