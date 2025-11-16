import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

enum AdPlacement {
  exam,
  randomPractice,
  aiPractice,
}

class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();
  
  AdMobService._();

  // Test Ad Unit IDs
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  // Production Ad Unit IDs (fallbacks)
  static const String _productionInterstitialAdUnitIdAndroid = 'ca-app-pub-9923309503448713/7981855426';
  static const String _productionInterstitialAdUnitIdIOS = 'ca-app-pub-9923309503448713/1405565133';

  static const Map<AdPlacement, String> _iosInterstitialUnitIds = {
    AdPlacement.exam: _productionInterstitialAdUnitIdIOS,
    AdPlacement.randomPractice: 'ca-app-pub-9923309503448713/2338031520',
    AdPlacement.aiPractice: 'ca-app-pub-9923309503448713/5819887630',
  };

  static const Map<AdPlacement, String> _androidInterstitialUnitIds = {
    AdPlacement.exam: 'ca-app-pub-9923309503448713/2104003903',
    AdPlacement.randomPractice: 'ca-app-pub-9923309503448713/7981855426',
    AdPlacement.aiPractice: 'ca-app-pub-9923309503448713/1768961985',
  };
  
  InterstitialAd? _interstitialAd;
  AdPlacement? _currentPlacement;
  bool _isInitialized = false;
  
  // Get appropriate ad unit ID based on platform, environment, and placement
  String _getAdUnitId(AdPlacement placement) {
    if (Platform.isAndroid) {
      return _androidInterstitialUnitIds[placement] ?? _productionInterstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _iosInterstitialUnitIds[placement] ?? _productionInterstitialAdUnitIdIOS;
    }
    return _testInterstitialAdUnitId;
  }

  /// Initialize AdMob SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('[AdMobService] AdMob SDK initialized successfully');
    } catch (e) {
      print('[AdMobService] Failed to initialize AdMob SDK: $e');
      // Don't crash the app if AdMob fails to initialize
      _isInitialized = false;
      await FirebaseCrashlytics.instance.recordError(
        e,
        null,
        fatal: false,
        information: ['AdMob initialization failed'],
      );
    }
  }

  /// Load interstitial ad
  Future<void> loadInterstitialAd({required AdPlacement placement}) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        print('[AdMobService] Cannot load ad - AdMob not initialized');
        return;
      }
    }

    // Dispose previously loaded ad if placement changed
    if (_interstitialAd != null && _currentPlacement != placement) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
    }

    try {
      await InterstitialAd.load(
        adUnitId: _getAdUnitId(placement),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _currentPlacement = placement;
            print('[AdMobService] Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            print('[AdMobService] Failed to load interstitial ad: $error');
            _interstitialAd = null;
            _currentPlacement = null;
          },
        ),
      );
    } catch (e) {
      print('[AdMobService] Error loading interstitial ad: $e');
      _interstitialAd = null;
      _currentPlacement = null;
      await FirebaseCrashlytics.instance.recordError(
        e,
        null,
        fatal: false,
        information: ['Interstitial ad load failed'],
      );
    }
  }

  /// Show interstitial ad
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd == null) {
      print('[AdMobService] No interstitial ad available to show');
      return false;
    }
    
    try {
      bool adShown = false;
      
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('[AdMobService] Interstitial ad showed full screen content');
          adShown = true;
        },
        onAdDismissedFullScreenContent: (ad) {
          print('[AdMobService] Interstitial ad dismissed');
          ad.dispose();
          _interstitialAd = null;
          final AdPlacement? placement = _currentPlacement;
          _currentPlacement = null;
          // Load next ad for future use
          if (placement != null) {
            loadInterstitialAd(placement: placement);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('[AdMobService] Failed to show interstitial ad: $error');
          ad.dispose();
          _interstitialAd = null;
          _currentPlacement = null;
        },
      );
      
      await _interstitialAd!.show();
      return adShown;
    } catch (e) {
      print('[AdMobService] Error showing interstitial ad: $e');
      await FirebaseCrashlytics.instance.recordError(
        e,
        null,
        fatal: false,
        information: ['Interstitial ad show failed'],
      );
      return false;
    }
  }

  /// Check if interstitial ad is loaded
  bool get isInterstitialAdLoaded => _interstitialAd != null;

  bool isAdLoadedForPlacement(AdPlacement placement) {
    return _interstitialAd != null && _currentPlacement == placement;
  }

  /// Dispose all ads
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
