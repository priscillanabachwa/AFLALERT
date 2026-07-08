import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // 1. Instantiate the single shared reference to Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. Real-time broadcast stream tracking if a user session is active, expired, or logged out
  Stream<User?> get userStream => _auth.authStateChanges();

  // 3. Get the current logged-in user profile attributes instantly
  User? get currentUser => _auth.currentUser;

  /// Registers a brand new user using Email and Password.
  /// Returns a [User] object upon success, or a descriptive [String] error message if it fails.
  Future<dynamic> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user; // Success! Returns the authenticated Firebase User object
    } on FirebaseAuthException catch (e) {
      // Return custom user-friendly text based on what failed inside Firebase rules
      if (e.code == 'weak-password') {
        return 'The password provided is too weak. Must be at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email address.';
      } else if (e.code == 'invalid-email') {
        return 'The email format entered is completely invalid.';
      }
      return e.message ?? 'An unknown authentication error occurred.';
    } catch (genericError) {
      return 'Network connection failed. Please try again.';
    }
  }

  /// Logs in an existing user profile record.
  /// Returns a [User] object upon success, or a descriptive [String] error message if it fails.
  Future<dynamic> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Invalid email address or password confirmation.';
      } else if (e.code == 'user-disabled') {
        return 'This account user has been disabled by administrators.';
      }
      return e.message ?? 'An unknown login error occurred.';
    } catch (genericError) {
      return 'Network connection failed. Please try again.';
    }
  }

  /// Completely clears out the local security session token data cache
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('AuthService: User successfully logged out.');
    } catch (e) {
      debugPrint('AuthService Error during logout: $e');
    }
  }
}