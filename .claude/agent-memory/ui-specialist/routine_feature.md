---
name: Routine feature UI
description: RoutineScreen implementation — view/edit modes, _RecommendedCard states, router wiring
type: project
---

RoutineScreen lives at `lib/features/routine/presentation/screens/routine_screen.dart`.

Three render states in _RecommendedCard (home screen): no routine, rest day, workout day.

AppRoutes.routine = '/routine' — added as a standalone GoRoute outside the ShellRoute (full-screen, no bottom nav).

**Why:** Feature requires full-screen layout without bottom navigation bar interference.

**How to apply:** Any future full-screen overlay screens should also be added outside the ShellRoute in app_router.dart.
