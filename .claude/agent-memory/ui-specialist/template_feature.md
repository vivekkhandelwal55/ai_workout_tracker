---
name: Template creation feature
description: Built template creation/editing feature with shared ExercisePicker widget
type: project
---

## Template Creation & Editing Feature

### What was built

**Shared widget**: `lib/shared/widgets/exercise_picker.dart`
- Extracted from `_ExercisePicker` in `active_workout_screen.dart`
- Public `ExercisePicker` class with `onExerciseSelected` callback
- Includes search, muscle group filter chips, exercise list
- Uses `exercisesProvider` from `exercise_providers.dart`

**New screen**: `lib/features/workout/presentation/screens/create_template_screen.dart`
- Handles both create and edit modes (via `template` constructor param)
- Template name input
- Add exercises via bottom sheet picker
- Per-exercise defaults: sets (int), reps (int?), weight (double?)
- Reorder with up/down arrow buttons
- Remove exercise button
- Estimated duration display (~2.5 min per exercise)
- Save calls `workoutRepositoryProvider.saveTemplate` and invalidates templates cache

**Router changes** (`lib/app/router/app_router.dart`):
- Added `AppRoutes.createTemplate = '/create-template'`
- Added `AppRoutes.editTemplate = '/edit-template'`
- `CreateTemplateScreen` imported
- `WorkoutTemplate` model imported for route extra

**HomeScreen wiring** (`lib/features/workout/presentation/screens/home_screen.dart`):
- `_TemplateCard`: tap starts workout + navigates; long press shows bottom sheet (Edit / Start Workout)
- `_NewTemplateCard`: tap navigates to create template

### Key implementation notes
- `CreateTemplateScreen` uses `mounted` guard before calling `setState` after async operations
- `_NumberField` and `_WeightField` are private inner widgets for inline editing
- Template ID generated via `uuid` package (already in pubspec.yaml)
- `workoutTemplatesProvider` is invalidated after save to refresh cache
