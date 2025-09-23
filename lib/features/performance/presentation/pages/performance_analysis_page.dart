import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
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
  String selectedPeriod = 'Son 7 Gün';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
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
              const PopupMenuItem(value: 'Tüm Zamanlar', child: Text('Tüm Zamanlar')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
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
          
          // Quick Stats
          _buildQuickStats(),
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
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
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
        isAuthenticated 
          ? currentUser.when(
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
                        'Seri',
                        streak.toString(),
                        Icons.local_fire_department,
                        Colors.orange,
                        'Gün',
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
        )
        : _buildGuestStatistics(),
      ],
    );
  }

  Widget _buildGuestStatistics() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(localStatisticsServiceProvider).getStats(''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }
        
        final stats = snapshot.data ?? {};
        final totalQuestions = stats['totalQuestions'] ?? 0;
        final correctAnswers = stats['correct'] ?? 0;
        final incorrectAnswers = stats['incorrect'] ?? 0;
        final studyTimeMinutes = stats['studyTimeMinutes'] ?? 0;
        
        if (totalQuestions == 0) {
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
        
        final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100) : 0.0;
        final avgTimePerQuestion = totalQuestions > 0 
            ? (studyTimeMinutes / totalQuestions).toStringAsFixed(1)
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
                    '$correctAnswers doğru',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Yanlış Cevaplar',
                    incorrectAnswers.toString(),
                    Icons.close,
                    Colors.red,
                    'Hatalar',
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bu veriler sadece bu cihazda saklanır. Giriş yaparak tüm cihazlarınızda senkronize edebilirsiniz.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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

  Widget _buildQuickStats() {
    final currentUser = ref.watch(currentUserProfileProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
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
            isAuthenticated 
              ? currentUser.when(
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
            )
            : _buildGuestQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestQuickStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(localStatisticsServiceProvider).getStats(''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }
        
        final stats = snapshot.data ?? {};
        final totalQuestions = stats['totalQuestions'] ?? 0;
        final correctAnswers = stats['correct'] ?? 0;
        final incorrectAnswers = stats['incorrect'] ?? 0;
        final studyTimeMinutes = stats['studyTimeMinutes'] ?? 0;
        
        if (totalQuestions == 0) {
          return const Center(child: Text('Henüz istatistik bulunmuyor'));
        }
        
        final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100) : 0.0;
        final studyTimeHours = (studyTimeMinutes / 60).toStringAsFixed(1);
        
        return Column(
          children: [
            _buildStatRow('Doğru Cevaplar', correctAnswers.toString(), '${accuracy.toStringAsFixed(1)}%'),
            _buildStatRow('Yanlış Cevaplar', incorrectAnswers.toString(), '${(100 - accuracy).toStringAsFixed(1)}%'),
            _buildStatRow('Toplam Sorular', totalQuestions.toString(), 'Cevaplanmış'),
            _buildStatRow('Toplam Çalışma Süresi', '$studyTimeHours saat', 'Tüm zamanlar'),
          ],
        );
      },
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
}