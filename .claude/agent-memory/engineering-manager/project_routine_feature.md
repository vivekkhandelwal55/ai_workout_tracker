---
name: Workout Routine Feature — Architecture Decision
description: Key non-obvious decisions made when designing the Workout Routine feature (cycle computation, Firestore placement, provider split)
type: project
---

The Workout Routine feature uses a single-document-per-user Firestore model at `users/{userId}/routine/active` rather than a sub-collection. The routine is a single repeating cycle, so only one document is ever active per user — no collection needed.

**Why:** A collection adds query overhead and ordering complexity for something that is conceptually a singleton. A single known document path also simplifies the real-time stream.

**How to apply:** The `RoutineRepository` interface uses `getRoutine`/`saveRoutine`/`deleteRoutine` that all target the same document path. No list/paginate methods needed.

---

The "today's routine day" computation is a pure Dart function in the domain layer (`TodayRoutineDay computeTodayRoutineDay(WorkoutRoutine, DateTime)`), not a provider chain.

**Why:** This avoids a provider that depends on the current time (hard to test, creates unnecessary rebuilds). The computation is called inside `todayRoutineDayProvider` which derives from `currentRoutineProvider`.

**How to apply:** Logic agent owns this function. UI agent consumes `todayRoutineDayProvider` only — never recomputes the day index in a widget.

---

`RoutineDay` has a nullable `templateId` and `templateName`. Template name is denormalized into the routine document to avoid a secondary Firestore read on the home screen.

**Why:** The home screen "RECOMMENDED" card renders synchronously from a single provider. Requiring a second fetch for the template name would introduce a loading flash on every home screen load.

**How to apply:** When the user links a template to a routine day, both `templateId` and `templateName` are written. When a template is renamed, the routine document is NOT automatically updated (acceptable stale tolerance for a name field).
