import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/router/app_router.dart';
import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/user_profile.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    await ref
        .read(authNotifierProvider.notifier)
        .signInWithEmail(email, password);
    // Navigation is handled by router redirect — no manual context.go needed
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  void _showForgotPasswordDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'RESET PASSWORD',
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: GoogleFonts.lexend(color: AppColors.onSurface, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'EMAIL',
            labelStyle: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.6,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.lexend(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = controller.text.trim();
              Navigator.of(dialogContext).pop();
              if (email.isNotEmpty) {
                await ref
                    .read(authNotifierProvider.notifier)
                    .sendPasswordResetEmail(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent'),
                    ),
                  );
                }
              }
            },
            child: Text(
              'SEND',
              style: GoogleFonts.lexend(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // TRAIN wordmark
              Text(
                'TRAIN',
                style: GoogleFonts.lexend(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Short horizontal divider
              Center(
                child: Container(
                  width: 32,
                  height: 2,
                  color: AppColors.outlineVariant,
                ),
              ),
              const SizedBox(height: 48),
              // AUTHENTICATION heading
              Text(
                'AUTHENTICATION',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 32),
              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: GoogleFonts.lexend(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                  hintText: 'athlete@performance.com',
                  labelStyle: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.lexend(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                  suffixIcon: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      'FORGOT?',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // CONTINUE TO DASHBOARD button
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
                        onPressed: _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onSurface,
                          foregroundColor: AppColors.surface,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          'CONTINUE TO DASHBOARD',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              // Social divider row
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: AppColors.outlineVariant,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'SOCIAL',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: AppColors.outlineVariant,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Social buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        side: const BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        minimumSize: const Size(0, 52),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'G',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'GOOGLE',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        side: const BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        minimumSize: const Size(0, 52),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(
                            'APPLE',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // New athlete row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New athlete? ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.register),
                    child: Text(
                      'Join Now',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Footer
              Text(
                'TERMS OF SERVICE & PRIVACY POLICY',
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '© 2024 KINETIC PERFORMANCE',
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
