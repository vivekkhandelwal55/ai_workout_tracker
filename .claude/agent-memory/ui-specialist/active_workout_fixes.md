---
name: Active workout screen fixes and enhancements
description: Bugs fixed + 3 new features: exercise description sheet, volume trend sheet, drag-to-reorder via SliverReorderableList
type: project
---

Fixed four issues in the active workout screen (2026-04-07):

1. **Settings button** — wrapped plain `Icon` in `GestureDetector` calling `_showSettingsSheet(context)`.
2. **Exercise 3-dot menu** — replaced plain `Icon` with `PopupMenuButton<String>`; added `onRemove` callback.
3. **Volume collection bug** — flush pending inline edits before toggling set completion; re-read latest set from provider.
4. **Keyboard unfocus** — `GestureDetector(behavior: HitTestBehavior.translucent)` wrapping scroll content.

Added three features (2026-04-07):

5. **Show Description** — "SHOW DESCRIPTION" popup menu item calls `_showDescriptionSheet(context, meta)` on `_ExerciseCardState`. Uses `DraggableScrollableSheet` inside `showModalBottomSheet`. Shows exercise name, `_MuscleChip` widgets for primary + target + secondary muscles, `_InfoPill` widgets for level/mechanic/force/equipment, then numbered instructions from `Exercise.instructions` (or `tips` as fallback).

6. **Show Trend** — "SHOW TREND" popup menu item calls `_showTrendSheet(context)`. Shows session-only stats: sets done, max weight, total volume. Renders a `_VolumeBarChart` (custom `LayoutBuilder`-based bar chart, no external package). Also renders a per-set breakdown table.

7. **Drag to reorder** — Replaced the `Column`/`SingleChildScrollView` scroll area with a `CustomScrollView` using:
   - `SliverToBoxAdapter` for the timer+stats header
   - `SliverPadding > SliverReorderableList` for exercise cards, with `ReorderableDelayedDragStartListener` wrapping each card (long-press to drag)
   - `SliverToBoxAdapter` for the Add Exercise + Finish Workout footer
   - `proxyDecorator` uses `AnimatedBuilder` for elevation lift during drag
   - `reorderExercises(oldIndex, newIndex)` method added to `ActiveWorkoutNotifier` in `workout_providers.dart`
   - Drag handle `Icons.drag_handle` added to `_ExerciseCard` header row (right of the exercise title, left of the 3-dot menu), wrapped in `Semantics(label: 'Drag to reorder')`

Fixed two additional issues (2026-04-07):

8. **Description sheet showing "No description available"** — Root cause: `exerciseMetadataProvider` looks up by ID; template exercise IDs sometimes don't match the JSON library IDs. Fix: added `exerciseMetadataByNameProvider` (case-insensitive name lookup) to `exercise_providers.dart`. In `_ExerciseCardState.build()`, if the ID-based `meta` is null, `metaByNameAsync` is also watched and `effectiveMeta = meta ?? metaByNameAsync.valueOrNull` is used everywhere — `_metadataLabel`, `_showDescriptionSheet`. The name-based provider only fires when the ID lookup already returned null (guarded by `meta == null` conditional).

9. **Trend sheet showing only current session data** — Refactored `_showTrendSheet` to delegate entirely to a new `_TrendSheet` ConsumerWidget. `_TrendSheet` watches `authNotifierProvider` for userId and `workoutHistoryProvider(userId)` for history. It keeps the existing "THIS SESSION" section at top, then adds a "HISTORY" section listing the last 10 sessions where this exercise appears (case-insensitive name match). Each past session is rendered by `_HistorySessionRow` showing date, set count, total reps, max weight, and total volume. Loading/error states are handled gracefully. No new packages used.

**Key widget relationships:**
- `_ExerciseCard` has an optional `onReorderStart` callback (unused currently — drag is handled by `ReorderableDelayedDragStartListener` at the list level).
- Helper widgets appended at file end: `_MuscleChip`, `_InfoPill`, `_TrendStat`, `_TrendSheet` (ConsumerWidget), `_HistorySessionRow`, `_VolumeBarChart`.
- `_ExerciseCard` instances are keyed with `ValueKey('${exercise.exerciseId}_card')` and the `ReorderableDelayedDragStartListener` with `ValueKey(exercise.exerciseId)`.

**How to apply:** When modifying `_ExerciseCard` in future, the card's build reads `meta` from `exerciseMetadataProvider` with name-based fallback, merged into `effectiveMeta`. This is passed to `_showDescriptionSheet` and used for `_metadataLabel`. The trend sheet is now a separate `ConsumerWidget` so it can watch providers; `_showTrendSheet` in the card just calls `showModalBottomSheet` passing `_TrendSheet`.
