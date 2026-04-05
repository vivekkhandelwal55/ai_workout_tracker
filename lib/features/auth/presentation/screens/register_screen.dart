import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_workout_tracker_app/app/router/app_router.dart';
import 'package:ai_workout_tracker_app/app/theme/app_theme.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/shared/models/user_profile.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          email,
          password,
          displayName: name.isEmpty ? null : name,
        );
  }

  Future<void> _handleGoogleSignUp() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
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
              // Back button row
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.onSurfaceVariant,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: 12),
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
              Center(
                child: Container(
                  width: 32,
                  height: 2,
                  color: AppColors.outlineVariant,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'CREATE ACCOUNT',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 32),
              // Display name field (optional)
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.lexend(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'NAME (OPTIONAL)',
                  hintText: 'Alex Mercer',
                  labelStyle: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Confirm password field
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: GoogleFonts.lexend(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'CONFIRM PASSWORD',
                  labelStyle: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // CREATE ACCOUNT button
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
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onSurface,
                          foregroundColor: AppColors.surface,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          'CREATE ACCOUNT',
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
              // Social divider
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
              // Google sign-up button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _handleGoogleSignUp,
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
                        'CONTINUE WITH GOOGLE',
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
              const SizedBox(height: 48),
              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: Text(
                      'Sign In',
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
