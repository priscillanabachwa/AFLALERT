import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // 1. Instantiate the single shared reference to Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // google_sign_in v7+ uses a singleton instance rather than creating a
  // new GoogleSignIn() object yourself.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

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

  /// Signs a user in using their Google account, letting them pick any
  /// Google account currently on their device via the native account picker.
  ///
  /// Returns a [User] object upon success, [null] if the user closed the
  /// picker without choosing an account, or a descriptive [String] error
  /// message if it fails.
  Future<dynamic> signInWithGoogle() async {
    try {
      // google_sign_in v7+ requires an explicit initialize() call before
      // any sign-in attempt. It's safe to call more than once, but we only
      // need to do it the first time this service is used.
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize();
        _googleSignInInitialized = true;
      }

      // authenticate() replaces the old signIn() call and opens the native
      // Google account picker, letting the user choose any account on
      // their device.
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // v7+ only issues an idToken through this flow (accessToken now
      // lives behind a separate authorization step), which is all
      // Firebase actually needs for GoogleAuthProvider.credential.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User closed the account picker without selecting anything.
        return null;
      }
      debugPrint('AuthService Error during Google sign-in: ${e.code} - ${e.description}');
      return 'Could not sign in with Google. Please try again.';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return 'An account already exists with this email using a different sign-in method.';
      } else if (e.code == 'invalid-credential') {
        return 'Could not verify your Google account. Please try again.';
      }
      return e.message ?? 'An unknown Google sign-in error occurred.';
    } catch (genericError) {
      debugPrint('AuthService Error during Google sign-in: $genericError');
      return 'Network connection failed. Please try again.';
    }
  }

  /// Completely clears out the local security session token data cache
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Sign out from Google as well to ensure the user is fully logged out.
      // This prevents automatic re-sign-in with the last used Google account,
      // which matters for apps that allow multiple Google accounts to be used.
      await _googleSignIn.signOut();
      debugPrint('AuthService: User successfully logged out.');
    } catch (e) {
      debugPrint('AuthService Error during logout: $e');
    }
  }
}