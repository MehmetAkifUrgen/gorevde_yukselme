import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing ad watching and question unlocking functionality
/// Implements the "Watch 3 ads for 5 questions" feature as per PRD requirements
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Stream controllers for ad-related events
  final StreamController<int> _adsWatchedController = 
      StreamController<int>.broadcast();
  final StreamController<int> _unlockedQuestionsController = 
      StreamController<int>.broadcast();
  
  // Constants as per PRD requirements
  static const int adsRequiredForUnlock = 3;
  static const int questionsUnlockedPerAdSet = 5;
  
  // Current state
  int _adsWatchedToday = 0;
  int _unlockedQuestionsToday = 0;
  DateTime _lastAdDate = DateTime.now();
  
  // Getters
  int get adsWatchedToday => _adsWatchedToday;
  int get unlockedQuestionsToday => _unlockedQuestionsToday;
  int get adsRemainingForUnlock => 
      (adsRequiredForUnlock - (_adsWatchedToday % adsRequiredForUnlock))
          .clamp(0, adsRequiredForUnlock);
  
  // Streams
  Stream<int> get adsWatchedStream => _adsWatchedController.stream;
  Stream<int> get unlockedQuestionsStream => _unlockedQuestionsController.stream;
  
  /// Initialize the ad service
  Future<void> initialize() async {
    await _loadAdData();
    debugPrint('AdService initialized - Ads watched: $_adsWatchedToday, Unlocked questions: $_unlockedQuestionsToday');
  }
  
  /// Check if user can unlock more questions by watching ads
  bool canUnlockMoreQuestions() {
    _checkDailyReset();
    return _adsWatchedToday % adsRequiredForUnlock != 0 || 
           _adsWatchedToday < adsRequiredForUnlock * 10; // Allow up to 10 sets per day
  }
  
  /// Simulate watching an ad and return if questions were unlocked
  Future<bool> watchAd() async {
    _checkDailyReset();
    
    // Simulate ad watching delay
    await Future.delayed(const Duration(seconds: 2));
    
    _adsWatchedToday++;
    await _saveAdData();
    
    // Notify listeners about ads watched
    _adsWatchedController.add(_adsWatchedToday);
    
    // Check if we've watched enough ads to unlock questions
    if (_adsWatchedToday % adsRequiredForUnlock == 0) {
      _unlockedQuestionsToday += questionsUnlockedPerAdSet;
      await _saveAdData();
      
      // Notify listeners about unlocked questions
      _unlockedQuestionsController.add(_unlockedQuestionsToday);
      
      debugPrint('Questions unlocked! Total unlocked today: $_unlockedQuestionsToday');
      return true;
    }
    
    debugPrint('Ad watched. Progress: ${_adsWatchedToday % adsRequiredForUnlock}/$adsRequiredForUnlock');
    return false;
  }
  
  /// Get the number of ads needed to unlock next set of questions
  int getAdsNeededForNextUnlock() {
    return adsRequiredForUnlock - (_adsWatchedToday % adsRequiredForUnlock);
  }
  
  /// Get total available questions for today (including unlocked ones)
  int getTotalAvailableQuestions(int baseLimit) {
    _checkDailyReset();
    return baseLimit + _unlockedQuestionsToday;
  }
  
  /// Check if user has unlocked questions available
  bool hasUnlockedQuestions() {
    _checkDailyReset();
    return _unlockedQuestionsToday > 0;
  }
  
  /// Consume an unlocked question (called when user answers a question beyond base limit)
  Future<void> consumeUnlockedQuestion() async {
    if (_unlockedQuestionsToday > 0) {
      _unlockedQuestionsToday--;
      await _saveAdData();
      _unlockedQuestionsController.add(_unlockedQuestionsToday);
      debugPrint('Unlocked question consumed. Remaining: $_unlockedQuestionsToday');
    }
  }
  
  /// Reset daily counters if it's a new day
  void _checkDailyReset() {
    final now = DateTime.now();
    final lastDate = DateTime(_lastAdDate.year, _lastAdDate.month, _lastAdDate.day);
    final currentDate = DateTime(now.year, now.month, now.day);
    
    if (currentDate.isAfter(lastDate)) {
      _adsWatchedToday = 0;
      _unlockedQuestionsToday = 0;
      _lastAdDate = now;
      _saveAdData();
      
      // Notify listeners about reset
      _adsWatchedController.add(_adsWatchedToday);
      _unlockedQuestionsController.add(_unlockedQuestionsToday);
      
      debugPrint('Daily ad counters reset');
    }
  }
  
  /// Load ad data from storage
  Future<void> _loadAdData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _adsWatchedToday = prefs.getInt('ads_watched_today') ?? 0;
      _unlockedQuestionsToday = prefs.getInt('unlocked_questions_today') ?? 0;
      
      final lastDateString = prefs.getString('last_ad_date');
      if (lastDateString != null) {
        _lastAdDate = DateTime.parse(lastDateString);
      }
      
      // Check if we need to reset for new day
      _checkDailyReset();
    } catch (e) {
      debugPrint('Error loading ad data: $e');
    }
  }
  
  /// Save ad data to storage
  Future<void> _saveAdData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ads_watched_today', _adsWatchedToday);
      await prefs.setInt('unlocked_questions_today', _unlockedQuestionsToday);
      await prefs.setString('last_ad_date', _lastAdDate.toIso8601String());
    } catch (e) {
      debugPrint('Error saving ad data: $e');
    }
  }
  
  /// Get ad progress message for UI
  String getAdProgressMessage() {
    final remaining = getAdsNeededForNextUnlock();
    if (remaining == adsRequiredForUnlock) {
      return 'İzle $adsRequiredForUnlock reklam, $questionsUnlockedPerAdSet soru kazan';
    } else {
      return '$remaining reklam daha izle, $questionsUnlockedPerAdSet soru kazan';
    }
  }
  
  /// Dispose resources
  void dispose() {
    _adsWatchedController.close();
    _unlockedQuestionsController.close();
  }
}