// Route name constants — kept in a separate file so screens can import
// these constants without creating a circular dependency with app_router.dart.
abstract class AppRoutes {
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String register = '/register';
  static const String userDetails = '/user-details';
  static const String home = '/home';
  static const String stats = '/stats';
  static const String exercises = '/exercises';
  static const String profile = '/profile';
  static const String activeWorkout = '/workout';
  static const String workoutSummary = '/workout-summary';
  static const String createTemplate = '/create-template';
  static const String editTemplate = '/edit-template';
  static const String routine = '/routine';
  static const String exerciseDetail = '/exercise-detail';
  static const String workoutHistoryDetail = '/workout-history-detail';
}
