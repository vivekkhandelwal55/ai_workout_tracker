---
name: Auth Feature — Current State (as of 2026-04-04)
description: What exists vs. what still needs to be built for the Firebase authentication flow
type: project
---

As of 2026-04-04, the auth feature has a scaffold but no real Firebase wiring.

**What exists:**
- `AuthRepository` abstract interface (domain layer) — uses `(UserProfile?, Failure?)` record return pattern, `Stream<String?>` for auth state
- `StubAuthRepository` (data layer) — simulates sign-in with a fake user, no Firebase
- `AuthNotifier` extends `StateNotifier<AuthState>` (providers) — NOT yet migrated to `AsyncNotifier` as required by CLAUDE.md
- `AuthState` plain class with `isLoading/error/user` — NOT a Freezed model
- `authNotifierProvider` uses `StateNotifierProvider` — violates the `@riverpod` annotation rule
- `LoginScreen` exists with email/password UI + skeleton Google/Apple buttons (onPressed is empty `{}`)
- `appRouter` has no `redirect` logic — no auth-aware navigation guard
- `UserProfile` is a plain Dart class — NOT a Freezed model, no `fromJson/toJson`
- No `firebase_auth`, `google_sign_in`, or `firebase_core` in pubspec.yaml yet
- No Firestore collection constants for users

**Why this matters:**
- Any new auth work must migrate away from `StateNotifier` and manual `Provider(...)` to `@riverpod` + `AsyncNotifier`
- `UserProfile` must be converted to `@freezed` before logic-agent builds the repository implementation
- Router redirect logic is a blocker for both agents — must be designed first

**How to apply:**
- Flag these gaps in every auth feature breakdown
- Do not allow logic-agent to build `FirebaseAuthRepositoryImpl` until `UserProfile` is Freezed and pubspec has firebase deps
- Do not allow ui-agent to wire up Google Sign-In button until `signInWithGoogle` method exists on the repository interface
