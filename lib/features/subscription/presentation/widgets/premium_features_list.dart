import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PremiumFeaturesList extends StatelessWidget {
  const PremiumFeaturesList({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.quiz,
        'title': 'Sınırsız Soru Çözme',
        'description': 'Günlük soru limitiniz olmadan istediğiniz kadar soru çözün',
      },
      {
        'icon': Icons.block,
        'title': 'Reklamsız Deneyim',
        'description': 'Hiçbir reklam olmadan kesintisiz çalışma deneyimi',
      },
      {
        'icon': Icons.analytics,
        'title': 'Detaylı İstatistikler',
        'description': 'Gelişiminizi takip edin, güçlü ve zayıf yönlerinizi keşfedin',
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
          Text(
            'Premium Özellikler',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavyBlue,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FeatureItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
            ),
          )),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
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
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavyBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkGrey,
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