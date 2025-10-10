import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';

class PremiumFeaturesList extends ConsumerWidget {
  const PremiumFeaturesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumUserProvider);
    
    final features = [
      {
        'icon': Icons.quiz,
        'title': 'Sınırsız Soru Çözme',
        'description': 'Günlük soru limitiniz olmadan istediğiniz kadar soru çözün',
        'freeDescription': 'Ücretsiz kullanıcılar için sınırsız soru çözme',
      },
      {
        'icon': Icons.block,
        'title': 'Reklamsız Deneyim',
        'description': 'Hiçbir reklam olmadan kesintisiz çalışma deneyimi',
        'freeDescription': 'Ücretsiz kullanıcılarda her 3 yanlış cevapta ve her 4 soruda reklam gösterilir',
      },
      {
        'icon': Icons.analytics,
        'title': 'Detaylı İstatistikler',
        'description': 'Gelişiminizi takip edin, güçlü ve zayıf yönlerinizi keşfedin',
        'freeDescription': 'Temel istatistikler ücretsiz kullanıcılara da sunulur',
      },
      {
        'icon': Icons.bookmark,
        'title': 'Sınırsız Yer İmi',
        'description': 'İstediğiniz kadar soruyu yer imlerine ekleyin',
        'freeDescription': 'Ücretsiz kullanıcılar sınırlı sayıda yer imi oluşturabilir',
      },
      
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Text(
                'Premium Özellikler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavyBlue,
                ),
              ),
              const Spacer(),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AKTİF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Ads Information Card
          if (!isPremium) _buildAdsInfoCard(),
          
          const SizedBox(height: 16),
          
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FeatureItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: isPremium 
                ? feature['description'] as String
                : feature['freeDescription'] as String,
              isPremium: isPremium,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAdsInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reklam Bilgisi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ücretsiz kullanıcılarda reklamlar şu durumlarda gösterilir:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildAdRule('Her 3 yanlış cevapta bir reklam'),
          _buildAdRule('Her 4 soruda bir reklam'),
          _buildAdRule('Banner reklamlar sayfa altlarında'),
          const SizedBox(height: 8),
          Text(
            'Premium üyelik ile tüm reklamlar kaldırılır!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        children: [
          Icon(
            Icons.arrow_right,
            color: Colors.orange[600],
            size: 16,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isPremium;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPremium 
              ? AppTheme.accentGold.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isPremium ? AppTheme.primaryNavyBlue : Colors.grey[600],
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? AppTheme.primaryNavyBlue : Colors.grey[700],
                      ),
                    ),
                  ),
                  if (isPremium)
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.accentGold,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isPremium ? AppTheme.darkGrey : Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}