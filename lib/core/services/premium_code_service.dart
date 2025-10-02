import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';

/// Service for handling premium codes (promo codes, gift codes, etc.)
class PremiumCodeService {
  static final PremiumCodeService _instance = PremiumCodeService._internal();
  factory PremiumCodeService() => _instance;
  PremiumCodeService._internal();

  static const String _usedCodesKey = 'used_premium_codes';
  static const String _premiumCodeKey = 'premium_code_subscription';
  
  // Stream controller for premium code status changes
  final StreamController<PremiumCodeResult> _codeResultController = 
      StreamController<PremiumCodeResult>.broadcast();
  
  // Getters
  Stream<PremiumCodeResult> get codeResultStream => _codeResultController.stream;
  
  /// Validate and redeem a premium code
  Future<PremiumCodeResult> redeemCode(String code) async {
    try {
      // Clean the code
      final cleanCode = code.trim().toUpperCase();
      
      if (cleanCode.isEmpty) {
        return PremiumCodeResult(
          success: false,
          message: 'Kod boş olamaz',
          subscription: null,
        );
      }
      
      // Check if code is already used
      final isUsed = await _isCodeUsed(cleanCode);
      if (isUsed) {
        return PremiumCodeResult(
          success: false,
          message: 'Bu kod daha önce kullanılmış',
          subscription: null,
        );
      }
      
      // Validate code format and content
      final validationResult = _validateCode(cleanCode);
      if (!validationResult.isValid) {
        return PremiumCodeResult(
          success: false,
          message: validationResult.errorMessage,
          subscription: null,
        );
      }
      
      // Create subscription from code
      final subscription = _createSubscriptionFromCode(cleanCode);
      
      // Save the subscription
      await _savePremiumCodeSubscription(subscription);
      
      // Mark code as used
      await _markCodeAsUsed(cleanCode);
      
      // Emit success result
      final result = PremiumCodeResult(
        success: true,
        message: 'Premium kod başarıyla kullanıldı!',
        subscription: subscription,
      );
      
      _codeResultController.add(result);
      
      debugPrint('Premium code redeemed successfully: $cleanCode');
      return result;
      
    } catch (e) {
      debugPrint('Error redeeming premium code: $e');
      final result = PremiumCodeResult(
        success: false,
        message: 'Kod kullanılırken bir hata oluştu: ${e.toString()}',
        subscription: null,
      );
      _codeResultController.add(result);
      return result;
    }
  }
  
  /// Check if a code is already used
  Future<bool> _isCodeUsed(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usedCodesJson = prefs.getString(_usedCodesKey);
      
      if (usedCodesJson == null) return false;
      
      final List<dynamic> usedCodes = jsonDecode(usedCodesJson);
      return usedCodes.contains(code);
    } catch (e) {
      debugPrint('Error checking if code is used: $e');
      return false;
    }
  }
  
  /// Mark a code as used
  Future<void> _markCodeAsUsed(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usedCodesJson = prefs.getString(_usedCodesKey);
      
      List<String> usedCodes = [];
      if (usedCodesJson != null) {
        final List<dynamic> decoded = jsonDecode(usedCodesJson);
        usedCodes = decoded.cast<String>();
      }
      
      usedCodes.add(code);
      
      await prefs.setString(_usedCodesKey, jsonEncode(usedCodes));
      debugPrint('Code marked as used: $code');
    } catch (e) {
      debugPrint('Error marking code as used: $e');
    }
  }
  
  /// Validate code format and content
  CodeValidationResult _validateCode(String code) {
    // Basic format validation
    if (code.length < 8) {
      return CodeValidationResult(
        isValid: false,
        errorMessage: 'Kod en az 8 karakter olmalıdır',
      );
    }
    
    if (code.length > 20) {
      return CodeValidationResult(
        isValid: false,
        errorMessage: 'Kod en fazla 20 karakter olabilir',
      );
    }
    
    // Check for valid characters (alphanumeric and some special chars)
    final validPattern = RegExp(r'^[A-Z0-9\-_]+$');
    if (!validPattern.hasMatch(code)) {
      return CodeValidationResult(
        isValid: false,
        errorMessage: 'Kod sadece büyük harf, rakam, tire ve alt çizgi içerebilir',
      );
    }
    
    // Check for specific code patterns
    if (code.startsWith('GYUD-')) {
      // Official app codes
      return CodeValidationResult(isValid: true);
    } else if (code.startsWith('PROMO-')) {
      // Promo codes
      return CodeValidationResult(isValid: true);
    } else if (code.startsWith('GIFT-')) {
      // Gift codes
      return CodeValidationResult(isValid: true);
    } else if (code.startsWith('TEST-')) {
      // Test codes (only in debug mode)
      if (kDebugMode) {
        return CodeValidationResult(isValid: true);
      } else {
        return CodeValidationResult(
          isValid: false,
          errorMessage: 'Test kodları sadece geliştirme modunda kullanılabilir',
        );
      }
    } else {
      // Generic validation for other formats
      return CodeValidationResult(isValid: true);
    }
  }
  
  /// Create subscription from code
  SubscriptionModel _createSubscriptionFromCode(String code) {
    SubscriptionPlan plan;
    int durationDays;
    
    // Determine plan and duration based on code prefix
    if (code.startsWith('GYUD-MONTHLY-')) {
      plan = SubscriptionPlan.monthly;
      durationDays = 30;
    } else if (code.startsWith('GYUD-QUARTERLY-')) {
      plan = SubscriptionPlan.quarterly;
      durationDays = 90;
    } else if (code.startsWith('PROMO-')) {
      // Promo codes are usually monthly
      plan = SubscriptionPlan.monthly;
      durationDays = 30;
    } else if (code.startsWith('GIFT-')) {
      // Gift codes can be quarterly
      plan = SubscriptionPlan.quarterly;
      durationDays = 90;
    } else if (code.startsWith('TEST-')) {
      // Test codes are monthly
      plan = SubscriptionPlan.monthly;
      durationDays = 30;
    } else {
      // Default to monthly
      plan = SubscriptionPlan.monthly;
      durationDays = 30;
    }
    
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: durationDays));
    
    return SubscriptionModel(
      id: 'code_${code}_${now.millisecondsSinceEpoch}',
      plan: plan,
      store: StoreType.premiumCode,
      isActive: true,
      expiryDate: expiryDate,
      features: SubscriptionPlanInfo.getPlanFeatures(plan),
      price: 0.0, // Free with code
      currency: 'TL',
      productId: code,
      originalTransactionId: code,
      purchaseToken: code,
      purchaseDate: now,
      autoRenewing: false, // Codes don't auto-renew
    );
  }
  
  /// Save premium code subscription
  Future<void> _savePremiumCodeSubscription(SubscriptionModel subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = jsonEncode(subscription.toJson());
      await prefs.setString(_premiumCodeKey, subscriptionJson);
      debugPrint('Premium code subscription saved');
    } catch (e) {
      debugPrint('Error saving premium code subscription: $e');
    }
  }
  
  /// Get premium code subscription
  Future<SubscriptionModel?> getPremiumCodeSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = prefs.getString(_premiumCodeKey);
      
      if (subscriptionJson == null) return null;
      
      final Map<String, dynamic> subscriptionMap = jsonDecode(subscriptionJson);
      final subscription = SubscriptionModel.fromJson(subscriptionMap);
      
      // Check if subscription is still valid
      if (subscription.expiryDate != null && 
          subscription.expiryDate!.isBefore(DateTime.now())) {
        // Subscription expired, remove it
        await _removePremiumCodeSubscription();
        return null;
      }
      
      return subscription;
    } catch (e) {
      debugPrint('Error getting premium code subscription: $e');
      return null;
    }
  }
  
  /// Remove premium code subscription
  Future<void> _removePremiumCodeSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_premiumCodeKey);
      debugPrint('Premium code subscription removed');
    } catch (e) {
      debugPrint('Error removing premium code subscription: $e');
    }
  }
  
  /// Clear all used codes (for testing)
  Future<void> clearUsedCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usedCodesKey);
      debugPrint('All used codes cleared');
    } catch (e) {
      debugPrint('Error clearing used codes: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _codeResultController.close();
  }
}

/// Result of premium code redemption
class PremiumCodeResult {
  final bool success;
  final String message;
  final SubscriptionModel? subscription;
  
  PremiumCodeResult({
    required this.success,
    required this.message,
    required this.subscription,
  });
}

/// Result of code validation
class CodeValidationResult {
  final bool isValid;
  final String errorMessage;
  
  CodeValidationResult({
    required this.isValid,
    this.errorMessage = '',
  });
}
