import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'google_signin_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignInService _googleSignInService;
  final FirebaseCrashlytics? _crashlytics;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignInService? googleSignInService,
    FirebaseCrashlytics? crashlytics,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignInService = googleSignInService ?? GoogleSignInService(),
        _crashlytics = crashlytics;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Email sign in failed'],
      );
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Email registration failed'],
      );
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      return await _googleSignInService.signInWithGoogle();
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Google sign in failed'],
      );
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Password reset failed'],
      );
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Profile update failed'],
      );
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignInService.signOut();
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Sign out failed'],
      );
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Account deletion failed'],
      );
      rethrow;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  // Get user ID
  String? get userId => _firebaseAuth.currentUser?.uid;

  // Get user email
  String? get userEmail => _firebaseAuth.currentUser?.email;

  // Get user display name
  String? get userDisplayName => _firebaseAuth.currentUser?.displayName;
}