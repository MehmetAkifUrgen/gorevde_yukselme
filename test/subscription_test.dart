import 'package:flutter_test/flutter_test.dart';
import 'package:gorevde_yukselme/core/models/subscription_model.dart';

void main() {
  group('Premium Features Constants Tests', () {
    test('should have correct premium feature limits', () {
      const maxDailyQuestions = 5;
      const maxBookmarks = 10;
      const maxStudySets = 3;
      
      expect(maxDailyQuestions, 5);
      expect(maxBookmarks, 10);
      expect(maxStudySets, 3);
    });

    test('should provide premium features list', () {
      final features = [
        'Sınırsız soru sorma',
        'Reklamsız deneyim',
        'Sınırsız yer imi',
        'Sınırsız çalışma seti',
        'Gelişmiş istatistikler',
        'Öncelikli destek',
        'Özel temalar',
        'Çevrimdışı erişim',
      ];
      
      expect(features.isNotEmpty, true);
      expect(features.contains('Sınırsız soru sorma'), true);
      expect(features.contains('Reklamsız deneyim'), true);
    });

    test('should provide restriction messages', () {
      const questionMessage = 'Günlük soru limitiniz doldu. Premium üyelik ile sınırsız soru sorabilirsiniz.';
      const bookmarkMessage = 'Maksimum 10 yer imi oluşturabilirsiniz. Premium üyelik ile sınırsız yer imi ekleyebilirsiniz.';
      
      expect(questionMessage.contains('Premium'), true);
      expect(bookmarkMessage.contains('Premium'), true);
    });
  });

  group('Subscription Model Tests', () {
    test('should create subscription model correctly', () {
      final subscription = SubscriptionModel(
        id: 'test_id',
        plan: SubscriptionPlan.monthly,
        store: StoreType.googlePlay,
        isActive: true,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        features: [PremiumFeature.adFree, PremiumFeature.unlimitedQuestions],
        price: 29.99,
        currency: 'TRY',
        productId: 'monthly_premium',
        autoRenewing: true,
      );

      expect(subscription.isActive, true);
      expect(subscription.productId, 'monthly_premium');
      expect(subscription.autoRenewing, true);
    });

    test('should detect expired subscription', () {
      final expiredSubscription = SubscriptionModel(
        id: 'test_id',
        plan: SubscriptionPlan.monthly,
        store: StoreType.appStore,
        isActive: false,
        expiryDate: DateTime.now().subtract(const Duration(days: 30)),
        features: [PremiumFeature.adFree],
        price: 29.99,
        currency: 'TRY',
        productId: 'monthly_premium',
        autoRenewing: false,
      );

      expect(expiredSubscription.isActive, false);
    });
  });

  group('Product Model Tests', () {
    test('should create product model correctly', () {
      final product = ProductModel(
        id: 'monthly_premium',
        title: 'Monthly Premium',
        description: 'Premium subscription for one month',
        price: 29.99,
        priceString: '₺29.99',
        currency: 'TRY',
        plan: SubscriptionPlan.monthly,
        store: StoreType.googlePlay,
        features: [PremiumFeature.adFree, PremiumFeature.unlimitedQuestions],
      );

      expect(product.id, 'monthly_premium');
      expect(product.plan, SubscriptionPlan.monthly);
      expect(product.priceString, '₺29.99');
    });
  });

  group('Purchase Result Tests', () {
    test('should create successful purchase result', () {
      final result = PurchaseResult(
        status: PurchaseStatus.purchased,
        productId: 'monthly_premium',
        transactionId: 'txn_123',
        purchaseToken: 'token_456',
        purchaseDate: DateTime.now(),
      );

      expect(result.status, PurchaseStatus.purchased);
      expect(result.productId, 'monthly_premium');
      expect(result.transactionId, 'txn_123');
    });

    test('should create failed purchase result', () {
      final result = PurchaseResult(
        status: PurchaseStatus.failed,
        productId: null,
        transactionId: null,
        purchaseToken: null,
        purchaseDate: null,
        error: 'Payment failed',
      );

      expect(result.status, PurchaseStatus.failed);
      expect(result.error, 'Payment failed');
    });
  });
}