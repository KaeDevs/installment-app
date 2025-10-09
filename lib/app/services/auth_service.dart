import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// AuthService handles Firebase Authentication (web-focused Google Sign-In).
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _initializing = true;
  bool _guestMode = false;
  // Sample guest metadata
  final Map<String, String> _guestProfile = {
    'email': 'guest@example.com',
    'displayName': 'Guest User',
  };

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
  bool get isGuest => _guestMode && _currentUser == null;
  String? get displayEmail => isGuest ? _guestProfile['email'] : _currentUser?.email;
  String? get displayName => isGuest ? _guestProfile['displayName'] : _currentUser?.displayName;

  Future<void> signInWithGoogleWeb() async {
    // For web, use signInWithPopup
    final provider = GoogleAuthProvider();
    await _auth.signInWithPopup(provider);
  }

  Future<void> signOut() async {
    try {
      // Proactively sign out and let listeners detach remote
      await _auth.signOut();
    } catch (_) {
      // Swallow to avoid surfacing during race conditions
    } finally {
      _guestMode = false;
      notifyListeners();
    }
  }

  /// Enable guest mode (no Firebase user). Used for testing / offline demo.
  void continueAsGuest() {
    _guestMode = true;
    _initializing = false;
    notifyListeners();
  }
}
