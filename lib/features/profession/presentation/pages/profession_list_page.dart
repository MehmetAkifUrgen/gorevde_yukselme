import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/questions_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';

class ProfessionListPage extends ConsumerWidget {
  final String examType;
  final String category; // Bu aslında bakanlık adı (ministry)
  
  const ProfessionListPage({
    super.key,
    required this.examType,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // URL decode parameters with error handling
    String decodedExamType;
    String decodedCategory;
    
    try {
      decodedExamType = Uri.decodeComponent(examType);
    } catch (e) {
      decodedExamType = examType;
      print('Profession List - ExamType URI decode error: $e');
    }
    
    try {
      decodedCategory = Uri.decodeComponent(category);
    } catch (e) {
      decodedCategory = category;
      print('Profession List - Category URI decode error: $e');
    }
    
    // API'den meslekleri al - examType (ana kategori) ve category (bakanlık) kullanarak
    final professionsAsync = ref.watch(apiProfessionsForMinistryProvider((category: decodedExamType, ministry: decodedCategory)));
    
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: StandardAppBar(
        title: _getPageTitle(),
        subtitle: 'Ana Sayfa > Bakanlıklar > $category > Meslekler',
      ),
      body: professionsAsync.when(
        data: (professions) {
          if (professions.isEmpty) {
            return const Center(
              child: Text(
                'Bu bakanlık için meslek verisi bulunmuyor',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meslek Seçiniz',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryNavyBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$category - Mesleğinizi seçin',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: professions.length,
                    itemBuilder: (context, index) {
                      final profession = professions[index];
                      return _buildProfessionCard(context, ref, profession, decodedExamType, decodedCategory);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Meslek listesi yüklenirken hata oluştu',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(apiProfessionsForMinistryProvider((category: decodedExamType, ministry: decodedCategory))),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionCard(BuildContext context, WidgetRef ref, String profession, String decodedExamType, String decodedCategory) {
    // Use examType (top-level category) and the selected profession to get subjects
    final questionsCountAsync = ref.watch(
      apiSubjectsProvider((category: decodedExamType, profession: profession))
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            // Meslek seçildiğinde konu/yıl listesine git
            // JSON yapısında: Ana Kategori > Bakanlık > Meslek > Konu
            // Bu yüzden decodedExamType (ana kategori), decodedCategory (bakanlık), profession (meslek) ile devam ediyoruz
            context.push('/subject-list/${Uri.encodeComponent(decodedExamType)}/${Uri.encodeComponent(decodedCategory)}/${Uri.encodeComponent(profession)}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.work_outline,
                    color: AppTheme.successGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profession,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      questionsCountAsync.when(
                        data: (subjects) => Text(
                          '${subjects.length} konu mevcut',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkGrey,
                          ),
                        ),
                        loading: () => Text(
                          'Yükleniyor...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkGrey,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Konu sayısı alınamadı',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.darkGrey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    return 'Meslekler';
  }
}