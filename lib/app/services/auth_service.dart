import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// AuthService handles Firebase Authentication (web-focused Google Sign-In).
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _initializing = true;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      _initializing = false;
      notifyListeners();
    });
  }

  bool get isInitializing => _initializing;
  User? get user => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<void> signInWithGoogleWeb() async {
    // For web, use signInWithPopup
    final provider = GoogleAuthProvider();
    await _auth.signInWithPopup(provider);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
