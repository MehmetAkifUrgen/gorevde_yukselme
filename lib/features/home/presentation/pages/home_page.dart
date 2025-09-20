import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/models/user_model.dart';
import '../widgets/navigation_card.dart';
import '../widgets/motivational_banner.dart';
import '../widgets/ad_banner.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  @override
  Widget build(BuildContext context) {
    final motivationalMessage = ref.watch(motivationalMessageProvider);
    final user = ref.watch(userProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(
          'ExamPrep',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.primaryNavyBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bildirimler yakında eklenecek'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motivational Banner
            MotivationalBanner(message: motivationalMessage),
            
            const SizedBox(height: 24),
            
            // Welcome Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş geldin${user?.name != null ? ', ${user!.name.split(' ').first}' : ''}!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primaryNavyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bugün hangi konuda çalışmak istiyorsun?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Navigation Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  NavigationCard(
                    title: 'Soru Havuzu',
                    subtitle: 'Kategorilere göre sorular',
                    icon: Icons.quiz_outlined,
                    color: AppTheme.primaryNavyBlue,
                    onTap: () => context.go(AppRouter.questionPool),
                  ),
                  NavigationCard(
                    title: 'Sınav Simülasyonu',
                    subtitle: 'Gerçek sınav deneyimi',
                    icon: Icons.assignment_outlined,
                    color: AppTheme.successGreen,
                    onTap: () => context.go(AppRouter.examSimulation),
                  ),
                  NavigationCard(
                    title: 'Favoriler',
                    subtitle: 'İşaretlediğin sorular',
                    icon: Icons.star_outline,
                    color: AppTheme.accentGold,
                    onTap: () => context.go(AppRouter.starredQuestions),
                  ),
                  NavigationCard(
                    title: 'Performans',
                    subtitle: 'İstatistikler ve analiz',
                    icon: Icons.analytics_outlined,
                    color: AppTheme.warningYellow,
                    onTap: () => context.go(AppRouter.performanceAnalysis),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Quick Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugünkü İlerleme',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Çözülen Soru',
                            '${user?.questionsAnsweredToday ?? 0}',
                            Icons.quiz,
                            AppTheme.primaryNavyBlue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Doğru Cevap',
                            '${((user?.questionsAnsweredToday ?? 0) * 0.75).round()}',
                            Icons.check_circle,
                            AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Ad Banner for non-premium users
            if (user?.subscriptionStatus != SubscriptionStatus.premium)
              const AdBanner(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}