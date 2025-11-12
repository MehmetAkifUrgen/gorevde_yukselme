import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/questions/presentation/pages/random_questions_practice_page.dart';
import '../../features/exam/presentation/pages/exam_simulation_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/subscription/presentation/pages/terms_privacy_page.dart';
import '../../features/ministry/presentation/pages/ministry_list_page.dart';
import '../../features/profession/presentation/pages/profession_list_page.dart';
import '../../features/subject/presentation/pages/subject_list_page.dart';
import '../navigation/main_navigation.dart';
import '../../core/models/question_model.dart';
import '../../core/providers/auth_providers.dart';

class AppRouter {
  static const String login = '/login';
  static const String splash = '/splash';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String home = '/home';
  static const String questionPool = '/question-pool';
  static const String randomQuestionsPractice = '/random-questions-practice';
  static const String examSimulation = '/exam-simulation';
  static const String starredQuestions = '/starred-questions';
  static const String performanceAnalysis = '/performance-analysis';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String termsPrivacy = '/terms-privacy';
  static const String profileEdit = '/profile/edit';
  static const String privacy = '/privacy';
  static const String help = '/help';

  static GoRouter createRouter(WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final isAuthenticated = user != null;
    final isEmailVerified = user?.emailVerified ?? false;
    
    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) {
        // Eğer kullanıcı giriş yapmışsa ama email doğrulanmamışsa
        if (isAuthenticated && !isEmailVerified) {
          // Email verification sayfasında değilse, oraya yönlendir
          if (state.uri.path != emailVerification) {
            final email = user.email ?? '';
            return '$emailVerification?email=${Uri.encodeComponent(email)}';
          }
        }
        
        // Opsiyonel giriş: Sadece giriş sayfasındayken ve kullanıcı zaten girişliyse ana sayfaya yönlendir
        if (state.uri.path == login && isAuthenticated && isEmailVerified) {
          return home;
        }
        
        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: \${state.uri}'),
        ),
      ),
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return LoginPage(email: email);
          },
        ),
        GoRoute(
          path: registration,
          builder: (context, state) => const RegistrationPage(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: emailVerification,
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return EmailVerificationPage(email: email);
          },
        ),
        GoRoute(
          path: home,
          builder: (context, state) => const MainNavigation(initialIndex: 0),
        ),
        GoRoute(
          path: questionPool,
          builder: (context, state) => const MainNavigation(initialIndex: 1),
        ),
        GoRoute(
          path: randomQuestionsPractice,
          builder: (context, state) {
            final questions = state.extra as List<Question>?;
            if (questions == null || questions.isEmpty) {
              return const _PlaceholderPage(title: 'Rastgele Sorular - Soru bulunamadı');
            }
            return RandomQuestionsPracticePage(questions: questions);
          },
        ),
        GoRoute(
          path: examSimulation,
          builder: (context, state) => const ExamSimulationPage(),
        ),
        GoRoute(
          path: starredQuestions,
          builder: (context, state) => const MainNavigation(initialIndex: 2),
        ),
        GoRoute(
          path: performanceAnalysis,
          builder: (context, state) => const MainNavigation(initialIndex: 3),
        ),
        GoRoute(
          path: profile,
          builder: (context, state) => const MainNavigation(initialIndex: 4),
        ),
        GoRoute(
          path: subscription,
          builder: (context, state) => const SubscriptionPage(),
        ),
        GoRoute(
          path: termsPrivacy,
          builder: (context, state) => const TermsPrivacyPage(),
        ),
        GoRoute(
          path: '/ministry-list/:examType',
          builder: (context, state) {
            final examType = state.pathParameters['examType']!;
            return MinistryListPage(examType: examType);
          },
        ),
        GoRoute(
          path: '/profession-list/:examType/:ministry',
          builder: (context, state) {
            final examType = state.pathParameters['examType']!;
            final ministry = state.pathParameters['ministry']!;
            return ProfessionListPage(
              examType: examType,
              category: ministry, // ministry'yi category olarak geç
            );
          },
        ),
        GoRoute(
          path: '/subject-list/:examType/:ministry/:profession',
          builder: (context, state) {
            final examType = state.pathParameters['examType']!;
            final ministry = state.pathParameters['ministry']!;
            final profession = state.pathParameters['profession']!;
            return SubjectListPage(
              examType: examType,
              category: ministry, // ministry'yi category olarak geç
              profession: profession,
            );
          },
        ),
        GoRoute(
          path: '/exam/:examType/:ministry/:profession/:subject',
          builder: (context, state) {
            final examType = state.pathParameters['examType']!;
            final ministry = state.pathParameters['ministry']!;
            final profession = state.pathParameters['profession']!;
            final subject = state.pathParameters['subject']!;
            return ExamSimulationPage(
              routeExamType: examType,
              category: ministry, // ministry'yi category olarak geç
              profession: profession,
              subject: subject,
            );
          },
        ),
        GoRoute(
          path: profileEdit,
          builder: (context, state) => const _PlaceholderPage(title: 'Profil Düzenle'),
        ),
        GoRoute(
          path: privacy,
          builder: (context, state) => const _PlaceholderPage(title: 'Gizlilik Ayarları'),
        ),
        GoRoute(
          path: help,
          builder: (context, state) => const _PlaceholderPage(title: 'Yardım Merkezi'),
        ),
      ],
    );
  }
}

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref as WidgetRef);
});

// Placeholder page for routes not yet implemented
class _PlaceholderPage extends StatelessWidget {
  final String title;
  
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '$title sayfası',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Yakında eklenecek...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
