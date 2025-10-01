import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';
import 'subscription_service.dart';
import 'ad_service.dart';

/// Service for managing premium feature access and restrictions
class PremiumFeaturesService {
  static final PremiumFeaturesService _instance = PremiumFeaturesService._internal();
  factory PremiumFeaturesService() => _instance;
  PremiumFeaturesService._internal();

  final SubscriptionService _subscriptionService = SubscriptionService();
  final AdService _adService = AdService();
  late StreamSubscription<SubscriptionModel?> _subscriptionSubscription;
  
  // Stream controller for premium status changes
  final StreamController<bool> _premiumStatusController = 
      StreamController<bool>.broadcast();
  
  // Current premium status
  bool _isPremium = false;
  SubscriptionModel? _currentSubscription;
  
  // Constants for free tier limits
  static const int maxDailyQuestions = 5;
  static const int maxBookmarks = 10;
  static const int maxStudySets = 3;
  
  // Getters
  bool get isPremium => _isPremium;
  SubscriptionModel? get currentSubscription => _currentSubscription;
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;
  
  /// Initialize the premium features service
  Future<void> initialize() async {
    await _loadUsageData();
    await _adService.initialize();
    
    // Listen to subscription changes
    _subscriptionSubscription = _subscriptionService.subscriptionStream.listen(
      (subscription) {
        _updatePremiumStatus(subscription);
      },
    );
    
    // Check current subscription status
    await _subscriptionService.initialize();
    _updatePremiumStatus(_subscriptionService.currentSubscription);
  }
  
  /// Update premium status based on subscription
  void _updatePremiumStatus(SubscriptionModel? subscription) {
    final wasPremium = _isPremium;
    _currentSubscription = subscription;
    _isPremium = subscription?.isActive ?? false;
    
    if (wasPremium != _isPremium) {
      _premiumStatusController.add(_isPremium);
      debugPrint('Premium status changed: $_isPremium');
    }
  }
  
  /// Check if ads should be shown
  bool shouldShowAds() {
    return !_isPremium;
  }
  
  /// Check if user can ask more questions today
  bool canAskQuestion() {
    // Günlük limit kaldırıldı - tüm kullanıcılar sınırsız soru sorabilir
    return true;
  }
  
  /// Get remaining questions for today
  int getRemainingQuestions() {
    // Günlük limit kaldırıldı - sınırsız soru
    return -1; // Unlimited
  }
  
  /// Record a question asked
  Future<void> recordQuestionAsked() async {
    // Günlük limit kaldırıldı - soru sayısı kaydedilmiyor
    return;
  }
  
  /// Check if user can create more bookmarks
  Future<bool> canCreateBookmark() async {
    if (_isPremium) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final bookmarkCount = prefs.getInt('bookmark_count') ?? 0;
    return bookmarkCount < maxBookmarks;
  }
  
  /// Check if user can create more study sets
  Future<bool> canCreateStudySet() async {
    if (_isPremium) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final studySetCount = prefs.getInt('study_set_count') ?? 0;
    return studySetCount < maxStudySets;
  }
  
  /// Get premium features list
  List<String> getPremiumFeatures() {
    return [
      'Sınırsız soru sorma',
      'Reklamsız deneyim',
      'Sınırsız yer imi',
      'Sınırsız çalışma seti',
      'Gelişmiş istatistikler',
      'Öncelikli destek',
      'Özel temalar',
      'Çevrimdışı erişim',
    ];
  }
  
  /// Get feature restriction message
  String getRestrictionMessage(String feature) {
    switch (feature) {
      case 'questions':
        if (_adService.canUnlockMoreQuestions()) {
          return 'Günlük soru limitiniz doldu. ${_adService.getAdProgressMessage()} veya Premium üyelik alın.';
        }
        return 'Günlük soru limitiniz doldu. Premium üyelik ile sınırsız soru sorabilirsiniz.';
      case 'bookmarks':
        return 'Maksimum $maxBookmarks yer imi oluşturabilirsiniz. Premium üyelik ile sınırsız yer imi ekleyebilirsiniz.';
      case 'study_sets':
        return 'Maksimum $maxStudySets çalışma seti oluşturabilirsiniz. Premium üyelik ile sınırsız set oluşturabilirsiniz.';
      case 'ads':
        return 'Premium üyelik ile reklamsız deneyimin keyfini çıkarın.';
      default:
        return 'Bu özellik premium üyeler için ayrılmıştır.';
    }
  }
  
  /// Get ad service instance for external access
  AdService get adService => _adService;
  
  /// Check if user can unlock questions via ads
  bool canUnlockQuestionsViaAds() {
    return !_isPremium && _adService.canUnlockMoreQuestions();
  }
  
  /// Get total available questions including ad-unlocked ones
  int getTotalAvailableQuestions() {
    if (_isPremium) return -1; // Unlimited
    return _adService.getTotalAvailableQuestions(maxDailyQuestions);
  }
  
  /// Get ad progress information for UI
  Map<String, dynamic> getAdProgressInfo() {
    return {
      'canUnlock': canUnlockQuestionsViaAds(),
      'adsWatched': _adService.adsWatchedToday,
      'adsNeeded': _adService.getAdsNeededForNextUnlock(),
      'unlockedQuestions': _adService.unlockedQuestionsToday,
      'progressMessage': _adService.getAdProgressMessage(),
    };
  }
  
  
  /// Load usage data from storage
  Future<void> _loadUsageData() async {
    // Günlük limit kaldırıldı - veri yükleme gerekmiyor
    return;
  }
  
  
  /// Dispose resources
  void dispose() {
    _subscriptionSubscription.cancel();
    _premiumStatusController.close();
  }
}