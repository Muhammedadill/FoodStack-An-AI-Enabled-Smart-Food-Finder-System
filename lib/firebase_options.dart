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

  // TODO: IMPORTANT! Replace the 'appId' and 'apiKey' values below with the
  // actual Web App details found in your Firebase Console (Project Settings > General > Your Apps > Web App)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY_HERE', // TODO: Add your Web API key
    appId:
        'YOUR_WEB_APP_ID_HERE', // TODO: Add your Web App ID (e.g., 1:1011189390736:web:...)
    messagingSenderId: '1011189390736',
    projectId: 'foodstack-bce2a',
    authDomain: 'foodstack-bce2a.firebaseapp.com',
    storageBucket: 'foodstack-bce2a.firebasestorage.app',
    measurementId: 'YOUR_WEB_MEASUREMENT_ID_HERE', // Optional
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANA8oE9yX9ov1oM3zmqI4FWn95XDlvTzo',
    appId: '1:1011189390736:android:7fb9b3ba4a264eb973e715',
    messagingSenderId: '1011189390736',
    projectId: 'foodstack-bce2a',
    storageBucket: 'foodstack-bce2a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY_HERE',
    appId: '1:1011189390736:ios:YOUR_IOS_APP_ID_HERE',
    messagingSenderId: '1011189390736',
    projectId: 'foodstack-bce2a',
    storageBucket: 'foodstack-bce2a.firebasestorage.app',
    iosBundleId: 'com.example.foodReelApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY_HERE',
    appId: '1:1011189390736:ios:YOUR_MACOS_APP_ID_HERE',
    messagingSenderId: '1011189390736',
    projectId: 'foodstack-bce2a',
    storageBucket: 'foodstack-bce2a.firebasestorage.app',
    iosBundleId: 'com.example.foodReelApp',
  );
}
