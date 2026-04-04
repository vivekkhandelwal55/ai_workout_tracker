import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_workout_tracker_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ai_workout_tracker_app/features/profile/presentation/screens/user_details_screen.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/screens/home_screen.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/screens/workout_summary_screen.dart';
import 'package:ai_workout_tracker_app/features/stats/presentation/screens/stats_screen.dart';
import 'package:ai_workout_tracker_app/features/exercises/presentation/screens/exercise_index_screen.dart';

// Route name constants
abstract class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String userDetails = '/user-details';
  static const String home = '/home';
  static const String stats = '/stats';
  static const String exercises = '/exercises';
  static const String profile = '/profile';
  static const String activeWorkout = '/workout';
  static const String workoutSummary = '/workout-summary';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.userDetails,
      builder: (context, state) => const UserDetailsScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.stats,
          builder: (context, state) => const StatsScreen(),
        ),
        GoRoute(
          path: AppRoutes.exercises,
          builder: (context, state) => const ExerciseIndexScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const _PlaceholderScreen(name: 'Profile'),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.activeWorkout,
      builder: (context, state) => const ActiveWorkoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.workoutSummary,
      builder: (context, state) => const WorkoutSummaryScreen(),
    ),
  ],
);

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = switch (location) {
      String l when l.startsWith('/home') => 0,
      String l when l.startsWith('/stats') => 1,
      String l when l.startsWith('/exercises') => 2,
      String l when l.startsWith('/profile') => 3,
      _ => 0,
    };

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.home);
          case 1:
            context.go(AppRoutes.stats);
          case 2:
            context.go(AppRoutes.exercises);
          case 3:
            context.go(AppRoutes.profile);
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'HOME'),
        NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'STATS'),
        NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'LIFTS'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'YOU'),
      ],
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String name;
  const _PlaceholderScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(name, style: Theme.of(context).textTheme.headlineLarge),
      ),
    );
  }
}
