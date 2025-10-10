import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Service for handling Apple Sign-In authentication
class AppleSignInService {
  late final FirebaseCrashlytics? _crashlytics;

  AppleSignInService({FirebaseCrashlytics? crashlytics}) {
    _crashlytics = crashlytics;
  }

  /// Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Check if running on iOS
      if (!Platform.isIOS) {
        print('[AppleSignInService] Apple Sign-In is only available on iOS');
        return null;
      }

      print('[AppleSignInService] Starting Apple Sign-In process...');
      
      // Check if Apple Sign-In is available
      final bool isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        print('[AppleSignInService] Apple Sign-In is not available on this device');
        throw Exception('Apple Sign-In is not available on this device');
      }
      
      // Request Apple ID credential with timeout
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Apple Sign-In timed out');
        },
      );

      print('[AppleSignInService] Apple credential obtained');
      print('[AppleSignInService] User ID: ${credential.userIdentifier}');
      print('[AppleSignInService] Email: ${credential.email}');

      // Validate tokens
      if (credential.identityToken == null) {
        throw Exception('Apple identity token is missing');
      }

      // Create Firebase credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      print('[AppleSignInService] Firebase credential created, signing in...');

      // Sign in to Firebase with Apple credential with timeout
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Firebase sign-in timed out');
        },
      );
      
      print('[AppleSignInService] Firebase sign-in successful');
      print('[AppleSignInService] Firebase user: ${userCredential.user?.email}');
      
      return userCredential;
    } catch (error, stackTrace) {
      print('[AppleSignInService] Error during Apple Sign-In: $error');
      print('[AppleSignInService] Error type: ${error.runtimeType}');
      
      // Record error to Crashlytics
      await _crashlytics?.recordError(
        error,
        stackTrace,
        fatal: false,
        information: ['Apple Sign-In failed'],
      );
      
      // Don't rethrow, return null instead to prevent crashes
      return null;
    }
  }

  /// Check if Apple Sign-In is available
  Future<bool> isAvailable() async {
    try {
      if (!Platform.isIOS) return false;
      
      // Check if Sign in with Apple is available on this device
      return await SignInWithApple.isAvailable();
    } catch (e) {
      print('[AppleSignInService] Error checking availability: $e');
      return false;
    }
  }
}
