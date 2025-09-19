import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';

class AdBanner extends ConsumerWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adCounter = ref.watch(adCounterProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkGrey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.ads_click_outlined,
                color: AppTheme.darkGrey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reklam Alanı',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Premium\'a geç',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.secondaryWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.darkGrey.withValues(alpha: 0.1),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: AppTheme.darkGrey.withValues(alpha: 0.5),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reklam İçeriği',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Görüntülenen reklam: ${adCounter + 1}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.darkGrey.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}