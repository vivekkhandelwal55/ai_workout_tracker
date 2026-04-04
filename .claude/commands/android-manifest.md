Review or update the Android configuration for the AI Workout Tracker app.

## Android Config Checklist

**Task:** $ARGUMENTS

### Files to check / edit
- `android/app/src/main/AndroidManifest.xml`
- `android/app/build.gradle` (or `build.gradle.kts`)
- `android/build.gradle`
- `android/app/proguard-rules.pro`

### Hard rules
1. **Target SDK must be 34** (Android 14), **minSdk must be 26** (Android 8.0)
2. Every `<uses-permission>` entry MUST have an XML comment above it:
   ```xml
   <!-- Required for: [exact feature that needs this permission] -->
   <uses-permission android:name="android.permission.CAMERA" />
   ```
3. Dangerous permissions (CAMERA, MICROPHONE, LOCATION, READ_MEDIA_*) must also be handled at runtime via `permission_handler` in Dart code
4. No API keys, secrets, or tokens hardcoded in any XML or Gradle file — use `google-services.json` (gitignored) or `--dart-define`
5. Firebase: confirm `google-services.json` is present and `.gitignore` excludes it
6. Verify `applicationId` matches the Firebase project bundle ID

### Gradle version rules
- Gradle plugin: 8.x
- Kotlin: 1.9.x+
- Java compatibility: `JavaVersion.VERSION_17`

### After any manifest/gradle change:
- Run `flutter build apk --debug` to verify the build isn't broken
- Run `flutter analyze` to catch any Dart-side issues introduced
- Check that no new lint warnings appear in `android/app/build/reports/`

### Common permission blocks for this app
```xml
<!-- Required for: AI coach voice input feature -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Required for: uploading workout progress photos -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Required for: GPS-based outdoor workout tracking -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Required for: background workout session tracking -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_HEALTH" />
```
