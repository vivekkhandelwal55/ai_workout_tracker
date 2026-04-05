---
name: Workout Routine feature — data/domain/provider layer
description: Context on what was built for the WorkoutRoutine feature and pre-existing errors in the codebase
type: project
---

The complete data/domain/provider layer for the WorkoutRoutine feature was implemented.

**Why:** Engineering manager spec requested single fixed Firestore document (`users/{userId}/routine/active`) cycling through routine days from a startDate.

**How to apply:** When extending routine logic, the key files are:
- `lib/shared/models/workout_routine.dart` (Freezed model)
- `lib/features/routine/domain/routine_repository.dart`
- `lib/features/routine/domain/routine_day_calculator.dart`
- `lib/features/routine/data/routine_firestore_data_source.dart`
- `lib/features/routine/data/routine_repository_impl.dart`
- `lib/features/routine/presentation/providers/routine_providers.dart`

Pre-existing errors fixed as a side-effect:
- `exercise_providers.dart` was missing an import for `auth_providers.dart` (authNotifierProvider was undefined)
- `home_screen.dart` referenced `_RecommendedCard` class that didn't exist — added a `SizedBox.shrink()` placeholder stub for the UI agent to implement

Remaining warnings (UI agent's responsibility):
- `routine_screen.dart` unused import of `workout_template.dart`
- `home_screen.dart` unused import of `routine_providers.dart` (UI not yet wired up)
