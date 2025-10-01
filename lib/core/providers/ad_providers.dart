import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admob_service.dart';
import '../providers/subscription_providers.dart';

// AdMob Service Provider
final adMobServiceProvider = Provider<AdMobService>((ref) {
  return AdMobService.instance;
});

// Wrong Answer Counter Provider
class WrongAnswerCounterNotifier extends StateNotifier<int> {
  WrongAnswerCounterNotifier() : super(0);

  void increment() {
    state++;
  }

  void reset() {
    state = 0;
  }

  bool get shouldShowAd => state > 0 && state % 3 == 0;
}

final wrongAnswerCounterProvider = StateNotifierProvider<WrongAnswerCounterNotifier, int>((ref) {
  return WrongAnswerCounterNotifier();
});

// Question Counter Provider for Random Questions Practice
class QuestionCounterNotifier extends StateNotifier<int> {
  QuestionCounterNotifier() : super(0);

  void increment() {
    state++;
  }

  void reset() {
    state = 0;
  }

  bool get shouldShowAd => state > 0 && state % 4 == 0;
}

final questionCounterProvider = StateNotifierProvider<QuestionCounterNotifier, int>((ref) {
  return QuestionCounterNotifier();
});

// Mini Questions Counter Provider
class MiniQuestionsCounterNotifier extends StateNotifier<int> {
  MiniQuestionsCounterNotifier() : super(0);

  void increment() {
    state++;
  }

  void reset() {
    state = 0;
  }

  bool get shouldShowAdAfter5 => state >= 5;
}

final miniQuestionsCounterProvider = StateNotifierProvider<MiniQuestionsCounterNotifier, int>((ref) {
  return MiniQuestionsCounterNotifier();
});

// Ad Display Provider
class AdDisplayNotifier extends StateNotifier<bool> {
  final Ref _ref;
  
  AdDisplayNotifier(this._ref) : super(false);

  /// Show ad if conditions are met (every 3rd wrong answer and user is not premium)
  Future<bool> showAdIfNeeded() async {
    final wrongAnswerCount = _ref.read(wrongAnswerCounterProvider);
    final isPremium = _ref.read(isPremiumUserProvider);
    
    print('[AdDisplayNotifier] Wrong answer count: $wrongAnswerCount');
    print('[AdDisplayNotifier] Is premium: $isPremium');
    
    // Don't show ads to premium users
    if (isPremium) {
      print('[AdDisplayNotifier] User is premium, skipping ad');
      return false;
    }
    
    // Show ad every 3rd wrong answer
    if (wrongAnswerCount > 0 && wrongAnswerCount % 3 == 0) {
      print('[AdDisplayNotifier] Showing ad for wrong answer #$wrongAnswerCount');
      return await _showInterstitialAd();
    }
    
    return false;
  }

  /// Show interstitial ad
  Future<bool> _showInterstitialAd() async {
    try {
      final adMobService = _ref.read(adMobServiceProvider);
      
      // Try to load ad if not already loaded
      if (!adMobService.isInterstitialAdLoaded) {
        print('[AdDisplayNotifier] Loading interstitial ad...');
        await adMobService.loadInterstitialAd();
        // Wait a bit for ad to load
        await Future.delayed(const Duration(milliseconds: 1500));
      }
      
      // Show ad if loaded
      if (adMobService.isInterstitialAdLoaded) {
        print('[AdDisplayNotifier] Showing interstitial ad...');
        state = true; // Set loading state
        final success = await adMobService.showInterstitialAd();
        state = false; // Clear loading state
        print('[AdDisplayNotifier] Ad show result: $success');
        return success;
      } else {
        print('[AdDisplayNotifier] Ad not loaded, skipping');
        return false;
      }
    } catch (e) {
      print('[AdDisplayNotifier] Error showing ad: $e');
      state = false;
      return false;
    }
  }

  /// Show ad every 4 questions in random practice
  Future<bool> showAdEvery4Questions() async {
    final questionCount = _ref.read(questionCounterProvider);
    final isPremium = _ref.read(isPremiumUserProvider);
    
    print('[AdDisplayNotifier] Question count: $questionCount');
    print('[AdDisplayNotifier] Is premium: $isPremium');
    
    // Don't show ads to premium users
    if (isPremium) {
      print('[AdDisplayNotifier] User is premium, skipping ad');
      return false;
    }
    
    // Show ad every 4th question
    if (questionCount > 0 && questionCount % 4 == 0) {
      print('[AdDisplayNotifier] Showing ad for question #$questionCount');
      return await _showInterstitialAd();
    }
    
    return false;
  }

  /// Force show ad (for testing purposes)
  Future<bool> forceShowAd() async {
    final isPremium = _ref.read(isPremiumUserProvider);
    
    if (isPremium) {
      print('[AdDisplayNotifier] User is premium, cannot force show ad');
      return false;
    }
    
    return await _showInterstitialAd();
  }
}

final adDisplayProvider = StateNotifierProvider<AdDisplayNotifier, bool>((ref) {
  return AdDisplayNotifier(ref);
});

// Ad Status Provider (for UI feedback)
final adStatusProvider = Provider<String>((ref) {
  final wrongAnswerCount = ref.watch(wrongAnswerCounterProvider);
  final isPremium = ref.watch(isPremiumUserProvider);
  final isLoading = ref.watch(adDisplayProvider);
  
  if (isPremium) {
    return 'Premium kullanıcı - Reklam yok';
  }
  
  if (isLoading) {
    return 'Reklam yükleniyor...';
  }
  
  if (wrongAnswerCount > 0 && wrongAnswerCount % 3 == 0) {
    return 'Reklam gösterilecek';
  }
  
  return 'Reklam bekleniyor (${3 - (wrongAnswerCount % 3)} yanlış kaldı)';
});