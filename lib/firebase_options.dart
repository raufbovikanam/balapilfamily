// File: firebase_options.dart
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          're-run FlutterFire CLI to configure.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          're-run FlutterFire CLI to configure.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          're-run FlutterFire CLI to configure.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAL2ktHZuDFZsE6f9_T6kDS8nYs-Kbgo6Q',
    appId: '1:348518026884:android:92267e3f69fba26075fcd1',
    messagingSenderId: '348518026884',
    projectId: 'balapil-family-b4bea',
    storageBucket: 'balapil-family-b4bea.firebasestorage.app',
  );

  // iOS configuration (optional, add if you plan iOS build)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '348518026884',
    projectId: 'balapil-family-b4bea',
    storageBucket: 'balapil-family-b4bea.firebasestorage.app',
  );

  // Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAL2ktHZuDFZsE6f9_T6kDS8nYs-Kbgo6Q",
    authDomain: "balapil-family-tree-8da8c.firebaseapp.com",
    projectId: "balapil-family-tree-8da8c",
    storageBucket: "balapil-family-tree-8da8c.firebasestorage.app",
    messagingSenderId: "348518026884",
    appId: "1:348518026884:web:8daeb71af193afeb75fcd1",
    measurementId: "G-S3RTSRB93F",
  );
}
