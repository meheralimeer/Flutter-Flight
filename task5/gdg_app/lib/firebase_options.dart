import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for fuchsia',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAAYiL8qLWLMq6jmhsaNsL4jngKYB6oGi0',
    appId: '1:599424656512:web:linux_desktop',
    messagingSenderId: '599424656512',
    projectId: 'gdg-team-manager',
    authDomain: 'gdg-team-manager.firebaseauth.com',
    storageBucket: 'gdg-team-manager.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAYiL8qLWLMq6jmhsaNsL4jngKYB6oGi0',
    appId: '1:599424656512:android:cd63679cbbdf16ab877265',
    messagingSenderId: '599424656512',
    projectId: 'gdg-team-manager',
    storageBucket: 'gdg-team-manager.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAYiL8qLWLMq6jmhsaNsL4jngKYB6oGi0',
    appId: '1:599424656512:ios:linux_desktop',
    messagingSenderId: '599424656512',
    projectId: 'gdg-team-manager',
    storageBucket: 'gdg-team-manager.firebasestorage.app',
    iosClientId: 'linux-client-id',
    iosBundleId: 'com.gdg.gdg_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAAYiL8qLWLMq6jmhsaNsL4jngKYB6oGi0',
    appId: '1:599424656512:macos:linux_desktop',
    messagingSenderId: '599424656512',
    projectId: 'gdg-team-manager',
    storageBucket: 'gdg-team-manager.firebasestorage.app',
    iosClientId: 'linux-client-id',
    iosBundleId: 'com.gdg.gdg_app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAAYiL8qLWLMq6jmhsaNsL4jngKYB6oGi0',
    appId: '1:599424656512:windows:linux_desktop',
    messagingSenderId: '599424656512',
    projectId: 'gdg-team-manager',
    storageBucket: 'gdg-team-manager.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyAAYiL8qLWLMq6jmhsaNsL4jngKYB6oGi0',
    appId: '1:599424656512:linux:linux_desktop',
    messagingSenderId: '599424656512',
    projectId: 'gdg-team-manager',
    storageBucket: 'gdg-team-manager.firebasestorage.app',
  );
}
