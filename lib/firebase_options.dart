// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyCTXpzyfhwGJIJqvG-3XZsaWl20KnkhhrE',
    appId: '1:621099587060:web:03493eda113add487e55a1',
    messagingSenderId: '621099587060',
    projectId: 'savergowes',
    authDomain: 'savergowes.firebaseapp.com',
    databaseURL: 'https://savergowes-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'savergowes.appspot.com',
    measurementId: 'G-XB9HXX07C7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCe9Y0VdtLqShidnik-gx-p_Z00Zm7feDI',
    appId: '1:621099587060:android:fc2c6987f0daf0a67e55a1',
    messagingSenderId: '621099587060',
    projectId: 'savergowes',
    databaseURL: 'https://savergowes-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'savergowes.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByZJvPF4dHze0Mto8okAeSypZTjk0ix1o',
    appId: '1:621099587060:ios:1a915411011f30257e55a1',
    messagingSenderId: '621099587060',
    projectId: 'savergowes',
    databaseURL: 'https://savergowes-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'savergowes.appspot.com',
    iosBundleId: 'com.example.savergowesser',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBBSA8KdivuZ9QXOYZkvtQDdGEpbY4BDHM',
    appId: '1:492428107682:ios:78e7ad04e4397c430edcfb',
    messagingSenderId: '492428107682',
    projectId: 'gowesser-36f23',
    databaseURL: 'https://gowesser-36f23-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gowesser-36f23.appspot.com',
    iosBundleId: 'com.example.gowesser',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDLx-xchbqcW3WBVJitgBuN5Mlv4GkSOPc',
    appId: '1:492428107682:web:4695200779eb34240edcfb',
    messagingSenderId: '492428107682',
    projectId: 'gowesser-36f23',
    authDomain: 'gowesser-36f23.firebaseapp.com',
    databaseURL: 'https://gowesser-36f23-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gowesser-36f23.appspot.com',
    measurementId: 'G-SGC3N8KTWW',
  );

}