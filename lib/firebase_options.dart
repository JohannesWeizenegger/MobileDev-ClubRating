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
    apiKey: 'AIzaSyAnLS4q7ij271sBTWKQUNkJORT1nRPsRPw',
    appId: '1:734874580425:android:caf3420360fde62ecb2418',
    messagingSenderId: '734874580425',
    projectId: 'cannaclubrating',
    storageBucket: 'cannaclubrating.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtNyQkcLJlwZetCF1VOorANac2m0lfZKs',
    appId: '1:734874580425:ios:bd63b26e3a23431dcb2418',
    messagingSenderId: '734874580425',
    projectId: 'cannaclubrating',
    storageBucket: 'cannaclubrating.appspot.com',
    iosClientId:
        '734874580425-5g52ohl2g6krgus7olma1riafu75c6kl.apps.googleusercontent.com',
    iosBundleId: 'com.hm.cannaClubRating',
  );
}
