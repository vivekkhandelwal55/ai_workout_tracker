import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/user_profile.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  final _nameController = TextEditingController(text: '');
  final _ageController = TextEditingController(text: '24');
  final _weightController = TextEditingController(text: '82');
  final _heightController = TextEditingController(text: '185');

  FitnessGoal _selectedGoal = FitnessGoal.hypertrophy;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final name = _nameController.text.trim().isEmpty
        ? null
        : _nameController.text.trim();
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    final currentUser = ref.read(authNotifierProvider).valueOrNull;
    if (currentUser == null) return;

    final profile = currentUser.copyWith(
      displayName: name,
      age: age,
      weightKg: weight,
      heightCm: height,
      primaryGoal: _selectedGoal,
      onboardingComplete: true,
      updatedAt: DateTime.now(),
    );

    await ref.read(authNotifierProvider.notifier).updateProfile(profile);
    // Router redirect handles navigation when onboardingComplete becomes true
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    ref.listen<AsyncValue<UserProfile?>>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom top row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TRAIN',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      'SETUP 01 / 04',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Title block
              Text(
                'PROFILE',
                style: GoogleFonts.lexend(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              Text(
                'DATA.',
                style: GoogleFonts.lexend(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'ESSENTIAL METRICS FOR PERFORMANCE CALIBRATION.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      letterSpacing: 0.8,
                    ),
              ),
              const SizedBox(height: 32),
              // Section label: IDENTITY
              Text(
                'IDENTITY',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              // Name text field — underline style
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'ALEX MERCER',
                  hintStyle: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceContainerHighest,
                    letterSpacing: 1.2,
                  ),
                  filled: false,
                  border: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.outlineVariant, width: 1),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.outlineVariant, width: 1),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              // Three inline metric fields
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricField(
                        label: 'AGE',
                        controller: _ageController,
                        unit: 'YRS',
                      ),
                    ),
                    const VerticalDivider(
                      color: AppColors.outlineVariant,
                      thickness: 1,
                      width: 1,
                    ),
                    Expanded(
                      child: _MetricField(
                        label: 'WEIGHT',
                        controller: _weightController,
                        unit: 'KG',
                      ),
                    ),
                    const VerticalDivider(
                      color: AppColors.outlineVariant,
                      thickness: 1,
                      width: 1,
                    ),
                    Expanded(
                      child: _MetricField(
                        label: 'HEIGHT',
                        controller: _heightController,
                        unit: 'CM',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Section label: PRIMARY OBJECTIVE
              Text(
                'PRIMARY OBJECTIVE',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              // Goal cards
              _GoalCard(
                title: 'HYPERTROPHY',
                subtitle: 'GAIN MUSCLE MASS',
                goal: FitnessGoal.hypertrophy,
                selectedGoal: _selectedGoal,
                onTap: () =>
                    setState(() => _selectedGoal = FitnessGoal.hypertrophy),
              ),
              const SizedBox(height: 8),
              _GoalCard(
                title: 'FAT LOSS',
                subtitle: 'WEIGHT REDUCTION',
                goal: FitnessGoal.fatLoss,
                selectedGoal: _selectedGoal,
                onTap: () =>
                    setState(() => _selectedGoal = FitnessGoal.fatLoss),
              ),
              const SizedBox(height: 8),
              _GoalCard(
                title: 'ENDURANCE',
                subtitle: 'VO2 MAX & STAMINA',
                goal: FitnessGoal.endurance,
                selectedGoal: _selectedGoal,
                onTap: () =>
                    setState(() => _selectedGoal = FitnessGoal.endurance),
              ),
              const SizedBox(height: 48),
              // CONTINUE button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          'CONTINUE →',
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
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;

  const _MetricField({
    required this.label,
    required this.controller,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(context).textTheme.headlineMedium,
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final FitnessGoal goal;
  final FitnessGoal selectedGoal;
  final VoidCallback onTap;

  const _GoalCard({
    required this.title,
    required this.subtitle,
    required this.goal,
    required this.selectedGoal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = goal == selectedGoal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceContainerHigh
              : AppColors.surfaceContainerLow,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
            top: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : AppColors.outlineVariant.withAlpha(38),
              width: 1,
            ),
            right: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : AppColors.outlineVariant.withAlpha(38),
              width: 1,
            ),
            bottom: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : AppColors.outlineVariant.withAlpha(38),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
