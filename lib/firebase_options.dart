// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCMb8rmrW37XJusCPKmwY_Y3_OQFd3_q04',
    appId: '1:544115296637:web:48a75333fac3bc62526414',
    messagingSenderId: '544115296637',
    projectId: 'artisan-0108',
    authDomain: 'artisan-0108.firebaseapp.com',
    storageBucket: 'artisan-0108.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCu_ZX0u-JZ66dT5hYy8YEeLQEggKcrEtM',
    appId: '1:544115296637:android:b0850b099425b1b1526414',
    messagingSenderId: '544115296637',
    projectId: 'artisan-0108',
    storageBucket: 'artisan-0108.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsiCFJ6CxSR5hxltVwqrcqir8LL9FYYQ0',
    appId: '1:544115296637:ios:0b5c963d1f28e457526414',
    messagingSenderId: '544115296637',
    projectId: 'artisan-0108',
    storageBucket: 'artisan-0108.appspot.com',
    iosBundleId: 'com.example.artisan',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDsiCFJ6CxSR5hxltVwqrcqir8LL9FYYQ0',
    appId: '1:544115296637:ios:30d22b126cbd785e526414',
    messagingSenderId: '544115296637',
    projectId: 'artisan-0108',
    storageBucket: 'artisan-0108.appspot.com',
    iosBundleId: 'com.example.artisan.RunnerTests',
  );
}