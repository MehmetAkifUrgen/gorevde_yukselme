import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling Google Sign-In authentication
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  
  GoogleSignInService._internal() {
    _googleSignIn = GoogleSignIn(
      clientId: '933845628166-4rt8461pls7smu34a77bft67767uhkff.apps.googleusercontent.com', // iOS client ID
      serverClientId: '933845628166-22vb551ktpt93jdu4pj1q2jh5m1562gf.apps.googleusercontent.com', // Web client ID
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
      print('[GoogleSignInService] Starting Google Sign-In process...');
      
      // Trigger the authentication flow with timeout
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('[GoogleSignInService] Sign-in timed out');
          return null; // Return null instead of throwing exception
        },
      );
      
      if (googleUser == null) {
        print('[GoogleSignInService] User canceled the sign-in or timed out');
        return null;
      }

      print('[GoogleSignInService] Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request with timeout
      final GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print('[GoogleSignInService] Authentication timed out');
            throw Exception('Google authentication timed out');
          },
        );
      } catch (e) {
        print('[GoogleSignInService] Authentication failed: $e');
        await _crashlytics?.recordError(
          e,
          null,
          fatal: false,
          information: ['Google authentication failed'],
        );
        return null; // Return null instead of propagating the error
      }
      
      print('[GoogleSignInService] Google auth obtained');
      
      // Validate tokens - handle missing tokens gracefully
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        print('[GoogleSignInService] Both access token and ID token are missing');
        await _crashlytics?.log('Google authentication tokens are missing');
        return null; // Return null instead of throwing exception
      }

      // Create a new credential - use null-safe access
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      print('[GoogleSignInService] Credential created, signing in with Firebase...');

      // Sign in to Firebase with the Google credential with timeout
      try {
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential).timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            print('[GoogleSignInService] Firebase sign-in timed out');
            throw Exception('Firebase sign-in timed out');
          },
        );
        
        print('[GoogleSignInService] Firebase sign-in successful');
        print('[GoogleSignInService] Firebase user: ${userCredential.user?.email}');
        
        return userCredential;
      } catch (e) {
        print('[GoogleSignInService] Firebase sign-in failed: $e');
        await _crashlytics?.recordError(
          e,
          null,
          fatal: false,
          information: ['Firebase sign-in with Google credential failed'],
        );
        return null; // Return null instead of propagating the error
      }
    } catch (error, stackTrace) {
      print('[GoogleSignInService] Exception occurred: $error');
      print('[GoogleSignInService] Exception type: ${error.runtimeType}');
      
      // Record error to Crashlytics
      await _crashlytics?.recordError(
        error,
        stackTrace,
        fatal: false,
        information: ['Google Sign-In failed'],
      );
      
      // Don't rethrow, return null instead to prevent crashes
      return null;
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