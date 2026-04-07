---
name: Workout History Detail feature
description: WorkoutHistoryDetailScreen (new), AppRoutes.workoutHistoryDetail constant, router wiring, StatsScreen _WorkoutHistoryRow onTap navigation
type: project
---

Added a full detail view for past workout sessions accessible from the Stats screen history section.

- New screen: `lib/features/stats/presentation/screens/workout_history_detail_screen.dart`
  - `ConsumerWidget`, accepts `WorkoutSession` in constructor
  - `CustomScrollView` with `SliverAppBar` (pinned, two-line title: template name + formatted date)
  - `_SummaryRow` shows 4 stats separated by vertical dividers: duration, volume, sets, exercises
  - `SliverList.separated` of `_ExerciseCard` widgets; empty state via `SliverFillRemaining`
  - `_ExerciseCard`: header row (numbered badge, name, set count), column headers, then `_SetRow` per set
  - `_SetRow`: set number, `_SetTypeBadge` (warmup=amber W, drop=orange D, failure=red F, normal=empty), weight, reps, status icon or `_PRBadge` (gold)
  - Uses `GoogleFonts.lexendMega` for numeric values to give monospace feel
  - All colors from `AppColors`; no hardcoded radius (app theme uses `BorderRadius.zero` everywhere)

- `AppRoutes.workoutHistoryDetail = '/workout-history-detail'` added to `app_routes.dart`
- Route added to `app_router.dart` as top-level `GoRoute` (outside `ShellRoute`) — passes `state.extra as WorkoutSession`
- `stats_screen.dart`: added `go_router` and `app_routes` imports; wrapped `_WorkoutHistoryRow` body with `InkWell(onTap: () => context.push(AppRoutes.workoutHistoryDetail, extra: session))`

**Why:** Users needed drill-down from the history list to see per-exercise, per-set details of completed sessions.
**How to apply:** Pattern for any detail screen navigated via `extra` — top-level GoRoute outside ShellRoute so it gets its own full-screen stack without bottom nav.
