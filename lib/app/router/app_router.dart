import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ai_workout_tracker_app/app/router/app_routes.dart';
export 'package:ai_workout_tracker_app/app/router/app_routes.dart';

import 'package:ai_workout_tracker_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/screens/register_screen.dart';
import 'package:ai_workout_tracker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_workout_tracker_app/features/profile/presentation/screens/user_details_screen.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/screens/home_screen.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/screens/workout_summary_screen.dart';
import 'package:ai_workout_tracker_app/features/stats/presentation/screens/stats_screen.dart';
import 'package:ai_workout_tracker_app/features/exercises/presentation/screens/exercise_index_screen.dart';
import 'package:ai_workout_tracker_app/features/workout/presentation/screens/create_template_screen.dart';
import 'package:ai_workout_tracker_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:ai_workout_tracker_app/features/routine/presentation/screens/routine_screen.dart';
import 'package:ai_workout_tracker_app/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:ai_workout_tracker_app/features/stats/presentation/screens/workout_history_detail_screen.dart';
import 'package:ai_workout_tracker_app/shared/models/exercise.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_session.dart';
import 'package:ai_workout_tracker_app/shared/models/user_profile.dart';
import 'package:ai_workout_tracker_app/shared/models/workout_template.dart';
import 'package:ai_workout_tracker_app/shared/widgets/active_workout_indicator.dart';

part 'app_router.g.dart';


@riverpod
GoRouter appRouter(Ref ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: (context, state) => notifier.redirect(state),
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
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
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
            builder: (context, state) => const ProfileScreen(),
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
      GoRoute(
        path: AppRoutes.createTemplate,
        builder: (context, state) => const CreateTemplateScreen(),
      ),
      GoRoute(
        path: AppRoutes.editTemplate,
        builder: (context, state) {
          final template = state.extra as WorkoutTemplate?;
          return CreateTemplateScreen(template: template);
        },
      ),
      GoRoute(
        path: AppRoutes.routine,
        builder: (context, state) => const RoutineScreen(),
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail,
        builder: (context, state) {
          final exercise = state.extra as Exercise;
          return ExerciseDetailScreen(exercise: exercise);
        },
      ),
      GoRoute(
        path: AppRoutes.workoutHistoryDetail,
        builder: (context, state) {
          final session = state.extra as WorkoutSession;
          return WorkoutHistoryDetailScreen(session: session);
        },
      ),
    ],
  );
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserProfile?>>(
      authNotifierProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;

  String? redirect(GoRouterState state) {
    final authAsync = _ref.read(authNotifierProvider);

    // While loading, stay on login — native splash handles the wait
    if (authAsync.isLoading) {
      return null;
    }

    final user = authAsync.valueOrNull;
    final isAuthenticated = user != null;
    final isOnboardingComplete = user?.onboardingComplete ?? false;

    final goingToAuth = [
      AppRoutes.login,
      AppRoutes.onboarding,
      AppRoutes.register,
    ].contains(state.matchedLocation);
    final goingToUserDetails =
        state.matchedLocation == AppRoutes.userDetails;

    // Not authenticated — send to login unless already going there
    if (!isAuthenticated) {
      return goingToAuth ? null : AppRoutes.login;
    }

    // Authenticated but onboarding not complete
    if (!isOnboardingComplete) {
      return goingToUserDetails ? null : AppRoutes.userDetails;
    }

    // Authenticated and onboarding complete — don't let them visit auth screens
    if (goingToAuth || goingToUserDetails) {
      return AppRoutes.home;
    }

    return null;
  }
}

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: child,
          bottomNavigationBar: const _BottomNav(),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ActiveWorkoutIndicator(),
        ),
      ],
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
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'HOME',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'STATS',
        ),
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'LIFTS',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'YOU',
        ),
      ],
    );
  }
}


