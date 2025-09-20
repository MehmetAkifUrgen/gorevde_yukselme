import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:gorevde_yukselme/core/services/google_signin_service.dart';

import 'google_signin_service_test.mocks.dart';

@GenerateMocks([
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  FirebaseAuth,
  UserCredential,
  FirebaseCrashlytics,
])
void main() {
  group('GoogleSignInService Tests', () {
    late GoogleSignInService googleSignInService;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUserCredential mockUserCredential;
    late MockFirebaseCrashlytics mockFirebaseCrashlytics;

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUserCredential = MockUserCredential();
      mockFirebaseCrashlytics = MockFirebaseCrashlytics();
      
      // Create GoogleSignInService with mocked dependencies
      googleSignInService = GoogleSignInService.test(
        googleSignIn: mockGoogleSignIn,
        firebaseAuth: mockFirebaseAuth,
        crashlytics: mockFirebaseCrashlytics,
      );
    });

    group('signInWithGoogle', () {
      test('should return UserCredential on successful sign in', () async {
        // Arrange
        const String accessToken = 'access_token';
        const String idToken = 'id_token';
        
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(mockGoogleSignInAuthentication.accessToken)
            .thenReturn(accessToken);
        when(mockGoogleSignInAuthentication.idToken)
            .thenReturn(idToken);
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await googleSignInService.signInWithGoogle();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockGoogleSignIn.signIn()).called(1);
        verify(mockGoogleSignInAccount.authentication).called(1);
        verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
      });

      test('should return null when user cancels sign in', () async {
        // Arrange
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act
        final result = await googleSignInService.signInWithGoogle();

        // Assert
        expect(result, isNull);
        verify(mockGoogleSignIn.signIn()).called(1);
        verifyNever(mockFirebaseAuth.signInWithCredential(any));
      });

      test('should throw exception when authentication fails', () async {
        // Arrange
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenThrow(Exception('Authentication failed'));

        // Act & Assert
        expect(
          () => googleSignInService.signInWithGoogle(),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when Firebase sign in fails', () async {
        // Arrange
        const String accessToken = 'access_token';
        const String idToken = 'id_token';
        
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(mockGoogleSignInAuthentication.accessToken)
            .thenReturn(accessToken);
        when(mockGoogleSignInAuthentication.idToken)
            .thenReturn(idToken);
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenThrow(FirebaseAuthException(
              code: 'account-exists-with-different-credential',
              message: 'Account exists with different credential',
            ));

        // Act & Assert
        expect(
          () => googleSignInService.signInWithGoogle(),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('should handle missing access token', () async {
        // Arrange
        const String idToken = 'id_token';
        
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(mockGoogleSignInAuthentication.accessToken)
            .thenReturn(null);
        when(mockGoogleSignInAuthentication.idToken)
            .thenReturn(idToken);
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await googleSignInService.signInWithGoogle();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
      });

      test('should handle missing id token', () async {
        // Arrange
        const String accessToken = 'access_token';
        
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(mockGoogleSignInAuthentication.accessToken)
            .thenReturn(accessToken);
        when(mockGoogleSignInAuthentication.idToken)
            .thenReturn(null);
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await googleSignInService.signInWithGoogle();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
      });
    });

    group('signOut', () {
      test('should sign out from both Google and Firebase successfully', () async {
        // Arrange
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        await googleSignInService.signOut();

        // Assert
        verify(mockGoogleSignIn.signOut()).called(1);
        verify(mockFirebaseAuth.signOut()).called(1);
      });

      test('should handle Google sign out error', () async {
        // Arrange
        when(mockGoogleSignIn.signOut())
            .thenThrow(Exception('Google sign out failed'));
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act & Assert
        expect(
          () => googleSignInService.signOut(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle Firebase sign out error', () async {
        // Arrange
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(mockFirebaseAuth.signOut())
            .thenThrow(FirebaseAuthException(
              code: 'network-request-failed',
              message: 'Network error',
            ));

        // Act & Assert
        expect(
          () => googleSignInService.signOut(),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('signInSilently', () {
      test('should return GoogleSignInAccount on successful silent sign in', () async {
        // Arrange
        when(mockGoogleSignIn.signInSilently())
            .thenAnswer((_) async => mockGoogleSignInAccount);

        // Act
        final result = await googleSignInService.signInSilently();

        // Assert
        expect(result, equals(mockGoogleSignInAccount));
        verify(mockGoogleSignIn.signInSilently()).called(1);
      });

      test('should return null when no previous sign in', () async {
        // Arrange
        when(mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);

        // Act
        final result = await googleSignInService.signInSilently();

        // Assert
        expect(result, isNull);
        verify(mockGoogleSignIn.signInSilently()).called(1);
      });

      test('should return null when silent sign in fails', () async {
        // Arrange
        when(mockGoogleSignIn.signInSilently())
            .thenThrow(Exception('Silent sign in failed'));

        // Act
        final result = await googleSignInService.signInSilently();

        // Assert
        expect(result, isNull);
        verify(mockFirebaseCrashlytics.recordError(any, any, reason: anyNamed('reason'))).called(1);
      });
    });

    group('isSignedIn', () {
      test('should return true when user is signed in', () {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(mockGoogleSignInAccount);

        // Act
        final result = googleSignInService.isSignedIn;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when user is not signed in', () {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(null);

        // Act
        final result = googleSignInService.isSignedIn;

        // Assert
        expect(result, isFalse);
      });
    });

    group('currentUser', () {
      test('should return current Google user when signed in', () {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(mockGoogleSignInAccount);

        // Act
        final result = googleSignInService.currentUser;

        // Assert
        expect(result, equals(mockGoogleSignInAccount));
      });

      test('should return null when no user is signed in', () {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(null);

        // Act
        final result = googleSignInService.currentUser;

        // Assert
        expect(result, isNull);
      });
    });
  });
}