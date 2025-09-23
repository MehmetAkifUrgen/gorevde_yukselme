import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();
  
  AdMobService._();

  // Test Ad Unit ID - Production'da gerçek ID kullanılacak
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  // Production Ad Unit ID - Firebase Console'dan alınacak
  static const String _productionInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // TODO: Replace with real ID
  
  InterstitialAd? _interstitialAd;
  bool _isInitialized = false;
  
  // Get appropriate ad unit ID based on platform and environment
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _productionInterstitialAdUnitId; // TODO: Replace with real Android ID
    } else if (Platform.isIOS) {
      return _productionInterstitialAdUnitId; // TODO: Replace with real iOS ID
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
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        print('[AdMobService] Cannot load ad - AdMob not initialized');
        return;
      }
    }
    
    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            print('[AdMobService] Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            print('[AdMobService] Failed to load interstitial ad: $error');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      print('[AdMobService] Error loading interstitial ad: $e');
      _interstitialAd = null;
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
          // Load next ad for future use
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('[AdMobService] Failed to show interstitial ad: $error');
          ad.dispose();
          _interstitialAd = null;
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

  /// Dispose all ads
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
