import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyB26w6oVazFtHHybqBIrRN9oNnVdXC6M4E',
    appId: '1:1045650886415:android:e3ac5c82d1ad5253a4787a',
    messagingSenderId: '1045650886415',
    projectId: 'highrating-6ef9a',
    storageBucket: 'highrating-6ef9a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDARYyVcKfFGhGO6gbNAmcKAIdSCSEZ5g',
    appId: '1:1045650886415:ios:7fd11e123c6d8ad6a4787a',
    messagingSenderId: '1045650886415',
    projectId: 'highrating-6ef9a',
    storageBucket: 'highrating-6ef9a.appspot.com',
    iosBundleId: 'com.hm.cannaClubRating',
  );

}