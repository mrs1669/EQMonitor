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
    apiKey: 'AIzaSyBkDpYc8eF_zrLEWPufW0O2A1TvA-gBMa0',
    appId: '1:179553945248:android:31d2c3e4dcc608f66fabc5',
    messagingSenderId: '179553945248',
    projectId: 'eqmonitor-main',
    storageBucket: 'eqmonitor-main.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARNQCNBeDoGYCzW8iQK_puUgx8IEu33tc',
    appId: '1:179553945248:ios:c9225a33990bccd36fabc5',
    messagingSenderId: '179553945248',
    projectId: 'eqmonitor-main',
    storageBucket: 'eqmonitor-main.appspot.com',
    androidClientId: '179553945248-gnhkjhr4feqsv308rf3dlcber84o647i.apps.googleusercontent.com',
    iosClientId: '179553945248-l0p6vhl8ujr8a6no8irbio8b0jv8ptjo.apps.googleusercontent.com',
    iosBundleId: 'com.yumnumm.eqmonitor',
  );
}