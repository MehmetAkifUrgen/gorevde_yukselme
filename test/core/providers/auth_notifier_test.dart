import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gorevde_yukselme/core/providers/auth_providers.dart';
import 'package:gorevde_yukselme/core/services/auth_service.dart';
import 'package:gorevde_yukselme/core/services/firestore_service.dart';

import 'auth_notifier_test.mocks.dart';

@GenerateMocks([AuthService, FirestoreService, firebase_auth.User, firebase_auth.UserCredential])
void main() {
  group('AuthNotifier', () {
    test('should sign in user successfully', () async {
      // Arrange
      final mockAuthService = MockAuthService();
      final mockFirestoreService = MockFirestoreService();
      final mockUser = MockUser();
      final mockUserCredential = MockUserCredential();

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);
      when(mockAuthService.saveUserSession()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          firestoreServiceProvider.overrideWithValue(mockFirestoreService),
        ],
      );

      final authNotifier = container.read(authNotifierProvider.notifier);

      // Act
      await authNotifier.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      verify(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
      verify(mockAuthService.saveUserSession()).called(1);

      container.dispose();
    });

    test('should handle sign in error', () async {
      // Arrange
      final mockAuthService = MockAuthService();
      final mockFirestoreService = MockFirestoreService();
      final mockUser = MockUser();
      final mockUserCredential = MockUserCredential();
      final authStateController = StreamController<firebase_auth.User?>();
      
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => authStateController.stream);
      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Sign in failed'));

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          firestoreServiceProvider.overrideWithValue(mockFirestoreService),
        ],
      );

      final authNotifier = container.read(authNotifierProvider.notifier);

      // Act
      await authNotifier.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      final state = authNotifier.state;
      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('Sign in failed'));
      
      // Clean up
      await authStateController.close();
    });

    test('should create user successfully', () async {
      // Arrange
      final mockAuthService = MockAuthService();
      final mockFirestoreService = MockFirestoreService();
      final mockUser = MockUser();
      final mockUserCredential = MockUserCredential();

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(null));
      when(mockAuthService.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);
      when(mockAuthService.updateUserProfile(displayName: anyNamed('displayName')))
          .thenAnswer((_) async {});
      when(mockFirestoreService.createUserProfile(
        userId: anyNamed('userId'),
        userData: anyNamed('userData'),
      )).thenAnswer((_) async {});
      when(mockAuthService.sendEmailVerification(user: anyNamed('user')))
          .thenAnswer((_) async {});
      when(mockAuthService.saveUserSession()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          firestoreServiceProvider.overrideWithValue(mockFirestoreService),
        ],
      );

      final authNotifier = container.read(authNotifierProvider.notifier);

      // Act
      await authNotifier.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      // Assert
      verify(mockAuthService.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
      verify(mockAuthService.updateUserProfile(displayName: anyNamed('displayName'))).called(1);
      verify(mockFirestoreService.createUserProfile(
        userId: anyNamed('userId'),
        userData: anyNamed('userData'),
      )).called(1);
      verify(mockAuthService.sendEmailVerification(user: anyNamed('user'))).called(1);

      container.dispose();
    });

    test('should sign out successfully', () async {
      // Arrange
      final mockAuthService = MockAuthService();
      final mockFirestoreService = MockFirestoreService();

      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(null));
      when(mockAuthService.signOut()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          firestoreServiceProvider.overrideWithValue(mockFirestoreService),
        ],
      );

      final authNotifier = container.read(authNotifierProvider.notifier);

      // Act
      await authNotifier.signOut();

      // Assert
      verify(mockAuthService.signOut()).called(1);

      container.dispose();
    });

    test('should delete account successfully', () async {
      // Arrange
      final mockAuthService = MockAuthService();
      final mockFirestoreService = MockFirestoreService();
      final mockUser = MockUser();

      when(mockUser.uid).thenReturn('test-uid');
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockFirestoreService.deleteAllUserData(userId: anyNamed('userId')))
          .thenAnswer((_) async {});
      when(mockAuthService.deleteAccount()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          firestoreServiceProvider.overrideWithValue(mockFirestoreService),
        ],
      );

      final authNotifier = container.read(authNotifierProvider.notifier);

      // Act
      await authNotifier.deleteAccount();

      // Assert
      verify(mockFirestoreService.deleteAllUserData(userId: 'test-uid')).called(1);
      verify(mockAuthService.deleteAccount()).called(1);

      container.dispose();
    });

    test('should handle delete account error when user is null', () async {
      // Arrange
      final mockAuthService = MockAuthService();
      final mockFirestoreService = MockFirestoreService();

      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          firestoreServiceProvider.overrideWithValue(mockFirestoreService),
        ],
      );

      final authNotifier = container.read(authNotifierProvider.notifier);

      // Act
      await authNotifier.deleteAccount();

      // Assert
      final state = authNotifier.state;
      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('No user is currently signed in'));

      container.dispose();
    });

    test('should handle delete account error during deletion', () async {
      // Arrange
      final mockAuthService = MockAuthService();
      final mockFirestoreService = MockFirestoreService();
      final mockUser = MockUser();
      final exception = Exception('Delete failed');

      when(mockUser.uid).thenReturn('test-uid');
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockFirestoreService.deleteAllUserData(userId: anyNamed('userId')))
          .thenThrow(exception);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          firestoreServiceProvider.overrideWithValue(mockFirestoreService),
        ],
      );

      final authNotifier = container.read(authNotifierProvider.notifier);

      // Act
      await authNotifier.deleteAccount();

      // Assert
      final state = authNotifier.state;
      expect(state.hasError, isTrue);
      expect(state.error, equals(exception));

      container.dispose();
    });
  });
}