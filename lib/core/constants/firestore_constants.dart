abstract class FirestoreCollections {
  static const String users = 'users';
  static const String workoutTemplates = 'workoutTemplates';
  static const String workoutSessions = 'workoutSessions';
  static const String exercises = 'exercises';
  static const String customExercises = 'customExercises';
  static const String routine = 'routine';
}

abstract class RoutineDocFields {
  static const String documentId = 'active';
  static const String userId = 'userId';
  static const String days = 'days';
  static const String startDate = 'startDate';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}

abstract class RoutineDayFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String templateId = 'templateId';
  static const String templateName = 'templateName';
}

abstract class UserProfileFields {
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String avatarUrl = 'avatarUrl';
  static const String age = 'age';
  static const String weightKg = 'weightKg';
  static const String heightCm = 'heightCm';
  static const String primaryGoal = 'primaryGoal';
  static const String experienceLevel = 'experienceLevel';
  static const String onboardingComplete = 'onboardingComplete';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}
