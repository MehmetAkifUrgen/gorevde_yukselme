import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/subscription_service.dart';
import '../models/subscription_model.dart';

// Subscription Service Provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

// Current Subscription Provider
final currentSubscriptionProvider = StreamProvider<SubscriptionModel?>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return subscriptionService.subscriptionStream;
});

// Available Products Provider
final availableProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return subscriptionService.productsStream;
});

// Purchase Result Provider
final purchaseResultProvider = StreamProvider<PurchaseResult>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return subscriptionService.purchaseStream;
});

// Is Premium User Provider
final isPremiumUserProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(currentSubscriptionProvider);
  return subscriptionAsync.when(
    data: (subscription) => subscription?.isActive == true &&
        (subscription?.expiryDate?.isAfter(DateTime.now()) ?? false),
    loading: () => false,
    error: (_, __) => false,
  );
});

// Has Premium Feature Provider
final hasPremiumFeatureProvider = Provider.family<bool, PremiumFeature>((ref, feature) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return subscriptionService.hasPremiumFeature(feature);
});

// Subscription Status Provider
final subscriptionStatusProvider = Provider<String>((ref) {
  final subscriptionAsync = ref.watch(currentSubscriptionProvider);
  return subscriptionAsync.when(
    data: (subscription) {
      if (subscription == null) return 'Ücretsiz';
      if (!subscription.isActive) return 'Pasif';
      if (subscription.expiryDate?.isBefore(DateTime.now()) ?? false) {
        return 'Süresi Dolmuş';
      }
      return 'Aktif';
    },
    loading: () => 'Yükleniyor...',
    error: (_, __) => 'Hata',
  );
});

// Subscription Plan Provider
final subscriptionPlanProvider = Provider<SubscriptionPlan>((ref) {
  final subscriptionAsync = ref.watch(currentSubscriptionProvider);
  return subscriptionAsync.when(
    data: (subscription) => subscription?.plan ?? SubscriptionPlan.free,
    loading: () => SubscriptionPlan.free,
    error: (_, __) => SubscriptionPlan.free,
  );
});

// Days Until Expiry Provider
final daysUntilExpiryProvider = Provider<int?>((ref) {
  final subscriptionAsync = ref.watch(currentSubscriptionProvider);
  return subscriptionAsync.when(
    data: (subscription) {
      if (subscription?.expiryDate == null) return null;
      final now = DateTime.now();
      final expiry = subscription!.expiryDate!;
      return expiry.difference(now).inDays;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
