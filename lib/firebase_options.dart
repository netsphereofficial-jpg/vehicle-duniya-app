import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration options for Vehicle Duniya Mobile App
///
/// NOTE: Run `flutterfire configure` to generate proper Firebase options
/// for Android and iOS platforms with your Firebase project.
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

  // Web configuration (same as admin panel - shared Firebase project)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCCRhwBqUXdSoJXvqwALteoVRQlD7la_a0',
    appId: '1:984534433660:web:4ac0dfdc9f7dbba764eef9',
    messagingSenderId: '984534433660',
    projectId: 'vehicle-duniya-198e5',
    authDomain: 'vehicle-duniya-198e5.firebaseapp.com',
    storageBucket: 'vehicle-duniya-198e5.firebasestorage.app',
    measurementId: 'G-4NSY02XRM2',
  );

  // Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxcaVHZ7hwdqRMAPCBuJGoeyjJcw8e_bw',
    appId: '1:984534433660:android:27ff93d5c99ba13a64eef9',
    messagingSenderId: '984534433660',
    projectId: 'vehicle-duniya-198e5',
    storageBucket: 'vehicle-duniya-198e5.firebasestorage.app',
  );

  // iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDGA1L8OeEOW1mg_vyLvsQvnpYwxLd1YlI',
    appId: '1:984534433660:ios:75ff9c84055bcc1a64eef9',
    messagingSenderId: '984534433660',
    projectId: 'vehicle-duniya-198e5',
    storageBucket: 'vehicle-duniya-198e5.firebasestorage.app',
    iosBundleId: 'com.vehicleduniya.vehicleDuniya',
  );
}
