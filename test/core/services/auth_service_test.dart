import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gorevde_yukselme/core/services/auth_service.dart';
import 'package:gorevde_yukselme/core/services/google_signin_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  GoogleSignInService,
])
void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignInService mockGoogleSignInService;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignInService = MockGoogleSignInService();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      
      // Create AuthService with mocked dependencies
      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        googleSignInService: mockGoogleSignInService,
      );
    });

    group('currentUser', () {
      test('should return current user when authenticated', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        
        // Act & Assert
        expect(authService.currentUser, equals(mockUser));
      });

      test('should return null when not authenticated', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);
        
        // Act & Assert
        expect(authService.currentUser, isNull);
      });
    });

    group('signInWithEmailAndPassword', () {
      const String testEmail = 'test@example.com';
      const String testPassword = 'password123';

      test('should return UserCredential on successful sign in', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authService.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).called(1);
      });

      test('should throw FirebaseAuthException on invalid credentials', () async {
        // Arrange
        final exception = FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for that email.',
        );
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('should handle empty email', () async {
        // Arrange
        final exception = FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is badly formatted.',
        );
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: '',
          password: testPassword,
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: '',
            password: testPassword,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('should handle empty password', () async {
        // Arrange
        final exception = FirebaseAuthException(
          code: 'wrong-password',
          message: 'The password is invalid.',
        );
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: '',
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: testEmail,
            password: '',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('createUserWithEmailAndPassword', () {
      const String testEmail = 'newuser@example.com';
      const String testPassword = 'password123';

      test('should return UserCredential on successful registration', () async {
        // Arrange
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authService.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).called(1);
      });

      test('should throw FirebaseAuthException on weak password', () async {
        // Arrange
        final exception = FirebaseAuthException(
          code: 'weak-password',
          message: 'The password provided is too weak.',
        );
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('should throw FirebaseAuthException on email already in use', () async {
        // Arrange
        final exception = FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The account already exists for that email.',
        );
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('signInWithGoogle', () {
      test('should return UserCredential on successful Google sign in', () async {
        // Arrange
        when(mockGoogleSignInService.signInWithGoogle())
            .thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockGoogleSignInService.signInWithGoogle()).called(1);
      });

      test('should return null when user cancels Google sign in', () async {
        // Arrange
        when(mockGoogleSignInService.signInWithGoogle())
            .thenAnswer((_) async => null);

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, isNull);
      });

      test('should throw exception on Google sign in error', () async {
        // Arrange
        final exception = Exception('Google sign in failed');
        when(mockGoogleSignInService.signInWithGoogle()).thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.signInWithGoogle(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('sendPasswordResetEmail', () {
      const String testEmail = 'test@example.com';

      test('should send password reset email successfully', () async {
        // Arrange
        when(mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .thenAnswer((_) async {});

        // Act
        await authService.sendPasswordResetEmail(email: testEmail);

        // Assert
        verify(mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .called(1);
      });

      test('should throw FirebaseAuthException on invalid email', () async {
        // Arrange
        final exception = FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for that email.',
        );
        when(mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.sendPasswordResetEmail(email: testEmail),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('signOut', () {
      test('should sign out successfully', () async {
        // Arrange
        when(mockGoogleSignInService.signOut()).thenAnswer((_) async {});

        // Act
        await authService.signOut();

        // Assert
        verify(mockGoogleSignInService.signOut()).called(1);
      });

      test('should handle sign out error', () async {
        // Arrange
        final exception = Exception('Sign out failed');
        when(mockGoogleSignInService.signOut()).thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.signOut(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteAccount', () {
      test('should delete account successfully', () async {
        // Arrange
        when(mockUser.delete()).thenAnswer((_) async {});
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        await authService.deleteAccount();

        // Assert
        verify(mockUser.delete()).called(1);
      });

      test('should throw exception when no user is signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => authService.deleteAccount(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateUserProfile', () {
      const String testDisplayName = 'Test User';
      const String testPhotoURL = 'https://example.com/photo.jpg';

      test('should update user profile successfully', () async {
        // Arrange
        when(mockUser.updateDisplayName(testDisplayName))
            .thenAnswer((_) async {});
        when(mockUser.updatePhotoURL(testPhotoURL)).thenAnswer((_) async {});
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        await authService.updateUserProfile(
          displayName: testDisplayName,
          photoURL: testPhotoURL,
        );

        // Assert
        verify(mockUser.updateDisplayName(testDisplayName)).called(1);
        verify(mockUser.updatePhotoURL(testPhotoURL)).called(1);
      });

      test('should throw exception when no user is signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => authService.updateUserProfile(displayName: testDisplayName),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('reloadUser', () {
      test('should reload user successfully', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.reload()).thenAnswer((_) async {});
        when(mockUser.emailVerified).thenReturn(true);

        // Act
        await authService.reloadUser();

        // Assert
        verify(mockUser.reload()).called(1);
        verify(mockFirebaseAuth.currentUser).called(2);
      });

      test('should throw exception when no user is signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => authService.reloadUser(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle reload error', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        final exception = FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Network error occurred.',
        );
        when(mockUser.reload()).thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.reloadUser(),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('sendEmailVerification', () {
      test('should send email verification successfully', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.sendEmailVerification()).thenAnswer((_) async {});
        when(mockUser.email).thenReturn('test@example.com');

        // Act
        await authService.sendEmailVerification();

        // Assert
        verify(mockUser.sendEmailVerification()).called(1);
      });

      test('should throw exception when no user is signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => authService.sendEmailVerification(),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when email is already verified', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(true);
        when(mockUser.email).thenReturn('test@example.com');

        // Act & Assert
        expect(
          () => authService.sendEmailVerification(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle too-many-requests error', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.email).thenReturn('test@example.com');
        final exception = FirebaseAuthException(
          code: 'too-many-requests',
          message: 'Too many requests. Try again later.',
        );
        when(mockUser.sendEmailVerification()).thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.sendEmailVerification(),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('isEmailVerified', () {
      test('should return true when email is verified', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(true);

        // Act
        final result = authService.isEmailVerified;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when email is not verified', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(false);

        // Act
        final result = authService.isEmailVerified;

        // Assert
        expect(result, isFalse);
      });

      test('should return false when no user is signed in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = authService.isEmailVerified;

        // Assert
        expect(result, isFalse);
      });
    });

    group('isSignedIn', () {
      test('should return true when user is signed in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = authService.isSignedIn;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when no user is signed in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = authService.isSignedIn;

        // Assert
        expect(result, isFalse);
      });
    });

    group('authStateChanges', () {
      test('should return Firebase auth state changes stream', () {
        // Arrange
        final mockStream = Stream<User?>.fromIterable([mockUser, null]);
        when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => mockStream);

        // Act
        final result = authService.authStateChanges;

        // Assert
        expect(result, isA<Stream<User?>>());
        verify(mockFirebaseAuth.authStateChanges()).called(1);
      });
    });
  });
}