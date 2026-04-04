# AI Workout Tracker — Claude Code Project Rules

## Project Overview
A Flutter-based AI workout tracker app targeting Android 14+ (API 34+) and iOS 17+. Uses Firebase as the backend, Riverpod for state management, and follows clean architecture with a feature-first folder structure.

### App Purpose
Help gym-goers track their daily workouts, monitor progress over time, and get AI-powered coaching suggestions.

### User Flows
1. **Onboarding** → Login → User details collection (fitness goals, experience level, etc.)
2. **Home Screen** → Weekly gym frequency stats, suggested workout for today, grid of workout templates (tap to start or create new), bottom navigation bar
3. **Active Workout** → Log exercises with flexible units (reps, weight in kg/lbs, time, distance), add warmup sets, drop sets, rest timer
4. **Workout Summ
** → Workout frequency, personal records (PRs), strength progression graphs, link to workout history
6. **Exercise List** → Full exercise library (built-in + user-created), animated GIFs demonstrating form, performance tips, searchable/filterable
7. **Profile Screen** → User details, settings, preferences

### Key Features
- **Workout Templates**: Push Day, Pull Day, Leg Day, etc. — user can create, edit, and reuse templates
- **Flexible Tracking Units**: Weight (kg/lbs), reps, time (seconds/minutes), distance
- **Set Types**: Normal sets, warmup sets, drop sets
- **Rest Timer**: Configurable rest periods between sets
- **Exercise Library**: Curated list with GIFs and form tips; users can add custom exercises
- **Progress Tracking**: Graphs showing strength over time per exercise; PR detection
- **Workout History**: Full log of past sessions with details
- **AI Coach** (`ai_coach` feature): Suggests workouts, flags overtraining, recommends progressions using Gemini/OpenAI API
- **Bottom Navigation**: Home, Stats, Exercises, Profile

---

## Tech Stack (non-negotiable)
- **Flutter**: 3.29.x (stable channel)
- **Dart**: 3.7.x (null-safe, use `required`, avoid `late` unless necessary)
- **State Management**: `flutter_riverpod` ^2.x with code generation (`riverpod_annotation`, `riverpod_generator`)
- **Backend**: Firebase (`firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`)
- **Navigation**: `go_router` ^14.x
- **DI/Code Gen**: `riverpod_generator`, `freezed`, `json_serializable`, `build_runner`
- **AI integration**: `google_generative_ai` or `http` to Gemini/OpenAI API (no opaque wrappers)
- **Testing**: `flutter_test`, `mocktail`, `riverpod_test`

## Forbidden Packages
Do NOT add packages without explicit approval:
- No `get` / `GetX`
- No `provider` (use Riverpod only)
- No `bloc` / `flutter_bloc` (Riverpod is the chosen solution)
- No `dio` (use `http` or `firebase` directly unless `dio` is already in pubspec)
- No deprecated packages (check pub.dev before adding)

---

## Architecture: Feature-First Clean Architecture

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── router/          # go_router configuration
│   ├── theme/           # AppTheme, ColorScheme, TextTheme
│   └── app.dart         # MaterialApp.router root widget
├── core/
│   ├── constants/       # AppConstants, ApiEndpoints
│   ├── errors/          # Failure, AppException classes
│   ├── extensions/      # BuildContext, String, DateTime extensions
│   ├── services/        # FirebaseService, AIService (abstract + impl)
│   └── utils/           # formatters, validators
├── features/
│   ├── auth/
│   │   ├── data/        # AuthRepository impl, FirebaseAuthDataSource
│   │   ├── domain/      # AuthRepository (abstract), User entity, usecases
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/   # Riverpod providers (*.g.dart generated)
│   ├── workout/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── ai_coach/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── widgets/         # Reusable app-wide widgets
    ├── models/          # Shared Freezed data models
    └── providers/       # App-wide providers (theme, connectivity, etc.)
```

---

## Coding Conventions

### Dart / Flutter
- Use `@riverpod` annotation for all providers; never use `Provider(...)` directly
- All data models use `@freezed` with `fromJson`/`toJson`
- Prefer `AsyncNotifier` / `Notifier` over `StateNotifier`
- Never put business logic in widgets — widgets call providers, providers call repositories
- Use `const` constructors everywhere possible
- `BuildContext` must never be used across `async` gaps without `mounted` guard
- Screen files are named `*_screen.dart`; widget files `*_widget.dart` or descriptive noun
- One class per file; file name matches class name in snake_case

### Error Handling
- Use a `Result<T>` / `Either<Failure, T>` pattern in the domain layer
- Surface errors via `AsyncValue.error` in Riverpod; never swallow exceptions silently
- Show user-facing errors with `ScaffoldMessenger` or a dedicated error widget

### Firebase
- All Firestore access goes through a Repository class — no direct `FirebaseFirestore.instance` in widgets or providers
- Collection names are defined as constants in `core/constants/`
- Security rules must be reviewed before any write operation pattern is added

### Android
- Target SDK: 34 (Android 14), Min SDK: 26 (Android 8)
- Every new Android permission must be documented with a comment in `AndroidManifest.xml` explaining why it is needed
- Permissions required at runtime must use `permission_handler` package
- No hardcoded API keys in source — use `--dart-define` or `google-services.json` (gitignored)

### iOS
- Deployment target: iOS 17.0
- Privacy usage descriptions required for camera, microphone, health, photo library

---

## Flutter Best Practices (3.x)
- Use `Material 3` design system (`useMaterial3: true`)
- Prefer `SliverList`, `CustomScrollView` for long lists
- Use `RepaintBoundary` around expensive widgets
- Avoid `setState` in screens — all state through Riverpod
- Use `FlexColorScheme` or a custom `ColorScheme.fromSeed` for theming
- Responsive layouts use `LayoutBuilder` / `MediaQuery`; no hardcoded pixel sizes

---

## Testing Rules
- Every Repository must have a unit test
- Every Provider must have a Riverpod test using `ProviderContainer`
- Widget tests for all shared widgets in `shared/widgets/`
- Integration tests for critical flows (auth, workout logging, AI coach)
- Mocks use `mocktail` — never `mockito`
- Run `flutter test` before committing anything

---

## Build & Release
- Debug: `flutter run`
- Profile: `flutter run --profile`
- Release APK: `flutter build apk --release --dart-define=ENV=prod`
- Release AAB: `flutter build appbundle --release --dart-define=ENV=prod`
- iOS: `flutter build ipa --release --dart-define=ENV=prod`
- Run `flutter analyze` and fix all issues before any build

---

## Agent Roles (for multi-agent workflows)

### Agent: ui-agent
Responsible for: `features/*/presentation/`, `shared/widgets/`, `app/theme/`
- Creates screens, widgets, navigation
- Must not contain business logic
- Calls into providers only via `ref.watch` / `ref.read`

### Agent: logic-agent
Responsible for: `features/*/domain/`, `features/*/data/`, `core/services/`, `shared/models/`
- Creates repositories, use cases, data sources, Freezed models
- No Flutter widgets — pure Dart only where possible
- Owns all Firebase and AI service integrations

### Agent: android-agent
Responsible for: `android/`, `AndroidManifest.xml`, `build.gradle`, Proguard rules
- Manages permissions, Gradle dependencies, signing configs
- Validates SDK versions and Google Services config
- Reviews all changes to Android-specific files

### Agent: ios-agent
Responsible for: `ios/`, `Info.plist`, `Podfile`, `AppDelegate.swift`, entitlements, `GoogleService-Info.plist`
- Manages privacy usage description strings, capabilities, and entitlements
- Validates deployment target (iOS 17.0) and bundle identifier
- Reviews all changes to iOS-specific files
- Ensures App Store privacy manifest requirements are met

---

## Pre-commit Checklist (enforced by hooks)
1. `flutter analyze` — zero errors, zero warnings
2. `flutter test` — all tests pass
3. No `print()` statements in production code (use `debugPrint` or a logger)
4. No hardcoded strings visible to users (use `l10n` / constants)
5. Android: no new permissions without a comment justification
