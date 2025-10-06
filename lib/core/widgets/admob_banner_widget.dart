import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/subscription_providers.dart';
import '../../../../core/services/admob_service.dart';

/// Real AdMob Banner Ad Widget
class AdMobBannerWidget extends ConsumerStatefulWidget {
  final AdSize? adSize;
  final EdgeInsets? margin;
  
  const AdMobBannerWidget({
    super.key,
    this.adSize,
    this.margin,
  });

  @override
  ConsumerState<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends ConsumerState<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (_isAdLoading) return;
    
    final isPremium = ref.read(isPremiumUserProvider);
    
    // Don't load ads for premium users
    if (isPremium) {
      return;
    }

    setState(() {
      _isAdLoading = true;
    });

    final adMobService = AdMobService.instance;
    
    _bannerAd = BannerAd(
      adUnitId: adMobService.bannerAdUnitId,
      size: widget.adSize ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('[AdMobBannerWidget] Banner ad loaded successfully');
          setState(() {
            _isAdLoaded = true;
            _isAdLoading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('[AdMobBannerWidget] Banner ad failed to load: $error');
          setState(() {
            _isAdLoaded = false;
            _isAdLoading = false;
          });
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('[AdMobBannerWidget] Banner ad opened');
        },
        onAdClosed: (ad) {
          print('[AdMobBannerWidget] Banner ad closed');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumUserProvider);
    
    // Don't show ads for premium users
    if (isPremium) {
      return const SizedBox.shrink();
    }

    // Show loading indicator while ad is loading
    if (_isAdLoading) {
      return Container(
        margin: widget.margin ?? const EdgeInsets.all(16),
        height: widget.adSize?.height.toDouble() ?? 50,
        decoration: BoxDecoration(
          color: AppTheme.lightGrey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.darkGrey.withValues(alpha: 0.2),
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavyBlue),
            ),
          ),
        ),
      );
    }

    // Show ad if loaded
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        margin: widget.margin ?? const EdgeInsets.all(16),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Show placeholder if ad failed to load
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      height: widget.adSize?.height.toDouble() ?? 50,
      decoration: BoxDecoration(
        color: AppTheme.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.darkGrey.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ads_click,
              color: AppTheme.darkGrey.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              'Reklam Yüklenemedi',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.darkGrey.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Large Banner Ad Widget (for main pages)
class LargeBannerAdWidget extends StatelessWidget {
  final EdgeInsets? margin;
  
  const LargeBannerAdWidget({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AdMobBannerWidget(
      adSize: AdSize.largeBanner,
      margin: margin,
    );
  }
}

/// Medium Rectangle Ad Widget (for sidebars)
class MediumRectangleAdWidget extends StatelessWidget {
  final EdgeInsets? margin;
  
  const MediumRectangleAdWidget({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AdMobBannerWidget(
      adSize: AdSize.mediumRectangle,
      margin: margin,
    );
  }
}
