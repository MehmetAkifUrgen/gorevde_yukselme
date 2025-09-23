import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

/// Platform-specific store types
enum StoreType {
  googlePlay,
  appStore,
  premiumCode,
  unknown,
}

/// Subscription plan types
enum SubscriptionPlan {
  free,
  monthly,
  yearly,
}

/// Premium features available to subscribers
enum PremiumFeature {
  adFree,
  unlimitedQuestions,
  detailedAnalytics,
  offlineMode,
  prioritySupport,
  customStudyPlans,
  advancedFilters,
}

/// Purchase status for tracking transactions
enum PurchaseStatus {
  pending,
  purchased,
  restored,
  failed,
  canceled,
}

/// Subscription model with platform-specific data
@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    required SubscriptionPlan plan,
    required StoreType store,
    required bool isActive,
    required DateTime? expiryDate,
    required List<PremiumFeature> features,
    required double price,
    required String currency,
    required String productId,
    String? originalTransactionId,
    String? purchaseToken,
    DateTime? purchaseDate,
    bool? autoRenewing,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}

/// Product information for in-app purchases
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String title,
    required String description,
    required double price,
    required String priceString,
    required String currency,
    required SubscriptionPlan plan,
    required StoreType store,
    required List<PremiumFeature> features,
    String? introductoryPrice,
    String? introductoryPriceString,
    int? introductoryPricePeriod,
    String? subscriptionPeriod,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

/// Purchase result model
@freezed
class PurchaseResult with _$PurchaseResult {
  const factory PurchaseResult({
    required PurchaseStatus status,
    required String? productId,
    required String? transactionId,
    required String? purchaseToken,
    required DateTime? purchaseDate,
    String? error,
    SubscriptionModel? subscription,
  }) = _PurchaseResult;

  factory PurchaseResult.fromJson(Map<String, dynamic> json) =>
      _$PurchaseResultFromJson(json);
}

/// Platform-specific product IDs
class ProductIds {
  // Google Play Store product IDs
  static const String googlePlayMonthly = 'gorevde_yukselme_monthly';
  static const String googlePlayYearly = 'gorevde_yukselme_yearly';
  
  // App Store product IDs
  static const String appStoreMonthly = 'com.gorevdeyukselme.monthly';
  static const String appStoreYearly = 'com.gorevdeyukselme.yearly';
  
  /// Get product IDs for current platform
  static List<String> getProductIds(StoreType store) {
    switch (store) {
      case StoreType.googlePlay:
        return [googlePlayMonthly, googlePlayYearly];
      case StoreType.appStore:
        return [appStoreMonthly, appStoreYearly];
      case StoreType.premiumCode:
        return []; // Premium codes don't have product IDs
      case StoreType.unknown:
        return [];
    }
  }
  
  /// Get subscription plan from product ID
  static SubscriptionPlan getPlanFromProductId(String productId) {
    if (productId.contains('monthly')) {
      return SubscriptionPlan.monthly;
    } else if (productId.contains('yearly')) {
      return SubscriptionPlan.yearly;
    }
    return SubscriptionPlan.free;
  }
}

/// Premium feature descriptions in Turkish
class PremiumFeatureDescriptions {
  static const Map<PremiumFeature, String> descriptions = {
    PremiumFeature.adFree: 'Reklamsız deneyim',
    PremiumFeature.unlimitedQuestions: 'Sınırsız soru çözme',
    PremiumFeature.detailedAnalytics: 'Detaylı performans analizi',
    PremiumFeature.offlineMode: 'Çevrimdışı çalışma modu',
    PremiumFeature.prioritySupport: 'Öncelikli destek',
    PremiumFeature.customStudyPlans: 'Kişisel çalışma planları',
    PremiumFeature.advancedFilters: 'Gelişmiş filtreleme seçenekleri',
  };
  
  static String getDescription(PremiumFeature feature) {
    return descriptions[feature] ?? 'Premium özellik';
  }
}

/// Subscription plan information
class SubscriptionPlanInfo {
  static const Map<SubscriptionPlan, Map<String, dynamic>> planInfo = {
    SubscriptionPlan.free: {
      'name': 'Ücretsiz',
      'price': 0.0,
      'currency': 'TL',
      'features': [
        PremiumFeature.unlimitedQuestions, // Limited in free version
      ],
      'limitations': {
        'daily_questions': 10,
        'ads': true,
      }
    },
    SubscriptionPlan.monthly: {
      'name': 'Aylık Premium',
      'price': 29.99,
      'currency': 'TL',
      'features': [
        PremiumFeature.adFree,
        PremiumFeature.unlimitedQuestions,
        PremiumFeature.detailedAnalytics,
        PremiumFeature.offlineMode,
        PremiumFeature.prioritySupport,
      ],
    },
    SubscriptionPlan.yearly: {
      'name': 'Yıllık Premium',
      'price': 299.99,
      'currency': 'TL',
      'features': [
        PremiumFeature.adFree,
        PremiumFeature.unlimitedQuestions,
        PremiumFeature.detailedAnalytics,
        PremiumFeature.offlineMode,
        PremiumFeature.prioritySupport,
        PremiumFeature.customStudyPlans,
        PremiumFeature.advancedFilters,
      ],
      'savings': '17% tasarruf',
    },
  };
  
  static Map<String, dynamic>? getPlanInfo(SubscriptionPlan plan) {
    return planInfo[plan];
  }
  
  static List<PremiumFeature> getPlanFeatures(SubscriptionPlan plan) {
    final info = planInfo[plan];
    if (info != null && info['features'] != null) {
      return List<PremiumFeature>.from(info['features']);
    }
    return [];
  }
}