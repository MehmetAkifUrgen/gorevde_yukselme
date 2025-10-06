import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'google_signin_service.dart';
import 'apple_signin_service.dart';
import 'session_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignInService _googleSignInService;
  final AppleSignInService _appleSignInService;
  final FirebaseCrashlytics? _crashlytics;
  final SessionService? _sessionService;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignInService? googleSignInService,
    AppleSignInService? appleSignInService,
    FirebaseCrashlytics? crashlytics,
    SessionService? sessionService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignInService = googleSignInService ?? GoogleSignInService(),
        _appleSignInService = appleSignInService ?? AppleSignInService(),
        _crashlytics = crashlytics,
        _sessionService = sessionService;

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

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      return await _appleSignInService.signInWithApple();
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Apple sign in failed'],
      );
      rethrow;
    }
  }

  // Check if Apple Sign-In is available
  Future<bool> isAppleSignInAvailable() async {
    try {
      return await _appleSignInService.isAvailable();
    } catch (e) {
      print('[AuthService] Error checking Apple Sign-In availability: $e');
      return false;
    }
  }

  // Check if email is registered with Google
  Future<bool> isEmailRegisteredWithGoogle({required String email}) async {
    try {
      print('[AuthService] Checking if email is registered with Google: $email');
      
      // Method 1: Check sign-in methods first
      try {
        final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
        print('[AuthService] Sign-in methods for $email: $signInMethods');
        
        if (signInMethods.contains('google.com')) {
          print('[AuthService] Email $email is registered with Google (direct method check)');
          return true;
        }
        
        if (signInMethods.contains('password')) {
          print('[AuthService] Email $email is registered with password (not Google-only)');
          return false;
        }
        
        // If no sign-in methods, email might not be registered in Firebase
        if (signInMethods.isEmpty) {
          print('[AuthService] No sign-in methods found for $email, trying alternative check');
        }
      } catch (e) {
        print('[AuthService] fetchSignInMethodsForEmail failed: $e, trying alternative method');
      }
      
      // Method 2: Try to create account with email/password
      // If email is registered with Google, this will fail with email-already-in-use
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: 'testPassword123!', // Strong password to avoid weak-password error
        );
        
        // If we reach here, email is not registered at all
        // Delete the test user we just created
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          await user.delete();
          print('[AuthService] Deleted test user for $email');
        }
        
        print('[AuthService] Email $email is NOT registered in Firebase');
        return false;
        
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('[AuthService] Email $email is already registered, checking provider type');
          
          // Method 3: Try to sign in with wrong password to determine provider
          try {
            await _firebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: 'wrongPassword123!', // Intentionally wrong password
            );
          } on FirebaseAuthException catch (signInError) {
            if (signInError.code == 'wrong-password') {
              // Email exists with password authentication (not Google-only)
              print('[AuthService] Email $email is registered with password (not Google-only)');
              return false;
            } else if (signInError.code == 'invalid-credential' || 
                      signInError.code == 'user-not-found' ||
                      signInError.code == 'user-disabled') {
              // These errors suggest the account exists but not with password auth
              // Likely a Google-only account
              print('[AuthService] Email $email appears to be Google-only account (error: ${signInError.code})');
              return true;
            } else {
              // Other errors - assume it's a Google account for safety
              print('[AuthService] Email $email - unknown sign-in error: ${signInError.code}, assuming Google');
              return true;
            }
          }
          
          // If no exception was thrown, assume Google account
          print('[AuthService] Email $email - no sign-in error, assuming Google account');
          return true;
        } else {
          // Other creation errors mean email is not registered
          print('[AuthService] Email $email is not registered (creation error: ${e.code})');
          return false;
        }
      }
      
    } catch (e) {
      print('[AuthService] Unknown error checking Google registration: $e');
      // For safety, assume it's not a Google account if we can't determine
      return false;
    }
  }

  // Debug method to test Google Sign-In for a specific email
  Future<void> debugGoogleSignInForEmail({required String email}) async {
    try {
      print('[AuthService] DEBUG: Testing Google Sign-In for $email');
      
      // Check if Google Sign-In is available
      final isAvailable = await _googleSignInService.isAvailable();
      print('[AuthService] DEBUG: Google Sign-In available: $isAvailable');
      
      if (!isAvailable) {
        print('[AuthService] DEBUG: Google Sign-In not available on this platform');
        return;
      }
      
      // Try to sign in with Google
      final result = await _googleSignInService.signInWithGoogle();
      
      if (result != null) {
        print('[AuthService] DEBUG: Google Sign-In successful');
        print('[AuthService] DEBUG: User email: ${result.user?.email}');
        print('[AuthService] DEBUG: User display name: ${result.user?.displayName}');
        
        // Check if the email matches
        if (result.user?.email == email) {
          print('[AuthService] DEBUG: ✅ Email $email IS associated with a Google account');
        } else {
          print('[AuthService] DEBUG: ❌ Signed in email (${result.user?.email}) does not match target email ($email)');
        }
        
        // Sign out after test
        await _googleSignInService.signOut();
        print('[AuthService] DEBUG: Signed out after test');
      } else {
        print('[AuthService] DEBUG: Google Sign-In returned null (user cancelled or error)');
      }
      
    } catch (e) {
      print('[AuthService] DEBUG: Error during Google Sign-In test: $e');
    }
  }

  // Check if email is already registered
  Future<bool> isEmailRegistered({required String email}) async {
    try {
      print('[AuthService] Checking if email is registered: $email');
      
      // Method 1: Try fetchSignInMethodsForEmail first
      try {
        final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
        print('[AuthService] Sign-in methods for $email: $signInMethods');
        
        // If we get sign-in methods, email is definitely registered
        if (signInMethods.isNotEmpty) {
          print('[AuthService] Email $email is registered (found sign-in methods)');
          return true;
        }
      } catch (e) {
        print('[AuthService] fetchSignInMethodsForEmail failed: $e');
      }
      
      // Method 2: Try to create account with dummy password to check if email exists
      // This is more reliable for Google-registered accounts
      print('[AuthService] Trying dummy account creation to verify email status');
      
      try {
        // Use a very weak password that will likely fail validation
        // but will still trigger email-already-in-use if email exists
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: 'test123', // Weak password
        );
        
        // If we reach here, email is not registered
        // Delete the test user we just created
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          await user.delete();
          print('[AuthService] Deleted test user for $email');
        }
        
        print('[AuthService] Email $email is NOT registered');
        return false;
        
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('[AuthService] Email $email is registered (email-already-in-use)');
          return true;
        } else if (e.code == 'weak-password') {
          // Password was weak but email is available
          // Delete the user that might have been created
          final user = _firebaseAuth.currentUser;
          if (user != null) {
            try {
              await user.delete();
              print('[AuthService] Deleted weak password test user for $email');
            } catch (deleteError) {
              print('[AuthService] Failed to delete test user: $deleteError');
            }
          }
          print('[AuthService] Email $email is NOT registered (weak password but available)');
          return false;
        } else {
          print('[AuthService] Other Firebase error during email check: ${e.code}');
          // For safety, assume email is registered
          return true;
        }
      }
      
    } on FirebaseAuthException catch (e) {
      print('[AuthService] FirebaseAuthException while checking email: ${e.code} - ${e.message}');
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Email check failed with code: ${e.code}', 'Email: $email'],
      );
      
      // If there's a specific error, handle it appropriately
      if (e.code == 'invalid-email') {
        print('[AuthService] Invalid email format');
        return false;
      }
      
      // For other errors, assume email might be registered for safety
      print('[AuthService] Unknown error, assuming email is registered for safety');
      return true;
    } catch (e) {
      print('[AuthService] Unknown error while checking email: $e');
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Email check failed with unknown error', 'Email: $email'],
      );
      
      // For safety, assume email is registered if we can't check properly
      return true;
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

  // Send email verification
  Future<void> sendEmailVerification({User? user}) async {
    try {
      final targetUser = user ?? _firebaseAuth.currentUser;
      print('[AuthService] Attempting to send email verification...');
      print('[AuthService] Target user: ${targetUser?.email}');
      print('[AuthService] Current user: ${_firebaseAuth.currentUser?.email}');
      print('[AuthService] Email verified: ${targetUser?.emailVerified}');
      
      if (targetUser == null) {
        print('[AuthService] Error: No user is currently signed in');
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user is currently signed in. Please log in first.',
        );
      }
      
      if (targetUser.emailVerified == true) {
        print('[AuthService] Email is already verified');
        throw FirebaseAuthException(
          code: 'email-already-verified',
          message: 'Email is already verified.',
        );
      }
      
      if (targetUser.emailVerified != true) {
        // Configure action code settings for better email delivery
        final actionCodeSettings = ActionCodeSettings(
          url: 'https://gorevdeyukselme-3d32f.firebaseapp.com/__/auth/action',
          handleCodeInApp: false,
          iOSBundleId: 'com.gyudsoft.apps',
          androidPackageName: 'com.gyudsoft.apps',
          androidInstallApp: false,
          androidMinimumVersion: '12',
        );
        
        // Retry mechanism for email sending
        int retryCount = 0;
        const maxRetries = 3;
        
        while (retryCount < maxRetries) {
           try {
             await targetUser.sendEmailVerification(actionCodeSettings);
             print('[AuthService] Email verification sent successfully to: ${targetUser.email}');
             break; // Success, exit retry loop
          } on FirebaseAuthException {
            retryCount++;
            if (retryCount >= maxRetries) {
              rethrow; // Max retries reached, throw the error
            }
            
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(seconds: retryCount * 2));
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Email verification failed'],
      );
      rethrow;
    }
  }

  // Check if email is verified
  bool get isEmailVerified {
    final user = _firebaseAuth.currentUser;
    final verified = user?.emailVerified ?? false;
    print('[AuthService] isEmailVerified - User: ${user?.email}, Verified: $verified');
    return verified;
  }

  // Reload user to get updated verification status
  Future<void> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      print('[AuthService] reloadUser - Current user: ${user?.email}');
      if (user != null) {
        print('[AuthService] reloadUser - Before reload: emailVerified=${user.emailVerified}');
        await user.reload();
        
        // Get fresh user instance after reload to avoid caching issues
        final freshUser = _firebaseAuth.currentUser;
        print('[AuthService] reloadUser - After reload: emailVerified=${freshUser?.emailVerified}');
        print('[AuthService] reloadUser - Fresh user verification: ${freshUser?.emailVerified}');
      } else {
        print('[AuthService] reloadUser - No current user found');
      }
    } catch (e) {
      print('[AuthService] reloadUser - Error: $e');
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['User reload failed'],
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
      await _sessionService?.clearSession();
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

  // Save user session
  Future<void> saveUserSession() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && _sessionService != null) {
        await _sessionService.saveSession(user.uid, user.email ?? '');
      }
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Session save failed'],
      );
      rethrow;
    }
  }

  // Check if valid session exists
  bool hasValidSession() {
    return _sessionService?.hasValidSession() ?? false;
  }

  // Get session data
  Map<String, dynamic>? getSessionData() {
    return _sessionService?.getSession();
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