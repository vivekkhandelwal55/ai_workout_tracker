---
name: Exercise Feature — Architecture Decisions
description: Data source strategy, model extension approach, and routing pattern for the Exercise detail feature
type: project
---

The exercise feature uses a dual data-source strategy: local JSON asset for the built-in library (1800+ exercises), Firestore subcollection only for user custom exercises. The global Firestore `exercises` collection is intentionally empty and not used.

**Why:** Seeding Firestore with 1800 exercises would be expensive (reads charged per doc), slow on first load, and a maintenance burden. The JSON asset is the canonical built-in source.

**Key decisions:**
- `ExerciseLocalDataSource` owns filtering and search for built-in exercises (applied in-memory after parsing)
- `ExerciseRepositoryImpl` merges: local first, custom exercises appended at end
- `ExerciseFirestoreDataSource.getExercises` is no longer called for the global collection — only `getCustomExercises(userId)` remains its responsibility
- The `Exercise` model gains 9 optional fields to preserve backward compat with custom exercises (which will never have bodyParts, instructions, etc.)
- `exerciseDetail` route sits outside the ShellRoute (no bottom nav on detail screen) — uses `context.push` not `context.go`
- Thumbnail shown in list row via `Image.network` with 48×48 box; animated GIF shown only on detail screen
- `bodyParts` → `primaryMuscle` mapping is done in `ExerciseLocalDataSource`, not in the model itself

**How to apply:** When planning future exercise-related features, remember the local-first data source strategy. Any feature that needs to read exercises should go through the repository, never directly to the asset or Firestore.
