import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/questions_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';

class SubjectListPage extends ConsumerWidget {
  final String examType;
  final String category;
  final String profession;
  
  const SubjectListPage({
    super.key,
    required this.examType,
    required this.category,
    required this.profession,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // URL decode parameters with error handling
    String decodedCategory;
    String decodedProfession;
    
    try {
      decodedCategory = Uri.decodeComponent(category);
    } catch (e) {
      try {
        String fixedCategory = category
            .replaceAll('%C4%B1', 'ı')
            .replaceAll('%C3%BC', 'ü')
            .replaceAll('%C3%B6', 'ö')
            .replaceAll('%C3%A7', 'ç')
            .replaceAll('%C4%9F', 'ğ')
            .replaceAll('%C5%9F', 'ş')
            .replaceAll('%C3%96', 'Ö')
            .replaceAll('%C3%9C', 'Ü')
            .replaceAll('%C3%87', 'Ç')
            .replaceAll('%C4%B0', 'İ')
            .replaceAll('%C4%9E', 'Ğ')
            .replaceAll('%C5%9E', 'Ş');
        decodedCategory = Uri.decodeComponent(fixedCategory);
      } catch (e2) {
        decodedCategory = category;
      }
    }
    
    try {
      decodedProfession = Uri.decodeComponent(profession);
    } catch (e) {
      try {
        String fixedProfession = profession
            .replaceAll('%C4%B1', 'ı')
            .replaceAll('%C3%BC', 'ü')
            .replaceAll('%C3%B6', 'ö')
            .replaceAll('%C3%A7', 'ç')
            .replaceAll('%C4%9F', 'ğ')
            .replaceAll('%C5%9F', 'ş')
            .replaceAll('%C3%96', 'Ö')
            .replaceAll('%C3%9C', 'Ü')
            .replaceAll('%C3%87', 'Ç')
            .replaceAll('%C4%B0', 'İ')
            .replaceAll('%C4%9E', 'Ğ')
            .replaceAll('%C5%9E', 'Ş');
        decodedProfession = Uri.decodeComponent(fixedProfession);
      } catch (e2) {
        decodedProfession = profession;
      }
    }
    
    // URL decode examType with error handling
    String decodedExamType;
    try {
      decodedExamType = Uri.decodeComponent(examType);
    } catch (e) {
      try {
        String fixedExamType = examType
            .replaceAll('%C4%B1', 'ı')
            .replaceAll('%C3%BC', 'ü')
            .replaceAll('%C3%B6', 'ö')
            .replaceAll('%C3%A7', 'ç')
            .replaceAll('%C4%9F', 'ğ')
            .replaceAll('%C5%9F', 'ş')
            .replaceAll('%C3%96', 'Ö')
            .replaceAll('%C3%9C', 'Ü')
            .replaceAll('%C3%87', 'Ç')
            .replaceAll('%C4%B0', 'İ')
            .replaceAll('%C4%9E', 'Ğ')
            .replaceAll('%C5%9E', 'Ş');
        decodedExamType = Uri.decodeComponent(fixedExamType);
      } catch (e2) {
        decodedExamType = examType;
      }
    }
    
    // Use examType as category, category as ministry, and profession for subjects
    final subjectsAsync = ref.watch(
      apiSubjectsForMinistryAndProfessionProvider((
        category: decodedExamType, 
        ministry: decodedCategory, 
        profession: decodedProfession
      ))
    );
    
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: StandardAppBar(
        title: _getPageTitle(),
      ),
      body: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return const Center(
              child: Text(
                'Bu meslek için konu verisi bulunmuyor',
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
                  'Konu Seçiniz',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryNavyBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$decodedProfession - Çalışmak istediğiniz konuyu seçin',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return _buildSubjectCard(context, ref, subject, decodedExamType, decodedCategory, decodedProfession);
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
                'Konular listesi yüklenirken hata oluştu',
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
                onPressed: () => ref.refresh(
                  apiSubjectsProvider((category: decodedExamType, profession: decodedProfession) as ({String category, String ministry, String profession}))
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, WidgetRef ref, String subject, String decodedExamType, String decodedCategory, String decodedProfession) {
    // Subject-specific question count using subject-filtered provider
    final questionsCountAsync = ref.watch(
      questionsByCategoryProfessionAndSubjectProvider((category: decodedExamType, profession: decodedProfession, subject: subject))
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
            // Navigate to exam page - questions will be filtered by subject there
            final String eExamType = Uri.encodeComponent(decodedExamType);
            final String eCategory = Uri.encodeComponent(decodedCategory);
            final String eProfession = Uri.encodeComponent(decodedProfession);
            final String eSubject = Uri.encodeComponent(subject);
            context.push('/exam/'
                '$eExamType/'
                '$eCategory/'
                '$eProfession/'
                '$eSubject');
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
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.book_outlined,
                    color: AppTheme.accentGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      questionsCountAsync.when(
                        data: (questions) {
                          final int questionCount = questions.length;
                          return Text(
                            '$questionCount soru',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.darkGrey,
                            ),
                          );
                        },
                        loading: () => Text(
                          'Yükleniyor...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkGrey,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Soru sayısı alınamadı',
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
    switch (examType) {
      case 'gorevde-yukselme':
        return 'Görevde Yükselme - Konular';
      case 'unvan-degisikligi':
        return 'Ünvan Değişikliği - Konular';
      default:
        return 'Konular';
    }
  }
}
