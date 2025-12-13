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
    apiKey: 'dummy_web_api_key',
    appId: 'dummy_web_app_id',
    messagingSenderId: 'dummy_messaging_sender_id',
    projectId: 'dummy_project_id',
    authDomain: 'dummy_auth_domain',
    storageBucket: 'dummy_storage_bucket',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'dummy_android_api_key',
    appId: 'dummy_android_app_id',
    messagingSenderId: 'dummy_messaging_sender_id',
    projectId: 'dummy_project_id',
    storageBucket: 'dummy_storage_bucket',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'dummy_ios_api_key',
    appId: 'dummy_ios_app_id',
    messagingSenderId: 'dummy_messaging_sender_id',
    projectId: 'dummy_project_id',
    storageBucket: 'dummy_storage_bucket',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'dummy_macos_api_key',
    appId: 'dummy_macos_app_id',
    messagingSenderId: 'dummy_messaging_sender_id',
    projectId: 'dummy_project_id',
    storageBucket: 'dummy_storage_bucket',
    iosBundleId: 'com.example.app',
  );
}
