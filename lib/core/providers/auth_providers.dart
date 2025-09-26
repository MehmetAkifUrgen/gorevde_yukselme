import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/favorites_service.dart';
import '../services/google_signin_service.dart';
import '../services/session_service.dart';
import '../services/local_statistics_service.dart';
import '../models/user_model.dart';
import '../models/user_preferences.dart';
import '../models/user_statistics.dart';
import 'app_providers.dart';


// Session Service Provider
final sessionServiceProvider = Provider<SessionService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return SessionService(sharedPreferences);
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final googleSignInService = ref.watch(googleSignInServiceProvider);
  final sessionService = ref.watch(sessionServiceProvider);
  return AuthService(
    googleSignInService: googleSignInService,
    crashlytics: FirebaseCrashlytics.instance,
    sessionService: sessionService,
  );
});

// Local Statistics Service Provider
final localStatisticsServiceProvider = Provider<LocalStatisticsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStatisticsService(prefs);
});

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Favorites Service Provider
final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return FavoritesService(sharedPreferences: sharedPreferences);
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
  final LocalStatisticsService _localStats;

  AuthNotifier(this._authService, this._firestoreService, this._localStats) 
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
        // Oturumu kaydet
        await _authService.saveUserSession();
        // Merge guest data to remote after login
        await _localStats.mergeGuestToRemote(userId: credential!.user!.uid, firestore: _firestoreService);
        state = AsyncValue.data(credential.user);
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
        
        // Send email verification immediately after user creation
        try {
          await _authService.sendEmailVerification(user: credential.user);
        } catch (verificationError) {
          // Don't fail the entire registration process if email verification fails
          // User can resend verification later
        }
        
        state = AsyncValue.data(credential.user);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    print('[AuthNotifier] Starting Google Sign-In...');
    state = const AsyncValue.loading();
    try {
      final credential = await _authService.signInWithGoogle();
      
      print('[AuthNotifier] Google Sign-In credential received: ${credential != null ? 'Success' : 'Null'}');
      
      // Kullanıcı iptal etti veya credential null
      if (credential == null) {
        print('[AuthNotifier] User canceled Google Sign-In or credential is null');
        // State'i önceki duruma geri döndür (null user)
        state = const AsyncValue.data(null);
        return;
      }
      
      if (credential.user != null) {
        print('[AuthNotifier] Firebase user obtained: ${credential.user!.email}');
        print('[AuthNotifier] Checking user profile in Firestore...');
        
        // Check if user profile exists, if not create one
        final userDoc = await _firestoreService.getUserProfile(
          userId: credential.user!.uid,
        );
        
        if (!userDoc.exists) {
          print('[AuthNotifier] User profile does not exist, creating new profile...');
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
        } else {
          print('[AuthNotifier] User profile already exists');
        }
        
        print('[AuthNotifier] Saving user session...');
        // Oturumu kaydet
        await _authService.saveUserSession();
        
        print('[AuthNotifier] Merging guest data to remote...');
        // Merge guest data to remote after Google login
        await _localStats.mergeGuestToRemote(userId: credential.user!.uid, firestore: _firestoreService);
        
        print('[AuthNotifier] Google Sign-In completed successfully');
        state = AsyncValue.data(credential.user);
      } else {
        print('[AuthNotifier] Credential exists but user is null');
        // Credential var ama user null - bu durumda da state'i null yap
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      print('[AuthNotifier] Google Sign-In error: $error');
      print('[AuthNotifier] Error type: ${error.runtimeType}');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> isEmailRegisteredWithGoogle({required String email}) async {
    try {
      print('[AuthNotifier] Checking if email is registered with Google: $email');
      final result = await _authService.isEmailRegisteredWithGoogle(email: email);
      print('[AuthNotifier] Google check result for $email: $result');
      return result;
    } catch (error, _) {
      print('[AuthNotifier] Error checking Google registration: $error');
      return false;
    }
  }

  Future<bool> isEmailRegistered({required String email}) async {
    try {
      print('[AuthNotifier] Checking if email is registered: $email');
      final result = await _authService.isEmailRegistered(email: email);
      print('[AuthNotifier] Email check result for $email: $result');
      return result;
    } catch (error, stackTrace) {
      print('[AuthNotifier] Error checking email registration: $error');
      state = AsyncValue.error(error, stackTrace);
      // For safety, assume email is registered if we can't check properly
      // This prevents duplicate registrations
      return true;
    }
  }

  Future<void> debugGoogleSignInForEmail({required String email}) async {
    try {
      print('[AuthNotifier] Starting debug Google Sign-In test for: $email');
      await _authService.debugGoogleSignInForEmail(email: email);
      print('[AuthNotifier] Debug Google Sign-In test completed for: $email');
    } catch (error, _) {
      print('[AuthNotifier] Error during debug Google Sign-In test: $error');
      throw error;
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
      print('[AuthNotifier] sendEmailVerification - Starting');
      await _authService.sendEmailVerification();
      print('[AuthNotifier] sendEmailVerification - Success');
    } catch (error, stackTrace) {
      print('[AuthNotifier] sendEmailVerification - Error: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      print('[AuthNotifier] reloadUser - Starting');
      await _authService.reloadUser();
      
      // Update state with reloaded user
      final user = _authService.currentUser;
      print('[AuthNotifier] reloadUser - User: ${user?.email}, Email verified: ${user?.emailVerified}');
      state = AsyncValue.data(user);
      
      // Force Firebase auth state change by triggering a token refresh
      if (user != null) {
        print('[AuthNotifier] reloadUser - Forcing auth state update with token refresh');
        try {
          // Force token refresh to trigger authStateChanges stream
          await user.getIdToken(true);
          print('[AuthNotifier] reloadUser - Token refresh completed');
        } catch (e) {
          print('[AuthNotifier] reloadUser - Token refresh failed: $e');
        }
        
        // Additional wait for state propagation
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (error, stackTrace) {
      print('[AuthNotifier] reloadUser - Error: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  bool get isEmailVerified {
    final verified = _authService.isEmailVerified;
    print('[AuthNotifier] isEmailVerified - Result: $verified');
    return verified;
  }

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
        // Delete all user data from Firestore first
        await _firestoreService.deleteAllUserData(userId: userId);
        
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
  final localStats = ref.watch(localStatisticsServiceProvider);
  return AuthNotifier(authService, firestoreService, localStats);
});

// User Profile Provider (from Firestore)
final userProfileProvider = StreamProvider.family<User?, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserProfileStream(userId: userId).map((doc) {
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return User(
        id: doc.id,
        name: data['displayName'] ?? data['name'] ?? '',
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
          ? (data['subscriptionExpiryDate'] is Timestamp 
              ? (data['subscriptionExpiryDate'] as Timestamp).toDate()
              : DateTime.parse(data['subscriptionExpiryDate'].toString()))
          : null,
        notificationsEnabled: data['notificationsEnabled'] ?? true,
        questionsAnsweredToday: data['questionsAnsweredToday'] ?? 0,
        weakAreas: List<String>.from(data['weakAreas'] ?? []),
        createdAt: data['createdAt'] != null 
          ? (data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.parse(data['createdAt'].toString()))
          : DateTime.now(),
        lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] is Timestamp 
              ? (data['lastLoginAt'] as Timestamp).toDate()
              : DateTime.parse(data['lastLoginAt'].toString()))
          : null,
        isEmailVerified: data['isEmailVerified'] ?? false,
        profileImageUrl: data['photoURL'] ?? data['profileImageUrl'],
        target: data['target'] ?? 50,
        preferences: UserPreferences(
          fontSize: (data['fontSize'] as num?)?.toDouble() ?? 16.0,
          notificationsEnabled: data['notificationsEnabled'] ?? true,
          darkModeEnabled: data['darkModeEnabled'] ?? false,
          soundEnabled: data['soundEnabled'] ?? true,
        ),
        statistics: UserStatistics(
          totalQuestionsAnswered: data['totalQuestionsAnswered'] ?? 0,
          correctAnswers: data['correctAnswers'] ?? 0,
          totalExamsTaken: data['totalExamsTaken'] ?? 0,
          averageScore: (data['averageScore'] ?? 0.0).toDouble(),
          totalStudyTimeMinutes: data['totalStudyTimeMinutes'] ?? 0,
          currentStreak: data['currentStreak'] ?? 0,
          longestStreak: data['longestStreak'] ?? 0,
        ),
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

// Email Verified Provider - Reactive email verification status
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  
  // Get verification status from authState only for consistency
  final isVerifiedFromState = authState.when(
    data: (user) => user?.emailVerified ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
  
  final isAuthenticated = authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
  
  // If not authenticated, return false
  if (!isAuthenticated) {
    print('[isEmailVerifiedProvider] Not authenticated, Result: false');
    return false;
  }
  
  // For authenticated users, check verification status
  print('[isEmailVerifiedProvider] Authenticated user, emailVerified: $isVerifiedFromState');
  
  return isVerifiedFromState;
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