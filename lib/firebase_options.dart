import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return web;
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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBbC7RkZXQWdGS97UbXJEqxKBCsxEXvPE',
    appId: '1:244672019672:ios:placeholder',
    messagingSenderId: '244672019672',
    projectId: 'nutri-tracker-34aef',
    storageBucket: 'nutri-tracker-34aef.appspot.com',
    iosBundleId: 'com.example.nutriTracker',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBBbC7RkZXQWdGS97UbXJEqxKBCsxEXvPE',
    appId: '1:244672019672:web:placeholder',
    messagingSenderId: '244672019672',
    projectId: 'nutri-tracker-34aef',
    authDomain: 'nutri-tracker-34aef.firebaseapp.com',
    storageBucket: 'nutri-tracker-34aef.appspot.com',
  );
}
