import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/questions_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';

class MinistryListPage extends ConsumerWidget {
  final String examType;
  
  const MinistryListPage({
    super.key,
    required this.examType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // URL decode the examType parameter with error handling
    String decodedExamType;
    try {
      // First try to decode, if it fails, use the original
      decodedExamType = Uri.decodeComponent(examType);
    } catch (e) {
      // If decoding fails, try to handle common encoding issues
      try {
        // Replace common problematic characters
        String fixedExamType = examType
            .replaceAll('%C4%B1', 'ı')
            .replaceAll('%C3%BC', 'ü')
            .replaceAll('%C3%B6', 'ö')
            .replaceAll('%C3%A7', 'ç')
            .replaceAll('%C4%9F', 'ğ')
            .replaceAll('%C5%9F', 'ş')
            .replaceAll('%C3%BC', 'ü')
            .replaceAll('%C3%96', 'Ö')
            .replaceAll('%C3%9C', 'Ü')
            .replaceAll('%C3%87', 'Ç')
            .replaceAll('%C4%B0', 'İ')
            .replaceAll('%C4%9E', 'Ğ')
            .replaceAll('%C5%9E', 'Ş');
        
        decodedExamType = Uri.decodeComponent(fixedExamType);
      } catch (e2) {
        // If all else fails, use the original examType
        decodedExamType = examType;
        print('Ministry List - URI decode error: $e');
      }
    }
    print('Ministry List - Original examType: $examType');
    print('Ministry List - Decoded examType: $decodedExamType');
    
    // examType burada ana kategori (örn: "Görevde Yükselme")
    // Bu sayfada bakanlıkları göstermemiz gerekiyor - apiMinistriesProvider kullanmalıyız
    final ministriesAsync = ref.watch(apiMinistriesProvider(decodedExamType));
    
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: StandardAppBar(
        title: _getPageTitle(),
        subtitle: 'Ana Sayfa > Bakanlıklar',
      ),
      body: ministriesAsync.when(
        data: (ministries) {
          if (ministries.isEmpty) {
            return const Center(
              child: Text(
                'Bakanlık verisi bulunmuyor',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          
          // Tekrarlanan bakanlıkları kaldır
          final uniqueMinistries = ministries.toSet().toList();
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bakanlıklar',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryNavyBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sınava girmek istediğiniz bakanlığı seçin',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: uniqueMinistries.length,
                    itemBuilder: (context, index) {
                      final ministry = uniqueMinistries[index];
                      return _buildMinistryCard(context, ref, ministry, decodedExamType);
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
                'Bakanlık listesi yüklenirken hata oluştu',
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
                onPressed: () => ref.refresh(apiProfessionsProvider(decodedExamType)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinistryCard(BuildContext context, WidgetRef ref, String ministry, String decodedExamType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            // Bakanlık seçildiğinde meslek listesine git
            context.push('/profession-list/${Uri.encodeComponent(decodedExamType)}/${Uri.encodeComponent(ministry)}');
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
                    color: AppTheme.primaryNavyBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: AppTheme.primaryNavyBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ministry,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Removed 'Sorular mevcut' text as requested
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
    return 'Bakanlıklar';
  }
}