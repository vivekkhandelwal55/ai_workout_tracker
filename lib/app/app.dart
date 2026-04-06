import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../features/workout/presentation/providers/workout_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the ticker at the app root so the workout clock keeps running
    // regardless of which screen is currently displayed.
    ref.watch(workoutTickerProvider);

    return MaterialApp.router(
      title: 'TRAIN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
