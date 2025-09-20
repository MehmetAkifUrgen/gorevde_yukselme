import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/google_signin_service.dart';
import '../models/user_model.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final googleSignInService = ref.watch(googleSignInServiceProvider);
  return AuthService(
    googleSignInService: googleSignInService,
    crashlytics: FirebaseCrashlytics.instance,
  );
});

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Google Sign-In Service Provider
final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService();
});

// Firebase Auth State Provider
final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current Firebase User Provider
final currentFirebaseUserProvider = Provider<firebase_auth.User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Authentication State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<firebase_auth.User?>> {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthNotifier(this._authService, this._firestoreService) 
      : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen(
      (user) {
        state = AsyncValue.data(user);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential?.user != null) {
        state = AsyncValue.data(credential!.user);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential?.user != null) {
        // Update display name
        await _authService.updateUserProfile(displayName: displayName);
        
        // Create user profile in Firestore
        await _firestoreService.createUserProfile(
          userId: credential!.user!.uid,
          userData: {
            'email': email,
            'displayName': displayName,
            'profession': 'student', // Default profession
            'notificationsEnabled': true,
            'questionsAnsweredToday': 0,
            'totalQuestionsAnswered': 0,
            'correctAnswers': 0,
            'incorrectAnswers': 0,
            'averageScore': 0.0,
            'studyStreak': 0,
            'lastActiveDate': DateTime.now().toIso8601String(),
          },
        );
        
        state = AsyncValue.data(credential.user);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential?.user != null) {
        // Check if user profile exists, if not create one
        final userDoc = await _firestoreService.getUserProfile(
          userId: credential!.user!.uid,
        );
        
        if (!userDoc.exists) {
          await _firestoreService.createUserProfile(
            userId: credential.user!.uid,
            userData: {
              'email': credential.user!.email ?? '',
              'displayName': credential.user!.displayName ?? '',
              'photoURL': credential.user!.photoURL ?? '',
              'profession': 'student', // Default profession
              'notificationsEnabled': true,
              'questionsAnsweredToday': 0,
              'totalQuestionsAnswered': 0,
              'correctAnswers': 0,
              'incorrectAnswers': 0,
              'averageScore': 0.0,
              'studyStreak': 0,
              'lastActiveDate': DateTime.now().toIso8601String(),
            },
          );
        }
        
        state = AsyncValue.data(credential.user);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      // Update state with reloaded user
      final user = _authService.currentUser;
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  bool get isEmailVerified => _authService.isEmailVerified;

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final userId = _authService.userId;
      if (userId != null) {
        // Delete user data from Firestore first
        await _firestoreService.deleteDocument(
          collection: 'users',
          documentId: userId,
        );
        
        // Delete Firebase Auth account
        await _authService.deleteAccount();
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Getters for convenience
  bool get isSignedIn => state.value != null;
  String? get userId => state.value?.uid;
  String? get userEmail => state.value?.email;
  String? get userDisplayName => state.value?.displayName;
  String? get userPhotoURL => state.value?.photoURL;
}

// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<firebase_auth.User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return AuthNotifier(authService, firestoreService);
});

// User Profile Provider (from Firestore)
final userProfileProvider = StreamProvider.family<User?, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserProfileStream(userId: userId).map((doc) {
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return User(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        profession: UserProfession.values.firstWhere(
          (p) => p.toString().split('.').last == (data['profession'] ?? 'electricalElectronicEngineer'),
          orElse: () => UserProfession.electricalElectronicEngineer,
        ),
        subscriptionStatus: SubscriptionStatus.values.firstWhere(
          (s) => s.toString().split('.').last == (data['subscriptionStatus'] ?? 'free'),
          orElse: () => SubscriptionStatus.free,
        ),
        subscriptionExpiryDate: data['subscriptionExpiryDate'] != null 
          ? DateTime.parse(data['subscriptionExpiryDate']) 
          : null,
        notificationsEnabled: data['notificationsEnabled'] ?? true,
        questionsAnsweredToday: data['questionsAnsweredToday'] ?? 0,
        weakAreas: List<String>.from(data['weakAreas'] ?? []),
      );
    }
    return null;
  });
});

// Current User Profile Provider
final currentUserProfileProvider = StreamProvider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (firebaseUser) {
      if (firebaseUser != null) {
        return ref.watch(userProfileProvider(firebaseUser.uid).stream);
      }
      return Stream.value(null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Auth Loading Provider
final authLoadingProvider = Provider<bool>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);
  return authNotifier.isLoading;
});

// Auth Error Provider
final authErrorProvider = Provider<String?>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);
  return authNotifier.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// User Answers Stream Provider
final userAnswersProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserAnswersStream(userId: userId).map((snapshot) {
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  });
});

// Current User Answers Provider
final currentUserAnswersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (firebaseUser) {
      if (firebaseUser != null) {
        return ref.watch(userAnswersProvider(firebaseUser.uid).stream);
      }
      return Stream.value(<Map<String, dynamic>>[]);
    },
    loading: () => Stream.value(<Map<String, dynamic>>[]),
    error: (_, __) => Stream.value(<Map<String, dynamic>>[]),
  );
});