import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase web options are not configured. Run flutterfire configure before building for web.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBbC7RkZXQWdGS97UbXJEqxKBCsxEXvPE',
    appId: '1:244672019672:android:6eef116c505f22b1da2bad',
    messagingSenderId: '244672019672',
    projectId: 'nutri-tracker-34aef',
    storageBucket: 'nutri-tracker-34aef.appspot.com',
  );
}
