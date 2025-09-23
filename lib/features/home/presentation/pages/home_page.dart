import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';
import '../widgets/motivational_banner.dart';

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
          'GYUD',
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
            
            // Fixed Exam Type Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sınav Türleri',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      color: AppTheme.primaryNavyBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Görevde Yükselme Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildExamTypeCard(
                      context,
                      'Görevde Yükselme',
                      'Mevcut görevinizde yükselmek için sınav hazırlığı yapın',
                      Icons.trending_up,
                      AppTheme.primaryNavyBlue,
                      () => context.push('/ministry-list/${Uri.encodeComponent('Görevde Yükselme')}'),
                    ),
                  ),
                  
                  // Ünvan Değişikliği Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildExamTypeCard(
                      context,
                      'Ünvan Değişikliği',
                      'Farklı bir ünvana geçiş için sınav hazırlığı yapın',
                      Icons.swap_horiz,
                      AppTheme.successGreen,
                      () => context.push('/ministry-list/${Uri.encodeComponent('Ünvan Değişikliği')}'),
                    ),
                  ),
                ],
              ),
            ),
            

            
            const SizedBox(height: 24),
            
            // Reklam kaldırıldı
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }



  Widget _buildExamTypeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }


}