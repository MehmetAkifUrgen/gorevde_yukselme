import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling Google Sign-In authentication
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  
  GoogleSignInService._internal() {
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    );
    _firebaseAuth = FirebaseAuth.instance;
    _crashlytics = FirebaseCrashlytics.instance;
  }

  // Constructor for testing with dependency injection
  GoogleSignInService.test({
    required GoogleSignIn googleSignIn,
    required FirebaseAuth firebaseAuth,
    FirebaseCrashlytics? crashlytics,
  }) : _googleSignIn = googleSignIn,
       _firebaseAuth = firebaseAuth,
       _crashlytics = crashlytics;

  late final GoogleSignIn _googleSignIn;
  late final FirebaseAuth _firebaseAuth;
  late final FirebaseCrashlytics? _crashlytics;

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      return userCredential;
    } catch (error, stackTrace) {
      await _crashlytics?.recordError(
        error,
        stackTrace,
        reason: 'Google Sign-In failed',
      );
      rethrow;
    }
  }

  /// Sign out from Google and Firebase
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
    } catch (error, stackTrace) {
      await _crashlytics?.recordError(
        error,
        stackTrace,
        reason: 'Google Sign-Out failed',
      );
      rethrow;
    }
  }

  /// Check if user is currently signed in with Google
  bool get isSignedIn => _googleSignIn.currentUser != null;

  /// Get current Google user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Disconnect Google account (revoke access)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error, stackTrace) {
      await _crashlytics?.recordError(
        error,
        stackTrace,
        reason: 'Google disconnect failed',
      );
      rethrow;
    }
  }

  /// Silent sign-in (if user was previously signed in)
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (error, stackTrace) {
      await _crashlytics?.recordError(
        error,
        stackTrace,
        reason: 'Google silent sign-in failed',
      );
      return null;
    }
  }

  /// Check if Google Play Services are available
  Future<bool> isAvailable() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      return false;
    }
  }
}