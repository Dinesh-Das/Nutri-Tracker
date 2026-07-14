import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase is only configured for Android in this checkout. Run flutterfire configure for this platform.',
        );
      default:
        throw UnsupportedError('Firebase is not configured for this platform.');
    }
  }

  static FirebaseOptions get web {
    const apiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
    const messagingSenderId =
        String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID');
    const projectId = String.fromEnvironment('FIREBASE_WEB_PROJECT_ID');
    const authDomain = String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN');
    const storageBucket = String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET');
    const measurementId = String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID');

    if (apiKey.isEmpty ||
        appId.isEmpty ||
        messagingSenderId.isEmpty ||
        projectId.isEmpty) {
      throw UnsupportedError(
        'Firebase web options are missing. Copy '
        'config/firebase.web.example.json to config/firebase.web.json, '
        'fill in the Firebase web app values, and build with '
        '--dart-define-from-file=config/firebase.web.json.',
      );
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain.isEmpty ? null : authDomain,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
      measurementId: measurementId.isEmpty ? null : measurementId,
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBbC7RkZXQWdGS97UbXJEqxKBCsxEXvPE',
    appId: '1:244672019672:android:6eef116c505f22b1da2bad',
    messagingSenderId: '244672019672',
    projectId: 'nutri-tracker-34aef',
    storageBucket: 'nutri-tracker-34aef.appspot.com',
  );
}
