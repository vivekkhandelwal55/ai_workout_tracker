# Native Splash Screen Setup

## Quick Start

Run these commands in order:

```bash
# 1. Get dependencies (includes flutter_native_splash)
flutter pub get

# 2. Create the splash logo placeholder
dart run setup_splash.dart

# 3. Generate native splash screens for Android and iOS
dart run flutter_native_splash:create

# 4. Regenerate the router (if app_router.g.dart needs updating)
dart run build_runner build --delete-conflicting-outputs
```

## What This Does

1. **`pubspec.yaml`** - Added `flutter_native_splash: ^2.4.0` to dev_dependencies and `assets/` folder
2. **`flutter_native_splash.yaml`** - Configuration for native splash screens
3. **`assets/splash_logo.png`** - Placeholder logo (replace with your branded logo)
4. **`lib/app/router/app_router.dart`** - Removed `_SplashScreen` widget and splash route

## Customizing the Splash

Replace `assets/splash_logo.png` with your branded logo, then re-run:
```bash
dart run flutter_native_splash:create
```

## Files Modified

- `/Users/Vivek-Khandelwal/Development/personal/ai_workout_tracker_app/pubspec.yaml`
- `/Users/Vivek-Khandelwal/Development/personal/ai_workout_tracker_app/flutter_native_splash.yaml` (new)
- `/Users/Vivek-Khandelwal/Development/personal/ai_workout_tracker_app/lib/app/router/app_router.dart`
