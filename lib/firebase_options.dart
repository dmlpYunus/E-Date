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
    apiKey: 'AIzaSyDi_cf8ILzrqeewRGkQ4BUA0MQo0BwFy_k',
    appId: '1:565359380959:android:97f67f2178163144ef5c6a',
    messagingSenderId: '565359380959',
    projectId: 'flutterdeneme-b4a9c',
    storageBucket: 'flutterdeneme-b4a9c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_bdRf2pwP9d_VM6Bk1ny3mDS3PMVGJHQ',
    appId: '1:565359380959:ios:99dec5b913b62545ef5c6a',
    messagingSenderId: '565359380959',
    projectId: 'flutterdeneme-b4a9c',
    storageBucket: 'flutterdeneme-b4a9c.appspot.com',
    iosClientId: '565359380959-2rb75k3vrisa5tng9jmh6al3c2s70soj.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterfirebasedeneme',
  );
}
