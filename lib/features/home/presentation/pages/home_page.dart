import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/questions_providers.dart';
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
                            '${((user?.questionsAnsweredToday ?? 0) > 0 ? ((user!.questionsAnsweredToday! * 0.75).round()) : 0)}',
                            Icons.check_circle,
                            AppTheme.successGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Başarı Oranı',
                            '${((user?.questionsAnsweredToday ?? 0) > 0 ? (((user!.questionsAnsweredToday! * 0.75) / user!.questionsAnsweredToday! * 100).round()) : 0)}%',
                            Icons.bar_chart,
                            AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // API Sınav Butonları Bölümü
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer(
                builder: (context, ref, child) {
                  final apiCategoriesAsync = ref.watch(apiCategoriesProvider);
                  
                  return apiCategoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'API Sınav Kategorileri',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: categories.map((category) {
                              return _buildExamCategoryCard(context, ref, category);
                            }).toList(),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Text(
                      'Sınav kategorileri yüklenirken hata: $error',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
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

  Widget _buildExamCategoryCard(BuildContext context, WidgetRef ref, String category) {
    final questionsCountAsync = ref.watch(apiCategoryQuestionsCountProvider(category));
    
    return questionsCountAsync.when(
      data: (count) {
        return GestureDetector(
          onTap: () {
            _showExamCategoryDetails(context, ref, category, count);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavyBlue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '$count soru',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Hata',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  void _showExamCategoryDetails(BuildContext context, WidgetRef ref, String category, int questionCount) {
    final apiProfessionsAsync = ref.watch(apiProfessionsProvider(category));
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Toplam soru sayısı: $questionCount',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                
                apiProfessionsAsync.when(
                  data: (professions) {
                    if (professions.isEmpty) {
                      return const Text('Bu kategoride meslek bulunamadı.');
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Meslekler:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        ...professions.map((profession) {
                          return FutureBuilder(
                            future: _getProfessionDetails(ref, category, profession),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return ListTile(
                                  title: Text(profession),
                                  trailing: const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              }
                              
                              if (snapshot.hasError) {
                                return ListTile(
                                  title: Text(profession),
                                  subtitle: const Text('Yüklenemedi'),
                                );
                              }
                              
                              final details = snapshot.data ?? {'questionCount': '0', 'subjects': []};
                              return ListTile(
                                title: Text(profession,
                                  style: const TextStyle(fontSize: 14)),
                                subtitle: Text('${details['questionCount']} soru',
                                  style: const TextStyle(fontSize: 12)),
                                onTap: () {
                                  _showProfessionDetails(context, ref, category, profession, details['subjects'] as List<String>);
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              );
                            },
                          );
                        }).toList(),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Text('Meslekler yüklenirken hata: $error',
                    style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
  
  Future<Map<String, dynamic>> _getProfessionDetails(WidgetRef ref, String category, String profession) async {
    try {
      final apiService = ref.read(questionsApiServiceProvider);
      final response = await apiService.fetchAllQuestions();
      
      // Bu meslekteki soru sayısını al
      final questions = apiService.convertApiQuestionsToQuestions(
        response,
        filterByCategory: category,
        filterByProfession: profession,
      );
      
      // Bu meslekteki konuları al
      final subjects = apiService.getAvailableSubjects(response, category, profession);
      
      return {
        'questionCount': questions.length.toString(),
        'subjects': subjects,
      };
    } catch (e) {
      return {
        'questionCount': '0',
        'subjects': [],
      };
    }
  }
  
  void _showProfessionDetails(BuildContext context, WidgetRef ref, String category, String profession, List<String> subjects) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$category - $profession',
            style: const TextStyle(fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Konular:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                
                if (subjects.isEmpty)
                  const Text('Bu meslekte konu bulunamadı.',
                    style: TextStyle(fontSize: 12))
                else
                  ...subjects.map((subject) {
                    return FutureBuilder(
                      future: _getSubjectDetails(ref, category, profession, subject),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text(subject,
                              style: const TextStyle(fontSize: 13)),
                            trailing: const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return ListTile(
                            title: Text(subject,
                              style: const TextStyle(fontSize: 13)),
                            subtitle: const Text('Yüklenemedi',
                              style: TextStyle(fontSize: 11)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          );
                        }
                        
                        final questionCount = snapshot.data ?? '0';
                        return ListTile(
                          title: Text(subject,
                            style: const TextStyle(fontSize: 13)),
                          subtitle: Text('$questionCount soru',
                            style: const TextStyle(fontSize: 11)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        );
                      },
                    );
                  }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
  
  Future<String> _getSubjectDetails(WidgetRef ref, String category, String profession, String subject) async {
    try {
      final apiService = ref.read(questionsApiServiceProvider);
      final response = await apiService.fetchAllQuestions();
      
      // Bu konudaki soru sayısını al
      final questions = apiService.convertApiQuestionsToQuestions(
        response,
        filterByCategory: category,
        filterByProfession: profession,
      );
      
      // API yapısı nedeniyle konu bazlı filtreleme için ek işlem gerekebilir
      // Şimdilik sadece meslek bazlı sayıyı döndürüyoruz
      return questions.length.toString();
    } catch (e) {
      return '0';
    }
  }
}