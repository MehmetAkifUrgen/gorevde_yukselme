// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionModelImpl _$$SubscriptionModelImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionModelImpl(
  id: json['id'] as String,
  plan: $enumDecode(_$SubscriptionPlanEnumMap, json['plan']),
  store: $enumDecode(_$StoreTypeEnumMap, json['store']),
  isActive: json['isActive'] as bool,
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  features: (json['features'] as List<dynamic>)
      .map((e) => $enumDecode(_$PremiumFeatureEnumMap, e))
      .toList(),
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String,
  productId: json['productId'] as String,
  originalTransactionId: json['originalTransactionId'] as String?,
  purchaseToken: json['purchaseToken'] as String?,
  purchaseDate: json['purchaseDate'] == null
      ? null
      : DateTime.parse(json['purchaseDate'] as String),
  autoRenewing: json['autoRenewing'] as bool?,
);

Map<String, dynamic> _$$SubscriptionModelImplToJson(
  _$SubscriptionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'plan': _$SubscriptionPlanEnumMap[instance.plan]!,
  'store': _$StoreTypeEnumMap[instance.store]!,
  'isActive': instance.isActive,
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'features': instance.features
      .map((e) => _$PremiumFeatureEnumMap[e]!)
      .toList(),
  'price': instance.price,
  'currency': instance.currency,
  'productId': instance.productId,
  'originalTransactionId': instance.originalTransactionId,
  'purchaseToken': instance.purchaseToken,
  'purchaseDate': instance.purchaseDate?.toIso8601String(),
  'autoRenewing': instance.autoRenewing,
};

const _$SubscriptionPlanEnumMap = {
  SubscriptionPlan.free: 'free',
  SubscriptionPlan.monthly: 'monthly',
  SubscriptionPlan.yearly: 'yearly',
};

const _$StoreTypeEnumMap = {
  StoreType.googlePlay: 'googlePlay',
  StoreType.appStore: 'appStore',
  StoreType.premiumCode: 'premiumCode',
  StoreType.unknown: 'unknown',
};

const _$PremiumFeatureEnumMap = {
  PremiumFeature.adFree: 'adFree',
  PremiumFeature.unlimitedQuestions: 'unlimitedQuestions',
  PremiumFeature.detailedAnalytics: 'detailedAnalytics',
  PremiumFeature.offlineMode: 'offlineMode',
  PremiumFeature.prioritySupport: 'prioritySupport',
  PremiumFeature.customStudyPlans: 'customStudyPlans',
  PremiumFeature.advancedFilters: 'advancedFilters',
};

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      priceString: json['priceString'] as String,
      currency: json['currency'] as String,
      plan: $enumDecode(_$SubscriptionPlanEnumMap, json['plan']),
      store: $enumDecode(_$StoreTypeEnumMap, json['store']),
      features: (json['features'] as List<dynamic>)
          .map((e) => $enumDecode(_$PremiumFeatureEnumMap, e))
          .toList(),
      introductoryPrice: json['introductoryPrice'] as String?,
      introductoryPriceString: json['introductoryPriceString'] as String?,
      introductoryPricePeriod: (json['introductoryPricePeriod'] as num?)
          ?.toInt(),
      subscriptionPeriod: json['subscriptionPeriod'] as String?,
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'priceString': instance.priceString,
      'currency': instance.currency,
      'plan': _$SubscriptionPlanEnumMap[instance.plan]!,
      'store': _$StoreTypeEnumMap[instance.store]!,
      'features': instance.features
          .map((e) => _$PremiumFeatureEnumMap[e]!)
          .toList(),
      'introductoryPrice': instance.introductoryPrice,
      'introductoryPriceString': instance.introductoryPriceString,
      'introductoryPricePeriod': instance.introductoryPricePeriod,
      'subscriptionPeriod': instance.subscriptionPeriod,
    };

_$PurchaseResultImpl _$$PurchaseResultImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseResultImpl(
      status: $enumDecode(_$PurchaseStatusEnumMap, json['status']),
      productId: json['productId'] as String?,
      transactionId: json['transactionId'] as String?,
      purchaseToken: json['purchaseToken'] as String?,
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      error: json['error'] as String?,
      subscription: json['subscription'] == null
          ? null
          : SubscriptionModel.fromJson(
              json['subscription'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$PurchaseResultImplToJson(
  _$PurchaseResultImpl instance,
) => <String, dynamic>{
  'status': _$PurchaseStatusEnumMap[instance.status]!,
  'productId': instance.productId,
  'transactionId': instance.transactionId,
  'purchaseToken': instance.purchaseToken,
  'purchaseDate': instance.purchaseDate?.toIso8601String(),
  'error': instance.error,
  'subscription': instance.subscription,
};

const _$PurchaseStatusEnumMap = {
  PurchaseStatus.pending: 'pending',
  PurchaseStatus.purchased: 'purchased',
  PurchaseStatus.restored: 'restored',
  PurchaseStatus.failed: 'failed',
  PurchaseStatus.canceled: 'canceled',
};
