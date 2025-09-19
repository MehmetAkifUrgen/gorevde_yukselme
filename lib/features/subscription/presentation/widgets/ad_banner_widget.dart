import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/premium_features_service.dart';

class AdBannerWidget extends ConsumerWidget {
  final EdgeInsets? margin;
  final double? height;

  const AdBannerWidget({
    super.key,
    this.margin,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumService = PremiumFeaturesService();

    return StreamBuilder<bool>(
      stream: premiumService.premiumStatusStream,
      initialData: premiumService.isPremium,
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;
        
        // Don't show ads for premium users
        if (isPremium) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: margin ?? const EdgeInsets.all(16),
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.lightGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.accentGold,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to subscription page
                Navigator.of(context).pushNamed('/subscription');
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Ad placeholder icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                      child: Icon(
                        Icons.ads_click,
                        color: AppTheme.accentGold,
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Ad content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Reklamsız deneyim için Premium\'a geçin',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryNavyBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sınırsız özellikler ve daha fazlası',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.darkGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Premium badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Close button
                    GestureDetector(
                      onTap: () {
                        // Temporarily hide the ad (could implement logic to hide for session)
                      },
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A smaller inline ad widget for use in lists or cards
class InlineAdWidget extends ConsumerWidget {
  const InlineAdWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumService = PremiumFeaturesService();

    return StreamBuilder<bool>(
      stream: premiumService.premiumStatusStream,
      initialData: premiumService.isPremium,
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;
        
        // Don't show ads for premium users
        if (isPremium) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
          color: AppTheme.accentGold.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.accentGold.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: AppTheme.accentGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Premium ile reklamsız deneyimin keyfini çıkarın',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryNavyBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/subscription');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Geç',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}