Build or run the AI Workout Tracker Flutter app.

## Build Task

**Arguments:** $ARGUMENTS

### Pre-build checks (always run first)
```bash
flutter analyze --no-pub          # must be zero errors
flutter test                      # must be all green
dart run build_runner build --delete-conflicting-outputs  # regenerate code if needed
```

### Run commands
```bash
# Development (hot reload)
flutter run

# Specific device
flutter run -d <device-id>

# Profile mode (performance testing)
flutter run --profile
```

### Android build commands
```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (sideload / direct install)
flutter build apk --release --dart-define=ENV=prod --obfuscate --split-debug-info=build/debug-info/

# Release AAB (for Play Store)
flutter build appbundle --release --dart-define=ENV=prod --obfuscate --split-debug-info=build/debug-info/

# Split APKs by ABI (smaller download)
flutter build apk --split-per-abi --release --dart-define=ENV=prod
```

### iOS build commands
```bash
# Debug
flutter build ios --debug --no-codesign

# Release IPA
flutter build ipa --release --dart-define=ENV=prod
```

### Release checklist
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — all passing
- [ ] `--dart-define=ENV=prod` included
- [ ] `--obfuscate --split-debug-info=build/debug-info/` included for release builds
- [ ] `google-services.json` is present and NOT committed to git
- [ ] Version and build number bumped in `pubspec.yaml`
- [ ] Android `signingConfig` points to a valid keystore (not debug keystore for Play Store)
- [ ] `minSdkVersion 26`, `targetSdkVersion 34` verified in `build.gradle`

### Artifact locations
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- IPA: `build/ios/ipa/*.ipa`
