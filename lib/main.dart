import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:gorevde_yukselme/core/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Oturum kontrolü yap
  await _checkAndRestoreSession(sharedPreferences);
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MainApp(),
    ),
  );
}

// Kayıtlı oturumu kontrol et ve geri yükle
Future<void> _checkAndRestoreSession(SharedPreferences prefs) async {
  final sessionService = SessionService(prefs);
  
  // Geçerli bir oturum var mı kontrol et
  if (sessionService.hasValidSession()) {
    final sessionData = sessionService.getSession();
    if (sessionData != null) {
      try {
        // Firebase Auth'da oturum açık mı kontrol et
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          // Oturum açık değilse, kullanıcıyı login sayfasına yönlendir
          // Bu durumda router otomatik olarak login sayfasına yönlendirecek
          print('Geçerli oturum bulundu ancak Firebase Auth oturumu kapalı');
        }
      } catch (e) {
        print('Oturum kontrolü sırasında hata: $e');
      }
    }
  } else {
    print('Geçerli oturum bulunamadı');
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.createRouter(ref);
    
    return MaterialApp.router(
      title: 'ExamPrep - Sınav Hazırlık Uygulaması',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
