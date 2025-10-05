// Placeholder for Firebase options. Replace with actual generated file from FlutterFire CLI.
// Run: flutterfire configure --project=<your-firebase-project-id>
// This file is required for Firebase.initializeApp.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
         apiKey: "AIzaSyACkT4fa0RRF-9hVgtUk_aoJYDUKVgMfU0",
  authDomain: "instalment-web-app.firebaseapp.com",
  projectId: "instalment-web-app",
  storageBucket: "instalment-web-app.firebasestorage.app",
  messagingSenderId: "859258660545",
  appId: "1:859258660545:web:6d5203da6794703b12d640"
      );
    }
    throw UnsupportedError('DefaultFirebaseOptions only configured for web.');
  }
}
