---
name: Exercise Detail feature
description: ExerciseDetailScreen (new), ExerciseIndexScreen updates, AppRoutes extraction to break circular import
type: project
---

AppRoutes was moved from `app_router.dart` into a dedicated `lib/app/router/app_routes.dart` file to break a circular import that would arise when screens need to reference route constants while the router also imports those screens. `app_router.dart` re-exports `app_routes.dart` so all existing `import 'app_router.dart'` callers continue to see `AppRoutes` unchanged.

**Why:** `exercise_index_screen.dart` is imported by `app_router.dart` (ShellRoute), and the index screen needed to push to `AppRoutes.exerciseDetail`. Importing `app_router.dart` from a file that `app_router.dart` already imports creates a Dart circular dependency error.

**How to apply:** Any future screen that needs to reference `AppRoutes` constants but is itself imported by `app_router.dart` (i.e. all shell/tab screens) must import `app_routes.dart`, not `app_router.dart`.

Key files touched:
- `lib/app/router/app_routes.dart` — new, holds `AppRoutes` abstract class
- `lib/app/router/app_router.dart` — removed inline `AppRoutes`, added import+export of `app_routes.dart`, added `exerciseDetail` GoRoute (top-level, outside ShellRoute)
- `lib/features/exercises/presentation/screens/exercise_detail_screen.dart` — new full-screen detail; StatelessWidget, takes `Exercise` as constructor param, no Riverpod
- `lib/features/exercises/presentation/screens/exercise_index_screen.dart` — thumbnail via `Image.network`, CUSTOM badge in trailing row, `context.push` to exerciseDetail
