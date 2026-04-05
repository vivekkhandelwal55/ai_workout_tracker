import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/features/stats/presentation/providers/stats_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/stats_data.dart';
import 'package:ai_workout_tracker_app/shared/models/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authNotifierProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (err, st) => Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: Text(err.toString())),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return _ProfileContent(user: user);
      },
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final UserProfile user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifetimeAsync = ref.watch(lifetimeWorkoutStatsProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          'YOU',
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showEditSheet(context, ref, user),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Text(
                              'EDIT',
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Avatar + identity
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _AvatarCircle(user: user),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (user.displayName?.isNotEmpty == true
                                        ? user.displayName!
                                        : user.email
                                            .split('@')
                                            .first)
                                    .toUpperCase(),
                                style: GoogleFonts.lexend(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (user.createdAt != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'MEMBER SINCE ${DateFormat('MMM yyyy').format(user.createdAt!).toUpperCase()}',
                                  style:
                                      Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Lifetime stats
                  lifetimeAsync.when(
                    loading: () => const SizedBox(height: 88),
                    error: (e, st) => const SizedBox(height: 88),
                    data: (stats) => _LifetimeStatsRow(stats: stats),
                  ),

                  const SizedBox(height: 24),
                  _divider(),

                  // Body metrics
                  _SectionHeader(title: 'BODY METRICS'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'AGE',
                              value: user.age?.toString() ?? '—',
                              unit: 'YRS',
                            ),
                          ),
                          Container(
                              width: 1, color: AppColors.outlineVariant),
                          Expanded(
                            child: _MetricTile(
                              label: 'WEIGHT',
                              value: user.weightKg != null
                                  ? user.weightKg!.toStringAsFixed(1)
                                  : '—',
                              unit: 'KG',
                            ),
                          ),
                          Container(
                              width: 1, color: AppColors.outlineVariant),
                          Expanded(
                            child: _MetricTile(
                              label: 'HEIGHT',
                              value: user.heightCm != null
                                  ? user.heightCm!.toStringAsFixed(0)
                                  : '—',
                              unit: 'CM',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _divider(),

                  // Fitness profile
                  _SectionHeader(title: 'FITNESS PROFILE'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'PRIMARY GOAL',
                          value: _goalLabel(user.primaryGoal),
                        ),
                        Container(
                            height: 1, color: AppColors.outlineVariant),
                        _InfoRow(
                          label: 'EXPERIENCE',
                          value: _levelLabel(user.experienceLevel),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _divider(),

                  // Account actions
                  _SectionHeader(title: 'ACCOUNT'),
                  _ActionRow(
                    icon: Icons.person_outline,
                    label: 'EDIT PROFILE',
                    onTap: () => _showEditSheet(context, ref, user),
                  ),
                  _divider(horizontal: 20),
                  _ActionRow(
                    icon: Icons.lock_reset_outlined,
                    label: 'RESET PASSWORD',
                    onTap: () =>
                        _handleResetPassword(context, ref, user.email),
                  ),
                  _divider(horizontal: 20),
                  _ActionRow(
                    icon: Icons.logout,
                    label: 'SIGN OUT',
                    labelColor: AppColors.error,
                    onTap: () => _handleSignOut(context, ref),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider({double horizontal = 0}) => Container(
        height: 1,
        color: AppColors.outlineVariant,
        margin: EdgeInsets.symmetric(horizontal: horizontal),
      );

  String _goalLabel(FitnessGoal goal) => switch (goal) {
        FitnessGoal.hypertrophy => 'HYPERTROPHY',
        FitnessGoal.fatLoss => 'FAT LOSS',
        FitnessGoal.endurance => 'ENDURANCE',
        FitnessGoal.strength => 'STRENGTH',
        FitnessGoal.generalFitness => 'GENERAL FITNESS',
      };

  String _levelLabel(ExperienceLevel level) => switch (level) {
        ExperienceLevel.beginner => 'BEGINNER',
        ExperienceLevel.intermediate => 'INTERMEDIATE',
        ExperienceLevel.advanced => 'ADVANCED',
      };

  void _showEditSheet(BuildContext context, WidgetRef ref, UserProfile user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      builder: (ctx) => _EditProfileSheet(user: user),
    );
  }

  Future<void> _handleResetPassword(
      BuildContext context, WidgetRef ref, String email) async {
    await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordResetEmail(email);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
        ),
      );
    }
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text(
          'SIGN OUT',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: 1.2,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }
}

// ──────────────────────────────────────────────
// Avatar
// ──────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  final UserProfile user;

  const _AvatarCircle({required this.user});

  String get _initials {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    return user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.primary,
      child: Center(
        child: Text(
          _initials,
          style: GoogleFonts.lexend(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.onPrimary,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Lifetime stats row
// ──────────────────────────────────────────────

class _LifetimeStatsRow extends StatelessWidget {
  final LifetimeStats stats;

  const _LifetimeStatsRow({required this.stats});

  String _formatVolume(double kg) {
    if (kg >= 1000000) return '${(kg / 1000000).toStringAsFixed(1)}M';
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)}K';
    return kg.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                label: 'WORKOUTS',
                value: stats.totalSessions.toString(),
              ),
            ),
            Container(width: 1, color: AppColors.outlineVariant),
            Expanded(
              child: _StatCell(
                label: 'VOLUME',
                value: '${_formatVolume(stats.totalVolumeKg)} KG',
              ),
            ),
            Container(width: 1, color: AppColors.outlineVariant),
            Expanded(
              child: _StatCell(
                label: 'TOTAL SETS',
                value: stats.totalSets.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;

  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Metric tile (body stats)
// ──────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Section header
// ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Info row (label + value)
// ──────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Action row (tappable)
// ──────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? AppColors.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                color: AppColors.onSurfaceVariant, size: 14),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Edit profile bottom sheet
// ──────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  final UserProfile user;

  const _EditProfileSheet({required this.user});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late FitnessGoal _selectedGoal;
  late ExperienceLevel _selectedLevel;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user.displayName ?? '');
    _ageController =
        TextEditingController(text: widget.user.age?.toString() ?? '');
    _weightController = TextEditingController(
        text: widget.user.weightKg?.toStringAsFixed(1) ?? '');
    _heightController = TextEditingController(
        text: widget.user.heightCm?.toStringAsFixed(0) ?? '');
    _selectedGoal = widget.user.primaryGoal;
    _selectedLevel = widget.user.experienceLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim().isEmpty
        ? null
        : _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    final updated = widget.user.copyWith(
      displayName: name,
      age: age,
      weightKg: weight,
      heightCm: height,
      primaryGoal: _selectedGoal,
      experienceLevel: _selectedLevel,
      updatedAt: DateTime.now(),
    );

    await ref.read(authNotifierProvider.notifier).updateProfile(updated);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    ref.listen<AsyncValue<UserProfile?>>(authNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (err, st) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(err.toString())),
            );
          }
        },
      );
    });

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                color: AppColors.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'EDIT PROFILE',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Name
            Text('IDENTITY', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                labelText: 'DISPLAY NAME',
                hintText: 'YOUR NAME',
                hintStyle: GoogleFonts.lexend(
                  fontSize: 18,
                  color: AppColors.surfaceContainerHighest,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Body metrics
            Text('BODY METRICS',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _SheetMetricField(
                      label: 'AGE',
                      controller: _ageController,
                      unit: 'YRS',
                      isDecimal: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetMetricField(
                      label: 'WEIGHT',
                      controller: _weightController,
                      unit: 'KG',
                      isDecimal: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetMetricField(
                      label: 'HEIGHT',
                      controller: _heightController,
                      unit: 'CM',
                      isDecimal: false,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Primary goal
            Text('PRIMARY GOAL',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            ...FitnessGoal.values.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectableCard(
                  label: _goalLabel(goal),
                  isSelected: _selectedGoal == goal,
                  onTap: () => setState(() => _selectedGoal = goal),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Experience level
            Text('EXPERIENCE',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            Row(
              children: ExperienceLevel.values
                  .map(
                    (level) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: level == ExperienceLevel.advanced ? 0 : 8),
                        child: _SelectableCard(
                          label: _levelLabel(level),
                          isSelected: _selectedLevel == level,
                          onTap: () =>
                              setState(() => _selectedLevel = level),
                          compact: true,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    )
                  : ElevatedButton(
                      onPressed: _handleSave,
                      child: Text(
                        'SAVE CHANGES',
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

  String _goalLabel(FitnessGoal goal) => switch (goal) {
        FitnessGoal.hypertrophy => 'HYPERTROPHY',
        FitnessGoal.fatLoss => 'FAT LOSS',
        FitnessGoal.endurance => 'ENDURANCE',
        FitnessGoal.strength => 'STRENGTH',
        FitnessGoal.generalFitness => 'GENERAL FITNESS',
      };

  String _levelLabel(ExperienceLevel level) => switch (level) {
        ExperienceLevel.beginner => 'BEGINNER',
        ExperienceLevel.intermediate => 'INTER',
        ExperienceLevel.advanced => 'ADVANCED',
      };
}

// ──────────────────────────────────────────────
// Sheet metric field
// ──────────────────────────────────────────────

class _SheetMetricField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final bool isDecimal;

  const _SheetMetricField({
    required this.label,
    required this.controller,
    required this.unit,
    required this.isDecimal,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: [
        if (isDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      style: GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        suffixStyle: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Selectable card (goal / level)
// ──────────────────────────────────────────────

class _SelectableCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  const _SelectableCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 16,
          vertical: compact ? 12 : 14,
        ),
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
        child: Row(
          mainAxisAlignment: compact
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: compact ? 10 : 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
                textAlign: compact ? TextAlign.center : TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected && !compact) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
