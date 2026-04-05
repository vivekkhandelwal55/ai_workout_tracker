// File generated based on google-services.json and GoogleService-Info.plist
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBycXrZ9hU-2eYvB6If5ngeox5I98GZsRU',
    appId: '1:482983016651:android:94f38078beab7279bb034e',
    messagingSenderId: '482983016651',
    projectId: 'ai-workout-tracker-f52fd',
    storageBucket: 'ai-workout-tracker-f52fd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDB7C6J86V3cYUDwRZY_1-DY8j5J4gb4DE',
    appId: '1:482983016651:ios:4ad49fd43ce47b9ebb034e',
    messagingSenderId: '482983016651',
    projectId: 'ai-workout-tracker-f52fd',
    storageBucket: 'ai-workout-tracker-f52fd.firebasestorage.app',
    iosClientId: '482983016651-sqij5en43eoflju9k6t3opur9ugvuvae.apps.googleusercontent.com',
    iosBundleId: 'com.example.aiWorkoutTrackerApp',
  );
}
