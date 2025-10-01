import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_providers.dart';

class PerformanceAnalysisPage extends ConsumerStatefulWidget {
  const PerformanceAnalysisPage({super.key});

  @override
  ConsumerState<PerformanceAnalysisPage> createState() => _PerformanceAnalysisPageState();
}

class _PerformanceAnalysisPageState extends ConsumerState<PerformanceAnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Guest statistics data
  Map<String, dynamic>? _guestStats;
  bool _isLoadingGuestStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadGuestStatistics();
  }

  Future<void> _loadGuestStatistics() async {
    try {
      print('[PerformanceAnalysisPage] Loading local statistics...');
      // Giriş yapmış kullanıcı için userId, misafir için boş string
      final firebaseUser = ref.read(currentFirebaseUserProvider);
      final userId = firebaseUser?.uid ?? '';
      print('[PerformanceAnalysisPage] Loading stats for userId: $userId');
      
      final stats = await ref.read(localStatisticsServiceProvider).getStats(userId);
      print('[PerformanceAnalysisPage] Local stats loaded: $stats');
      if (mounted) {
        setState(() {
          _guestStats = stats;
          _isLoadingGuestStats = false;
        });
      }
    } catch (e) {
      print('[PerformanceAnalysisPage] Error loading local stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingGuestStats = false;
        });
      }
    }
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('[PerformanceAnalysisPage] Refresh button pressed');
              // Refresh performance data
              ref.invalidate(currentUserProfileProvider);
              _loadGuestStatistics();
            },
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
          
          // Subject Statistics
          if (_guestStats != null) _buildSubjectStatistics(_guestStats!),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary() {
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
        // Her zaman local statistics kullan (hem guest hem authenticated için)
        _buildGuestStatistics(),
      ],
    );
  }

  Widget _buildGuestStatistics() {
    if (_isLoadingGuestStats) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_guestStats == null) {
      return const Center(child: Text('Hata: İstatistikler yüklenemedi'));
    }
    
    final stats = _guestStats!;
    final totalQuestions = stats['totalQuestions'] ?? 0;
    final correctAnswers = stats['correct'] ?? 0;
    final incorrectAnswers = stats['incorrect'] ?? 0;
    final studyTimeMinutes = stats['studyTimeMinutes'] ?? 0;
    final totalTests = stats['totalTests'] ?? 0;
    final totalRandomQuestions = stats['totalRandomQuestions'] ?? 0;
    final totalMiniQuestions = stats['totalMiniQuestions'] ?? 0;
    
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
                'Mini Sorular',
                totalMiniQuestions.toString(),
                Icons.quiz_outlined,
                Colors.orange,
                'Mini quiz sorular',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Tamamlanan Test',
                totalTests.toString(),
                Icons.assignment_turned_in,
                Colors.indigo,
                'Test sayısı',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Soru Karıştır',
                totalRandomQuestions.toString(),
                Icons.shuffle,
                Colors.teal,
                'Random sorular',
              ),
            ),
          ],
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

  Widget _buildQuickStats() {
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
            // Her zaman local statistics kullan (hem guest hem authenticated için)
            _buildGuestQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestQuickStats() {
    if (_isLoadingGuestStats) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_guestStats == null) {
      return const Center(child: Text('Hata: İstatistikler yüklenemedi'));
    }
    
    final stats = _guestStats!;
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

  Widget _buildSubjectStatistics(Map<String, dynamic> stats) {
    final subjectStats = stats['subjectStats'] as Map<String, dynamic>? ?? {};
    
    if (subjectStats.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konu Bazlı Performans',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...subjectStats.entries.map((entry) {
              final subjectName = entry.key;
              final subjectData = entry.value as Map<String, dynamic>;
              final total = subjectData['total'] ?? 0;
              final correct = subjectData['correct'] ?? 0;
              final accuracy = total > 0 ? (correct / total * 100).round() : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        subjectName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$total soru',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '%$accuracy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accuracy >= 70 ? Colors.green : accuracy >= 50 ? Colors.orange : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

}