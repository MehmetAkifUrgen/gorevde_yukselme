import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/questions/presentation/pages/question_pool_page.dart';
// import '../../features/exam/presentation/pages/exam_simulation_page.dart';
// import '../../features/starred/presentation/pages/starred_questions_page.dart';
// import '../../features/performance/presentation/pages/performance_analysis_page.dart';
// import '../../features/profile/presentation/pages/profile_page.dart';
// import '../../features/subscription/presentation/pages/subscription_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String home = '/home';
  static const String questionPool = '/question-pool';
  static const String examSimulation = '/exam-simulation';
  static const String starredQuestions = '/starred-questions';
  static const String performanceAnalysis = '/performance-analysis';
  static const String profile = '/profile';
  static const String subscription = '/subscription';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
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
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: questionPool,
        builder: (context, state) => const QuestionPoolPage(),
      ),
      GoRoute(
        path: examSimulation,
        builder: (context, state) => const _PlaceholderPage(title: 'Sınav Simülasyonu'),
      ),
      GoRoute(
        path: starredQuestions,
        builder: (context, state) => const _PlaceholderPage(title: 'Favoriler'),
      ),
      GoRoute(
        path: performanceAnalysis,
        builder: (context, state) => const _PlaceholderPage(title: 'Performans Analizi'),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const _PlaceholderPage(title: 'Profil'),
      ),
      GoRoute(
        path: subscription,
        builder: (context, state) => const _PlaceholderPage(title: 'Abonelik'),
      ),
    ],
  );
}

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
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