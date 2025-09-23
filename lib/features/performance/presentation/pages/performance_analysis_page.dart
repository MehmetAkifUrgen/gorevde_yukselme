import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/models/performance_model.dart';
import '../../../../core/models/user_statistics.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/models/user_model.dart';
import '../../../subscription/presentation/widgets/ad_banner_widget.dart';

class PerformanceAnalysisPage extends ConsumerStatefulWidget {
  const PerformanceAnalysisPage({super.key});

  @override
  ConsumerState<PerformanceAnalysisPage> createState() => _PerformanceAnalysisPageState();
}

class _PerformanceAnalysisPageState extends ConsumerState<PerformanceAnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'Son 30 Gün';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performans Analizi'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Genel Bakış', icon: Icon(Icons.dashboard)),
            Tab(text: 'Kategoriler', icon: Icon(Icons.category)),
            Tab(text: 'İlerleme', icon: Icon(Icons.trending_up)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: selectedPeriod,
            onSelected: (value) {
              setState(() {
                selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Son 7 Gün', child: Text('Son 7 Gün')),
              const PopupMenuItem(value: 'Son 30 Gün', child: Text('Son 30 Gün')),
              const PopupMenuItem(value: 'Son 3 Ay', child: Text('Son 3 Ay')),
              const PopupMenuItem(value: 'Tüm Zamanlar', child: Text('Tüm Zamanlar')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedPeriod, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCategoriesTab(),
          _buildProgressTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Summary Cards
          _buildPerformanceSummary(),
          const SizedBox(height: 24),
          
          // Recent Performance Chart
          _buildPerformanceChart(),
          const SizedBox(height: 24),
          
          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 24),
          
          // Recommendations
          _buildRecommendations(),
          const SizedBox(height: 24),
          
          // Ad Banner for non-premium users
          Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserProfileProvider);
              return currentUser.when(
                data: (user) {
                  if (user?.subscriptionStatus != SubscriptionStatus.premium) {
                    return const AdBannerWidget();
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    final currentUser = ref.watch(currentUserProfileProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performans Özeti',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        currentUser.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Performans verilerini görmek için giriş yapın'));
            }
            
            final stats = user.statistics;
            final accuracy = stats.accuracy;
            final totalQuestions = stats.totalQuestionsAnswered;
            final streak = stats.currentStreak;
            final avgTimePerQuestion = totalQuestions > 0 
                ? (stats.totalStudyTimeMinutes / totalQuestions).toStringAsFixed(1)
                : '0.0';
            
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Genel Puan',
                        '${accuracy.toStringAsFixed(1)}%',
                        Icons.grade,
                        Colors.blue,
                        'Doğruluk oranı',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Çözülen Sorular',
                        totalQuestions.toString(),
                        Icons.quiz,
                        Colors.green,
                        '${stats.correctAnswers} doğru',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Çalışma Serisi',
                        '$streak gün',
                        Icons.local_fire_department,
                        Colors.orange,
                        'Böyle devam et!',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Ort. Süre',
                        '$avgTimePerQuestion dk',
                        Icons.timer,
                        Colors.purple,
                        'Soru başına',
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performans Grafiği',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: _buildSimpleChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart() {
    final currentUser = ref.watch(currentUserProfileProvider);
    
    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Performans verilerini görmek için giriş yapın',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }
        
        final stats = user.statistics;
        
        if (stats.totalQuestionsAnswered == 0) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Henüz performans verisi bulunmuyor.\nSorular çözmeye başladığınızda burada görünecek.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }
        
        // Show current accuracy as a simple indicator
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Genel Performans',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    '${stats.accuracy.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${stats.totalQuestionsAnswered} soru çözüldü',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
    );
  }

  Widget _buildQuickStats() {
    final currentUser = ref.watch(currentUserProfileProvider);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hızlı İstatistikler',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            currentUser.when(
              data: (user) {
                if (user == null) {
                  return const Center(child: Text('İstatistikleri görmek için giriş yapın'));
                }
                
                final stats = user.statistics;
                final correctAnswers = stats.correctAnswers;
                final wrongAnswers = stats.incorrectAnswers;
                final totalQuestions = stats.totalQuestionsAnswered;
                final accuracy = stats.accuracy;
                final studyTimeHours = (stats.totalStudyTimeMinutes / 60).toStringAsFixed(1);
                
                return Column(
                  children: [
                    _buildStatRow('Doğru Cevaplar', correctAnswers.toString(), '${accuracy.toStringAsFixed(1)}%'),
                    _buildStatRow('Yanlış Cevaplar', wrongAnswers.toString(), '${(100 - accuracy).toStringAsFixed(1)}%'),
                    _buildStatRow('Toplam Sorular', totalQuestions.toString(), 'Cevaplanmış'),
                    _buildStatRow('Sınavlar', stats.totalExamsTaken.toString(), 'Tamamlanmış'),
                    _buildStatRow('Toplam Çalışma Süresi', '$studyTimeHours saat', 'Tüm zamanlar'),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Hata: $error')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              percentage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final currentUser = ref.watch(currentUserProfileProvider);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Öneriler',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            currentUser.when(
              data: (user) {
                if (user == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Önerileri görmek için giriş yapın',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                
                final stats = user.statistics;
                final recommendations = <Widget>[];
                
                // Accuracy-based recommendation
                if (stats.accuracy < 70) {
                  recommendations.add(_buildRecommendationItem(
                    Icons.trending_up,
                    'Doğruluk Oranınızı Artırın',
                    'Genel doğruluk oranınız %${stats.accuracy.toStringAsFixed(1)}. Temel konuları tekrar gözden geçirmeyi düşünün.',
                    Colors.orange,
                  ));
                }
                
                // Speed-based recommendation
                final avgTimePerQuestion = stats.totalQuestionsAnswered > 0 
                    ? stats.totalStudyTimeMinutes / stats.totalQuestionsAnswered
                    : 0.0;
                if (avgTimePerQuestion > 2.0) {
                  recommendations.add(_buildRecommendationItem(
                    Icons.timer,
                    'Hızınızı Artırın',
                    'Soru başına ${avgTimePerQuestion.toStringAsFixed(1)} dakika harcıyorsunuz. Bunu 2 dakikanın altına indirmeye çalışın.',
                    Colors.blue,
                  ));
                }
                
                // Streak-based recommendation
                if (stats.currentStreak < 3) {
                  recommendations.add(_buildRecommendationItem(
                    Icons.local_fire_department,
                    'Düzenli Çalışın',
                    'Çalışma seriniz ${stats.currentStreak} gün. Her gün düzenli çalışmaya odaklanın.',
                    Colors.red,
                  ));
                }
                
                if (recommendations.isEmpty) {
                  recommendations.add(_buildRecommendationItem(
                    Icons.emoji_events,
                    'Harika Gidiyorsunuz!',
                    'Performansınız çok iyi. Bu şekilde devam edin.',
                    Colors.green,
                  ));
                }
                
                return Column(children: recommendations);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Hata: $error')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final performanceData = ref.watch(performanceProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Performansı',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (performanceData != null && performanceData.categoryPerformance.isNotEmpty)
            ...performanceData.categoryPerformance.entries.map((entry) => 
              _buildCategoryCard(entry.key, entry.value))
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Henüz kategori performans verisi bulunmuyor.\nSorular çözmeye başladığınızda burada görünecek.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(QuestionCategory category, CategoryPerformance categoryPerformance) {
    final int score = categoryPerformance.accuracy.round();
    final int questionsAnswered = categoryPerformance.questionsAnswered;
    final String performanceText = categoryPerformance.performanceLevel;
    
    final color = score >= 80 ? Colors.green : score >= 70 ? Colors.orange : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$score%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$questionsAnswered soru çözüldü',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  performanceText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Öğrenme İlerlemesi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Study Goals
          _buildStudyGoals(),
          const SizedBox(height: 24),
          
          // Weekly Progress
          _buildWeeklyProgress(),
          const SizedBox(height: 24),
          
          // Achievements
          _buildAchievements(),
        ],
      ),
    );
  }

  Widget _buildStudyGoals() {
    final currentUser = ref.watch(currentUserProfileProvider);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Çalışma Hedefleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            currentUser.when(
              data: (user) {
                if (user == null) {
                  return const Center(child: Text('Çalışma hedeflerini görmek için giriş yapın'));
                }
                
                final stats = user.statistics;
                final userTarget = user.target;
                
                // Calculate daily questions (assuming current streak represents daily activity)
                final dailyQuestions = stats.currentStreak;
                final dailyTarget = (userTarget * 0.4).round(); // 40% of target as daily goal
                
                // Calculate weekly study time
                final weeklyStudyHours = (stats.totalStudyTimeMinutes / 60 / 4).round(); // Rough weekly estimate
                final weeklyTarget = (userTarget * 0.2).round(); // 20% of target as weekly hours
                
                // Calculate monthly exams
                final monthlyExams = (stats.totalExamsTaken / 4).round(); // Rough monthly estimate
                final monthlyTarget = (userTarget * 0.1).round().clamp(1, 10); // 10% of target as monthly exams
                
                return Column(
                  children: [
                    _buildGoalItem('Günlük Sorular', dailyQuestions, dailyTarget, 'soru'),
                    _buildGoalItem('Haftalık Çalışma Süresi', weeklyStudyHours, weeklyTarget, 'saat'),
                    _buildGoalItem('Aylık Sınavlar', monthlyExams, monthlyTarget, 'sınav'),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Hata: $error')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String title, int current, int target, String unit) {
    final progress = current / target;
    final color = progress >= 1.0 ? Colors.green : progress >= 0.7 ? Colors.orange : Colors.red;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$current / $target $unit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress > 1.0 ? 1.0 : progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    final currentUser = ref.watch(currentUserProfileProvider);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu Haftanın Aktivitesi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            currentUser.when(
              data: (user) {
                if (user == null) {
                  return const Center(child: Text('Haftalık aktiviteyi görmek için giriş yapın'));
                }
                return _buildWeeklyChart(user.statistics);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Hata: $error')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(UserStatistics stats) {
    if (stats.totalQuestionsAnswered == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Henüz haftalık aktivite verisi bulunmuyor.\nSorular çözmeye başladığınızda burada görünecek.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final todayIndex = DateTime.now().weekday - 1;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isToday = index == todayIndex;
        
        // Show current streak for today, 0 for other days (since we don't have real daily data)
        final activity = isToday && stats.currentStreak > 0 ? stats.currentStreak : 0;
        final height = activity > 0 ? 60.0 : 20.0;
        
        return Column(
          children: [
            Text(
              '$activity',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Container(
              width: 24,
              height: height,
              decoration: BoxDecoration(
                color: isToday 
                    ? AppTheme.lightTheme.primaryColor 
                    : AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAchievements() {
    final currentUser = ref.watch(currentUserProfileProvider);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Başarılar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            currentUser.when(
              data: (user) {
                if (user == null) {
                  return const Center(child: Text('Başarıları görmek için giriş yapın'));
                }
                
                final stats = user.statistics;
                
                return Column(
                  children: [
                    _buildAchievementItem(
                      Icons.emoji_events,
                      'İlk 100 Soru',
                      'İlk 100 sorunuzu tamamladınız',
                      Colors.amber,
                      stats.totalQuestionsAnswered >= 100,
                    ),
                    _buildAchievementItem(
                      Icons.local_fire_department,
                      '7 Günlük Seri',
                      '7 gün üst üste çalıştınız',
                      Colors.orange,
                      stats.currentStreak >= 7,
                    ),
                    _buildAchievementItem(
                      Icons.school,
                      'Sınav Ustası',
                      '10 sınavı tamamladınız',
                      Colors.blue,
                      stats.totalExamsTaken >= 10,
                    ),
                    _buildAchievementItem(
                      Icons.speed,
                      'Yüksek Başarı',
                      '%80 ortalama puanı koruyun',
                      Colors.purple,
                      stats.averageScore >= 80.0,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Hata: $error')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(IconData icon, String title, String description, Color color, bool unlocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: unlocked ? color : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: unlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: unlocked ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            Icon(Icons.check_circle, color: color, size: 20)
          else
            Icon(Icons.lock, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}