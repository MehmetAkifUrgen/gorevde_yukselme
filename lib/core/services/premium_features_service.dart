import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';
import 'subscription_service.dart';

/// Service for managing premium feature access and restrictions
class PremiumFeaturesService {
  static final PremiumFeaturesService _instance = PremiumFeaturesService._internal();
  factory PremiumFeaturesService() => _instance;
  PremiumFeaturesService._internal();

  final SubscriptionService _subscriptionService = SubscriptionService();
  late StreamSubscription<SubscriptionModel?> _subscriptionSubscription;
  
  // Stream controller for premium status changes
  final StreamController<bool> _premiumStatusController = 
      StreamController<bool>.broadcast();
  
  // Current premium status
  bool _isPremium = false;
  SubscriptionModel? _currentSubscription;
  
  // Feature usage tracking
  int _dailyQuestionCount = 0;
  DateTime _lastQuestionDate = DateTime.now();
  
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
    if (_isPremium) return true;
    
    _checkDailyReset();
    return _dailyQuestionCount < maxDailyQuestions;
  }
  
  /// Get remaining questions for today
  int getRemainingQuestions() {
    if (_isPremium) return -1; // Unlimited
    
    _checkDailyReset();
    return (maxDailyQuestions - _dailyQuestionCount).clamp(0, maxDailyQuestions);
  }
  
  /// Record a question asked
  Future<void> recordQuestionAsked() async {
    if (_isPremium) return;
    
    _checkDailyReset();
    _dailyQuestionCount++;
    await _saveUsageData();
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
  
  /// Check and reset daily counters if needed
  void _checkDailyReset() {
    final now = DateTime.now();
    final lastDate = DateTime(_lastQuestionDate.year, _lastQuestionDate.month, _lastQuestionDate.day);
    final currentDate = DateTime(now.year, now.month, now.day);
    
    if (currentDate.isAfter(lastDate)) {
      _dailyQuestionCount = 0;
      _lastQuestionDate = now;
      _saveUsageData();
    }
  }
  
  /// Load usage data from storage
  Future<void> _loadUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyQuestionCount = prefs.getInt('daily_question_count') ?? 0;
      final lastDateString = prefs.getString('last_question_date');
      if (lastDateString != null) {
        _lastQuestionDate = DateTime.parse(lastDateString);
      }
    } catch (e) {
      debugPrint('Error loading usage data: $e');
    }
  }
  
  /// Save usage data to storage
  Future<void> _saveUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('daily_question_count', _dailyQuestionCount);
      await prefs.setString('last_question_date', _lastQuestionDate.toIso8601String());
    } catch (e) {
      debugPrint('Error saving usage data: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _subscriptionSubscription.cancel();
    _premiumStatusController.close();
  }
}